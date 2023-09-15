output "kubernetes_host" {
  value = module.sks.kubernetes_host
}

output "kubernetes_cluster_ca_certificate" {
  value     = module.sks.kubernetes_cluster_ca_certificate
  sensitive = true
}

output "kubernetes_client_key" {
  value     = module.sks.kubernetes_client_key
  sensitive = true
}

output "kubernetes_client_certificate" {
  value     = module.sks.kubernetes_client_certificate
  sensitive = true
}
