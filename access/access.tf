resource "openstack_compute_keypair_v2" "cloud_key_keypair" {
  name       = "cloud_key"
  public_key = file("${path.module}/id_ed25519.pub")
}
