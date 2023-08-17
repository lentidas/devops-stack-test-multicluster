variable "oidc" {
  description = "OIDC configuration as required by the DevOps Stack modules."
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
