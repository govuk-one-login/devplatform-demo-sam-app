data "aws_organizations_organization" "gds" {}


data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer-pipeline"
}

module "dns-zones-pipeline" {
  source     = "git@github.com:alphagov/di-ipv-terraform-modules.git//secure-pipeline/deploy-pipeline"
  stack_name = "dns-zones-pipeline"
  parameters = {
    SAMStackName               = "dns-zones-build"
    Environment                = "build"
    VpcStackName               = "vpc"
    AllowedAccounts            = "791977510340"
    # AWSOrganizationId          = data.aws_organizations_organization.gds.id
    LogRetentionDays           = 7
    SigningProfileArn          = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileArn"]
    SigningProfileVersionArn   = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileVersionArn"]
    GitHubRepositoryName       = "di-shared-assets"
    OneLoginRepositoryName     = "shared-assets"
    SlackNotificationType      = "Failures"
    BuildNotificationStackName = "di-assets-notifications"
  }

  tags_custom = {
    System = "DI ASSETS"
  }
}

module "upload-assets-pipeline" {
  source     = "git@github.com:alphagov/di-ipv-terraform-modules.git//secure-pipeline/deploy-pipeline"
  stack_name = "upload-assets-pipeline"
  parameters = {
    SAMStackName             = "upload-assets"
    Environment              = "build"
    VpcStackName             = "vpc"
    AllowedAccounts          = "791977510340"
    # AWSOrganizationId        = data.aws_organizations_organization.gds.id
    LogRetentionDays         = 7
    SigningProfileArn        = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileArn"]
    SigningProfileVersionArn = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileVersionArn"]
    GitHubRepositoryName     = "di-shared-assets"
    OneLoginRepositoryName     = "shared-assets"
    #TestImageRepositoryUri     = "913579054627.dkr.ecr.eu-west-2.amazonaws.com/test-repo-pipeline-imagerepository-ivqx0hq7tcyz"
    #TestReportFormat           = "CUCUMBERJSON"
    SlackNotificationType      = "Failures"
    BuildNotificationStackName = "di-assets-notifications"
  }

  tags_custom = {
    System = "DI ASSETS"
  }
}

module "upload-event-rule-pipeline" {
  source     = "git@github.com:alphagov/di-ipv-terraform-modules.git//secure-pipeline/deploy-pipeline"
  stack_name = "upload-event-rule-pipeline"
  parameters = {
    SAMStackName             = "upload-event-rule"
    Environment              = "build"
    VpcStackName             = "vpc"
    AllowedAccounts          = "791977510340"
    # AWSOrganizationId        = data.aws_organizations_organization.gds.id
    LogRetentionDays         = 7
    SigningProfileArn        = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileArn"]
    SigningProfileVersionArn = data.aws_cloudformation_stack.aws-signer.outputs["SigningProfileVersionArn"]
    GitHubRepositoryName     = "di-shared-assets"
    OneLoginRepositoryName     = "shared-assets"
    #TestImageRepositoryUri     = "913579054627.dkr.ecr.eu-west-2.amazonaws.com/test-repo-pipeline-imagerepository-ivqx0hq7tcyz"
    #TestReportFormat           = "CUCUMBERJSON"
    SlackNotificationType      = "Failures"
    BuildNotificationStackName = "di-assets-notifications"
  }

  tags_custom = {
    System = "DI ASSETS"
  }
}
