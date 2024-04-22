module "base-stacks" {
    source           = "../../modules/base-stacks"
    environment      = "build"
    allowed_accounts = "223594937353,092449966640"
}

module "vpc" {
    source     = "git@github.com:govuk-one-login/ipv-terraform-modules.git//secure-pipeline/vpc?ref=on-failure-null-option"
    stack_name = "vpc-node-app"
    parameters = {
        CidrBlock                         = "10.0.0.0/16"
        AvailabilityZoneCount             = "2"
        AccessLogsCustomBucketNameEnabled = "Yes"
        DynatraceApiEnabled               = "Yes"
        ECRApiEnabled                     = "Yes"
        KMSApiEnabled                     = "Yes"
        LogsApiEnabled                    = "Yes"
        NlbCrossZoneEnabled               = "Yes"
        SSMParametersStoreEnabled         = "Yes"
        SecretsManagerApiEnabled          = "Yes" # pragma: allowlist secret
        VpcLinkEnabled                    = "Yes"
    }
    on_failure = ""

    tags_custom = {
        System = "DevPlatform"
    }
}

module "pipelines" {
    depends_on = [
        module.base-stacks,
        module.vpc
    ]

    source                                 = "../../modules/pipelines"
    environment                            = "build"
    allowed_accounts                       = "223594937353"
    one_login_repository_name              = "devplatform-demo-sam-app"
    build_notification_stack_name          = "dev-platform-build-demo-notifications"
    demo_sam_app_lambda_canary_deployment  = "Canary10Percent5Minutes"
    demo_sam_app_test_image_repository_uri = "372033887444.dkr.ecr.eu-west-2.amazonaws.com/demo-sam-app-build-test-repository-testrunnerimagerepository-6uhsbtqym38k"
    node_app_ecs_canary_deployment         = "CodeDeployDefault.ECSCanary10Percent5Minutes"
    vpc_stack_name                         = "vpc-node-app"
}
