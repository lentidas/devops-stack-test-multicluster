locals {
  app_autosync = var.enable_app_autosync ? { allow_empty = false, prune = true, self_heal = true } : {}

  # Automatic subnets IP range calculation, splitting the vpc_cidr into 6 subnets.
  private_subnets_cidr = cidrsubnet(var.vpc_cidr, 1, 0)
  public_subnets_cidr  = cidrsubnet(var.vpc_cidr, 1, 1)
  private_subnets      = cidrsubnets(local.private_subnets_cidr, 2, 2, 2)
  public_subnets       = cidrsubnets(local.public_subnets_cidr, 2, 2, 2)
}
