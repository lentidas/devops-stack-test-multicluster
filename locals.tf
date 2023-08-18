locals {
  control_plane = {
    kubernetes_version     = "1.27"
    cluster_name           = "gh-control-plane"
    base_domain            = "is-sandbox.camptocamp.com"
    cluster_issuer         = "letsencrypt-staging"
    enable_service_monitor = false # Can be enabled after the first bootstrap.
    enable_app_autosync    = true
    vpc_cidr               = "10.56.0.0/16"
  }

  worker_1 = {
    kubernetes_version       = "1.27.4"
    cluster_name             = "gh-worker-1"
    zone                     = "ch-gva-2"
    service_level            = "starter"
    base_domain              = "is-sandbox-exo.camptocamp.com"
    activate_wildcard_record = true
    cluster_issuer           = "letsencrypt-staging"
    enable_service_monitor   = false # Can be enabled after the first bootstrap.
    enable_app_autosync      = true
  }
}
