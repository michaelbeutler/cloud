# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 3.0.0"
    }
  }
}

provider "openstack" {
  auth_url                      = var.openstack_auth_url
  user_name                     = var.openstack_user_name
  application_credential_name   = var.openstack_application_credential_name
  application_credential_secret = var.openstack_application_credential_secret
  region                        = var.openstack_region
}

resource "openstack_networking_secgroup_v2" "proxmox" {
  name        = "proxmox"
  description = "a security group for proxmox servers"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.proxmox.id
}

resource "openstack_networking_secgroup_rule_v2" "web-ui" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 8006
  port_range_max    = 8006
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.proxmox.id
}

resource "openstack_networking_network_v2" "iaas" {
  name           = "iaas"
  admin_state_up = "true"
}

resource "openstack_networking_router_v2" "iaas" {
  name                = "iaas"
  admin_state_up      = true
  external_network_id = "3cc83f7d-9119-475b-ba17-f3510c7902e8"
}

resource "openstack_networking_subnet_v2" "management" {
  name       = "management"
  network_id = openstack_networking_network_v2.iaas.id
  cidr       = "10.0.10.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "management" {
  router_id = openstack_networking_router_v2.iaas.id
  subnet_id = openstack_networking_subnet_v2.management.id
}

resource "openstack_networking_port_v2" "node" {
  for_each = toset(["node01", "node02", "node03"])
  name     = each.key
  # network_id         = "c34c17a4-341e-463e-ab52-eed4817387ad"
  network_id         = openstack_networking_network_v2.iaas.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.proxmox.id, "e0fe42d3-b1a6-4958-bab9-2e176415e2b1"]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.management.id
  }
}

resource "openstack_networking_floatingip_v2" "node" {
  for_each = toset(["node01", "node02", "node03"])
  pool     = "public"
}

resource "openstack_networking_floatingip_associate_v2" "node" {
  for_each    = toset(["node01", "node02", "node03"])
  floating_ip = openstack_networking_floatingip_v2.node[each.key].address
  port_id     = openstack_networking_port_v2.node[each.key].id
  depends_on  = [openstack_networking_floatingip_v2.node]
}

# Spawn 3 instances called node01, node02, node03
resource "openstack_compute_instance_v2" "node" {
  for_each  = toset(["node01", "node02", "node03"])
  name      = each.key
  image_id  = "654bf798-579b-47aa-a7f7-8a8798c9779d"
  flavor_id = "592bcbc2-456b-484b-bdd0-12bcb85c1dae"
  user_data = file("${path.module}/cloud-init.yml")

  network {
    port = openstack_networking_port_v2.node[each.key].id
  }
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      proxmox_hosts = [
        { ip = openstack_networking_floatingip_v2.node["node01"].address, hostname = "node01", local_ip = openstack_compute_instance_v2.node["node01"].access_ip_v4 },
        { ip = openstack_networking_floatingip_v2.node["node02"].address, hostname = "node02", local_ip = openstack_compute_instance_v2.node["node02"].access_ip_v4 },
        { ip = openstack_networking_floatingip_v2.node["node03"].address, hostname = "node03", local_ip = openstack_compute_instance_v2.node["node03"].access_ip_v4 }
      ]
    }
  )
  filename   = "./ansible/inventory/hosts.cfg"
  depends_on = [openstack_networking_floatingip_v2.node]
}