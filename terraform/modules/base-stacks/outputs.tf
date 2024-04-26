output "aws-signer_stack_outputs" {
    value = var.environment == "build" || var.environment == "dev" ? module.aws-signer[0].stack_outputs : null
}

output "container-signer_stack_outputs" {
    value = var.environment == "build" || var.environment == "dev" ? module.container-signer[0].stack_outputs : null
}
