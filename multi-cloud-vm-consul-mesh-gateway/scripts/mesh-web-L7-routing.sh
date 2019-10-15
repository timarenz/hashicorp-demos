#!/bin/bash

consul config write -<<EOF
{
  "kind": "service-defaults",
  "name": "web",
  "protocol": "http"
}
EOF

consul config write -<<EOF
{
  "kind": "service-defaults",
  "name": "web-admin",
  "protocol": "http"
}
EOF

consul config write -<<EOF
{
  "kind": "service-defaults",
  "name": "web-login",
  "protocol": "http"
}
EOF

consul config write -<<EOF
kind = "service-router"
name = "web"
routes = [
  {
    match {
      http {
        path_prefix = "/login"
      }
    }

    destination {
      service = "web-login",
      prefix_rewrite = "/"
    }
  },
  {
    match {
      http {
        path_prefix = "/admin"
      }
    }

    destination {
      service = "web-admin",
      prefix_rewrite = "/"
    }
  }
]
EOF

consul config write -<<EOF
kind            = "service-resolver"
name            = "web-login"
connect_timeout = "15s"
failover = {
  "*" = {
    datacenters = ["dc-aws", "dc-gcp"]
  }
}
EOF

consul config write -<<EOF
kind            = "service-resolver"
name            = "web-admin"
connect_timeout = "15s"
failover = {
  "*" = {
    datacenters = ["dc-aws", "dc-gcp"]
  }
}
EOF

consul config write -<<EOF
kind            = "service-resolver"
name            = "web"
connect_timeout = "15s"
failover = {
  "*" = {
    datacenters = ["dc-aws", "dc-gcp"]
  }
}
EOF

