
module "csgo-eu" {
  source          = "./modules/csgo"
  config = var.config
  admin_ips = var.admin_ips
  steam_authkey = var.steam_authkey
}

output "ips" {
  value = module.csgo-eu.ips
}
