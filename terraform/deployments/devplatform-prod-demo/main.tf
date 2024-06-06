module "base-stacks" {
    source           = "../../modules/base-stacks"
    environment      = "production"

    aws-signer-template_url       = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/signer/template.yaml"
    container-signer-template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/container-signer/template.yaml"
}

module "vpc" {
    source       = "git@github.com:govuk-one-login/ipv-terraform-modules.git//secure-pipeline/vpc?ref=on-failure-null-option"
    template_url = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/vpc/template.yaml"
    stack_name   = "vpc-node-app"
    parameters   = {
        CidrBlock                         = "10.0.0.0/16"
        AvailabilityZoneCount             = "2"
        AccessLogsCustomBucketNameEnabled = "Yes"
        CloudWatchApiEnabled              = "Yes"
        DynatraceApiEnabled               = "Yes"
        ECRApiEnabled                     = "Yes"
        KMSApiEnabled                     = "Yes"
        LogsApiEnabled                    = "Yes"
        NlbCrossZoneEnabled               = "Yes"
        RestAPIGWVpcLinkEnabled           = "Yes"
        SNSApiEnabled                     = "Yes"
        SQSApiEnabled                     = "Yes"
        SSMApiEnabled                     = "Yes"
        SSMParametersStoreEnabled         = "Yes"
        SecretsManagerApiEnabled          = "Yes" # pragma: allowlist secret
        VpcLinkEnabled                    = "Yes"
    }
    on_failure   = ""

    tags_custom  = {
        System   = "DevPlatform"
    }
}

module "pipelines" {
    depends_on = [
        module.base-stacks,
        module.vpc
    ]

    source                        = "../../modules/pipelines"
    environment                   = "production"
    include_promotion             = "No"
    build_notification_stack_name = "dev-platform-prod-demo-notifications"
    container_signer_kms_key_arn  = data.terraform_remote_state.build.outputs.container_signer_kms_key_arn
    signing_profile_arn           = data.terraform_remote_state.build.outputs.signing_profile_arn
    signing_profile_version_arn   = data.terraform_remote_state.build.outputs.signing_profile_version_arn
    vpc_stack_name                = "vpc-node-app"

    demo_sam_app_pipeline_template_url                         = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
    demo_sam_app_artifact_source_bucket_arn                    = data.terraform_remote_state.staging.outputs.demo-sam-app-promotion_bucket_arn
    demo_sam_app_artifact_source_bucket_event_trigger_role_arn = data.terraform_remote_state.staging.outputs.demo-sam-app-promotion_event_trigger_role_arn
    demo_sam_app_lambda_canary_deployment                      = "Canary10Percent5Minutes"

    demo_sam_app2_pipeline_template_url                         = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
    demo_sam_app2_artifact_source_bucket_arn                    = data.terraform_remote_state.staging.outputs.demo-sam-app2-promotion_bucket_arn
    demo_sam_app2_artifact_source_bucket_event_trigger_role_arn = data.terraform_remote_state.staging.outputs.demo-sam-app2-promotion_event_trigger_role_arn

    node_app_pipeline_template_url                         = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.eu-west-2.amazonaws.com/sam-deploy-pipeline/template.yaml"
    node_app_artifact_source_bucket_arn                    = data.terraform_remote_state.staging.outputs.node-app-promotion_bucket_arn
    node_app_artifact_source_bucket_event_trigger_role_arn = data.terraform_remote_state.staging.outputs.node-app-promotion_event_trigger_role_arn
    node_app_ecs_canary_deployment                         = "CodeDeployDefault.ECSCanary10Percent5Minutes"
}
