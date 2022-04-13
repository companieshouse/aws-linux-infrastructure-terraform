# ------------------------------------------------------------------------------
# Vault Variables
# ------------------------------------------------------------------------------
variable "vault_username" {
  type        = string
  description = "Username for connecting to Vault - usually supplied through TF_VARS"
}

variable "vault_password" {
  type        = string
  description = "Password for connecting to Vault - usually supplied through TF_VARS"
}

# ------------------------------------------------------------------------------
# AWS Variables
# ------------------------------------------------------------------------------
variable "aws_region" {
  type        = string
  description = "The AWS region in which resources will be administered"
}

variable "aws_profile" {
  type        = string
  description = "The AWS profile to use"
}

variable "aws_account" {
  type        = string
  description = "The name of the AWS Account in which resources will be administered"
}

# ------------------------------------------------------------------------------
# AWS Variables - Shorthand
# ------------------------------------------------------------------------------

variable "account" {
  type        = string
  description = "Short version of the name of the AWS Account in which resources will be administered"
}

variable "region" {
  type        = string
  description = "Short version of the name of the AWS region in which resources will be administered"
}

# ------------------------------------------------------------------------------
# Environment Variables
# ------------------------------------------------------------------------------
variable "environment" {
  type        = string
  description = "The name of the environment"
}

variable "category" {
  type        = string
  description = "The category of services in this repo"
  default     = "linux-workloads"
}

variable "ServiceTeam" {
  type        = string
  description = "The service team that supports the application"
  default     = "linux-support"
}

variable "default_log_group_retention_in_days" {
  type        = number
  default     = 30
  description = "Total days to retain logs in CloudWatch log group if not specified for specific logs"
}

# ------------------------------------------------------------------------------
# EC2 Variables
# ------------------------------------------------------------------------------

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it."
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# EBS Variables
# ------------------------------------------------------------------------------

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "delete_on_termination" {
  type        = string
  default     = "false"
  description = "EBS delete on termination"
}

variable "ebs_encrypted" {
  type        = string
  default     = "true"
  description = "EBS encrypted"
}

variable "volume_type" {
  type        = string
  default     = "gp3"
  description = "EBS volume type"
}

# ------------------------------------------------------------------------------
# Bulk Gateway Server Variables
# ------------------------------------------------------------------------------

variable "bulk_gateway_application" {
  description = "EC2 application description"
  type        = string
}

variable "bulk_gateway_ec2_instance_type" {
  type        = string
  description = "The size of the EC2 instance"
}

variable "bulk_gateway_ami" {
  type        = string
  description = "Name of the Bulk Gateway AMI"
}

variable "bulk_gateway_cw_logs" {
  type        = map(any)
  description = "Map of log file information; used to create log groups, IAM permissions and passed to the application to configure remote logging"
  default     = {}
}

variable "bulk_gateway_bck_retention_days" {
  type        = string
  description = "The number of retention days after which backups will be deleted"
}

variable "bulk_gateway_instance_count" {
  type        = string
  description = "The number of ec2 instances to create"
}

variable "cloudwatch_namespace" {
  type        = string
  default     = null
  description = "A custom namespace to define for CloudWatch custom metrics such as CPU"
}