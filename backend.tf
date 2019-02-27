terraform {
  backend "local" {
    path = "local-state/terraform.tfstate"
  }
}