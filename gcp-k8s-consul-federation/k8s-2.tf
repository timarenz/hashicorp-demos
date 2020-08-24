module "k8s_2" {
  source           = "git::https://github.com/timarenz/terraform-google-kubernetes.git?ref=v0.5.0"
  project          = module.gcp.project_id
  environment_name = var.environment_name
  owner_name       = var.owner_name
  name             = "${local.prefix}-k8s-2"
  network          = module.gcp.network
  subnet           = module.gcp.subnet_self_links[0]
  region           = module.gcp.region
  node_count       = 1
  oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/cloud-platform"
  ]
}

resource "local_file" "kubeconfig_2" {
  content  = module.k8s_2.kubeconfig
  filename = "${path.cwd}/kubeconfig-2.yaml"
}

provider "kubernetes" {
  alias                  = "k8s_2"
  host                   = module.k8s_2.endpoint
  cluster_ca_certificate = module.k8s_2.cluster_ca_certificate
  token                  = data.google_client_config.client.access_token

  load_config_file = false
}

resource "kubernetes_secret" "consul_2" {
  provider = kubernetes.k8s_2
  metadata {
    name = "consul-federation"
  }

  data = {
    license             = file(var.consul_license_file)
    caCert              = data.kubernetes_secret.consul_federation.data["caCert"]
    caKey               = data.kubernetes_secret.consul_federation.data["caKey"]
    gossipEncryptionKey = data.kubernetes_secret.consul_federation.data["gossipEncryptionKey"]
    replicationToken    = data.kubernetes_secret.consul_federation.data["replicationToken"]
    serverConfigJSON    = data.kubernetes_secret.consul_federation.data["serverConfigJSON"]
  }
}

provider "helm" {
  alias = "k8s_2"
  kubernetes {
    host                   = module.k8s_2.endpoint
    cluster_ca_certificate = module.k8s_2.cluster_ca_certificate
    token                  = data.google_client_config.client.access_token

    load_config_file = false
  }
}

resource "helm_release" "consul_2" {
  provider = helm.k8s_2

  name       = "consul"
  chart      = "consul"
  repository = "https://helm.releases.hashicorp.com"

  set {
    name  = "global.name"
    value = "consul"
  }

  set {
    name  = "global.image"
    value = "hashicorp/consul-enterprise:1.8.3-ent"
  }

  set {
    name  = "global.datacenter"
    value = "k8s-2"
  }

  set {
    name  = "global.gossipEncryption.secretName"
    value = kubernetes_secret.consul_2.metadata[0].name
  }

  set {
    name  = "global.gossipEncryption.secretKey"
    value = "gossipEncryptionKey"
  }

  set {
    name  = "global.tls.enabled"
    value = true
  }

  set {
    name  = "global.tls.enableAutoEncrypt"
    value = true
  }

  set {
    name  = "global.tls.caCert.secretName"
    value = kubernetes_secret.consul_2.metadata[0].name
  }

  set {
    name  = "global.tls.caCert.secretKey"
    value = "caCert"
  }

  set {
    name  = "global.tls.caKey.secretName"
    value = kubernetes_secret.consul_2.metadata[0].name
  }

  set {
    name  = "global.tls.caKey.secretKey"
    value = "caKey"
  }

  set {
    name  = "global.enableConsulNamespaces"
    value = true
  }

  set {
    name  = "global.acls.manageSystemACLs"
    value = true
  }

  set {
    name  = "global.acls.replicationToken.secretName"
    value = kubernetes_secret.consul_2.metadata[0].name
  }

  set {
    name  = "global.acls.replicationToken.secretKey"
    value = "replicationToken"
  }

  set {
    name  = "global.federation.enabled"
    value = true
  }

  set {
    name  = "server.enterpriseLicense.secretName"
    value = kubernetes_secret.consul_2.metadata[0].name
  }

  set {
    name  = "server.enterpriseLicense.secretKey"
    value = "license"
  }

  set {
    name  = "server.extraVolumes[0].type"
    value = "secret"
  }

  set {
    name  = "server.extraVolumes[0].name"
    value = "consul-federation"
  }

  set {
    name  = "server.extraVolumes[0].items[0].key"
    value = "serverConfigJSON"
  }

  set {
    name  = "server.extraVolumes[0].items[0].path"
    value = "config.json"
  }

  set {
    name  = "server.extraVolumes[0].load"
    value = true
  }

  set {
    name  = "syncCatalog.enabled"
    value = true
  }

  set {
    name  = "syncCatalog.default"
    value = false
  }

  set {
    name  = "syncCatalog.consulNamespaces.mirroringK8S"
    value = true
  }

  set {
    name  = "syncCatalog.addK8SNamespaceSuffix"
    value = false
  }

  set {
    name  = "meshGateway.enabled"
    value = true
  }

  set {
    name  = "connectInject.enabled"
    value = true
  }

  set {
    name  = "connectInject.centralConfig.enabled"
    value = true
  }

  set {
    name  = "connectInject.consulNamespaces.mirroringK8S"
    value = true
  }

  values = [<<EOF
  server:
    extraConfig: |
      { "log_level"   : "TRACE" }
  EOF
  ]
}
