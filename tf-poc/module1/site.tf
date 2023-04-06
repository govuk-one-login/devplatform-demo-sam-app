terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.6.0"
    }
  }

  backend "s3" {
    encrypt   = true
    region    = "eu-west-2"
  }
}

provider "aws" {
  region      = "eu-west-2"
}
