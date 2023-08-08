# ------------------------------------------------------------------------------
# Linux Bulk Gateway
# ------------------------------------------------------------------------------
module "bulk_gateway_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"

  name = var.bulk_gateway_application

  ami                    = data.aws_ami.bulk_gateway.id
  instance_type          = var.bulk_gateway_ec2_instance_type
  key_name               = aws_key_pair.bulk_gateway.key_name
  monitoring             = var.monitoring
  get_password_data      = var.get_password_data
  vpc_security_group_ids = [module.bulk_gateway_sg.this_security_group_id]
  subnet_id              = coalesce(data.aws_subnet_ids.application.ids...)
  iam_instance_profile   = module.bulk_gateway_instance_profile.aws_iam_instance_profile.name
  ebs_optimized          = var.ebs_optimized
  user_data_base64       = data.template_cloudinit_config.bulk_gateway_userdata_config.rendered

  root_block_device = [
    {
      delete_on_termination = var.delete_on_termination
      volume_size           = "100"
      volume_type           = var.volume_type
      encrypted             = var.ebs_encrypted
      kms_key_id            = data.aws_kms_key.ebs.arn
    }
  ]

  tags = merge(
    local.default_tags,
    map(
      "Name", var.bulk_gateway_application,
      "Application", var.bulk_gateway_application,
      "ServiceTeam", var.ServiceTeam,
      "Backup", var.bulk_gateway_bck_retention_days
    )
  )

  volume_tags = merge(
    local.default_tags,
    map(
      "Name", var.bulk_gateway_application,
      "Application", var.bulk_gateway_application,
      "ServiceTeam", var.ServiceTeam,
      "Backup", var.bulk_gateway_bck_retention_days
    )
  )
}