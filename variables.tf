variable "admin_ips" {
  default = []
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
