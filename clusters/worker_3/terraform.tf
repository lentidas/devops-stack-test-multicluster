terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3"
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
