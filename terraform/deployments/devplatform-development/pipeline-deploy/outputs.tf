output "service-catalog-demo-pipeline_stack_id" {
  value = module.service-catalog-demo-pipeline.stack_id
}
output "service-catalog-demo-pipeline_stack_outputs" {
  value = module.service-catalog-demo-pipeline.stack_outputs
}
output "service-catalog-demo-pipeline_stack_tags" {
  value = module.service-catalog-demo-pipeline.stack_tags
}

output "gds_org_id" {
  value = data.aws_organizations_organization.gds.id
}
