module "pipelines" {
    source                                  = "../../modules/pipelines"
    environment                             = "staging"
    allowed_accounts                        = "092449966640"
    build_notification_stack_name           = "dev-platform-staging-notifications"

    demo_sam_app_artifact_source_bucket_arn = "arn:aws:s3:::demo-sam-app-pipeline-artifactpromotionbucket-ginukv4pdtg"
    demo_sam_app_artifact_source_bucket_event_trigger_role_arn = "arn:aws:iam::372033887444:role/PL-demo-sam-app-pipeline-PromoTrigRole-02617bc63eb0"
    demo_sam_app_lambda_canary_deployment   = "Canary10Percent5Minutes"
    demo_sam_app_test_image_repository_uri  = "372033887444.dkr.ecr.eu-west-2.amazonaws.com/demo-sam-app-staging-test-repository-testrunnerimagerepository-oianxs4afakm"

    node_app_artifact_source_bucket_arn     = "arn:aws:s3:::pipeline-node-app-artifactpromotionbucket-17smrqha2i49k"
    node_app_artifact_source_bucket_event_trigger_role_arn = "arn:aws:iam::372033887444:role/PL-pipeline-node-app-PromoTrigRole-06e58b425cb2"
    node_app_ecs_canary_deployment          = "CodeDeployDefault.ECSCanary10Percent5Minutes"

    container_signer_kms_key_arn            = "arn:aws:kms:eu-west-2:372033887444:key/7e00725a-0ff2-44c0-8cb6-c9510bad39dd"
    signing_profile_arn                     = "arn:aws:signer:eu-west-2:372033887444:/signing-profiles/SigningProfile_930aGH3MZI96"
    signing_profile_version_arn             = "arn:aws:signer:eu-west-2:372033887444:/signing-profiles/SigningProfile_930aGH3MZI96/pIzwuKOlmf"
    vpc_stack_name                          = "vpc-node-app"
}
