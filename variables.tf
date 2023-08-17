variable "control_plane_aws_iam_access_key" {
  description = "The AWS IAM key to use for the control plane cluster."
  type        = string
  sensitive   = true
}

variable "control_plane_aws_iam_secret_key" {
  description = "The AWS IAM secret key to use for the control plane cluster."
  type        = string
  sensitive   = true
}
