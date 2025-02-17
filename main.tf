# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "openstack" {
  user_name                     = ""
  tenant_name                   = "sysad_hs23_1lbb1_08"
  application_credential_name   = "terraform"
  application_credential_secret = "my secret"
  auth_url                      = "https://keystone.cloud.switch.ch:5000/v3"
  region                        = "ZH"
}

# Configure the GitHub Provider
provider "github" {}