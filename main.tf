
module "csgo-eu" {
  source          = "./modules/csgo"
  config = var.config
  admin_ips = var.admin_ips
}

output "ips" {
  value = module.csgo-eu.ips
}
