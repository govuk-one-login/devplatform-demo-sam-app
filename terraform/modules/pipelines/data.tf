data "aws_cloudformation_stack" "aws-signer" {
    name = "signer"
}

data "aws_cloudformation_stack" "container-signer" {
    name = "container-signer"
}
