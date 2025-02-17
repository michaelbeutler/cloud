variable "private_key_path" {
  description = "Path to the private key"
  default     = "~/.ssh/id_rsa"
}

variable "k3snode_count" {
  description = "Number of K3s nodes to create"
  default     = 2
  validation {
    condition     = var.k3snode_count > 0 && var.k3snode_count < 10
    error_message = "The number of K3s nodes must be greater than 0 and less than 10"
  }
}

variable "k3snode_image" {
  description = "Image ID for K3s nodes"
  default     = "54ee4d6e-9155-4698-ab2b-45d9067e8e8e"
}

resource "openstack_networking_floatingip_v2" "k3snode_floating_ip" {
  pool        = "public"
  for_each    = toset([for i in range(var.k3snode_count) : i])
  description = "Public floating ip for k3s node."
}

resource "openstack_compute_instance_v2" "k3snode" {
  for_each        = toset([for i in range(var.k3snode_count) : i])
  name            = "k3snode0${each.value}"
  image_id        = var.k3snode_image
  security_groups = ["default"]

  connection {
    user        = "root"
    host        = openstack_networking_floatingip_v2.k3snode_floating_ip[each.key].fixed_ip_v4
    private_key = var.private_key_path
  }

  provisioner "file" {
    source      = "${path.module}/scripts/prepare.sh"
    destination = "/tmp/prepare.sh"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_k3s.sh"
    destination = "/tmp/install_k3s.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/prepare.sh",
      "chmod +x /tmp/install_k3s.sh",
      "/tmp/prepare.sh",
      "/tmp/install_k3s.sh"
    ]
  }
}