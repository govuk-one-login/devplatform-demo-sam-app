terraform {
  required_version = ">= 1.3.0"

  # Comment out when bootstrapping
  # backend "s3" {
  #   bucket = "devplatform-service-catalog-tfstate"
  #   key    = "pipeline_deploy.tfstate"
  #   region = "eu-west-2"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  allowed_account_ids = ["637423182621"]
  region              = "eu-west-2"
}
