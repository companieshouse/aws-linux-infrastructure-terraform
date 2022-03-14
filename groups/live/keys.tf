resource "aws_key_pair" "jfil" {
  key_name   = "jfil-server"
  public_key = data.vault_generic_secret.jfil_ec2_data.data["public-key"]
}
