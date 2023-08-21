terraform {
  required_providers {
    exoscale = {
      source  = "exoscale/exoscale"
      version = ">= 0.51"
    }
    aws = { # Needed to store the state file in S3 and to create S3 buckets (provider configuration bellow)
      source  = "hashicorp/aws"
      version = ">= 5"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2"
    }
    argocd = {
      source  = "oboukili/argocd"
      version = ">= 6"
    }
  }
}
