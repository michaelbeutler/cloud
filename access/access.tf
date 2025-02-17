resource "openstack_compute_keypair_v2" "cloud_key_keypair" {
  name       = "cloud_key"
  public_key = file("${path.module}/id_ed25519.pub")
}

data "github_user" "current" {
  username = ""
}

resource "openstack_compute_keypair_v2" "github_key_keypair" {
  for_each   = data.github_user.current.ssh_keys
  name       = "github${each.key}_key_keypair"
  public_key = each.value
}
