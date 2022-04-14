module "jfil_instance_profile" {
  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=tags/1.0.59"

  name       = "${var.jfil_ec2_name}-profile"
  enable_SSM = true
  cw_log_group_arns = length(local.jfil_log_groups) > 0 ? flatten([
    formatlist(
      "arn:aws:logs:%s:%s:log-group:%s:*:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.jfil_log_groups
    ),
    formatlist("arn:aws:logs:%s:%s:log-group:%s:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.jfil_log_groups
    ),
  ]) : null

  kms_key_refs = [
    "alias/${var.account}/${var.region}/ebs",
    local.ssm_kms_key_id
  ]
  s3_buckets_write = [local.session_manager_bucket_name]
}

module "bulk_gateway_instance_profile" {
  source = "git@github.com:companieshouse/terraform-modules//aws/instance_profile?ref=tags/1.0.59"

  name       = "${var.bulk_gateway_application}-profile"
  enable_SSM = true
  cw_log_group_arns = length(local.bulk_gateway_log_groups) > 0 ? flatten([
    formatlist(
      "arn:aws:logs:%s:%s:log-group:%s:*:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.bulk_gateway_log_groups
    ),
    formatlist("arn:aws:logs:%s:%s:log-group:%s:*",
      var.aws_region,
      data.aws_caller_identity.current.account_id,
      local.bulk_gateway_log_groups
    ),
  ]) : null

  kms_key_refs = [
    "alias/${var.account}/${var.region}/ebs",
    "alias/kms-bulk-gateway-${var.environment}-sftp",
    local.ssm_kms_key_id
  ]
  s3_buckets_write = [local.session_manager_bucket_name]
  custom_statements = [
    {
      sid    = "AllowAccessToBulkGatewayBuckets",
      effect = "Allow",
      resources = [
        "arn:aws:s3:::adhoc.bulk-gateway.heritage-${var.environment}.ch.gov.uk/*",
        "arn:aws:s3:::adhoc.bulk-gateway.heritage-${var.environment}.ch.gov.uk",
        "arn:aws:s3:::archive.bulk-gateway.heritage-${var.environment}.ch.gov.uk/*",
        "arn:aws:s3:::archive.bulk-gateway.heritage-${var.environment}.ch.gov.uk",
        "arn:aws:s3:::free.bulk-gateway.heritage-${var.environment}.ch.gov.uk/*",
        "arn:aws:s3:::free.bulk-gateway.heritage-${var.environment}.ch.gov.uk",
        "arn:aws:s3:::search.bulk-gateway.heritage-${var.environment}.ch.gov.uk/*",
        "arn:aws:s3:::search.bulk-gateway.heritage-${var.environment}.ch.gov.uk",
        "arn:aws:s3:::secure.bulk-gateway.heritage-${var.environment}.ch.gov.uk/*",
        "arn:aws:s3:::secure.bulk-gateway.heritage-${var.environment}.ch.gov.uk"
      ],
      actions = [
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:DeleteObject"
      ]
    },
    {
      sid    = "AllowAccessToSFTPBulkGatewayBuckets",
      effect = "Allow",
      resources = [
        "arn:aws:s3:::sftp-logs.bulk-gateway.heritage-${var.environment}.ch.gov.uk/*",
        "arn:aws:s3:::sftp-logs.bulk-gateway.heritage-${var.environment}.ch.gov.uk"
      ],
      actions = [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:GetObjectAcl",
      ]
    },
    {
      sid       = "CloudwatchMetrics"
      effect    = "Allow"
      resources = ["*"]
      actions = [
        "cloudwatch:PutMetricData"
      ]
    }
  ]
}
