terraform {
  required_providers {
    hcloud = {
      source  = "opentofu/hcloud"
      version = "1.49.1"
    }
    github = {
      source  = "hashicorp/github"
      version = "6.5.0"
    }
  }
}

provider "hcloud" {
  token = var.hcloud_token
}

provider "github" {}