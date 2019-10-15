#!/bin/bash

sudo mkdir /tmp/web/
sudo tee /tmp/web/index.html <<EOF
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to DEFAULT API path!</title>
    </head>
    <body>
    <h1>Welcome to DEFAULT API path!</h1>
    <h1>Located on host $(hostname)</h1>
    <p>If you see this page, you were NOT redirected by a Consul Service Mesh L7 service-router and hitting the default service endpoint.</p>
    </body>
    </html>
EOF

sudo docker stop web
sudo docker rm web
sudo docker run -d -p 87:80 -v /tmp/web:/usr/share/nginx/html --hostname ${HOSTNAME} --name web nginx

sudo tee /etc/consul.d/web.json <<EOF
{
  "service": {
    "name": "web",
    "port": 87,
    "check": {
      "args": [
        "curl",
        "localhost:87"
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

sudo docker stop web-proxy
sudo docker rm web-proxy
sudo docker run -d --network host --name web-proxy timarenz/envoy-consul:v1.11.1_1.6.1 -sidecar-for web -admin-bind localhost:19010 -- -l debug

