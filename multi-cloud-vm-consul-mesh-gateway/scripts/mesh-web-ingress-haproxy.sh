#!/bin/bash

sudo mkdir /tmp/ingress/
sudo tee /tmp/ingress/haproxy.cfg <<EOF
frontend ingress
    bind *:80
    mode http
    default_backend connect-sidecar
backend connect-sidecar
    mode http
    balance roundrobin
    server sidecar 127.0.0.1:90 check
EOF

sudo docker stop ingress
sudo docker rm ingress
sudo docker run -d --network host -v /tmp/ingress:/usr/local/etc/haproxy:ro --hostname ${HOSTNAME} --name ingress haproxy

sudo tee /etc/consul.d/ingress.json <<EOF
{
  "service": {
    "name": "ingress",
    "port": 80,
    "check": {
      "args": [
        "curl",
        "localhost:80"
      ],
      "interval": "5s"
    },
    "connect": {
      "sidecar_service": {"proxy": {
          "upstreams": [
            {
              "destination_name": "web",
              "local_bind_port": 90
            }
          ]
        }
      }
    }
  }
}
EOF
sudo consul reload

sudo docker stop ingress-proxy
sudo docker rm ingress-proxy
sudo docker run -d --network host --name ingress-proxy timarenz/envoy-consul:v1.11.1_1.6.1 -sidecar-for ingress -admin-bind localhost:19013 -- -l debug

