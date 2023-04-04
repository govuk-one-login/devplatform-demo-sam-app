provider "aws" {
  region = "eu-west-2"
}

terraform {

  backend "s3" {
    bucket         = "di-devplatform-state-bucket"
		key            = "environment/terraform.tfstate"
		dynamodb_table = "di-devplatform-state-bucket-development-table"
		region         = "eu-west-2"
    profile        = "terraform"
  }

  required_version = ">= 1.0.3"
}