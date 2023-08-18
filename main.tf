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
