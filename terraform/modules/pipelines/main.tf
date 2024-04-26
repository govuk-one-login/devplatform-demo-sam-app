module "demo-sam-app" {
  source       = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = var.demo_sam_app_pipeline_template_url
  stack_name   = "demo-sam-app-pipeline"
  parameters = {
    SAMStackName                            = "demo-sam-app"
    VpcStackName                            = "none"
    Environment                             = var.environment
    IncludePromotion                        = var.include_promotion
    AllowedAccounts                         = var.allowed_accounts
    LogRetentionDays                        = 7
    ContainerSignerKmsKeyArn                = "none"
    SigningProfileArn                       = local.signing_profile_arn
    SigningProfileVersionArn                = local.signing_profile_version_arn
    OneLoginRepositoryName                  = var.one_login_repository_name
    ArtifactSourceBucketArn                 = var.demo_sam_app_artifact_source_bucket_arn
    ArtifactSourceBucketEventTriggerRoleArn = var.demo_sam_app_artifact_source_bucket_event_trigger_role_arn
    LambdaCanaryDeployment                  = var.demo_sam_app_lambda_canary_deployment
    TestImageRepositoryUri                  = var.demo_sam_app_test_image_repository_uri
    BuildNotificationStackName              = var.build_notification_stack_name
    SlackNotificationType                   = "Failures"
  }
  on_failure = ""

  tags_custom = {
    System = "DevPlatform"
  }
}

module "node-app" {
  source       = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = var.node_app_pipeline_template_url
  stack_name   = "pipeline-node-app"
  parameters = {
    SAMStackName                            = "node-app"
    ProgrammaticPermissionsBoundary         = "True"
    AllowedServiceOne                       = "ECR & ECS"
    AllowedServiceTwo                       = "Lambda"
    VpcStackName                            = var.vpc_stack_name
    Environment                             = var.environment
    IncludePromotion                        = var.include_promotion
    AllowedAccounts                         = var.allowed_accounts
    LogRetentionDays                        = 7
    ContainerSignerKmsKeyArn                = local.container_signer_kms_key_arn
    SigningProfileArn                       = local.signing_profile_arn
    SigningProfileVersionArn                = local.signing_profile_version_arn
    AdditionalCodeSigningVersionArns        = "arn:aws:signer:eu-west-2:354770603991:/signing-profiles/SigningProfile_SxeU7YX0F6Pb/HyVGO9gC7b"
    OneLoginRepositoryName                  = var.one_login_repository_name
    ArtifactSourceBucketArn                 = var.node_app_artifact_source_bucket_arn
    ArtifactSourceBucketEventTriggerRoleArn = var.node_app_artifact_source_bucket_event_trigger_role_arn
    ECSCanaryDeployment                     = var.node_app_ecs_canary_deployment
    BuildNotificationStackName              = var.build_notification_stack_name
    SlackNotificationType                   = "Failures"
  }
  on_failure = ""

  tags_custom = {
    System = "DevPlatform"
  }
}
