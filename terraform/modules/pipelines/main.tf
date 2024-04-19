module "demo-sam-app" {
  source     = "git@github.com:govuk-one-login/ipv-terraform-modules//secure-pipeline/deploy-pipeline"
  template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
  stack_name = "demo-sam-app-pipeline"
  parameters = {
    SAMStackName               = "demo-sam-app"
    VpcStackName               = "none"
    Environment                = var.environment
    IncludePromotion           = var.include_promotion
    AllowedAccounts            = var.allowed_accounts
    LogRetentionDays           = 7
    ContainerSignerKmsKeyArn   = "none"
    SigningProfileArn          = local.signing_profile_arn
    SigningProfileVersionArn   = local.signing_profile_version_arn
    OneLoginRepositoryName     = var.one_login_repository_name
    ArtifactSourceBucketArn    = var.demo_sam_app_artifact_source_bucket_arn
    ArtifactSourceBucketEventTriggerRoleArn = var.demo_sam_app_artifact_source_bucket_event_trigger_role_arn
    LambdaCanaryDeployment     = var.demo_sam_app_lambda_canary_deployment
    TestImageRepositoryUri     = var.demo_sam_app_test_image_repository_uri
    BuildNotificationStackName = var.build_notification_stack_name
    SlackNotificationType      = "Failures"
  }
  on_failure = ""

  tags_custom = {
    System = "DevPlatform"
  }
}
