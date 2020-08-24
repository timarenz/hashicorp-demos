output "useful_commands" {
  value = <<EOF

-------------------------------------------------------------------------------------
Useful commands:

# Set K8S-1 config for kubectl
export KUBECONFIG="$(pwd)/kubeconfig-1.yaml"

# Set K8S-2 config for kubectl
export KUBECONFIG="$(pwd)/kubeconfig-2.yaml"

# Get Consul master token 
kubectl get secret consul-bootstrap-acl-token -o jsonpath="{.data.token}" | base64 -d

# Port-forward Consul API / UI
kubectl port-forward consul-server-0 8501
-------------------------------------------------------------------------------------
EOF
}