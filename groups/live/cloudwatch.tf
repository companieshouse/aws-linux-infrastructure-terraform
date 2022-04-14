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

module "cloudwatch-alarms" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ec2-cloudwatch-alarms?ref=tags/1.0.123"
  count  = var.bulk_gateway_instance_count

  name_prefix               = var.bulk_gateway_application
  namespace                 = var.cloudwatch_namespace
  instance_id               = element(module.bulk_gateway_ec2.id, 0)
  status_evaluation_periods = "3"
  status_statistics_period  = "60"

  cpuutilization_evaluation_periods = "2"
  cpuutilization_statistics_period  = "60"
  cpuutilization_threshold          = "75" # Percentage

  enable_disk_alarms = false

  enable_memory_alarms = false

  alarm_actions = [
    data.aws_sns_topic.bulk_gateway_sns.arn
  ]

  ok_actions = [
    data.aws_sns_topic.bulk_gateway_sns.arn
  ]

  depends_on = [
    module.bulk_gateway_ec2
  ]

  tags = merge(
    local.default_tags,
    tomap({
      "ServiceTeam" = var.ServiceTeam,
      "Terraform"   = true
    })
  )
}