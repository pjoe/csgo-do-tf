variable "size" {
  default = "s-1vcpu-2gb"
}

variable "admin_ips" {
  default = []
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_key_name" {
  default = "id_rsa"
}

variable "config" {
  type = map(object({
    region          = string
    gslt_token      = string
    server_name     = string
    server_password = string
    rcon_password   = string
    domain          = string
    hostname        = string
    options         = map(any)
  }))
}
