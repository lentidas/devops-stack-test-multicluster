module "helloworld_apps_worker_1" {
  source = "git::https://github.com/camptocamp/devops-stack-module-applicationset.git?ref=v2.1.1"
  # source = "../../devops-stack-module-applicationset"

  providers = {
    argocd = argocd
  }

  depends_on = [module.worker_1]

  name                      = "helloworld-apps"
  argocd_namespace          = module.control_plane.argocd_namespace
  project_dest_cluster_name = local.clusters.workers.worker_1.cluster_name
  project_source_repo       = "https://github.com/camptocamp/devops-stack-helloworld-templates.git"

  app_autosync = {
    allow_empty = false
    prune       = true
    self_heal   = true
  }

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
              name: "${local.clusters.workers.worker_1.cluster_name}"
              domain: "${local.clusters.workers.worker_1.base_domain}"
              issuer: "${local.clusters.workers.worker_1.cluster_issuer}"
            apps:
              longhorn: true
              grafana: true
              prometheus: true
              thanos: true
          EOT
        }
      }

      destination = {
        name      = local.clusters.workers.worker_1.cluster_name
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
