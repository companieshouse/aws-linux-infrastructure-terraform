module "jfil_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "2.19.0"

  name = var.jfil_ec2_name

  ami                    = var.jfil_ami
  instance_type          = var.jfil_ec2_instance_type
  key_name               = aws_key_pair.jfil.key_name
  monitoring             = var.monitoring
  get_password_data      = var.get_password_data
  vpc_security_group_ids = [module.jfil_sg.this_security_group_id]
  subnet_id              = coalesce(data.aws_subnet_ids.application.ids...)
  iam_instance_profile   = module.jfil_instance_profile.aws_iam_instance_profile.name
  ebs_optimized          = var.ebs_optimized

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
      "Name", var.jfil_ec2_name,
      "Application", var.jfil_application,
      "ServiceTeam", var.ServiceTeam,
      "Backup", "true" # 7 day retention only as logs are shipped and files stored on NetApp volumes
    )
  )
}
