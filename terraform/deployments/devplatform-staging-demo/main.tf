module "pipelines" {
    source                                  = "../../modules/pipelines"
    environment                             = "staging"
    allowed_accounts                        = "092449966640"
    build_notification_stack_name           = "dev-platform-staging-notifications"

    demo_sam_app_artifact_source_bucket_arn = data.terraform_remote_state.build.outputs.demo-sam-app-promotion_bucket_arn
    demo_sam_app_artifact_source_bucket_event_trigger_role_arn = data.terraform_remote_state.build.outputs.demo-sam-app-promotion_event_trigger_role_arn
    demo_sam_app_lambda_canary_deployment   = "Canary10Percent5Minutes"
    demo_sam_app_test_image_repository_uri  = "372033887444.dkr.ecr.eu-west-2.amazonaws.com/demo-sam-app-staging-test-repository-testrunnerimagerepository-oianxs4afakm"

    node_app_artifact_source_bucket_arn     = data.terraform_remote_state.build.outputs.node-app-promotion_bucket_arn
    node_app_artifact_source_bucket_event_trigger_role_arn = data.terraform_remote_state.build.outputs.node-app-promotion_event_trigger_role_arn
    node_app_ecs_canary_deployment          = "CodeDeployDefault.ECSCanary10Percent5Minutes"

    container_signer_kms_key_arn            = data.terraform_remote_state.build.outputs.container_signer_kms_key_arn
    signing_profile_arn                     = data.terraform_remote_state.build.outputs.signing_profile_arn
    signing_profile_version_arn             = data.terraform_remote_state.build.outputs.signing_profile_version_arn
    vpc_stack_name                          = "vpc-node-app"
}
