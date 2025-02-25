
resource "openstack_compute_secgroup_v2" "secgroup_http" {
  name        = "HTTP"
  description = "Allow ingress http/https traffic."

  rule {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }

  rule {
    from_port   = 443
    to_port     = 443
    ip_protocol = "tcp"
    cidr        = "0.0.0.0/0"
  }
}

resource "openstack_networking_floatingip_v2" "cloud_01_iaas" {
  pool        = "public"
  description = "Public floating ip for cloud project."
}

resource "openstack_compute_instance_v2" "cloud_01_iaas" {
  name      = "cloud-01-iaas"
  image_id  = "54ee4d6e-9155-4698-ab2b-45d9067e8e8e"
  flavor_id = "11d87870-2b1f-47ca-a400-0fcaaa1272ac"
  key_pair = [
    "cloud_key"
  ]
  security_groups   = ["default", "SSH", "HTTP"]
  availability_zone = "nova"

  network {
    name = "private"
  }
}

resource "openstack_compute_floatingip_associate_v2" "cloud_01_iaas" {
  floating_ip = openstack_networking_floatingip_v2.cloud_01_iaas.address
  instance_id = openstack_compute_instance_v2.cloud_01_iaas.id
}