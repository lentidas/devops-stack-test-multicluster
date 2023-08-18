output "cluster_name" {
  description = "Name of the worker cluster."
  value       = module.eks.cluster_name
}

output "base_domain" {
  description = "Base domain of the worker cluster."
  value       = module.eks.base_domain
}

output "ingress_domain" {
  description = "Domain to use for accessing the applications in the worker cluster."
  value       = "${module.eks.cluster_name}.${module.eks.base_domain}"
}

output "kubernetes_host" {
  description = "Kubernetes API server endpoint of the worker cluster."
  value       = module.eks.kubernetes_host
}

output "kubernetes_cluster_ca_certificate" {
  description = "Kubernetes API server CA certificate of the worker cluster."
  value       = base64decode(local.kubeconfig.clusters.0.cluster.certificate-authority-data)
  sensitive   = true
}

output "kubernetes_client_key" {
  description = "Kubernetes API server client key of the worker cluster."
  value       = base64decode(local.kubeconfig.users.0.user.client-key-data)
  sensitive   = true
}

output "kubernetes_client_certificate" {
  description = "Kubernetes API server client certificate of the worker cluster."
  value       = base64decode(local.kubeconfig.users.0.user.client-certificate-data)
  sensitive   = true
}
