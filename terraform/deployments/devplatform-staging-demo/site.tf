terraform {
  required_version = ">= 1.7.0"

  # Comment out when bootstrapping
  backend "s3" {
    bucket         = "devplatform-staging-demo-tfstate"
    dynamodb_table = "devplatform-staging-demo-tfstate-lock-dynamodb"
    key            = "account.tfstate"
    region         = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["223594937353"]
}

module "state_bucket" {
  source                       = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls?ref=state-bucket-org-access"
  bucket_name                  = "devplatform-staging-demo-tfstate"
  logging_bucket               = "devplatform-staging-demo-access-logs"
  enable_tls                   = true
  enable_state_lock_dynamodb   = true
  allowed_accounts             = "092449966640" # cross-account read access enabled only from di-devplatform-prod-demo
}

module "logging_bucket" {
  source         = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls"
  bucket_name    = "devplatform-staging-demo-access-logs"
  enable_tls     = true
}

data "terraform_remote_state" "build" {
  backend = "s3"

  config = {
    bucket = "devplatform-build-demo-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}
