output "devops_stack_admins" {
  description = "Map containing the usernames and e-mails of the created users on the control plane pool."
  value       = { for key, value in local.user_map : value.username => value.email }
  sensitive   = true
}

output "ingress_domain" {
  description = "List containing the domain to use for accessing the applications on each cluster."
  value       = [
    module.control_plane.ingress_domain,
    module.worker_1.ingress_domain,
  ]
}
