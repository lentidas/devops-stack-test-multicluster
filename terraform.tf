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
    exoscale = {
      source  = "exoscale/exoscale"
      version = "~> 0.51"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3"
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

### AWS provider configurations

# Default AWS provider (configured through the standard AWS environment variables in the secrets.yml).
# Used mainly for the S3 bucket where the Terraform state is stored.
provider "aws" {}

provider "aws" {
  alias = "control_plane"

  region     = "eu-west-1"
  access_key = var.control_plane_aws_iam_access_key
  secret_key = var.control_plane_aws_iam_secret_key
}

provider "aws" {
  alias = "worker_1"

  endpoints {
    s3 = "https://sos-${local.clusters.workers.worker_1.zone}.exo.io"
  }

  region = local.clusters.workers.worker_1.zone

  access_key = var.worker_1_exoscale_iam_access_key
  secret_key = var.worker_1_exoscale_iam_secret_key

  # Skip validations specific to AWS in order to use this provider for Exoscale services
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

provider "aws" {
  alias = "worker_2"

  endpoints {
    s3 = "https://sos-${local.clusters.workers.worker_2.zone}.exo.io"
  }

  region = local.clusters.workers.worker_2.zone

  access_key = var.worker_2_exoscale_iam_access_key
  secret_key = var.worker_2_exoscale_iam_secret_key

  # Skip validations specific to AWS in order to use this provider for Exoscale services
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
}

### Exoscale provider configurations

provider "exoscale" {
  alias = "worker_1"

  key    = var.worker_1_exoscale_iam_access_key
  secret = var.worker_1_exoscale_iam_secret_key
}

provider "exoscale" {
  alias = "worker_2"

  key    = var.worker_2_exoscale_iam_access_key
  secret = var.worker_2_exoscale_iam_secret_key
}

### Azure provider configurations

provider "azurerm" {
  alias = "worker_3"

  features {}

  tenant_id       = "fc621a41-14f1-4ca5-831e-15c0a062ec75"
  subscription_id = "f8d4a723-c049-4de2-9a1d-deb775365d57"
}

### Argo CD provider configuration

# No need to set an alias for the Argo CD provider, because there is only:
# One Argo CD to rule them all,
# One Argo CD to find them,
# One Argo CD to bring them all,
# and in the darkness bind them.
provider "argocd" {
  alias = "control_plane_1"

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

provider "argocd" {
  alias = "control_plane_2"

  auth_token                  = module.control_plane_2.argocd_auth_token
  port_forward_with_namespace = module.control_plane_2.argocd_namespace
  insecure                    = true
  plain_text                  = true

  kubernetes {
    host                   = module.control_plane_2.kubernetes_host
    cluster_ca_certificate = module.control_plane_2.kubernetes_cluster_ca_certificate
    token                  = module.control_plane_2.kubernetes_token
  }
}

### Kubernetes provider configurations

provider "kubernetes" {
  alias = "control_plane"

  host                   = module.control_plane.kubernetes_host
  cluster_ca_certificate = module.control_plane.kubernetes_cluster_ca_certificate
  token                  = module.control_plane.kubernetes_token
}

provider "kubernetes" {
  alias = "control_plane_2"

  host                   = module.control_plane_2.kubernetes_host
  cluster_ca_certificate = module.control_plane_2.kubernetes_cluster_ca_certificate
  token                  = module.control_plane_2.kubernetes_token
}

provider "kubernetes" {
  alias = "worker_1"

  host                   = module.worker_1.kubernetes_host
  client_certificate     = module.worker_1.kubernetes_client_certificate
  client_key             = module.worker_1.kubernetes_client_key
  cluster_ca_certificate = module.worker_1.kubernetes_cluster_ca_certificate
}

provider "kubernetes" {
  alias = "worker_2"

  host                   = module.worker_2.kubernetes_host
  client_certificate     = module.worker_2.kubernetes_client_certificate
  client_key             = module.worker_2.kubernetes_client_key
  cluster_ca_certificate = module.worker_2.kubernetes_cluster_ca_certificate
}

provider "kubernetes" {
  alias = "worker_3"

  host                   = local.clusters.workers.worker_3.kubernetes_host
  username               = local.clusters.workers.worker_3.kubernetes_username
  password               = local.clusters.workers.worker_3.kubernetes_password
  client_certificate     = local.clusters.workers.worker_3.kubernetes_client_certificate
  client_key             = local.clusters.workers.worker_3.kubernetes_client_key
  cluster_ca_certificate = local.clusters.workers.worker_3.kubernetes_cluster_ca_certificate
}

### Helm provider configurations

provider "helm" {
  alias = "control_plane"

  kubernetes {
    host                   = module.control_plane.kubernetes_host
    cluster_ca_certificate = module.control_plane.kubernetes_cluster_ca_certificate
    token                  = module.control_plane.kubernetes_token
  }
}

provider "helm" {
  alias = "control_plane_2"

  kubernetes {
    host                   = module.control_plane_2.kubernetes_host
    cluster_ca_certificate = module.control_plane_2.kubernetes_cluster_ca_certificate
    token                  = module.control_plane_2.kubernetes_token
  }
}

provider "helm" {
  alias = "worker_1"

  kubernetes {
    host                   = module.worker_1.kubernetes_host
    client_certificate     = module.worker_1.kubernetes_client_certificate
    client_key             = module.worker_1.kubernetes_client_key
    cluster_ca_certificate = module.worker_1.kubernetes_cluster_ca_certificate
  }
}

provider "helm" {
  alias = "worker_2"

  kubernetes {
    host                   = module.worker_2.kubernetes_host
    client_certificate     = module.worker_2.kubernetes_client_certificate
    client_key             = module.worker_2.kubernetes_client_key
    cluster_ca_certificate = module.worker_2.kubernetes_cluster_ca_certificate
  }
}

provider "helm" {
  alias = "worker_3"

  kubernetes {
    host                   = local.clusters.workers.worker_3.kubernetes_host
    username               = local.clusters.workers.worker_3.kubernetes_username
    password               = local.clusters.workers.worker_3.kubernetes_password
    client_certificate     = local.clusters.workers.worker_3.kubernetes_client_certificate
    client_key             = local.clusters.workers.worker_3.kubernetes_client_key
    cluster_ca_certificate = local.clusters.workers.worker_3.kubernetes_cluster_ca_certificate
  }
}
