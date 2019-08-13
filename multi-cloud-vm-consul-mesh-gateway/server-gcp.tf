module "consul_server_firewall" {
  source           = "git::https://github.com/timarenz/terraform-google-firewall.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  name             = "consul-server-${random_string.random.result}"
  network          = module.gcp.network
  allow_rules = [{
    protocol = "tcp"
    ports    = ["8500", "8302", "8300"]
    }, {
    protocol = "udp"
    ports    = ["8302"]
  }]
  target_tags = [local.gcp_discovery_tag]
}

module "gcp_consul_server_1" {
  source           = "git::https://github.com/timarenz/terraform-google-virtual-machine.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-server-1-${random_string.random.result}"
  subnet           = module.gcp.subnets[0]
  username         = local.gcp_username
  ssh_public_key   = local.ssh_public_key
  network_tags     = [local.gcp_discovery_tag]
  access_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/compute.readonly"
  ]
}

module "gcp_consul_server_2" {
  source           = "git::https://github.com/timarenz/terraform-google-virtual-machine.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-server-2-${random_string.random.result}"
  subnet           = module.gcp.subnets[0]
  username         = local.gcp_username
  ssh_public_key   = local.ssh_public_key
  network_tags     = [local.gcp_discovery_tag]
  access_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/compute.readonly"
  ]
}

module "gcp_consul_server_3" {
  source           = "git::https://github.com/timarenz/terraform-google-virtual-machine.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-server-3-${random_string.random.result}"
  subnet           = module.gcp.subnets[0]
  username         = local.gcp_username
  ssh_public_key   = local.ssh_public_key
  network_tags     = [local.gcp_discovery_tag]
  access_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/compute.readonly"
  ]
}

module "gcp_consul_server_1_config" {
  source              = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                = module.gcp_consul_server_1.public_ip
  username            = local.gcp_username
  ssh_private_key     = local.ssh_private_key
  retry_join          = ["provider=gce project_name=${local.gcp_project} tag_value=${local.gcp_discovery_tag}"]
  retry_join_wan      = [module.aws_consul_server_1.public_ip, module.aws_consul_server_2.public_ip, module.aws_consul_server_3.public_ip]
  connect             = true
  advertise_addr      = module.gcp_consul_server_1.private_ip
  advertise_addr_wan  = module.gcp_consul_server_1.public_ip
  translate_wan_addrs = true
  datacenter          = local.gcp_consul_dc_name
  primary_datacenter  = local.gcp_consul_dc_name
  bootstrap_expect    = 3
  consul_version      = local.consul_version
}

module "gcp_consul_server_2_config" {
  source              = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                = module.gcp_consul_server_2.public_ip
  username            = local.gcp_username
  ssh_private_key     = local.ssh_private_key
  retry_join          = ["provider=gce project_name=${local.gcp_project} tag_value=${local.gcp_discovery_tag}"]
  retry_join_wan      = [module.aws_consul_server_1.public_ip, module.aws_consul_server_2.public_ip, module.aws_consul_server_3.public_ip]
  connect             = true
  advertise_addr      = module.gcp_consul_server_2.private_ip
  advertise_addr_wan  = module.gcp_consul_server_2.public_ip
  translate_wan_addrs = true
  datacenter          = local.gcp_consul_dc_name
  primary_datacenter  = local.gcp_consul_dc_name
  bootstrap_expect    = 3
  consul_version      = local.consul_version
}

module "gcp_consul_server_3_config" {
  source              = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                = module.gcp_consul_server_3.public_ip
  username            = local.gcp_username
  ssh_private_key     = local.ssh_private_key
  retry_join          = ["provider=gce project_name=${local.gcp_project} tag_value=${local.gcp_discovery_tag}"]
  retry_join_wan      = [module.aws_consul_server_1.public_ip, module.aws_consul_server_2.public_ip, module.aws_consul_server_3.public_ip]
  connect             = true
  advertise_addr      = module.gcp_consul_server_3.private_ip
  advertise_addr_wan  = module.gcp_consul_server_3.public_ip
  translate_wan_addrs = true
  datacenter          = local.gcp_consul_dc_name
  primary_datacenter  = local.gcp_consul_dc_name
  bootstrap_expect    = 3
  consul_version      = local.consul_version
}

resource "null_resource" "gcp_consul_server_1_meshify" {
  depends_on = [module.gcp_consul_server_1_config, module.gcp_consul_server_2_config, module.gcp_consul_server_3_config]
  connection {
    host        = module.gcp_consul_server_1.public_ip
    user        = local.gcp_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/mesh-central-config.sh"
    ]
  }
}
