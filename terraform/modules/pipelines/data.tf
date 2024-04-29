data "aws_cloudformation_stack" "aws-signer" {
    count = contains(["dev", "build"], var.environment) ? 1 : 0
    name = "signer"
}

data "aws_cloudformation_stack" "container-signer" {
    count = contains(["dev", "build"], var.environment) ? 1 : 0
    name = "container-signer"
}
