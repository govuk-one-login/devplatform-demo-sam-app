terraform {

  backend "s3" {
    bucket         = "di-devplatform-state-bucket"
		key            = "environment/terraform.tfstate"
		dynamodb_table = "di-devplatform-state-bucket-development-table"
		region         = "eu-west-2"
  }
}