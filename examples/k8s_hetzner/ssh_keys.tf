data "github_user" "current" {
  username = ""
}

resource "hcloud_ssh_key" "default" {
  public_key = data.github_user.current.ssh_keys[0]
  name       = "github-${data.github_user.current.login}"
}
