module "pipelines" {
    source = "../../modules/pipelines"
    environment = "build"
    allowed_accounts = "223594937353"
    one_login_repository_name = "devplatform-demo-sam-app"
    build_notification_stack_name = "dev-platform-build-demo-notifications"
    demo_sam_app_lambda_canary_deployment = "Canary10Percent5Minutes"
    demo_sam_app_test_image_repository_uri = "372033887444.dkr.ecr.eu-west-2.amazonaws.com/demo-sam-app-build-test-repository-testrunnerimagerepository-6uhsbtqym38k"
    vpc_stack_name = "vpc-node-app"
}
