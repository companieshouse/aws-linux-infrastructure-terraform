module "jfil_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.category}"
  description = "Security group for the ${var.category} ${var.environment} Server"
  vpc_id      = data.aws_vpc.vpc.id

  egress_rules = ["all-all"]
}
