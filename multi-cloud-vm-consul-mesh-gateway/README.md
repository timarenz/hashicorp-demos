# multi-cloud-vm-consul-mesh-gateway

This repo shows how to use Terraform to provision a Multi-Cloud (GCP & AWS) Consul environment and connect the using Mesh Gateways

## Overview

Terraform is used to provision a full Consul datacenter (3 servers each) in each cloud.
Cloud auto join is used to form the Consul cluster in each cloud.

## Prerequisites

This Terraform environments assumes the following:

- AWS and GCP account for provisiong cloud resources
- A project must be available in GCP
- Terraform 0.12 or later

## Usage

It is required to use this folder as working directory. AWS and GCP credenials need to be exposed via environments variables or the need to be configured in the `main.tf` provider definition.

1. Set requried variables in a file named `terraform.tfvars`(see terraform.tfvars.example)
2. Provision the environment using the following commands

````
terraform init
terraform apply
````

3. Access Consul UI via port 8500 on one of the servers
4. Access the countaing dashboard that is running on the first client of each DC on port 9002
5. Change the dashboard service configuration on one of the first clients and configure the other datacenter as upstream. Below you see an example configuration of the dashboard service in AWS.

````
{
  "service": {
    "name": "dashboard",
    "port": 9002,
    "check": {
      "args": [
        "curl",
        "localhost:9002"
      ],
      "interval": "10s"
    },
    "connect": {
      "sidecar_service": {
        "proxy": {
          "upstreams": [
            {
              "destination_name": "counting",
              "local_bind_port": 9191,
              "datacenter": "dc-gcp"
            }
          ]
        }
      }
    }
  }
}
````

6. You should the hostname changing within the dashboard service as it is now using the service of the other datacenter.