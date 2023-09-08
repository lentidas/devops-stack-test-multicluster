locals {
  kubernetes_version       = "1.27.4"
  cluster_name             = "gh-worker-1" # Must be unique for each DevOps Stack deployment in a single account.
  zone                     = "ch-gva-2"
  service_level            = "starter"
  base_domain              = "is-sandbox-exo.camptocamp.com"
  activate_wildcard_record = true
  cluster_issuer           = "letsencrypt-staging"
  enable_service_monitor   = false # Can be enabled after the first bootstrap
  app_autosync             = true ? { allow_empty = false, prune = true, self_heal = true } : {}
}