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
# Bulk Gateway
# ------------------------------------------------------------------------------

data "vault_generic_secret" "bulk_gateway_ec2_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.category}/bulk_gateway/ec2"
}

data "vault_generic_secret" "bulk_gateway_shares_data" {
  path = "applications/${var.aws_account}-${var.aws_region}/${var.category}/bulk_gateway/shares"
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