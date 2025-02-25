resource "hcloud_network" "network" {
  name     = "network"
  ip_range = "10.0.0.0/8"
}

resource "hcloud_network_subnet" "k8s-subnet" {
  type         = "cloud"
  network_id   = hcloud_network.network.id
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}