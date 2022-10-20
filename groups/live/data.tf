data "aws_caller_identity" "current" {}

data "aws_vpc" "vpc" {
  tags = {
    Name = "vpc-${var.aws_account}"
  }
}

data "aws_subnet_ids" "application" {
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = ["sub-application-*"]
  }
}

data "aws_kms_key" "ebs" {
  key_id = "alias/${var.account}/${var.region}/ebs"
}

data "aws_kms_key" "logs" {
  key_id = "alias/${var.account}/${var.region}/logs"
}

data "vault_generic_secret" "kms_keys" {
  path = "aws-accounts/${var.aws_account}/kms"
}

data "vault_generic_secret" "security_kms_keys" {
  path = "aws-accounts/security/kms"
}

data "vault_generic_secret" "security_s3_buckets" {
  path = "aws-accounts/security/s3"
}

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}


# ------------------------------------------------------------------------------
# jfil Data Sources
# ------------------------------------------------------------------------------
data "vault_generic_secret" "jfil_ec2_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.category}/jfil/ec2"
}

# ------------------------------------------------------------------------------
# Bulk Gateway
# ------------------------------------------------------------------------------

data "vault_generic_secret" "bulk_gateway_ec2_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/ec2"
}

data "vault_generic_secret" "bulk_gateway_shares_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/shares"
}

data "vault_generic_secret" "bulk_gateway_github_deploy_key_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/github-deploy"
}

data "vault_generic_secret" "bulk_gateway_e5_ssh_key_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/e5-ssh"
}

data "vault_generic_secret" "bulk_gateway_gateway_ssh_key_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/gateway-ssh"
}

data "vault_generic_secret" "bulk_gateway_kms_key_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/bulk-kms-key"
}

data "vault_generic_secret" "bulk_gateway_bulk_live_dot_aws_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/bulk-live-dot-aws"
}

data "vault_generic_secret" "bulk_gateway_gateway_dot_aws_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/bulk-gateway/bulk-gw-lx/gateway-dot-aws"
}


data "aws_ami" "bulk_gateway" {
  most_recent = true
  owners      = [data.vault_generic_secret.account_ids.data["development"]]

  filter {
    name = "name"
    values = [
      var.bulk_gateway_ami,
    ]
  }

  filter {
    name = "state"
    values = [
      "available",
    ]
  }
}

data "template_file" "bulk_gateway_userdata" {
  template = file("${path.module}/templates/bulk_gateway_user_data.tpl")

  vars = {
    REGION               = var.aws_region
    ANSIBLE_INPUTS       = jsonencode(local.bulk_gateway_ansible_inputs)
    HERITAGE_ENVIRONMENT = title(var.environment)
    BULK_GATEWAY_INPUTS  = local.bulk_gateway_shares_data["share-mounts"]
    GITHUB_DEPLOY_KEY    = local.bulk_gateway_github_deploy_key_data["private-key"]
    E5_SSH_KEY           = local.bulk_gateway_e5_ssh_key_data["private-key"]
    E5_SSH_KEY_PUB       = local.bulk_gateway_e5_ssh_key_data["public-key"]
    GATEWAY_SSH_KEY      = local.bulk_gateway_gateway_ssh_key_data["private-key"]
    GATEWAY_SSH_KEY_PUB  = local.bulk_gateway_gateway_ssh_key_data["public-key"]
    BULKLIVE_KMS_KEY     = local.bulk_gateway_kms_key_data["key"]
    BULK_LIVE_DOT_AWS_CONFIG      = local.bulk_gateway_bulk_live_dot_aws_data["config"]
    BULK_LIVE_DOT_AWS_CREDENTIALS = local.bulk_gateway_bulk_live_dot_aws_data["credentials"]
    GATEWAY_DOT_AWS_CONFIG        = local.bulk_gateway_gateway_dot_aws_data["config"]
    GATEWAY_DOT_AWS_CREDENTIALS   = local.bulk_gateway_gateway_dot_aws_data["credentials"]
  }
}

data "template_cloudinit_config" "bulk_gateway_userdata_config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.bulk_gateway_userdata.rendered
  }
}

data "aws_sns_topic" "bulk_gateway_sns" {
  name = "bulk-gateway-sftp-cloudwatch-20220325131737971800000002"
}
