terraform {
  required_providers {
    aws = {
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
