data "aws_organizations_organization" "gds" {}


data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

module "service-catalog-pipeline" {
  source     = "git@github.com:alphagov/di-ipv-terraform-modules.git//secure-pipeline/deploy-pipeline"
  stack_name = "service-catalog-pipeline"
  parameters = {
    SAMStackName               = "service-catalog-poc"
    Environment                = "dev"
    VpcStackName               = "vpc"
    # AWSOrganizationId          = data.aws_organizations_organization.gds.id
    LogRetentionDays           = 7
    SigningProfileArn          = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileArn"]
    SigningProfileVersionArn   = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileVersionArn"]
    OneLoginRepositoryName     = "devplatform-demo-sam-app"
    SlackNotificationType      = "Failures"
    BuildNotificationStackName = "build-notifications"
  }

  tags_custom = {
    System = "DevPlatform"
  }
}