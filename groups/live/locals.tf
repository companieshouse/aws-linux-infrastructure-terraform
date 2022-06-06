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
  jfil_cw_logs    = { for log, map in var.jfil_cw_logs : log => merge(map, { "log_group_name" = "${var.category}-${var.jfil_ec2_name}-${log}" }) }
  jfil_log_groups = compact([for log, map in local.jfil_cw_logs : lookup(map, "log_group_name", "")])

  # ------------------------------------------------------------------------------
  # Bulk Gateway Server locals
  # ------------------------------------------------------------------------------

  bulk_gateway_ec2_data    = data.vault_generic_secret.bulk_gateway_ec2_data.data
  bulk_gateway_shares_data = data.vault_generic_secret.bulk_gateway_shares_data.data
  bulk_gateway_github_deploy_key_data = data.vault_generic_secret.bulk_gateway_github_deploy_key_data.data
  bulk_gateway_e5_ssh_key_data = data.vault_generic_secret.bulk_gateway_e5_ssh_key_data.data
  bulk_gateway_gateway_ssh_key_data = data.vault_generic_secret.bulk_gateway_gateway_ssh_key_data.data
  bulk_gateway_kms_key_data = data.vault_generic_secret.bulk_gateway_kms_key_data.data

  #For each log map passed, add an extra kv for the log group name
  bulk_gateway_cw_logs    = { for log, map in var.bulk_gateway_cw_logs : log => merge(map, { "log_group_name" = "${var.category}-${var.bulk_gateway_application}-${log}" }) }
  bulk_gateway_log_groups = compact([for log, map in local.bulk_gateway_cw_logs : lookup(map, "log_group_name", "")])

  bulk_gateway_ansible_inputs = {
    cw_log_files  = local.bulk_gateway_cw_logs
    cw_agent_user = "root"
  }
}
