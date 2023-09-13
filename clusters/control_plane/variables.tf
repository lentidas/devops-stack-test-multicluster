variable "kubernetes_version" {
  type = string
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

variable "vpc_cidr" {
  type = string
}

variable "cluster_names" {
  type    = list(string)
  default = []
}

variable "project_extra_source_repos" {
  type    = list(string)
  default = []
}

variable "project_extra_allowed_namespaces" {
  type    = list(string)
  default = []
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
