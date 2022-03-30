resource "aws_cloudwatch_log_group" "bulk_gateway" {
  for_each = local.bulk_gateway_cw_logs

  name              = each.value["log_group_name"]
  retention_in_days = lookup(each.value, "log_group_retention", var.default_log_group_retention_in_days)
  kms_key_id        = lookup(each.value, "kms_key_id", data.aws_kms_key.logs.arn)

  tags = merge(
    local.default_tags,
    map(
      "Name", "${var.category}-bulk-gateway-server",
      "ServiceTeam", var.ServiceTeam
    )
  )
}