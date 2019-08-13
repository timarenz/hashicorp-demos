#!/bin/bash

consul config write -<<EOF
{
  "Kind": "proxy-defaults",
  "Name": "global",
  "MeshGateway": {
    "Mode": "local"
  }
}
EOF