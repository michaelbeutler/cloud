variable "openstack_user_name" {
  sensitive = true
}

# variable "openstack_tenant_name" {
#   sensitive = false
# }

variable "openstack_application_credential_name" {
  sensitive = true
}

variable "openstack_application_credential_secret" {
  sensitive = true
}

variable "openstack_auth_url" {
  default = "https://keystone.cloud.switch.ch:5000/v3"
  validation {
    condition     = can(regex("https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?", var.openstack_auth_url))
    error_message = "The auth_url must be a valid URL"
  }
}

variable "openstack_region" {
  default = "ZH"
  validation {
    condition     = can(regex("[a-zA-Z0-9]+", var.openstack_region))
    error_message = "The region must be a valid string"
  }
}

variable "ssh_private_key" {
  sensitive = true
}