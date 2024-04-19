data "aws_cloudformation_stack" "aws-signer" {
    count = var.environment == "build" || var.environment == "dev" ? 1 : 0
    name = "signer"
}

data "aws_cloudformation_stack" "container-signer" {
    count = var.environment == "build" || var.environment == "dev" ? 1 : 0
    name = "container-signer"
}
