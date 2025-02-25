variable "connection" {
  description = "Connection block for the provisioner"
  type = object({
    type        = string
    user        = string
    private_key = string
    host        = string
  })
  validation {
    condition     = !can(values(var.connection)) || !contains([for v in var.agents : can(tomap(v.connection))], false)
    error_message = "connection must be a valid terraform connection"
  }
}

variable "k3s_url" {
  description = "Setting the K3S_URL parameter causes the installer to configure K3s as an agent, instead of a server. The K3s agent will register with the K3s server listening at the supplied URL. The value to use for K3S_TOKEN is stored at /var/lib/rancher/k3s/server/node-token on your server node."
  nullable = true
  default = null
  validation {
    condition = can(regex("^https://.*", var.k3s_url))
    error_message = "k3s_url must be a valid URL"
  }
}

variable "k3s_token" {
  description = "The value to use for K3S_TOKEN is stored at /var/lib/rancher/k3s/server/node-token on your server node."
  nullable = true
  default = null
  validation {
    condition = can(regex("^[a-zA-Z0-9]{64}$", var.k3s_token))
    error_message = "k3s_token must be a 64 character alphanumeric string"
  }
}

variable "install_k3s_skip_download" {
  description = "If set to true will not download K3s hash or binary."
  default = false
  validation {
    condition = can(regex("true|false", var.install_k3s_skip_download))
    error_message = "install_k3s_skip_download must be a boolean"
  }
}

variable "install_k3s_symlink" {
  description = "By default will create symlinks for the kubectl, crictl, and ctr binaries if the commands do not already exist in path. If set to 'skip' will not create symlinks and 'force' will overwrite."
  nullable = true
  validation {
    condition = can(regex("default|skip|force", var.install_k3s_symlink))
    error_message = "install_k3s_symlink must be 'default', 'skip', or 'force'"
  } 
}

variable "install_k3s_skip_enable" {
  description = "If set to true will not enable or start K3s service."
  default = false
  validation {
    condition = can(regex("true|false", var.install_k3s_skip_enable))
    error_message = "install_k3s_skip_enable must be a boolean"
  }
}

variable "install_k3s_skip_start" {
  description = "If set to true will not start K3s service."
  default = false
  validation {
    condition = can(regex("true|false", var.install_k3s_skip_start))
    error_message = "install_k3s_skip_start must be a boolean"
  }
}

variable "install_k3s_version" {
  description = "Version of K3s to download from Github. Will attempt to download from the stable channel if not specified."
  default = "v1.31.5+k3s1"
  validation {
    condition = can(regex("^v[0-9]\\.[0-9]+\\.[0-9]\\+k3s[0-9]$", var.install_k3s_version))
    error_message = "install_k3s_version must be a valid version number"
  }
}

variable "install_k3s_bin_dir" {
  description = "Directory to install K3s binary, links, and uninstall script to, or use /usr/local/bin as the default."
  default = "/usr/local/bin"
  validation {
    condition = can(regex("^/.*", var.install_k3s_bin_dir))
    error_message = "install_k3s_bin_dir must be an absolute path"
  }
}

variable "install_k3s_bin_dir_read_only" {
  description = "If set to true will not write files to INSTALL_K3S_BIN_DIR, forces setting INSTALL_K3S_SKIP_DOWNLOAD=true."
  default = false
  validation {
    condition = can(regex("true|false", var.install_k3s_bin_dir_read_only))
    error_message = "install_k3s_bin_dir_read_only must be a boolean"
  }
}

variable "install_k3s_systemd_dir" {
  description = "Directory to install systemd service and environment files to, or use /etc/systemd/system as the default."
  default = "/etc/systemd/system"
  validation {
    condition = can(regex("^/.*", var.install_k3s_systemd_dir))
    error_message = "install_k3s_systemd_dir must be an absolute path"
  }
}

variable "install_k3s_exec" {
  description = "Command with flags to use for launching K3s in the service. If the command is not specified, and the K3S_URL is set, it will default to 'agent.' If K3S_URL not set, it will default to 'server.' For help, refer to this example."
  nullable = true
}

variable "install_k3s_name" {
  description = "Name of systemd service to create, will default to 'k3s' if running k3s as a server and 'k3s-agent' if running k3s as an agent. If specified the name will be prefixed with 'k3s-'."
  default = "k3s"
}

variable "install_k3s_type" {
  description = "Type of systemd service to create, will default from the K3s exec command if not specified."
  nullable = true
}

variable "install_k3s_selinux_warn" {
  description = "If set to true will continue if k3s-selinux policy is not found."
  default = false
  validation {
    condition = can(regex("true|false", var.install_k3s_selinux_warn))
    error_message = "install_k3s_selinux_warn must be a boolean"
  }
}

variable "install_k3s_skip_selinux_rpm" {
  description = "If set to true will skip automatic installation of the k3s RPM."
  default = false
  validation {
    condition = can(regex("true|false", var.install_k3s_skip_selinux_rpm))
    error_message = "install_k3s_skip_selinux_rpm must be a boolean"
  }
}

variable "install_k3s_channel_url" {
  description = "Channel URL for fetching K3s download URL. Defaults to https://update.k3s.io/v1-release/channels."
  default = "https://update.k3s.io/v1-release/channels"
  validation {
    condition = can(regex("^https://.*", var.install_k3s_channel_url))
    error_message = "install_k3s_channel_url must be a valid URL"
  }
}

variable "install_k3s_channel" {
  description = "Channel to use for fetching K3s download URL. Defaults to 'stable'. Options include: stable, latest, testing."
  default = "stable"
  validation {
    condition = can(regex("stable|latest|testing", var.install_k3s_channel))
    error_message = "install_k3s_channel must be 'stable', 'latest', or 'testing'"
  }
} 