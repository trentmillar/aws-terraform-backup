provider "aws" {
  version = "~> 2.14"
  region  = "us-west-2"
}

module "backup_vault" {
  source = "github.com/trentmillar/aws-terraform-backup//modules/vault/?ref=v0.0.3"

  kms_key_arn = "arn:aws:kms:us-west-2:<aws_account_number>:key/12345678-90ab-cdef-1234-567890abcdef"

  tags = {
    tag_name  = "tag_value"
    other_tag = "other_value"
  }

  vault_name = "new_vault_name"
}
