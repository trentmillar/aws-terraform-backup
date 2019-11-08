provider "aws" {
  version = "~> 2.14"
  region  = "us-west-2"
}

locals {
  tags = {
    Environment = "Test"
  }

  plan_name = "${local.tags["Environment"]}-Plan"
}

module "efs" {
  source = "github.com/trentmillar/aws-terraform-efs//?ref=v0.0.8"

  custom_tags = "${merge(
    local.tags,
    map("BackupPlan", "${local.plan_name}")
  )}"

  name            = "${local.tags["Environment"]}-EFS"
  security_groups = ["sg-1234567890abcdef1"]
  vpc_id          = "vpc-1234567890abcdef1"
}

module "backup" {
  source = "github.com/trentmillar/aws-terraform-backup//modules/backup/?ref=v0.0.3"

  completion_window = 300
  environment       = "${local.tags["Environment"]}"

  lifecycle = {
    cold_storage_after = 30
    delete_after       = 120
  }

  lifecycle_enable = true
  plan_name        = "${local.plan_name}"
  plan_tags        = "${local.tags}"
  rule_name        = "Daily"
  schedule         = "cron(0 5 ? * * *)"
  selection_name   = "fullSelectionName"

  selection_tag = [
    {
      type  = "STRINGEQUALS"
      key   = "BackupPlan"
      value = "${local.plan_name}"
    },
  ]

  start_window = 60
  vault_name   = "${local.tags["Environment"]}-Vault"
  vault_tags   = "${local.tags}"
}
