locals {
  project_allowed_source_repos = [
    "https://github.com/camptocamp/devops-stack-module-argocd.git",
    "https://github.com/camptocamp/devops-stack-module-cert-manager.git",
    "https://github.com/camptocamp/devops-stack-module-ebs-csi-driver.git",
    "https://github.com/camptocamp/devops-stack-module-efs-csi-driver.git",
    "https://github.com/camptocamp/devops-stack-module-keycloak.git",
    "https://github.com/camptocamp/devops-stack-module-kube-prometheus-stack.git",
    "https://github.com/camptocamp/devops-stack-module-loki-stack.git",
    "https://github.com/camptocamp/devops-stack-module-longhorn.git",
    "https://github.com/camptocamp/devops-stack-module-metrics-server.git",
    "https://github.com/camptocamp/devops-stack-module-minio.git",
    "https://github.com/camptocamp/devops-stack-module-thanos.git",
    "https://github.com/camptocamp/devops-stack-module-traefik.git",
  ]

  project_allowed_namespaces = [
    "argocd",
    "cert-manager",
    "keycloak",
    "kube-prometheus-stack",
    "kube-system",
    "loki-stack",
    "longhorn-system",
    "minio",
    "thanos",
    "traefik",
  ]

  # Local variable that containts the variables required to create Argo CD projects per cluster using the argocd-bootstrap module.
  argocd_projects = {
    "control-plane" = {
      destination_cluster = "in-cluster"
    }
    "worker-1" = {
      destination_cluster  = local.clusters.workers.worker_1.cluster_name
      allowed_source_repos = local.project_allowed_source_repos
      allowed_namespaces   = local.project_allowed_namespaces
    }
    "worker-2" = {
      destination_cluster  = local.clusters.workers.worker_2.cluster_name
      allowed_source_repos = local.project_allowed_source_repos
      allowed_namespaces   = local.project_allowed_namespaces
    }
  }

  # TODO Consider chosing better names than control_plane and workers
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
      worker_2 = {
        kubernetes_version       = "1.28.1"
        cluster_name             = "gh-worker-2"
        zone                     = "ch-dk-2"
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

  kubernetes_version     = local.clusters.control_plane.kubernetes_version
  cluster_name           = local.clusters.control_plane.cluster_name
  base_domain            = local.clusters.control_plane.base_domain
  cluster_issuer         = local.clusters.control_plane.cluster_issuer
  enable_service_monitor = local.clusters.control_plane.enable_service_monitor
  enable_app_autosync    = local.clusters.control_plane.enable_app_autosync
  vpc_cidr               = local.clusters.control_plane.vpc_cidr
  argocd_project         = keys(local.argocd_projects)[0]
  argocd_projects        = local.argocd_projects
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

  kubernetes_version       = local.clusters.workers.worker_1.kubernetes_version
  cluster_name             = local.clusters.workers.worker_1.cluster_name
  zone                     = local.clusters.workers.worker_1.zone
  service_level            = local.clusters.workers.worker_1.service_level
  base_domain              = local.clusters.workers.worker_1.base_domain
  activate_wildcard_record = local.clusters.workers.worker_1.activate_wildcard_record
  cluster_issuer           = local.clusters.workers.worker_1.cluster_issuer
  enable_service_monitor   = local.clusters.workers.worker_1.enable_service_monitor
  enable_app_autosync      = local.clusters.workers.worker_1.enable_app_autosync
  argocd_project           = keys(local.argocd_projects)[1]
  argocd_namespace         = module.control_plane.argocd_namespace
  oidc                     = local.oidc_config

  depends_on = [module.control_plane]
}

module "worker_2" {
  source = "./clusters/worker_2"

  providers = {
    aws        = aws.worker_2
    exoscale   = exoscale.worker_2
    kubernetes = kubernetes.worker_2
    helm       = helm.worker_2
    argocd     = argocd
  }

  kubernetes_version       = local.clusters.workers.worker_2.kubernetes_version
  cluster_name             = local.clusters.workers.worker_2.cluster_name
  zone                     = local.clusters.workers.worker_2.zone
  service_level            = local.clusters.workers.worker_2.service_level
  base_domain              = local.clusters.workers.worker_2.base_domain
  activate_wildcard_record = local.clusters.workers.worker_2.activate_wildcard_record
  cluster_issuer           = local.clusters.workers.worker_2.cluster_issuer
  enable_service_monitor   = local.clusters.workers.worker_2.enable_service_monitor
  enable_app_autosync      = local.clusters.workers.worker_2.enable_app_autosync
  argocd_project           = keys(local.argocd_projects)[2]
  argocd_namespace         = module.control_plane.argocd_namespace
  oidc                     = local.oidc_config

  depends_on = [module.control_plane]
}
