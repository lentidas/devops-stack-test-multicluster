variable "control_plane_aws_iam_access_key" {
  description = "AWS IAM key to use for the control plane cluster."
  type        = string
  sensitive   = true
}

variable "control_plane_aws_iam_secret_key" {
  description = "AWS IAM secret key to use for the control plane cluster."
  type        = string
  sensitive   = true
}

variable "worker_1_exoscale_iam_access_key" {
  description = "Exoscale IAM key to use for the worker 1 cluster."
  type        = string
  sensitive   = true
}

variable "worker_1_exoscale_iam_secret_key" {
  description = "Exoscale IAM secret key to use for the worker 1 cluster."
  type        = string
  sensitive   = true
}

variable "worker_2_exoscale_iam_access_key" {
  description = "Exoscale IAM key to use for the worker 2 cluster."
  type        = string
  sensitive   = true
}

variable "worker_2_exoscale_iam_secret_key" {
  description = "Exoscale IAM secret key to use for the worker 2 cluster."
  type        = string
  sensitive   = true
}

variable "worker_3_kubernetes_password" {
  type      = string
  sensitive = true
}

variable "worker_3_kubernetes_client_certificate" {
  type      = string
  sensitive = true
}

variable "worker_3_kubernetes_client_key" {
  type      = string
  sensitive = true
}

variable "worker_3_kubernetes_cluster_ca_certificate" {
  type      = string
  sensitive = true
}
