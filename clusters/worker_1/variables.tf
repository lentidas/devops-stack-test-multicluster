variable "kubernetes_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "zone" {
  type = string
}

variable "service_level" {
  type    = string
  default = "starter"
}

variable "base_domain" {
  type = string
}

variable "activate_wildcard_record" {
  type    = bool
  default = true
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

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}
