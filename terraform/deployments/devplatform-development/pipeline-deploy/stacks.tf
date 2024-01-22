data "aws_organizations_organization" "gds" {}


data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

module "service-catalog-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "service-catalog-pipeline"
  parameters = {
    SAMStackName               = "service-catalog-poc"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "service-resource-pipeline"
  parameters = {
    SAMStackName               = "service-resource-poc"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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

module "cloudfront-estimate-ecr" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules.git//secure-pipeline/container-image-repository"
  stack_name = "cloudfront-estimate-ecr"
  parameters = {
    PipelineStackName = "cloudfront-estimate-pipeline"
    #AWSOrganizationId = data.aws_organizations_organization.gds.id
  }

  tags_custom = {
    System = "DevPlatform"
  }

  depends_on = [
    module.cloudfront-estimate-pipeline
  ]
}

module "cloudfront-estimate-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "cloudfront-estimate-pipeline"
  parameters = {
    SAMStackName               = "cloudfront-estimate"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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

module "dev-dns-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "dev-dns-pipeline"
  parameters = {
    SAMStackName               = "dev-dns"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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

module "waf-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "waf-pipeline"
  parameters = {
    SAMStackName               = "waf"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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

module "cloudfront-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "cloudfront-pipeline"
  parameters = {
    SAMStackName               = "cloudfront"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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

module "cloudfront-function-pipeline" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "cloudfront-function-pipeline"
  parameters = {
    SAMStackName               = "cloudfront-function"
    Environment                = "dev"
    VpcStackName               = "vpc-node-app"
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