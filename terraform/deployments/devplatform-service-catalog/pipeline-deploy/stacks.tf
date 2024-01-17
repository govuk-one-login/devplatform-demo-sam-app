data "aws_organizations_organization" "gds" {}

data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

module "service-catalog-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "service-catalog-pipeline"
  parameters = {
    SAMStackName               = "service-catalog"
    Environment                = "build"
    VpcStackName               = "vpc"
    IncludePromotion           = "No"
    # AWSOrganizationId        = data.aws_organizations_organization.gds.id
    LogRetentionDays           = 7
    SigningProfileArn          = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileArn"]
    SigningProfileVersionArn   = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileVersionArn"]
    OneLoginRepositoryName     = "devplatform-demo-sam-app"
    #SlackNotificationType      = "Failures"
    #BuildNotificationStackName = "build-notifications"
  }

  tags_custom = {
    System = "DevPlatform"
  }
}
