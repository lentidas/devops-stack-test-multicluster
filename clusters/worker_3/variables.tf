variable "kubernetes_host" {
  type      = string
  sensitive = false
}

variable "kubernetes_username" {
  type      = string
  sensitive = false
}

variable "kubernetes_password" {
  type      = string
  sensitive = true
}

variable "kubernetes_client_certificate" {
  type      = string
  sensitive = true
}

variable "kubernetes_client_key" {
  type      = string
  sensitive = true
}

variable "kubernetes_cluster_ca_certificate" {
  type      = string
  sensitive = true
}

variable "cluster_name" {
  type = string
}

variable "base_domain" {
  type = string
}

variable "cluster_issuer" {
  type    = string
  default = "letsencrypt-staging"
}

variable "enable_service_monitor" {
  type    = bool
  default = false
}

variable "enable_app_autosync" {
  type    = bool
  default = true
}

variable "argocd_project" {
  type    = string
  default = null
}

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}

variable "oidc" {
  type = object({
    issuer_url              = string
    oauth_url               = string
    token_url               = string
    api_url                 = string
    client_id               = string
    client_secret           = string
    oauth2_proxy_extra_args = list(string)
  })
}
