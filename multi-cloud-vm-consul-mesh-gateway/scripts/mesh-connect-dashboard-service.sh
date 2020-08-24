#!/bin/bash
sudo docker run -d --network host -e COUNTING_SERVICE_URL=http://localhost:9191 --name dashboard hashicorp/dashboard-service:0.0.3

sudo tee /etc/consul.d/dashboard-service.json <<EOF
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
              "local_bind_port": 9191
            }
          ]
        }
      }
    }
  }
}
EOF
sudo consul reload

sudo docker run -d --network host --name dashboard-proxy timarenz/envoy-consul:v1.11.1_1.6.1 -sidecar-for dashboard -- -l debug
#consul connect proxy -sidecar-for dashboard -log-level debug
