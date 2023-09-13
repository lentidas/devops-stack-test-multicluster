locals {
  # Local variable that containts the variables required to create Argo CD projects per cluster using the argocd-bootstrap module.
  argocd_projects = {
    cluster_names                    = concat([local.clusters.control_plane.cluster_name], [for i in local.clusters.workers : i.cluster_name])
    project_extra_source_repos       = []
    project_extra_allowed_namespaces = []
  }

  clusters = {
    control_plane = {
      kubernetes_version     = "1.27"
      cluster_name           = "gh-control-plane"
      base_domain            = "is-sandbox.camptocamp.com"
      cluster_issuer         = "letsencrypt-staging"
      enable_service_monitor = false # Can be enabled after the first bootstrap.
      enable_app_autosync    = true
      vpc_cidr               = "10.56.0.0/16"
    }
    workers = {
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

  kubernetes_version               = local.clusters.control_plane.kubernetes_version
  cluster_name                     = local.clusters.control_plane.cluster_name
  base_domain                      = local.clusters.control_plane.base_domain
  cluster_issuer                   = local.clusters.control_plane.cluster_issuer
  enable_service_monitor           = local.clusters.control_plane.enable_service_monitor
  enable_app_autosync              = local.clusters.control_plane.enable_app_autosync
  vpc_cidr                         = local.clusters.control_plane.vpc_cidr
  cluster_names                    = local.argocd_projects.cluster_names
  project_extra_source_repos       = local.argocd_projects.project_extra_source_repos
  project_extra_allowed_namespaces = local.argocd_projects.project_extra_allowed_namespaces
  oidc                             = local.oidc_config
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

  kubernetes_version       = local.clusters.workers.worker_1.kubernetes_version
  cluster_name             = local.clusters.workers.worker_1.cluster_name
  zone                     = local.clusters.workers.worker_1.zone
  service_level            = local.clusters.workers.worker_1.service_level
  base_domain              = local.clusters.workers.worker_1.base_domain
  activate_wildcard_record = local.clusters.workers.worker_1.activate_wildcard_record
  cluster_issuer           = local.clusters.workers.worker_1.cluster_issuer
  enable_service_monitor   = local.clusters.workers.worker_1.enable_service_monitor
  enable_app_autosync      = local.clusters.workers.worker_1.enable_app_autosync
  argocd_namespace         = module.control_plane.argocd_namespace
  oidc                     = local.oidc_config

  depends_on = [module.control_plane]
}
