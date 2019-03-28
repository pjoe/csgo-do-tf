# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

variable "gslt_token" {}

variable "admin_ips" {
  default = []
}

variable "server_name" {
  default = "CS:GO Server on DigitalOcean"
}

variable "server_password" {
  default = ""
}

variable "rcon_password" {
  default = ""
}

variable "mysql_password" {}

variable "domain" {}
variable "hostname" {}

variable "ssh_key_public" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_key" {
  default = "~/.ssh/id_rsa"
}

variable "ssh_key_name" {
  default = "id_rsa"
}

variable "region" {
  default = "nyc1"
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = "${var.do_token}"
}

# resource "digitalocean_ssh_key" "csgo" {
#   name       = "Terraform CS:GO"
#   public_key = "${file(var.ssh_key_public)}"
# }

data "digitalocean_ssh_key" "csgo" {
  name = "${var.ssh_key_name}"
}

resource "digitalocean_droplet" "csgo" {
  image      = "docker-18-04"
  name       = "csgo.${var.region}"
  region     = "${var.region}"
  size       = "s-1vcpu-2gb"
  ssh_keys   = ["${data.digitalocean_ssh_key.csgo.fingerprint}"]
  monitoring = true
}

resource "digitalocean_firewall" "csgo" {
  name        = "csgo"
  droplet_ids = ["${digitalocean_droplet.csgo.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "22"
      source_addresses = "${formatlist("%s/32", var.admin_ips)}"
    },
    {
      protocol         = "tcp"
      port_range       = "27015"
      source_addresses = ["0.0.0.0/0"]
    },
    {
      protocol         = "udp"
      port_range       = "27015"
      source_addresses = ["0.0.0.0/0"]
    },
    {
      protocol         = "udp"
      port_range       = "27005"
      source_addresses = ["0.0.0.0/0"]
    },
    {
      protocol         = "udp"
      port_range       = "27020"
      source_addresses = ["0.0.0.0/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0"]
    },
    {
      protocol              = "udp"
      port_range            = "1-65535"
      destination_addresses = ["0.0.0.0/0"]
    },
    {
      protocol              = "icmp"
      destination_addresses = ["0.0.0.0/0"]
    },
  ]
}

resource "digitalocean_domain" "csgo" {
  name = "${var.domain}"
}

resource "digitalocean_record" "csgo" {
  domain = "${digitalocean_domain.csgo.name}"
  type   = "A"
  name   = "${var.hostname}"
  value  = "${digitalocean_droplet.csgo.ipv4_address}"
  ttl    = 900
}

output "csgo ip" {
  value = "${digitalocean_droplet.csgo.ipv4_address}"
}

output "csgo fqdn" {
  value = "${digitalocean_record.csgo.fqdn}"
}
