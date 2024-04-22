output "aws-signer_stack_outputs" {
    value = module.aws-signer[0].stack_outputs
}

output "container-signer_stack_outputs" {
    value = module.container-signer[0].stack_outputs
}
