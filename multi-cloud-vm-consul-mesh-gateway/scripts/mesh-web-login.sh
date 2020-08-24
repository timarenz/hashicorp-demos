#!/bin/bash

sudo mkdir /tmp/web-login/
sudo tee /tmp/web-login/index.html <<EOF
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to /LOGIN API path!</title>
    </head>
    <body>
    <h1>Welcome to /LOGIN API path!</h1>
    <h1>Located on host $(hostname)</h1>
    <p>If you see this page, you were redirected by a Consul Service Mesh L7 service-router.</p>
    </body>
    </html>
EOF

sudo docker stop web-login
sudo docker rm web-login
sudo docker run -d -p 89:80 -v /tmp/web-login:/usr/share/nginx/html --hostname ${HOSTNAME} --name web-login nginx

sudo tee /etc/consul.d/web-login.json <<EOF
{
  "service": {
    "name": "web-login",
    "port": 89,
    "check": {
      "args": [
        "curl",
        "localhost:89"
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

sudo docker stop web-login-proxy
sudo docker rm web-login-proxy
sudo docker run -d --network host --name web-login-proxy timarenz/envoy-consul:v1.11.1_1.6.1 -sidecar-for web-login -admin-bind localhost:19012 -- -l debug
