
module "iam_profile_consul_cloud_auto_join" {
  source           = "git::https://github.com/timarenz/terraform-aws-iam-instance-profile.git?ref=v0.1.0"
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-cloud-auto-join-${random_string.random.result}"
}

module "consul_server_security_group" {
  source           = "git::https://github.com/timarenz/terraform-aws-security-group.git?ref=v0.1.0"
  environment_name = local.environment_name
  owner_name       = local.owner_name
  name             = "consul-server-${random_string.random.result}"
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
    from_port        = "8500"
    to_port          = "8500"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "tcp"
    from_port        = "8300"
    to_port          = "8300"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "tcp"
    from_port        = "8301"
    to_port          = "8301"
    cidr_blocks      = ["192.168.30.0/24"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "udp"
    from_port        = "8301"
    to_port          = "8301"
    cidr_blocks      = ["192.168.30.0/24"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "tcp"
    from_port        = "8302"
    to_port          = "8302"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
    }, {
    protocol         = "udp"
    from_port        = "8302"
    to_port          = "8302"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = null
    security_groups  = null
    prefix_list_ids  = null
    self             = true
  }]
}

module "aws_consul_server_1" {
  source                 = "git::https://github.com/timarenz/terraform-aws-virtual-machine.git?ref=v0.1.0"
  environment_name       = local.environment_name
  owner_name             = local.owner_name
  name                   = "consul-server-1-${random_string.random.result}"
  subnet_id              = module.aws.public_subnet_ids[0]
  ssh_public_key         = local.ssh_public_key
  vpc_security_group_ids = [module.consul_server_security_group.id]
  iam_instance_profile   = module.iam_profile_consul_cloud_auto_join.instance_profile_name
  tags = {
    "${local.aws_discovery_tag}" = "${local.aws_discovery_value}"
  }
}

module "aws_consul_server_2" {
  source                 = "git::https://github.com/timarenz/terraform-aws-virtual-machine.git?ref=v0.1.0"
  environment_name       = local.environment_name
  owner_name             = local.owner_name
  name                   = "consul-server-2-${random_string.random.result}"
  subnet_id              = module.aws.public_subnet_ids[0]
  ssh_public_key         = local.ssh_public_key
  vpc_security_group_ids = [module.consul_server_security_group.id]
  iam_instance_profile   = module.iam_profile_consul_cloud_auto_join.instance_profile_name
  tags = {
    "${local.aws_discovery_tag}" = "${local.aws_discovery_value}"
  }
}

module "aws_consul_server_3" {
  source                 = "git::https://github.com/timarenz/terraform-aws-virtual-machine.git?ref=v0.1.0"
  environment_name       = local.environment_name
  owner_name             = local.owner_name
  name                   = "consul-server-3-${random_string.random.result}"
  subnet_id              = module.aws.public_subnet_ids[0]
  ssh_public_key         = local.ssh_public_key
  vpc_security_group_ids = [module.consul_server_security_group.id]
  iam_instance_profile   = module.iam_profile_consul_cloud_auto_join.instance_profile_name
  tags = {
    "${local.aws_discovery_tag}" = "${local.aws_discovery_value}"
  }
}

module "aws_consul_server_1_config" {
  source              = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                = module.aws_consul_server_1.public_ip
  username            = local.aws_username
  ssh_private_key     = local.ssh_private_key
  retry_join          = ["provider=aws tag_key=${local.aws_discovery_tag} tag_value=${local.aws_discovery_value}"]
  retry_join_wan      = [module.gcp_consul_server_1.public_ip, module.gcp_consul_server_2.public_ip, module.gcp_consul_server_3.public_ip]
  connect             = true
  advertise_addr      = module.aws_consul_server_1.private_ip
  advertise_addr_wan  = module.aws_consul_server_1.public_ip
  translate_wan_addrs = true
  datacenter          = local.aws_consul_dc_name
  primary_datacenter  = local.gcp_consul_dc_name
  bootstrap_expect    = 3
  consul_version      = local.consul_version
}

module "aws_consul_server_2_config" {
  source              = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                = module.aws_consul_server_2.public_ip
  username            = local.aws_username
  ssh_private_key     = local.ssh_private_key
  retry_join          = ["provider=aws tag_key=${local.aws_discovery_tag} tag_value=${local.aws_discovery_value}"]
  retry_join_wan      = [module.gcp_consul_server_1.public_ip, module.gcp_consul_server_2.public_ip, module.gcp_consul_server_3.public_ip]
  connect             = true
  advertise_addr      = module.aws_consul_server_2.private_ip
  advertise_addr_wan  = module.aws_consul_server_2.public_ip
  translate_wan_addrs = true
  datacenter          = local.aws_consul_dc_name
  primary_datacenter  = local.gcp_consul_dc_name
  bootstrap_expect    = 3
  consul_version      = local.consul_version
}

module "aws_consul_server_3_config" {
  source              = "git::https://github.com/timarenz/terraform-ssh-consul.git?ref=v0.1.0"
  host                = module.aws_consul_server_3.public_ip
  username            = local.aws_username
  ssh_private_key     = local.ssh_private_key
  retry_join          = ["provider=aws tag_key=${local.aws_discovery_tag} tag_value=${local.aws_discovery_value}"]
  retry_join_wan      = [module.gcp_consul_server_1.public_ip, module.gcp_consul_server_2.public_ip, module.gcp_consul_server_3.public_ip]
  connect             = true
  advertise_addr      = module.aws_consul_server_3.private_ip
  advertise_addr_wan  = module.aws_consul_server_3.public_ip
  translate_wan_addrs = true
  datacenter          = local.aws_consul_dc_name
  primary_datacenter  = local.gcp_consul_dc_name
  bootstrap_expect    = 3
  consul_version      = local.consul_version
}

resource "null_resource" "aws_consul_server_1_meshify" {
  depends_on = [module.aws_consul_server_1_config, module.aws_consul_server_2_config, module.aws_consul_server_3_config]
  connection {
    host        = module.aws_consul_server_1.public_ip
    user        = local.aws_username
    private_key = local.ssh_private_key
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.module}/scripts/mesh-central-config.sh"
    ]
  }
}
