#!/bin/bash

sudo mkdir /tmp/web-admin/
sudo tee /tmp/web-admin/index.html <<EOF
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to /ADMIN API path!</title>
    </head>
    <body>
    <h1>Welcome to /ADMIN API path!</h1>
    <h1>Located on host $(hostname)</h1>
    <p>If you see this page, you were redirected by a Consul Service Mesh L7 service-router.</p>
    </body>
    </html>
EOF

sudo docker stop web-admin
sudo docker rm web-admin
sudo docker run -d -p 88:80 -v /tmp/web-admin:/usr/share/nginx/html --hostname ${HOSTNAME} --name web-admin nginx

sudo tee /etc/consul.d/web-admin.json <<EOF
{
  "service": {
    "name": "web-admin",
    "port": 88,
    "check": {
      "args": [
        "curl",
        "localhost:88"
      ],
      "interval": "5s"
    },
    "connect": {
      "sidecar_service": {}
    }
  }
}
EOF
sudo consul reload

sudo docker stop web-admin-proxy
sudo docker rm web-admin-proxy
sudo docker run -d --network host --name web-admin-proxy timarenz/envoy-consul:v1.11.1_1.6.1 -sidecar-for web-admin -admin-bind localhost:19011 -- -l debug

