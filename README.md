# aws-linux-infrastructure-terraform

This repo contains the underlying infrastructure for the Linux servers migrated to Heritage AWS accounts.

## User Data
User Data within AWS is only run at VM build time using a template file, that contains standard bash syntax and is referenced by the EC2 Resource in Terraform which uses the template as User Data
This concept is used on almost all the new servers built in the Heritage Environment to provide some basic settings for the server. In most cases they are using AutoScaling or deploying full applications.  For example, this repo using template file called bulk_gateway_user_data.tpl, which creates user accounts, directories and permissions, NFS & CIFS share mounts, bulk output deploy script and postfix and mailx install and configuration.

See user data link for further information: https://registry.terraform.io/providers/serverscom/serverscom/latest/docs/guides/user-data

