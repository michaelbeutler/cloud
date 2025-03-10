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

resource "openstack_networking_port_v2" "node" {
  for_each           = toset(["node01", "node02", "node03"])
  name               = each.key
  network_id         = "c34c17a4-341e-463e-ab52-eed4817387ad"
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.proxmox.id]
}

resource "openstack_networking_floatingip_v2" "node" {
  for_each    = toset(["node01", "node02", "node03"])
  pool = "public"
}

resource "openstack_networking_floatingip_associate_v2" "node" {
  for_each    = toset(["node01", "node02", "node03"])
  floating_ip = openstack_networking_floatingip_v2.node[each.key].address
  port_id     = openstack_networking_port_v2.node[each.key].id
  depends_on = [ openstack_networking_floatingip_v2.node ]
}

# Spawn 3 instances called node01, node02, node03
resource "openstack_compute_instance_v2" "node" {
  for_each  = toset(["node01", "node02", "node03"])
  name      = each.key
  image_id  = "54ee4d6e-9155-4698-ab2b-45d9067e8e8e"
  flavor_id = "a421ad62-9aa6-4154-b9ae-9e8af4b64af9"
  user_data = file("${path.module}/cloud-init.yml")

  network {
    port = openstack_networking_port_v2.node[each.key].id
  }
}
