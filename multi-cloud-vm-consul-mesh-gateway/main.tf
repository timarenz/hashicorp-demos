provider "google" {}

provider "aws" {}

locals {
  gcp_project         = var.gcp_project
  environment_name    = var.environment_name
  owner_name          = var.owner_name
  aws_username        = "ubuntu"
  gcp_username        = "ubuntu"
  ssh_public_key      = file(var.ssh_public_key_file)
  ssh_private_key     = file(var.ssh_private_key_file)
  consul_version      = "1.6.1"
  aws_consul_dc_name  = "dc-aws"
  gcp_consul_dc_name  = "dc-gcp"
  aws_discovery_tag   = "consul"
  aws_discovery_value = "server"
  gcp_discovery_tag   = "consul-server"
}

module "gcp" {
  source           = "git::https://github.com/timarenz/terraform-google-environment.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
}

module "aws" {
  source           = "git::https://github.com/timarenz/terraform-aws-environment.git?ref=v0.1.0"
  environment_name = local.environment_name
  owner_name       = local.owner_name
  nat_gateway      = false
}

resource "random_string" "random" {
  length  = 4
  special = false
  upper   = false
}
