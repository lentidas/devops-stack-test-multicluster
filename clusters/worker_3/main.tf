data "azurerm_resource_group" "default" {
  name = "default"
}

data "azurerm_kubernetes_cluster" "blue" {
  name                = var.cluster_name
  resource_group_name = "blue-rg"
}

resource "argocd_cluster" "this" {
  name   = local.argocd_cluster_name
  server = var.kubernetes_host

  config {
    username = var.kubernetes_username
    password = var.kubernetes_password
    tls_client_config {
      ca_data   = var.kubernetes_cluster_ca_certificate
      cert_data = var.kubernetes_client_certificate
      key_data  = var.kubernetes_client_key
      insecure  = false # This is the default value, but it is set here explicitly for clarity.
    }
  }
  metadata {
    labels = {
      "cluster-type" = "worker",
      "cloud"        = "azure",
      "region"       = "france-central",
    }
  }
}

module "traefik" {
  # source = "git::https://github.com/camptocamp/devops-stack-module-traefik.git//aks?ref=v2.0.1"
  source = "../../../../devops-stack-module-traefik/aks"

  cluster_name        = var.cluster_name
  base_domain         = var.base_domain
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = local.argocd_cluster_name

  dns_zone_resource_group_name = data.azurerm_resource_group.default.name
  node_resource_group_name     = "blue-rg"

  app_autosync           = local.app_autosync
  enable_service_monitor = var.enable_service_monitor

  dependency_ids = {}

  depends_on = [argocd_cluster.this]
}

module "cert-manager" {
  # source = "git::https://github.com/camptocamp/devops-stack-module-cert-manager.git//aks?ref=v5.1.0"
  source = "../../../../devops-stack-module-cert-manager/aks"

  cluster_name        = var.cluster_name
  base_domain         = var.base_domain
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = local.argocd_cluster_name

  dns_zone_resource_group_name = data.azurerm_resource_group.default.name
  node_resource_group_name     = "blue-rg"
  cluster_oidc_issuer_url      = data.azurerm_kubernetes_cluster.blue.oidc_issuer_url

  app_autosync           = local.app_autosync
  enable_service_monitor = var.enable_service_monitor

  dependency_ids = {}

  depends_on = [argocd_cluster.this]
}


module "loki-stack" {
  # source = "git::https://github.com/camptocamp/devops-stack-module-loki-stack.git//aks?ref=v4.0.2"
  source = "../../../../devops-stack-module-loki-stack/aks"

  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = local.argocd_cluster_name

  app_autosync = local.app_autosync

  logs_storage = {
    container           = resource.azurerm_storage_container.storage["loki"].name
    storage_account     = resource.azurerm_storage_account.storage["loki"].name
    storage_account_key = resource.azurerm_storage_account.storage["loki"].primary_access_key
  }

  dependency_ids = {}

  depends_on = [argocd_cluster.this]
}

module "kube-prometheus-stack" {
  # source = "git::https://github.com/camptocamp/devops-stack-module-kube-prometheus-stack.git//aks?ref=v6.1.1"
  source = "../../../../devops-stack-module-kube-prometheus-stack/aks"

  cluster_name        = var.cluster_name
  base_domain         = var.base_domain
  cluster_issuer      = var.cluster_issuer
  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  destination_cluster = local.argocd_cluster_name

  app_autosync = local.app_autosync

  prometheus = {
    oidc = var.oidc
  }
  alertmanager = {
    oidc = var.oidc
  }
  grafana = {
    oidc = var.oidc
  }

  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    loki-stack   = module.loki-stack.id
  }

  depends_on = [argocd_cluster.this]
}
