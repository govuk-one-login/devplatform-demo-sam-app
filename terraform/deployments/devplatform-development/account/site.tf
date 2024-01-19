terraform {
  required_version = ">= 1.0.11"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "devplatform-development-tfstate"
    key    = "account.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  allowed_account_ids = ["842766856468"]
}

module "state_bucket" {
  source         = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls"
  bucket_name    = "devplatform-development-tfstate"
  logging_bucket = "devplatform-development-access-logs"
  enable_tls     = true
}
module "logging_bucket" {
  source         = "git@github.com:govuk-one-login/ipv-terraform-modules//common/state-bucket-logging-tls"
  bucket_name    = "devplatform-development-access-logs"
  enable_tls     = true
}