variable "gcp_credentials_file" {
  default = "../../creds/terraform-tim-arenz-0ca4ad9bf9ed.json"
}

variable "gcp_project" {
  default = "tim-arenz"
}

variable "gcp_region" {
  default = "europe-west4"
}

variable "environment_name" {
  default = "consul-k8s-federation"
}

variable "owner_name" {
  default = "tar"
}

variable "consul_license_file" {
  default = "../../creds/consul.license"
}