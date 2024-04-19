variable "vpc_stack_name" {
    type = string
    default = "none"
}

variable "environment" {
    type = string
    description = "The name of the environment to deploy to"
}

variable "include_promotion" {
    type = string
    description = "Should a promote stage be included in the pipeline"
    default = "Yes"
}

variable "allowed_accounts" {
    type = string
    description = "Comma seperated list of accounts that can read from the artifact bucket"
    default = ""
}

variable "signing_profile_arn" {
    type = string
    description = "The ARN of the signing profile to use for signing artifacts"
    default = "none"
}

variable "signing_profile_version_arn" {
    type = string
    description = "The versioned profile ARN of the signing profile to use for verifying that Lambdas deployed by this pipeline were generated from post-merge build pipeline"
    default = "none"
}

variable "one_login_repository_name" {
    type = string
    description = "The name of the GitHub repository (within the govuk-one-login organization) which initiates this pipeline"
    default = "none"
}

variable "build_notification_stack_name" {
    type = string
    description = "The name of the BuildNotificationStack, which links to the Slack channel where notifications from this pipeline are sent"
    default = "none"
}

variable "demo_sam_app_test_image_repository_uri" {
    type = string
    description = "A URI referring to the ECR repository containing a test image to be executed within this pipeline"
    default = "none"
}

variable "demo_sam_app_artifact_source_bucket_arn" {
    type = string
    description = "The ARN of the bucket to use as a pipeline source"
    default = "none"
}

variable "demo_sam_app_artifact_source_bucket_event_trigger_role_arn" {
    type = string
    description = "The ARN of the IAM role assumed by upstream environment CloudWatch events, notifying any changes to the ArtifactSource bucket"
    default = "none"
}

variable "demo_sam_app_lambda_canary_deployment" {
    type = string
    description = "Canary strategy to be used with your Lambda applications"
    default = "None"
}
