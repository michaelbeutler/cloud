# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
  description = "The Hetzner Cloud API token"
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{64}$", var.hcloud_token))
    error_message = "hcloud_token must be a 64 character alphanumeric string"
  }
}

variable "controlplane_count" {
  description = "The number of control plane nodes"
  default     = 3
  validation {
    condition     = var.controlplane_count > 0
    error_message = "controlplane_count must be greater than 0"
  }
  validation {
    condition     = var.controlplane_count % 2 == 1
    error_message = "controlplane_count must odd number"
  }
}

variable "worker_count" {
  description = "The number of worker nodes"
  default     = 1
  validation {
    condition     = var.worker_count > 0
    error_message = "worker_count must be greater than 0"
  }

}