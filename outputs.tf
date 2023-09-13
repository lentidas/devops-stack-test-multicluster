output "devops_stack_admins" {
  description = "Map containing the usernames and e-mails of the created users on the control plane pool."
  value       = { for key, value in local.user_map : value.username => value.email }
}

output "ingress_domains" {
  description = "List containing the domain to use for accessing the applications on each cluster."
  value = concat(
    [format("%s.%s", local.clusters.control_plane.cluster_name, local.clusters.control_plane.base_domain)],
    [for item in local.clusters.workers : format("%s.%s", item.cluster_name, item.base_domain)]
  )
}
