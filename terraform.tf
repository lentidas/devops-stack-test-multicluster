terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "camptocamp-aws-is-sandbox-terraform-state"
    key            = "e63d725c-0ea4-4f87-9bc5-693e4946492a"
    region         = "eu-west-1"
    dynamodb_table = "camptocamp-aws-is-sandbox-terraform-statelock"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = "~> 6"
    }
  }
}

# Default AWS provider (configured through the standard AWS environment variables in the secrets.yml).
provider "aws" {}

provider "aws" {
  alias = "control_plane"

  region     = "eu-west-1"
  access_key = var.control_plane_aws_iam_access_key
  secret_key = var.control_plane_aws_iam_secret_key
}

provider "kubernetes" {
  alias = "control_plane"

  host                   = module.control_plane.kubernetes_host
  cluster_ca_certificate = module.control_plane.kubernetes_cluster_ca_certificate
  token                  = module.control_plane.kubernetes_token
}

provider "helm" {
  alias = "control_plane"

  kubernetes {
    host                   = module.control_plane.kubernetes_host
    cluster_ca_certificate = module.control_plane.kubernetes_cluster_ca_certificate
    token                  = module.control_plane.kubernetes_token
  }
}

# No need to set an alias for the Argo CD provider, because there is only:
# One Argo CD to rule them all,
# One Argo CD to find them,
# One Argo CD to bring them all,
# and in the darkness bind them.
provider "argocd" {
  auth_token                  = module.control_plane.argocd_auth_token
  port_forward_with_namespace = module.control_plane.argocd_namespace
  insecure                    = true
  plain_text                  = true

  kubernetes {
    host                   = module.control_plane.kubernetes_host
    cluster_ca_certificate = module.control_plane.kubernetes_cluster_ca_certificate
    token                  = module.control_plane.kubernetes_token
  }
}
