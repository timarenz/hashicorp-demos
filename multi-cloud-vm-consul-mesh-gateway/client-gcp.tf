module "consul_client_firewall" {
  source           = "git::https://github.com/timarenz/terraform-google-firewall.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  name             = "consul-client-${random_string.random.result}"
  network          = module.gcp.network
  allow_rules = [{
    protocol = "tcp"
    ports    = ["9002", "8443"]
  }]
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["consul-client"]
}

module "gcp_consul_client_1" {
  source           = "git::https://github.com/timarenz/terraform-google-virtual-machine.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-client-1-${random_string.random.result}"
  subnet           = module.gcp.subnets[0]
  username         = local.gcp_username
  ssh_public_key   = local.ssh_public_key
  network_tags     = ["consul-client"]
  access_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/compute.readonly"
  ]
}

module "gcp_consul_client_2" {
  source           = "git::https://github.com/timarenz/terraform-google-virtual-machine.git?ref=v0.1.0"
  project          = local.gcp_project
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-client-2-${random_string.random.result}"
  subnet           = module.gcp.subnets[0]
  username         = local.gcp_username
  ssh_public_key   = local.ssh_public_key
  network_tags     = ["consul-client"]
  access_scopes = [
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/compute.readonly"
  ]
}

module "gcp_consul_client_1_config" {
  source                        = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                          = module.gcp_consul_client_1.public_ip
  username                      = local.gcp_username
  ssh_private_key               = local.ssh_private_key
  retry_join                    = ["provider=gce project_name=${local.gcp_project} tag_value=${local.gcp_discovery_tag}"]
  connect                       = true
  grpc_port                     = 8502
  agent_type                    = "client"
  advertise_addr                = module.gcp_consul_client_1.private_ip
  datacenter                    = local.gcp_consul_dc_name
  primary_datacenter            = local.gcp_consul_dc_name
  consul_version                = local.consul_version
  enable_local_script_checks    = true
  enable_central_service_config = true
}

module "gcp_consul_client_2_config" {
  source                        = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                          = module.gcp_consul_client_2.public_ip
  username                      = local.gcp_username
  ssh_private_key               = local.ssh_private_key
  retry_join                    = ["provider=gce project_name=${local.gcp_project} tag_value=${local.gcp_discovery_tag}"]
  connect                       = true
  grpc_port                     = 8502
  agent_type                    = "client"
  advertise_addr                = module.gcp_consul_client_2.private_ip
  datacenter                    = local.gcp_consul_dc_name
  primary_datacenter            = local.gcp_consul_dc_name
  consul_version                = local.consul_version
  enable_local_script_checks    = true
  enable_central_service_config = true
}

resource "null_resource" "gcp_consul_client_1_meshify" {
  depends_on = [module.gcp_consul_client_1_config]
  connection {
    host        = module.gcp_consul_client_1.public_ip
    user        = local.gcp_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-docker.sh",
      "${path.module}/scripts/mesh-connect-dashboard-service.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [<<EOF
sudo docker run -d --network host --name gateway-gcp timarenz/consul-envoy:1.6.0-beta3_1.10.0 -mesh-gateway -register \
  -service "gateway-gcp" \
  -bind-address bind=${module.gcp_consul_client_1.private_ip}:8443 \
  -address ${module.gcp_consul_client_1.private_ip}:8443 \
  -wan-address ${module.gcp_consul_client_1.public_ip}:8443 \
  -admin-bind localhost:19001 \
  -- -l debug
EOF
    ]
  }
}

resource "null_resource" "gcp_consul_client_2_meshify" {
  depends_on = [module.gcp_consul_client_2_config]
  connection {
    host        = module.gcp_consul_client_2.public_ip
    user        = local.gcp_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-docker.sh",
      "${path.module}/scripts/mesh-connect-counting-service.sh"
    ]
  }
}
