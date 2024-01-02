output "service-catalog-pipeline_stack_id" {
  value = module.service-catalog-pipeline.stack_id
}
output "service-catalog-pipeline_stack_outputs" {
  value = module.service-catalog-pipeline.stack_outputs
}
output "service-catalog-pipeline_stack_tags" {
  value = module.service-catalog-pipeline.stack_tags
}

output "gds_org_id" {
  value = data.aws_organizations_organization.gds.id
}

output "service-resource-pipeline_stack_id" {
  value = module.service-resource-pipeline.stack_id
}
output "service-resource-pipeline_stack_outputs" {
  value = module.service-resource-pipeline.stack_outputs
}
output "service-resource-pipeline_stack_tags" {
  value = module.service-resource-pipeline.stack_tags
}

output "cloudfront-estimate-pipeline_stack_id" {
  value = module.cloudfront-estimate-pipeline.stack_id
}
output "cloudfront-estimate-pipeline_stack_outputs" {
  value = module.cloudfront-estimate-pipeline.stack_outputs
}
output "cloudfront-estimate-pipeline_stack_tags" {
  value = module.cloudfront-estimate-pipeline.stack_tags
}

output "cloudfront-estimate-ecr_stack_id" {
  value = module.cloudfront-estimate-ecr.stack_id
}
output "cloudfront-estimate-ecr_stack_outputs" {
  value = module.cloudfront-estimate-ecr.stack_outputs
}
output "cloudfront-estimate-ecr_stack_tags" {
  value = module.cloudfront-estimate-ecr.stack_tags
}

output "dev-dns-pipeline_stack_id" {
  value = module.dev-dns-pipeline.stack_id
}
output "dev-dns-pipeline_stack_outputs" {
  value = module.dev-dns-pipeline.stack_outputs
}
output "dev-dns-pipeline_stack_tags" {
  value = module.dev-dns-pipeline.stack_tags
}

output "waf-pipeline_stack_id" {
  value = module.waf-pipeline.stack_id
}
output "waf-pipeline_stack_outputs" {
  value = module.waf-pipeline.stack_outputs
}
output "waf-pipeline_stack_tags" {
  value = module.waf-pipeline.stack_tags
}