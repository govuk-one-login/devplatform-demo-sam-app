terraform {
  required_version = ">= 1.7.0"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "devplatform-build-demo-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["372033887444"]
}

module "state_bucket" {
  source         = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls?ref=state-bucket-org-access"
  bucket_name    = "devplatform-build-demo-tfstate"
  logging_bucket = "devplatform-build-demo-access-logs"
  enable_tls     = true
}

module "logging_bucket" {
  source         = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls"
  bucket_name    = "devplatform-build-demo-access-logs"
  enable_tls     = true
}