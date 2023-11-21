data "aws_organizations_organization" "gds" {}


data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

module "service-catalog-pipeline" {
  source     = "git@github.com:alphagov/di-ipv-terraform-modules.git//secure-pipeline/deploy-pipeline"
  template_url = "https://template-bucket-templatebucket-35qbug5k1irh.s3.eu-west-2.amazonaws.com/test-templates/sam-deploy-pipeline/PLAT-2936-template.yaml"
  stack_name = "service-catalog-pipeline"
  parameters = {
    SAMStackName               = "service-catalog-poc"
    Environment                = "dev"
    VpcStackName               = "vpc"
    IncludePromotion           = "No"
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

module "service-resource-pipeline" {
  source     = "git@github.com:alphagov/di-ipv-terraform-modules.git//secure-pipeline/deploy-pipeline"
  template_url = "https://template-bucket-templatebucket-35qbug5k1irh.s3.eu-west-2.amazonaws.com/test-templates/sam-deploy-pipeline/PLAT-2936-template.yaml"
  stack_name = "service-resource-pipeline"
  parameters = {
    SAMStackName               = "service-resource-poc"
    Environment                = "dev"
    VpcStackName               = "vpc"
    IncludePromotion           = "No"
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