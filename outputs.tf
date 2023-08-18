output "devops_stack_admins" {
  description = "Map containing the usernames and e-mails of the created users on the control plane pool."
  value       = { for key, value in local.user_map : value.username => value.email }
}

output "ingress_domains" {
  description = "List containing the domain to use for accessing the applications on each cluster."
  value = [
    format("%s.%s", local.control_plane.cluster_name, local.control_plane.base_domain),
    format("%s.%s", local.worker_1.cluster_name, local.worker_1.base_domain),
  ]
}
