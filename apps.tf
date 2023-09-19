# module "helloworld_apps" {
#   # source = "git::https://github.com/camptocamp/devops-stack-module-applicationset.git?ref=v2.0.1"
#   source = "../../devops-stack-module-applicationset"

#   depends_on = [module.worker_1]

#   name                      = "helloworld-apps"
#   argocd_namespace          = module.control_plane.argocd_namespace
#   project_dest_cluster_name = local.worker_1.cluster_name
#   # project_dest_cluster_address = module.worker_1.kubernetes_host
#   project_dest_namespace = "*"
#   project_source_repo    = "https://github.com/camptocamp/devops-stack-helloworld-templates.git

#   generators = [
#     {
#       git = {
#         repoURL  = "https://github.com/camptocamp/devops-stack-helloworld-templates.git"
#         revision = "main"

#         directories = [
#           {
#             path = "apps/*"
#           }
#         ]
#       }
#     }
#   ]
#   template = {
#     metadata = {
#       name = "{{path.basename}}"
#     }

#     spec = {
#       project = "helloworld-apps"

#       source = {
#         repoURL        = "https://github.com/camptocamp/devops-stack-helloworld-templates.git"
#         targetRevision = "main"
#         path           = "{{path}}"

#         helm = {
#           valueFiles = []
#           # The following value defines this global variables that will be available to all apps in apps/*
#           # These are needed to generate the ingresses containing the name and base domain of the cluster.
#           values = <<-EOT
#             cluster:
#               name: "${local.worker_1.cluster_name}"
#               domain: "${local.worker_1.base_domain}"
#               issuer: "${local.worker_1.cluster_issuer}"
#             apps:
#               traefik_dashboard: false
#               grafana: true
#               prometheus: true
#               thanos: true
#               alertmanager: true
#           EOT
#         }
#       }

#       destination = {
#         name = local.worker_1.cluster_name
#         # server    = module.worker_1.kubernetes_host
#         namespace = "{{path.basename}}"
#       }

#       syncPolicy = {
#         automated = {
#           allowEmpty = false
#           selfHeal   = true
#           prune      = true
#         }
#         syncOptions = [
#           "CreateNamespace=true"
#         ]
#       }
#     }
#   }
# }

# module "nginx_test" {
#   source = "../../devops-stack-module-application"

#   depends_on = [module.control_plane]

#   name             = "nginx-test"
#   argocd_namespace = module.control_plane.argocd_namespace

#   source_repo            = "https://github.com/lentidas/devops-stack-private-chart.git"
#   source_repo_path       = "apps/nginx"
#   source_target_revision = "main"

#   helm_values = [{
#     cluster = {
#       name   = local.control_plane.cluster_name
#       domain = local.control_plane.base_domain
#     }
#   }]

#   source_credentials_https = {
#     username = "lentidas"
#     password = "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"
#     # https_insecure = false
#   }
# }
