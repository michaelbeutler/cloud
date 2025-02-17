resource "openstack_compute_keypair_v2" "cloud_key_keypair" {
  name       = "cloud-key"
  public_key = file("id_ed25519.pub")
}
