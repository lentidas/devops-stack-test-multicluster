output "cluster_name" {
  description = "The name of the control plane cluster."
  value       = module.eks.cluster_name
}

output "base_domain" {
  description = "The base domain of the control plane cluster."
  value       = module.eks.base_domain
}

output "ingress_domain" {
  description = "The domain to use for accessing the applications in the control plane cluster."
  value       = "${module.eks.cluster_name}.${module.eks.base_domain}"
}

output "kubernetes_host" {
  description = "The Kubernetes API server endpoint of the control plane cluster."
  value       = module.eks.kubernetes_host
}

output "kubernetes_cluster_ca_certificate" {
  description = "The Kubernetes API server CA certificate of the control plane cluster."
  value       = module.eks.kubernetes_cluster_ca_certificate
  sensitive   = true
}

output "kubernetes_token" {
  description = "The Kubernetes API server token of the control plane cluster."
  value       = module.eks.kubernetes_token
  sensitive   = true
}

output "argocd_auth_token" {
  description = "The Argo CD authentication token of the control plane Argo CD."
  value       = module.argocd_bootstrap.argocd_auth_token
  sensitive   = true
}

output "argocd_namespace" {
  description = "The Argo CD namespace of the control plane Argo CD."
  value       = module.argocd_bootstrap.argocd_namespace
}
