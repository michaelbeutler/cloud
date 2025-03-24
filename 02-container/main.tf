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

resource "openstack_networking_secgroup_v2" "container" {
  name        = "02-container"
  description = "Allow traffic to Portainer UI on port 9443 and SSH from anywhere."
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.container.id
}

resource "openstack_networking_secgroup_rule_v2" "portainer-ui" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 9443
  port_range_max    = 9443
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.container.id
}

resource "openstack_networking_network_v2" "container" {
  name           = "02-container"
  admin_state_up = "true"
}

resource "openstack_networking_router_v2" "container" {
  name                = "02-container"
  admin_state_up      = true
  external_network_id = "3cc83f7d-9119-475b-ba17-f3510c7902e8"
}

resource "openstack_networking_subnet_v2" "container" {
  name       = "02-container"
  network_id = openstack_networking_network_v2.container.id
  cidr       = "10.0.10.0/24"
  ip_version = 4
}

resource "openstack_networking_router_interface_v2" "container" {
  router_id = openstack_networking_router_v2.container.id
  subnet_id = openstack_networking_subnet_v2.container.id
}

resource "openstack_networking_port_v2" "container-host" {
  name               = "container-host"
  network_id         = openstack_networking_network_v2.container.id
  admin_state_up     = "true"
  security_group_ids = [openstack_networking_secgroup_v2.container.id, "e0fe42d3-b1a6-4958-bab9-2e176415e2b1"]
  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.container.id
  }
}

resource "openstack_networking_floatingip_v2" "container-host" {
  pool = "public"
}

resource "openstack_networking_floatingip_associate_v2" "container-host" {
  floating_ip = openstack_networking_floatingip_v2.container-host.address
  port_id     = openstack_networking_port_v2.container-host.id
  depends_on  = [openstack_networking_floatingip_v2.container-host]
}

# Spawn 3 instances called node01, node02, node03
resource "openstack_compute_instance_v2" "container-host" {
  name      = "container-host"
  image_id  = "654bf798-579b-47aa-a7f7-8a8798c9779d"
  flavor_id = "592bcbc2-456b-484b-bdd0-12bcb85c1dae"
  user_data = file("${path.module}/cloud-init.yml")

  network {
    port = openstack_networking_port_v2.container-host.id
  }

  # Copies the file as the root user using SSH
  provisioner "file" {
    source      = "${path.module}/monitoringstack-main"
    destination = "/home/michaelbeutler/monitoringstack-main"

    connection {
      type        = "ssh"
      user        = "michaelbeutler"
      private_key = file("${path.module}/id_rsa")
      host        = openstack_networking_floatingip_v2.container-host.address
    }
  }
}