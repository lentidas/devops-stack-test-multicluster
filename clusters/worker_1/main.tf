module "sks" {
  source = "git::https://github.com/camptocamp/devops-stack-module-cluster-sks.git?ref=v1.1.0"

  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version
  zone               = var.zone
  base_domain        = data.exoscale_domain.domain.name

  service_level = var.service_level

  nodepools = {
    "${var.cluster_name}-default" = {
      size            = 3
      instance_type   = "standard.large"
      description     = "Default node pool for ${var.cluster_name}."
      instance_prefix = "default"
    },
  }
}

module "traefik" {
  source = "git::https://github.com/camptocamp/devops-stack-module-traefik.git//sks?ref=v3.1.0"
  # source = "../../../../devops-stack-module-traefik/sks"

  cluster_name        = var.cluster_name
  base_domain         = module.sks.base_domain
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = var.cluster_name

  nlb_id                  = module.sks.nlb_id
  router_nodepool_id      = module.sks.router_nodepool_id
  router_instance_pool_id = module.sks.router_instance_pool_id

  app_autosync           = local.app_autosync
  enable_service_monitor = var.enable_service_monitor

  dependency_ids = {}
}

module "cert-manager" {
  source = "git::https://github.com/camptocamp/devops-stack-module-cert-manager.git//sks?ref=v5.3.0"
  # source = "../../../../devops-stack-module-cert-manager/sks"

  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = var.cluster_name

  app_autosync           = local.app_autosync
  enable_service_monitor = var.enable_service_monitor

  dependency_ids = {}
}

module "longhorn" {
  source = "git::https://github.com/camptocamp/devops-stack-module-longhorn.git?ref=v2.3.0"
  # source = "../../../../devops-stack-module-longhorn"

  cluster_name        = var.cluster_name
  base_domain         = module.sks.base_domain
  cluster_issuer      = var.cluster_issuer
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = var.cluster_name

  app_autosync           = local.app_autosync
  enable_service_monitor = var.enable_service_monitor

  enable_dashboard_ingress = true
  oidc                     = var.oidc

  enable_pv_backups = true
  backup_storage = {
    bucket_name = resource.aws_s3_bucket.this["longhorn"].id
    region      = resource.aws_s3_bucket.this["longhorn"].region
    endpoint    = "sos-${resource.aws_s3_bucket.this["longhorn"].region}.exo.io"
    access_key  = resource.exoscale_iam_access_key.s3_iam_key["longhorn"].key
    secret_key  = resource.exoscale_iam_access_key.s3_iam_key["longhorn"].secret
  }

  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
  }
}

module "loki-stack" {
  source = "git::https://github.com/camptocamp/devops-stack-module-loki-stack.git//sks?ref=v5.1.0"
  # source = "../../../../devops-stack-module-loki-stack/sks"

  cluster_id          = module.sks.cluster_id
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = var.cluster_name

  app_autosync = local.app_autosync

  logs_storage = {
    bucket_name = resource.aws_s3_bucket.this["loki"].id
    region      = resource.aws_s3_bucket.this["loki"].region
    access_key  = resource.exoscale_iam_access_key.s3_iam_key["loki"].key
    secret_key  = resource.exoscale_iam_access_key.s3_iam_key["loki"].secret
  }

  dependency_ids = {
    longhorn = module.longhorn.id
  }
}

module "kube-prometheus-stack" {
  source = "git::https://github.com/camptocamp/devops-stack-module-kube-prometheus-stack.git//sks?ref=v7.1.0"
  # source = "../../../../devops-stack-module-kube-prometheus-stack/sks"

  cluster_name        = var.cluster_name
  base_domain         = module.sks.base_domain
  cluster_issuer      = var.cluster_issuer
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = var.cluster_name

  app_autosync = local.app_autosync

  prometheus = {
    oidc = var.oidc
  }
  alertmanager = {
    oidc = var.oidc
  }
  grafana = {
    oidc = var.oidc
  }

  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    longhorn     = module.longhorn.id
    loki-stack   = module.loki-stack.id
  }
}
