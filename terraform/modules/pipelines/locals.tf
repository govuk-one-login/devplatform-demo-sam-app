locals {
  signing_profile_arn = var.environment == "build" ?  data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileArn"] : var.signing_profile_arn
  signing_profile_version_arn = var.environment == "build" ?  data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileVersionArn"] : var.signing_profile_version_arn
}
