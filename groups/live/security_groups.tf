module "bulk_gateway_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = "sgr-${var.bulk_gateway_application}"
  description = "Security group for the ${var.category} ${var.environment} ${var.bulk_gateway_application} Server"
  vpc_id      = data.aws_vpc.vpc.id

  egress_rules = ["all-all"]
}