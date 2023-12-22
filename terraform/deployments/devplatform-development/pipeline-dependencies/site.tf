terraform {
  required_version = ">= 1.3.0"

  # Comment out when bootstrapping
  backend "s3" {
    bucket = "devplatform-development-tfstate"
    key    = "pipeline_dependencies.tfstate"
    region = "eu-west-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  allowed_account_ids = ["842766856468"]
  region              = "eu-west-2"
}
