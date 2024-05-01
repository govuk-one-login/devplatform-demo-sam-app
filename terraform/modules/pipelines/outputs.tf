output "demo-sam-app-github_role_arn" {
    value = module.demo-sam-app.github_role_arn
}

output "demo-sam-app-source_bucket_name" {
    value = module.demo-sam-app.source_bucket_name
}

output "demo-sam-app-promotion_bucket_arn" {
    value = module.demo-sam-app.promotion_bucket_arn
}

output "demo-sam-app-promotion_event_trigger_role_arn" {
    value = module.demo-sam-app.promotion_event_trigger_role_arn
}

output "node-app-github_role_arn" {
    value = module.node-app.github_role_arn
}

output "node-app-source_bucket_name" {
    value = module.node-app.source_bucket_name
}

output "node-app-promotion_bucket_arn" {
    value = module.node-app.promotion_bucket_arn
}

output "node-app-promotion_event_trigger_role_arn" {
    value = module.node-app.promotion_event_trigger_role_arn
}
