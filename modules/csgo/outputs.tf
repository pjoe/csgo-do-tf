output "ips" {
  value = {
    for name, droplet in digitalocean_droplet.csgo :
    name => droplet.ipv4_address
  }

}

output "fqdns" {
  value = {
    for name, record in digitalocean_record.csgo :
    name => record.fqdn
  }
}
