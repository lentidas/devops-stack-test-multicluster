module "control_plane" {
  source = "./clusters/control_plane"

  providers = {
    aws        = aws.control_plane
    kubernetes = kubernetes.control_plane
    helm       = helm.control_plane
    argocd     = argocd
  }

  oidc = local.oidc_config
}
