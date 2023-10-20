module "helloworld_apps" {
  # source = "git::https://github.com/camptocamp/devops-stack-module-applicationset.git?ref=v2.0.1"
  source = "../../../../devops-stack-module-applicationset"

  dependency_ids = {
    "traefik"               = module.traefik.id
    "cert-manager"          = module.cert-manager.id
    "loki-stack"            = module.loki-stack.id
    "kube-prometheus-stack" = module.kube-prometheus-stack.id
  }

  name                      = "helloworld-apps"
  argocd_namespace          = var.argocd_namespace
  project_dest_cluster_name = local.argocd_cluster_name
  project_dest_namespace    = "*"
  project_source_repo       = "https://github.com/camptocamp/devops-stack-helloworld-templates.git"

  generators = [
    {
      git = {
        repoURL  = "https://github.com/camptocamp/devops-stack-helloworld-templates.git"
        revision = "main"

        directories = [
          {
            path = "apps/*"
          }
        ]
      }
    }
  ]
  template = {
    metadata = {
      name = "{{path.basename}}"
    }

    spec = {
      project = "helloworld-apps"

      source = {
        repoURL        = "https://github.com/camptocamp/devops-stack-helloworld-templates.git"
        targetRevision = "main"
        path           = "{{path}}"

        helm = {
          valueFiles = []
          # The following value defines this global variables that will be available to all apps in apps/*
          # These are needed to generate the ingresses containing the name and base domain of the cluster.
          values = <<-EOT
            cluster:
              name: "${var.cluster_name}"
              domain: "${var.base_domain}"
              issuer: "${var.cluster_issuer}"
            apps:
              traefik_dashboard: false
              grafana: true
              prometheus: true
              thanos: true
              alertmanager: true
          EOT
        }
      }

      destination = {
        name      = local.argocd_cluster_name
        namespace = "{{path.basename}}"
      }

      syncPolicy = {
        automated = {
          allowEmpty = false
          selfHeal   = true
          prune      = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
}
