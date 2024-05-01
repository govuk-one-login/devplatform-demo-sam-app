terraform {
  required_version = ">= 1.7.0"

  # Comment out when bootstrapping
  backend "s3" {
    bucket         = "devplatform-build-demo-tfstate-0f25031c-03e7-a1f6-3cae-f474fe5f"
    dynamodb_table = "devplatform-build-demo-tfstate-lock-dynamodb"
    key            = "account.tfstate"
    region         = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["372033887444"]
}

module "state_bucket" {
  source                      = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls?ref=state-bucket-org-access"
  bucket_name                 = "devplatform-build-demo-tfstate"
  enable_bucket_random_suffix = true
  logging_bucket              = "devplatform-build-demo-access-logs"
  enable_tls                  = true
  enable_state_lock_dynamodb  = true
  allowed_accounts            = "223594937353,092449966640" # cross-account read access enabled from di-devplatform-staging-demo, di-devplatform-prod-demo
}

module "logging_bucket" {
  source         = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls"
  bucket_name    = "devplatform-build-demo-access-logs"
  enable_tls     = true
}