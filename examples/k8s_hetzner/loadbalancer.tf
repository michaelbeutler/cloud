resource "hcloud_load_balancer" "k8s-workers" {
  name               = "k8s-workers"
  load_balancer_type = "lb11"
  location           = "nbg1"
}

resource "hcloud_load_balancer" "k8s-control-planes" {
  name               = "k8s-control-planes"
  load_balancer_type = "lb11"
  location           = "nbg1"
}

resource "hcloud_load_balancer_service" "k8s-api" {
  load_balancer_id = hcloud_load_balancer.k8s-control-planes.id
  protocol         = "tcp"
  listen_port      = 6443
  destination_port = 6443

  health_check {
    protocol = "tcp"
    port     = 6443
    interval = 5
    timeout  = 5
  }
}

resource "hcloud_load_balancer_service" "http" {
  load_balancer_id = hcloud_load_balancer.k8s-workers.id
  protocol         = "http"

  health_check {
    protocol = "http"
    port     = 80
    interval = 5
    timeout  = 5

    http {
      path         = "/healthz"
      response     = "OK"
      tls          = false
      status_codes = ["200"]
    }
  }
}

resource "hcloud_load_balancer_service" "https" {
  load_balancer_id = hcloud_load_balancer.k8s-workers.id
  protocol         = "tcp"

  health_check {
    protocol = "tcp"
    port     = 443
    interval = 5
    timeout  = 5
  }
}

resource "hcloud_load_balancer_network" "load-balancer-network-workers" {
  load_balancer_id = hcloud_load_balancer.k8s-workers.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.1.11"

  depends_on = [
    hcloud_network_subnet.k8s-subnet
  ]
}

resource "hcloud_load_balancer_network" "load-balancer-network-control-planes" {
  load_balancer_id = hcloud_load_balancer.k8s-control-planes.id
  network_id       = hcloud_network.network.id
  ip               = "10.0.1.10"

  depends_on = [
    hcloud_network_subnet.k8s-subnet
  ]
}