module "consul_client_security_group" {
  source           = "git::https://github.com/timarenz/terraform-aws-security-group.git?ref=v0.1.0"
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-client-${random_string.random.result}"
  vpc_id           = module.aws.vpc_id
  ingress_rules = [{
    protocol         = "tcp"
    from_port        = "22"
    to_port          = "22"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "tcp"
    from_port        = "80"
    to_port          = "80"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    },{
    protocol         = "-1"
    from_port        = "0"
    to_port          = "0"
    cidr_blocks      = ["192.168.30.0/24"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "tcp"
    from_port        = "9002"
    to_port          = "9002"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "tcp"
    from_port        = "8443"
    to_port          = "8443"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
  }]
}

module "aws_consul_client_1" {
  source                 = "git::https://github.com/timarenz/terraform-aws-virtual-machine.git?ref=v0.1.0"
  environment_name       = local.environment_name
  owner_name             = local.owner_name
  name                   = "consul-client-1-${random_string.random.result}"
  subnet_id              = module.aws.public_subnet_ids[0]
  ssh_public_key         = local.ssh_public_key
  vpc_security_group_ids = [module.consul_client_security_group.id]
  iam_instance_profile   = module.iam_profile_consul_cloud_auto_join.instance_profile_name
}

module "aws_consul_client_2" {
  source                 = "git::https://github.com/timarenz/terraform-aws-virtual-machine.git?ref=v0.1.0"
  environment_name       = local.environment_name
  owner_name             = local.owner_name
  name                   = "consul-client-2-${random_string.random.result}"
  subnet_id              = module.aws.public_subnet_ids[0]
  ssh_public_key         = local.ssh_public_key
  vpc_security_group_ids = [module.consul_client_security_group.id]
  iam_instance_profile   = module.iam_profile_consul_cloud_auto_join.instance_profile_name
}

module "aws_consul_client_3" {
  source                 = "git::https://github.com/timarenz/terraform-aws-virtual-machine.git?ref=v0.1.0"
  environment_name       = local.environment_name
  owner_name             = local.owner_name
  name                   = "consul-client-3-${random_string.random.result}"
  subnet_id              = module.aws.public_subnet_ids[0]
  ssh_public_key         = local.ssh_public_key
  vpc_security_group_ids = [module.consul_client_security_group.id]
  iam_instance_profile   = module.iam_profile_consul_cloud_auto_join.instance_profile_name
}

module "aws_consul_client_1_config" {
  source                        = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                          = module.aws_consul_client_1.public_ip
  username                      = local.aws_username
  ssh_private_key               = local.ssh_private_key
  retry_join                    = ["provider=aws tag_key=${local.aws_discovery_tag} tag_value=${local.aws_discovery_value}"]
  connect                       = true
  grpc_port                     = 8502
  agent_type                    = "client"
  advertise_addr                = module.aws_consul_client_1.private_ip
  datacenter                    = local.aws_consul_dc_name
  primary_datacenter            = local.gcp_consul_dc_name
  consul_version                = local.consul_version
  enable_local_script_checks    = true
  enable_central_service_config = true
}

module "aws_consul_client_2_config" {
  source                        = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                          = module.aws_consul_client_2.public_ip
  username                      = local.aws_username
  ssh_private_key               = local.ssh_private_key
  retry_join                    = ["provider=aws tag_key=${local.aws_discovery_tag} tag_value=${local.aws_discovery_value}"]
  connect                       = true
  grpc_port                     = 8502
  agent_type                    = "client"
  advertise_addr                = module.aws_consul_client_2.private_ip
  datacenter                    = local.aws_consul_dc_name
  primary_datacenter            = local.gcp_consul_dc_name
  consul_version                = local.consul_version
  enable_local_script_checks    = true
  enable_central_service_config = true
}

module "aws_consul_client_3_config" {
  source                        = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                          = module.aws_consul_client_3.public_ip
  username                      = local.aws_username
  ssh_private_key               = local.ssh_private_key
  retry_join                    = ["provider=aws tag_key=${local.aws_discovery_tag} tag_value=${local.aws_discovery_value}"]
  connect                       = true
  grpc_port                     = 8502
  agent_type                    = "client"
  advertise_addr                = module.aws_consul_client_3.private_ip
  datacenter                    = local.aws_consul_dc_name
  primary_datacenter            = local.gcp_consul_dc_name
  consul_version                = local.consul_version
  enable_local_script_checks    = true
  enable_central_service_config = true
}

resource "null_resource" "aws_consul_client_1_meshify" {
  depends_on = [module.aws_consul_client_1_config]
  connection {
    host        = module.aws_consul_client_1.public_ip
    user        = local.aws_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-docker.sh",
      "${path.module}/scripts/mesh-connect-dashboard-service.sh",
      "${path.module}/scripts/mesh-web-admin.sh"
    ]
  }
}

resource "null_resource" "aws_consul_client_2_meshify" {
  depends_on = [module.aws_consul_client_2_config]
  connection {
    host        = module.aws_consul_client_2.public_ip
    user        = local.aws_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-docker.sh",
      "${path.module}/scripts/mesh-connect-counting-service.sh",
      "${path.module}/scripts/mesh-web-login.sh"
    ]
  }
}

resource "null_resource" "aws_consul_client_3_meshify" {
  depends_on = [module.aws_consul_client_3_config]
  connection {
    host        = module.aws_consul_client_3.public_ip
    user        = local.aws_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/install-docker.sh",
      "${path.module}/scripts/mesh-web-L7-routing.sh",
      "${path.module}/scripts/mesh-web.sh",
      "${path.module}/scripts/mesh-web-ingress-haproxy.sh"
    ]
  }

  provisioner "remote-exec" {
    inline = [<<EOF
sudo docker run -d --network host --name gateway-aws timarenz/envoy-consul:v1.11.1_1.6.1 -mesh-gateway -register \
  -service "gateway-aws" \
  -bind-address bind=${module.aws_consul_client_3.private_ip}:8443 \
  -address ${module.aws_consul_client_3.private_ip}:8443 \
  -wan-address ${module.aws_consul_client_3.public_ip}:8443 \
  -admin-bind localhost:19003 \
  -- -l debug
EOF
    ]
  }
}
