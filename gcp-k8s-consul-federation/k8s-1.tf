module "k8s_1" {
  source           = "git::https://github.com/timarenz/terraform-google-kubernetes.git?ref=v0.5.0"
  project          = module.gcp.project_id
  environment_name = var.environment_name
  owner_name       = var.owner_name
  name             = "${local.prefix}-k8s-1"
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

resource "local_file" "kubeconfig_1" {
  content  = module.k8s_1.kubeconfig
  filename = "${path.cwd}/kubeconfig-1.yaml"
}

provider "kubernetes" {
  alias                  = "k8s_1"
  host                   = module.k8s_1.endpoint
  cluster_ca_certificate = module.k8s_1.cluster_ca_certificate
  token                  = data.google_client_config.client.access_token

  load_config_file = false
}

resource "kubernetes_secret" "consul_1" {
  provider = kubernetes.k8s_1
  metadata {
    name = "consul"
  }

  data = {
    license             = file(var.consul_license_file)
    gossipEncryptionKey = random_id.consul_gossip_encryption_key.b64_std
  }
}

provider "helm" {
  alias = "k8s_1"
  kubernetes {
    host                   = module.k8s_1.endpoint
    cluster_ca_certificate = module.k8s_1.cluster_ca_certificate
    token                  = data.google_client_config.client.access_token

    load_config_file = false
  }
}

resource "helm_release" "consul_1" {
  provider = helm.k8s_1

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
    value = "k8s-1"
  }

  set {
    name  = "global.gossipEncryption.secretName"
    value = kubernetes_secret.consul_1.metadata[0].name
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
    name  = "global.enableConsulNamespaces"
    value = true
  }

  set {
    name  = "global.acls.manageSystemACLs"
    value = true
  }

  set {
    name  = "global.acls.createReplicationToken"
    value = true
  }

  set {
    name  = "global.federation.enabled"
    value = true
  }

  set {
    name  = "global.federation.createFederationSecret"
    value = true
  }

  set {
    name  = "server.enterpriseLicense.secretName"
    value = kubernetes_secret.consul_1.metadata[0].name
  }

  set {
    name  = "server.enterpriseLicense.secretKey"
    value = "license"
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
    name  = "syncCatalog.logLevel"
    value = "trace"
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

  set {
    name  = "terminatingGateways.enabled"
    value = true
  }

  set {
    name  = "terminatingGateways.defaults.replicas"
    value = "1"
  }

  values = [<<EOF
  server:
    extraConfig: |
      { "log_level"   : "TRACE" }
  EOF
  ]
}

data "kubernetes_secret" "consul_federation" {
  provider   = kubernetes.k8s_1
  depends_on = [helm_release.consul_1]
  metadata {
    name = "consul-federation"
  }
}
