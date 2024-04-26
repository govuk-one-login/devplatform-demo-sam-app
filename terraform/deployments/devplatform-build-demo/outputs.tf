output "container_signer_kms_key_arn" {
    value = module.base-stacks.container-signer_stack_outputs["ContainerSignerKmsKeyArn"]
}

output "signing_profile_arn" {
    value = module.base-stacks.aws-signer_stack_outputs["SigningProfileArn"]
}

output "signing_profile_version_arn" {
    value = module.base-stacks.aws-signer_stack_outputs["SigningProfileVersionArn"]
}

output "demo-sam-app-github_role_arn" {
    value = module.pipelines.demo-sam-app-github_role_arn
}

output "demo-sam-app-source_bucket_name" {
    value = module.pipelines.demo-sam-app-source_bucket_name
}

output "demo-sam-app-promotion_bucket_arn" {
    value = module.pipelines.demo-sam-app-promotion_bucket_arn
}

output "demo-sam-app-promotion_event_trigger_role_arn" {
    value = module.pipelines.demo-sam-app-promotion_event_trigger_role_arn
}

output "node-app-github_role_arn" {
    value = module.pipelines.node-app-github_role_arn
}

output "node-app-source_bucket_name" {
    value = module.pipelines.node-app-source_bucket_name
}

output "node-app-promotion_bucket_arn" {
    value = module.pipelines.node-app-promotion_bucket_arn
}

output "node-app-promotion_event_trigger_role_arn" {
    value = module.pipelines.node-app-promotion_event_trigger_role_arn
}
