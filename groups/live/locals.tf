locals {

  kms_keys_data               = data.vault_generic_secret.kms_keys.data
  security_kms_keys_data      = data.vault_generic_secret.security_kms_keys.data
  ssm_kms_key_id              = local.security_kms_keys_data["session-manager-kms-key-arn"]
  security_s3_data            = data.vault_generic_secret.security_s3_buckets.data
  session_manager_bucket_name = local.security_s3_data["session-manager-bucket-name"]

  default_tags = {
    Terraform   = "true"
    Application = upper(var.category)
    Region      = var.aws_region
    Account     = var.aws_account
  }

  # ------------------------------------------------------------------------------
  # jfil Server locals
  # ------------------------------------------------------------------------------

  #For each log map passed, add an extra kv for the log group name
  jfil_cw_logs    = { for log, map in var.jfil_cw_logs : log => merge(map, { "log_group_name" = "${var.category}-${log}" }) }
  jfil_log_groups = compact([for log, map in local.jfil_cw_logs : lookup(map, "log_group_name", "")])

  # ------------------------------------------------------------------------------
  # jfil Server Security Group Variables
  # ------------------------------------------------------------------------------

  # TODO: any SG ingress required??
  #  jfil_80_cidr_block = [
  #    "172.18.0.0/16",
  #    "172.19.0.0/17",
  #    "172.23.0.0/16"
  #  ]


}