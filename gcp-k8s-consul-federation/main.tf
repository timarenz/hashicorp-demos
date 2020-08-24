provider "google" {
  project     = var.gcp_project
  credentials = file(var.gcp_credentials_file)
  region      = var.gcp_region
}

data "google_client_config" "client" {}

resource "random_id" "uid" {
  byte_length = 3
  prefix      = "${var.owner_name}-"
}

locals {
  prefix = "${random_id.uid.hex}-${var.environment_name}"
}

resource "random_id" "consul_gossip_encryption_key" {
  byte_length = 32
}

module "gcp" {
  source           = "git::https://github.com/timarenz/terraform-google-environment.git?ref=v0.2.4"
  region           = var.gcp_region
  project          = var.gcp_project
  environment_name = var.environment_name
}
