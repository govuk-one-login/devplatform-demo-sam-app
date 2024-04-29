locals {
  container_signer_kms_key_arn = contains(["dev", "build"], var.environment) ? data.aws_cloudformation_stack.container-signer[0].outputs["ContainerSignerKmsKeyArn"] : var.container_signer_kms_key_arn
  signing_profile_arn          = contains(["dev", "build"], var.environment) ? data.aws_cloudformation_stack.aws-signer[0].outputs["SigningProfileArn"] : var.signing_profile_arn
  signing_profile_version_arn  = contains(["dev", "build"], var.environment) ? data.aws_cloudformation_stack.aws-signer[0].outputs["SigningProfileVersionArn"] : var.signing_profile_version_arn
}
