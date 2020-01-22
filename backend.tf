# Add config to backend.cfg and run terraform init -backend-config backend.cfg
terraform {
  backend "s3" {}
}