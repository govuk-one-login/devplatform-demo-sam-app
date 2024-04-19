module "pipelines" {
    source                                  = "../../modules/pipelines"
    environment                             = "production"
    include_promotion                       = "No"
    build_notification_stack_name           = "dev-platform-prod-demo-notifications"

    demo_sam_app_artifact_source_bucket_arn = "arn:aws:s3:::demo-sam-app-pipeline-artifactpromotionbucket-1v52bphquqyjw"
    demo_sam_app_artifact_source_bucket_event_trigger_role_arn = "arn:aws:iam::223594937353:role/PL-demo-sam-app-pipeline-PromoTrigRole-06e5bbc9b20e"
    demo_sam_app_lambda_canary_deployment   = "Canary10Percent5Minutes"

    node_app_artifact_source_bucket_arn     = "arn:aws:s3:::pipeline-node-app-artifactpromotionbucket-gg4q44g9vr9q"
    node_app_artifact_source_bucket_event_trigger_role_arn = "arn:aws:iam::223594937353:role/PL-pipeline-node-app-PromoTrigRole-0a61d16eaf14"
    node_app_ecs_canary_deployment          = "CodeDeployDefault.ECSCanary10Percent5Minutes"

    container_signer_kms_key_arn            = "arn:aws:kms:eu-west-2:372033887444:key/7e00725a-0ff2-44c0-8cb6-c9510bad39dd"
    signing_profile_arn                     = "arn:aws:signer:eu-west-2:372033887444:/signing-profiles/SigningProfile_930aGH3MZI96"
    signing_profile_version_arn             = "arn:aws:signer:eu-west-2:372033887444:/signing-profiles/SigningProfile_930aGH3MZI96/pIzwuKOlmf"
    vpc_stack_name                          = "vpc-node-app"
}
