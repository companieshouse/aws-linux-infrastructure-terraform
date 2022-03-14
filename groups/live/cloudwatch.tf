# TODO: confirm with on-prem as to what logs need picking up

resource "aws_cloudwatch_log_group" "jfil" {
  for_each = local.jfil_cw_logs

  name              = each.value["log_group_name"]
  retention_in_days = lookup(each.value, "log_group_retention", var.default_log_group_retention_in_days)
  kms_key_id        = lookup(each.value, "kms_key_id", data.aws_kms_key.logs.arn)

  tags = merge(
    local.default_tags,
    map(
      "Name", "${var.category}-jfil-server",
      "ServiceTeam", var.ServiceTeam
    )
  )
}