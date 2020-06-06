
module "csgo-eu" {
  source          = "./modules/csgo"
  config = var.config
  admin_ips = var.admin_ips
  steam_user = var.steam_user
  steam_pass = var.steam_pass
}

output "ips" {
  value = module.csgo-eu.ips
}
