# TODO Right now the Argo CD is using the administrator cluster role. Consider creating a dedicated role for Argo CD.
resource "argocd_cluster" "control_plane_1_worker_1" {
  provider = argocd.control_plane_1

  name   = local.clusters.workers.worker_1.cluster_name
  server = module.worker_1.kubernetes_host

  config {
    tls_client_config {
      ca_data   = module.worker_1.kubernetes_cluster_ca_certificate
      cert_data = module.worker_1.kubernetes_client_certificate
      key_data  = module.worker_1.kubernetes_client_key
      insecure  = false # This is the default value, but it is set here explicitly for clarity.
    }
  }
  metadata {
    labels = {
      "cluster-type" = "worker",
      "cloud"        = "exoscale",
      "region"       = local.clusters.workers.worker_1.zone,
    }
  }
}

resource "argocd_cluster" "control_plane_1_worker_2" {
  provider = argocd.control_plane_1


  name   = local.clusters.workers.worker_2.cluster_name
  server = module.worker_2.kubernetes_host

  config {
    tls_client_config {
      ca_data   = module.worker_2.kubernetes_cluster_ca_certificate
      cert_data = module.worker_2.kubernetes_client_certificate
      key_data  = module.worker_2.kubernetes_client_key
      insecure  = false # This is the default value, but it is set here explicitly for clarity.
    }
  }
  metadata {
    labels = {
      "cluster-type" = "worker",
      "cloud"        = "exoscale",
      "region"       = local.clusters.workers.worker_2.zone,
    }
  }
}

resource "argocd_cluster" "control_plane_2_worker_1" {
  provider = argocd.control_plane_2


  name   = local.clusters.workers.worker_1.cluster_name
  server = module.worker_1.kubernetes_host

  config {
    tls_client_config {
      ca_data   = module.worker_1.kubernetes_cluster_ca_certificate
      cert_data = module.worker_1.kubernetes_client_certificate
      key_data  = module.worker_1.kubernetes_client_key
      insecure  = false # This is the default value, but it is set here explicitly for clarity.
    }
  }
  metadata {
    labels = {
      "cluster-type" = "worker",
      "cloud"        = "exoscale",
      "region"       = local.clusters.workers.worker_1.zone,
    }
  }
}

resource "argocd_cluster" "control_plane_2_worker_2" {
  provider = argocd.control_plane_2

  name   = local.clusters.workers.worker_2.cluster_name
  server = module.worker_2.kubernetes_host

  config {
    tls_client_config {
      ca_data   = module.worker_2.kubernetes_cluster_ca_certificate
      cert_data = module.worker_2.kubernetes_client_certificate
      key_data  = module.worker_2.kubernetes_client_key
      insecure  = false # This is the default value, but it is set here explicitly for clarity.
    }
  }
  metadata {
    labels = {
      "cluster-type" = "worker",
      "cloud"        = "exoscale",
      "region"       = local.clusters.workers.worker_2.zone,
    }
  }
}
