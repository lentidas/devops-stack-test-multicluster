data "aws_availability_zones" "available" {}

module "vpc" {
  source               = "terraform-aws-modules/vpc/aws"
  version              = "~> 5.0"
  name                 = module.eks.cluster_name
  cidr                 = local.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = local.private_subnets
  public_subnets       = local.public_subnets
  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true

  private_subnet_tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                  = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${module.eks.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                           = "1"
  }
}

module "eks" {
  # source = "git::https://github.com/camptocamp/devops-stack-module-cluster-eks?ref=v2.0.2"
  source = "git::https://github.com/camptocamp/devops-stack-module-cluster-eks?ref=eks-nodegroups-attachment"
  # source = "../../devops-stack-module-cluster-eks"

  cluster_name       = local.cluster_name
  kubernetes_version = local.cluster_version
  base_domain        = local.base_domain

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets
  public_subnet_ids  = module.vpc.public_subnets

  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]

  node_groups = {
    "${module.eks.cluster_name}-main" = {
      instance_types = ["m5a.xlarge"]
      min_size       = 3
      max_size       = 3
      desired_size   = 3
      block_device_mappings = {
        "default" = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size = 100
          }
        }
      }
    },
  }

  create_public_nlb = true
}

module "argocd_bootstrap" {
  source = "git::https://github.com/camptocamp/devops-stack-module-argocd.git//bootstrap?ref=chart-autoupdate-minor-argocd"
  # source = "../../devops-stack-module-argocd/bootstrap"

  depends_on = [module.eks]
}

module "traefik" {
  source = "git::https://github.com/camptocamp/devops-stack-module-traefik.git//eks?ref=v2.0.1"
  # source = "../../devops-stack-module-traefik/eks"

  target_revision = "chart-autoupdate-major-traefik"

  cluster_name     = module.eks.cluster_name
  base_domain      = module.eks.base_domain
  argocd_namespace = module.argocd_bootstrap.argocd_namespace

  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor

  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

module "cert-manager" {
  source = "git::https://github.com/camptocamp/devops-stack-module-cert-manager.git//eks?ref=v5.1.0"
  # source = "../../devops-stack-module-cert-manager/eks"

  cluster_name     = module.eks.cluster_name
  base_domain      = module.eks.base_domain
  argocd_namespace = module.argocd_bootstrap.argocd_namespace

  app_autosync           = local.app_autosync
  enable_service_monitor = local.enable_service_monitor

  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url

  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

module "loki-stack" {
  source = "git::https://github.com/camptocamp/devops-stack-module-loki-stack//eks?ref=v4.0.2"
  # source = "../../devops-stack-module-loki-stack/eks"

  argocd_namespace = module.argocd_bootstrap.argocd_namespace

  app_autosync = local.app_autosync

  distributed_mode = true

  logs_storage = {
    bucket_id    = aws_s3_bucket.loki_logs_storage.id
    region       = aws_s3_bucket.loki_logs_storage.region
    iam_role_arn = module.iam_assumable_role_loki.iam_role_arn
  }

  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

module "thanos" {
  source = "git::https://github.com/camptocamp/devops-stack-module-thanos.git//eks?ref=v2.1.0"
  # source          = "../../devops-stack-module-thanos/eks"

  cluster_name     = module.eks.cluster_name
  base_domain      = module.eks.base_domain
  cluster_issuer   = local.cluster_issuer
  argocd_namespace = module.argocd_bootstrap.argocd_namespace

  app_autosync = local.app_autosync

  metrics_storage = {
    bucket_id    = aws_s3_bucket.thanos_metrics_storage.id
    region       = aws_s3_bucket.thanos_metrics_storage.region
    iam_role_arn = module.iam_assumable_role_thanos.iam_role_arn
  }
  thanos = {
    oidc = var.oidc
  }

  dependency_ids = {
    argocd       = module.argocd_bootstrap.id
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
  }
}

module "kube-prometheus-stack" {
  source = "git::https://github.com/camptocamp/devops-stack-module-kube-prometheus-stack.git//eks?ref=v6.1.1"
  # source = "../../devops-stack-module-kube-prometheus-stack/eks"

  cluster_name     = module.eks.cluster_name
  argocd_namespace = module.argocd_bootstrap.argocd_namespace
  base_domain      = module.eks.base_domain
  cluster_issuer   = local.cluster_issuer

  app_autosync = local.app_autosync

  metrics_storage = {
    bucket_id    = aws_s3_bucket.thanos_metrics_storage.id
    region       = aws_s3_bucket.thanos_metrics_storage.region
    iam_role_arn = module.iam_assumable_role_thanos.iam_role_arn
  }

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
    argocd       = module.argocd_bootstrap.id
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    thanos       = module.thanos.id
    loki-stack   = module.loki-stack.id
  }
}

module "argocd" {
  source = "git::https://github.com/camptocamp/devops-stack-module-argocd.git?ref=chart-autoupdate-minor-argocd"
  # source = "../../devops-stack-module-argocd"

  target_revision = "chart-autoupdate-minor-argocd"

  cluster_name   = module.eks.cluster_name
  base_domain    = module.eks.base_domain
  cluster_issuer = local.cluster_issuer

  accounts_pipeline_tokens = module.argocd_bootstrap.argocd_accounts_pipeline_tokens
  server_secretkey         = module.argocd_bootstrap.argocd_server_secretkey

  app_autosync = local.app_autosync

  admin_enabled = true
  exec_enabled  = true

  oidc = {
    name         = "OIDC"
    issuer       = var.oidc.issuer_url
    clientID     = var.oidc.client_id
    clientSecret = var.oidc.client_secret
    requestedIDTokenClaims = {
      groups = {
        essential = true
      }
    }
    requestedScopes = [
      "openid", "profile", "email"
    ]
  }

  rbac = {
    policy_csv = <<-EOT
      g, pipeline, role:admin
      g, devops-stack-admins, role:admin
    EOT
  }

  dependency_ids = {
    argocd                = module.argocd_bootstrap.id
    traefik               = module.traefik.id
    cert-manager          = module.cert-manager.id
    kube-prometheus-stack = module.kube-prometheus-stack.id
  }
}

module "metrics_server" {
  source = "git::https://github.com/camptocamp/devops-stack-module-application.git?ref=v2.0.1"
  # source = "../../devops-stack-module-application"

  name             = "metrics-server"
  argocd_namespace = module.argocd_bootstrap.argocd_namespace

  app_autosync = local.app_autosync

  source_repo            = "https://github.com/kubernetes-sigs/metrics-server.git"
  source_repo_path       = "charts/metrics-server"
  source_target_revision = "metrics-server-helm-chart-3.10.0"
  destination_namespace  = "kube-system"

  dependency_ids = {
    argocd = module.argocd.id
  }
}
