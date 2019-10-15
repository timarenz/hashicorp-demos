output "aws_consul_server_1_public_ip" {
  value = module.aws_consul_server_1.public_ip
}

output "aws_consul_server_2_public_ip" {
  value = module.aws_consul_server_2.public_ip
}

output "aws_consul_server_3_public_ip" {
  value = module.aws_consul_server_3.public_ip
}

output "gcp_consul_server_1_public_ip" {
  value = module.gcp_consul_server_1.public_ip
}

output "gcp_consul_server_2_public_ip" {
  value = module.gcp_consul_server_2.public_ip
}

output "gcp_consul_server_3_public_ip" {
  value = module.gcp_consul_server_3.public_ip
}

output "aws_consul_client_1_public_ip" {
  value = module.aws_consul_client_1.public_ip
}

output "aws_consul_client_2_public_ip" {
  value = module.aws_consul_client_2.public_ip
}

output "aws_consul_client_3_public_ip" {
  value = module.aws_consul_client_3.public_ip
}

output "gcp_consul_client_1_public_ip" {
  value = module.gcp_consul_client_1.public_ip
}

output "gcp_consul_client_2_public_ip" {
  value = module.gcp_consul_client_2.public_ip
}

output "gcp_consul_client_3_public_ip" {
  value = module.gcp_consul_client_3.public_ip
}

output "consul_ui_gcp" {
  value = "http://${module.gcp_consul_server_1.public_ip}:8500"
}

output "consul_ui_aws" {
  value = "http://${module.aws_consul_server_1.public_ip}:8500"
}

output "counting_dashboard_gcp" {
  value = "http://${module.gcp_consul_client_1.public_ip}:9002"
}

output "counting_dashboard_aws" {
  value = "http://${module.aws_consul_client_1.public_ip}:9002"
}

output "gcp_L7_route_default" {
  value = "http://${module.gcp_consul_client_3.public_ip}"
}

output "gcp_L7_route_admin" {
  value = "http://${module.gcp_consul_client_3.public_ip}/admin"
}

output "gcp_L7_route_login" {
  value = "http://${module.gcp_consul_client_3.public_ip}/login"
}

output "aws_L7_route_default" {
  value = "http://${module.aws_consul_client_3.public_ip}"
}

output "aws_L7_route_admin" {
  value = "http://${module.aws_consul_client_3.public_ip}/admin"
}

output "aws_L7_route_login" {
  value = "http://${module.aws_consul_client_3.public_ip}/login"
}
