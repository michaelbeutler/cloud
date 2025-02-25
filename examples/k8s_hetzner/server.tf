resource "hcloud_server" "server" {
  count       = var.controlplane_count
  name        = "k8s-control-plane-${count.index + 1}"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  labels = {
    "k8s" = "control-plane"
  }
  ssh_keys = [hcloud_ssh_key.default.id]

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.${count.index + 20}"
  }

  depends_on = [
    hcloud_network_subnet.k8s-subnet
  ]
}

resource "hcloud_load_balancer_target" "k8s-control-planes" {
  count            = var.controlplane_count
  type             = "server"
  load_balancer_id = hcloud_load_balancer.k8s-control-planes.id
  server_id        = hcloud_server.server.*.id[count.index]
}

resource "hcloud_server" "worker" {
  count       = var.worker_count
  name        = "k8s-worker-${count.index + 1}"
  server_type = "cx22"
  image       = "ubuntu-24.04"
  location    = "nbg1"
  labels = {
    "k8s" = "worker"
  }
  ssh_keys = [hcloud_ssh_key.default.id]

  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }

  network {
    network_id = hcloud_network.network.id
    ip         = "10.0.1.${count.index + 30}"
  }

  depends_on = [
    hcloud_network_subnet.k8s-subnet
  ]
}

resource "hcloud_load_balancer_target" "k8s-workers" {
  count            = var.worker_count
  type             = "server"
  load_balancer_id = hcloud_load_balancer.k8s-workers.id
  server_id        = hcloud_server.worker.*.id[count.index]
}