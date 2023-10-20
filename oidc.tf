locals {
  user_map = {
    gheleno = {
      username   = "gheleno"
      email      = "goncalo.heleno@camptocamp.com"
      first_name = "Gonçalo"
      last_name  = "Heleno"
    },
    # jbarascut = {
    #   username   = "jbarascut"
    #   email      = "jeremy.barascut@camptocamp.com"
    #   first_name = "Jérémy"
    #   last_name  = "Barascut"
    # },
    # fsismondi = {
    #   username   = "fsismondi"
    #   email      = "federico.sismondi@camptocamp.com"
    #   first_name = "Federico"
    #   last_name  = "Sismondi"
    # }
  }

  control_plane_callback_urls = concat([
    format("https://argocd.apps.%s.%s/auth/callback", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain),
    format("https://grafana.apps.%s.%s/login/generic_oauth", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain),
    format("https://prometheus.apps.%s.%s/oauth2/callback", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain),
    format("https://thanos-query.apps.%s.%s/oauth2/callback", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain),
    format("https://thanos-bucketweb.apps.%s.%s/oauth2/callback", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain),
    format("https://alertmanager.apps.%s.%s/oauth2/callback", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain),
    ], [
    format("https://argocd.apps.%s.%s/auth/callback", local.clusters.control_plane_2.cluster_name, local.clusters.control_plane_2.base_domain),
    format("https://grafana.apps.%s.%s/login/generic_oauth", local.clusters.control_plane_2.cluster_name, local.clusters.control_plane_2.base_domain),
    format("https://prometheus.apps.%s.%s/oauth2/callback", local.clusters.control_plane_2.cluster_name, local.clusters.control_plane_2.base_domain),
    format("https://thanos-query.apps.%s.%s/oauth2/callback", local.clusters.control_plane_2.cluster_name, local.clusters.control_plane_2.base_domain),
    format("https://thanos-bucketweb.apps.%s.%s/oauth2/callback", local.clusters.control_plane_2.cluster_name, local.clusters.control_plane_2.base_domain),
    format("https://alertmanager.apps.%s.%s/oauth2/callback", local.clusters.control_plane_2.cluster_name, local.clusters.control_plane_2.base_domain),

  ])

  # TODO Maybe add Thanos callback URLs here?
  worker_callback_urls = flatten([for item in local.clusters.workers : [
    format("https://longhorn.apps.%s.%s/oauth2/callback", item.cluster_name, item.base_domain),
    format("https://grafana.apps.%s.%s/login/generic_oauth", item.cluster_name, item.base_domain),
    format("https://prometheus.apps.%s.%s/oauth2/callback", item.cluster_name, item.base_domain),
    format("https://alertmanager.apps.%s.%s/oauth2/callback", item.cluster_name, item.base_domain),
    ]
  ])

  # The distinct() here is only to ensure there are no repeated URLs, although there is little risk of that happening 
  # since we hardcode the URLs above. 
  callback_urls = distinct(concat(local.control_plane_callback_urls, local.worker_callback_urls))

  oidc_config = {
    issuer_url              = format("https://cognito-idp.%s.amazonaws.com/%s", data.aws_region.cognito_pool_region.name, resource.aws_cognito_user_pool.devops_stack_user_pool.id)
    oauth_url               = format("https://%s.auth.%s.amazoncognito.com/oauth2/authorize", resource.aws_cognito_user_pool_domain.devops_stack_user_pool_domain.domain, data.aws_region.cognito_pool_region.name)
    token_url               = format("https://%s.auth.%s.amazoncognito.com/oauth2/token", resource.aws_cognito_user_pool_domain.devops_stack_user_pool_domain.domain, data.aws_region.cognito_pool_region.name)
    api_url                 = format("https://%s.auth.%s.amazoncognito.com/oauth2/userInfo", resource.aws_cognito_user_pool_domain.devops_stack_user_pool_domain.domain, data.aws_region.cognito_pool_region.name)
    client_id               = resource.aws_cognito_user_pool_client.client.id
    client_secret           = resource.aws_cognito_user_pool_client.client.client_secret
    oauth2_proxy_extra_args = []
  }
}

resource "aws_cognito_user_pool" "devops_stack_user_pool" {
  name = "${local.clusters.control_plane.cluster_name}-pool"

  admin_create_user_config {
    allow_admin_create_user_only = true
  }
}

resource "aws_cognito_user_pool_domain" "devops_stack_user_pool_domain" {
  domain       = local.clusters.control_plane.cluster_name
  user_pool_id = resource.aws_cognito_user_pool.devops_stack_user_pool.id
}

resource "aws_cognito_user_group" "devops_stack_admin_group" {
  name         = "devops-stack-admins"
  user_pool_id = resource.aws_cognito_user_pool.devops_stack_user_pool.id
  description  = "Users with administrator access to the applications on all the clusters controlled by ${local.clusters.control_plane.cluster_name}."
}

resource "aws_cognito_user" "devops_stack_users" {
  for_each = local.user_map

  user_pool_id = resource.aws_cognito_user_pool.devops_stack_user_pool.id

  desired_delivery_mediums = ["EMAIL"]

  username = each.value.username
  attributes = {
    given_name     = each.value.first_name
    family_name    = each.value.last_name
    email          = each.value.email
    email_verified = true
  }
}

resource "aws_cognito_user_in_group" "devops_stack_users" {
  for_each = local.user_map

  user_pool_id = resource.aws_cognito_user_pool.devops_stack_user_pool.id
  group_name   = resource.aws_cognito_user_group.devops_stack_admin_group.name
  username     = resource.aws_cognito_user.devops_stack_users[each.key].username
}

resource "aws_cognito_user_pool_client" "client" {
  name = format("client-%s", local.clusters.control_plane.cluster_name)

  user_pool_id = resource.aws_cognito_user_pool.devops_stack_user_pool.id

  allowed_oauth_flows = [
    "code",
  ]

  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile",
  ]

  supported_identity_providers = [
    "COGNITO",
  ]

  generate_secret = true

  allowed_oauth_flows_user_pool_client = true

  callback_urls = local.callback_urls
}

data "aws_region" "cognito_pool_region" {
  provider = aws.control_plane
}
