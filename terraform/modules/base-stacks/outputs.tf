output "aws-signer_stack_outputs" {
    value = contains(["dev", "build"], var.environment) ? module.aws-signer[0].stack_outputs : null
}

output "container-signer_stack_outputs" {
    value = contains(["dev", "build"], var.environment) ? module.container-signer[0].stack_outputs : null
}
