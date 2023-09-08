locals {
  control_plane = {
    kubernetes_version     = "1.27"
    cluster_name           = "gh-control-plane"
    base_domain            = "is-sandbox.camptocamp.com"
    cluster_issuer         = "letsencrypt-staging"
    enable_service_monitor = false # Can be enabled after the first bootstrap.
    enable_app_autosync    = true
    vpc_cidr               = "10.56.0.0/16"
  }

  worker_1 = {
    kubernetes_version       = "1.28.1"
    cluster_name             = "gh-worker-1"
    zone                     = "ch-gva-2"
    service_level            = "starter"
    base_domain              = "is-sandbox-exo.camptocamp.com"
    activate_wildcard_record = true
    cluster_issuer           = "letsencrypt-staging"
    enable_service_monitor   = false # Can be enabled after the first bootstrap.
    enable_app_autosync      = true
  }
}

module "control_plane" {
  source = "./clusters/control_plane"

  providers = {
    aws        = aws.control_plane
    kubernetes = kubernetes.control_plane
    helm       = helm.control_plane
    argocd     = argocd
  }

  kubernetes_version     = local.control_plane.kubernetes_version
  cluster_name           = local.control_plane.cluster_name
  base_domain            = local.control_plane.base_domain
  cluster_issuer         = local.control_plane.cluster_issuer
  enable_service_monitor = local.control_plane.enable_service_monitor
  enable_app_autosync    = local.control_plane.enable_app_autosync
  vpc_cidr               = local.control_plane.vpc_cidr
  oidc                   = local.oidc_config
}

module "worker_1" {
  source = "./clusters/worker_1"

  providers = {
    aws        = aws.worker_1
    exoscale   = exoscale.worker_1
    kubernetes = kubernetes.worker_1
    helm       = helm.worker_1
    argocd     = argocd
  }

  kubernetes_version       = local.worker_1.kubernetes_version
  cluster_name             = local.worker_1.cluster_name
  zone                     = local.worker_1.zone
  service_level            = local.worker_1.service_level
  base_domain              = local.worker_1.base_domain
  activate_wildcard_record = local.worker_1.activate_wildcard_record
  cluster_issuer           = local.worker_1.cluster_issuer
  enable_service_monitor   = local.worker_1.enable_service_monitor
  enable_app_autosync      = local.worker_1.enable_app_autosync
  argocd_namespace         = module.control_plane.argocd_namespace
  oidc                     = local.oidc_config

  depends_on = [module.control_plane]
}

# TODO Right now the Argo CD is using the administrator cluster role. Consider creating a dedicated role for Argo CD.
resource "argocd_cluster" "worker_1" {
  name   = local.worker_1.cluster_name
  server = module.worker_1.kubernetes_host

  config {
    tls_client_config {
      ca_data   = module.worker_1.kubernetes_cluster_ca_certificate
      cert_data = module.worker_1.kubernetes_client_certificate
      key_data  = module.worker_1.kubernetes_client_key
      insecure  = false # This is the default value, but we set it explicitly for clarity.
    }
  }
  metadata {
    labels = {
      "cluster-type" = "worker",
      "cloud"        = "exoscale",
      "region"       = "ch-gva-2",
    }
  }
}
