# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.53.0"
    }
    github = {
      source  = "hashicorp/github"
      version = "6.5.0"
    }
  }
}

provider "openstack" {
  user_name                     = var.openstack_user_name
  tenant_name                   = var.openstack_tenant_name
  application_credential_name   = var.openstack_application_credential_name
  application_credential_secret = var.openstack_application_credential_secret
  auth_url                      = var.openstack_auth_url
  region                        = var.openstack_region
}

provider "github" {}

module "access" {
  source = "./access"
}