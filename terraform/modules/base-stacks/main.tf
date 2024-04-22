module "aws-signer" {
    count      = var.environment == "build" || var.environment == "dev" ? 1 : 0
    source     = "git@github.com:govuk-one-login/ipv-terraform-modules.git//secure-pipeline/aws-signer?ref=on-failure-null-option"
    stack_name = "signer"
    parameters = {
        Environment = var.environment
        System      = "Demo application"
    }
    on_failure = ""

    tags_custom = {
        System = "DevPlatform"
    }
}

module "container-signer" {
    count      = var.environment == "build" || var.environment == "dev" ? 1 : 0
    source     = "git@github.com:govuk-one-login/ipv-terraform-modules.git//secure-pipeline/container-signer?ref=on-failure-null-option"
    stack_name = "container-signer"
    parameters = {
        Environment     = var.environment
        AllowedAccounts = var.allowed_accounts
    }
    on_failure = ""

    tags_custom = {
        System = "DevPlatform"
    }
}
