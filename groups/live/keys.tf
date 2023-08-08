resource "aws_key_pair" "bulk_gateway" {
  key_name   = "bulk-gateway-server"
  public_key = data.vault_generic_secret.bulk_gateway_ec2_data.data["public-key"]
}

