data "digitalocean_ssh_key" "csgo" {
  name = var.ssh_key_name
}

resource "digitalocean_droplet" "csgo" {
  for_each   = var.config
  image      = "docker-18-04"
  name       = each.key
  region     = each.value.region
  size       = var.size
  ssh_keys   = [data.digitalocean_ssh_key.csgo.fingerprint]
  monitoring = true
}

resource "digitalocean_firewall" "csgo" {
  name        = "csgo.fw"
  droplet_ids = [for n, droplet in digitalocean_droplet.csgo : droplet.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = formatlist("%s/32", var.admin_ips)
  }
  inbound_rule {
    protocol         = "tcp"
    port_range       = "27015"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "27015"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "27005"
    source_addresses = ["0.0.0.0/0"]
  }
  inbound_rule {
    protocol         = "udp"
    port_range       = "27020"
    source_addresses = ["0.0.0.0/0"]
  }


  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0"]
  }
  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0"]
  }
}

resource "digitalocean_record" "csgo" {
  for_each = var.config
  domain   = each.value.domain
  type     = "A"
  name     = each.value.hostname
  value    = digitalocean_droplet.csgo[each.key].ipv4_address
  ttl      = 900
}
