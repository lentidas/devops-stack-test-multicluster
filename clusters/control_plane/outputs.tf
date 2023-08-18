output "kubernetes_host" {
  value = module.eks.kubernetes_host
}

output "kubernetes_cluster_ca_certificate" {
  value     = module.eks.kubernetes_cluster_ca_certificate
  sensitive = true
}

output "kubernetes_token" {
  value     = module.eks.kubernetes_token
  sensitive = true
}

output "argocd_auth_token" {
  value     = module.argocd_bootstrap.argocd_auth_token
  sensitive = true
}

output "argocd_namespace" {
  value = module.argocd_bootstrap.argocd_namespace
}
