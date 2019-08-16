#!/bin/bash
sudo docker run -d -p 9001:9001 --hostname ${HOSTNAME} --name counting hashicorp/counting-service:0.0.2

sudo tee /etc/consul.d/counting-service.json <<EOF
{
  "service": {
    "name": "counting",
    "port": 9001,
    "check": {
      "args": [
        "curl",
        "localhost:9001"
      ],
      "interval": "10s"
    },
    "connect": {
      "sidecar_service": {}
    }
  }
}
EOF
sudo consul reload

sudo docker run -d --network host --name counting-proxy timarenz/consul-envoy:1.6.0-beta3_1.10.0 -sidecar-for counting -- -l debug
#consul connect proxy -sidecar-for counting -log-level debug

consul config write -<<EOF
{
  "kind": "service-defaults",
  "name": "counting",
  "protocol": "http"
}
EOF

consul config write -<<EOF
kind            = "service-resolver"
name            = "counting"
connect_timeout = "15s"
failover = {
  "*" = {
    datacenters = ["dc-aws", "dc-gcp"]
  }
}
EOF
