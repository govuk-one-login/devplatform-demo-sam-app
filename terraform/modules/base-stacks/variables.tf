variable "environment" {
    type = string
    description = "The name of the environment to deploy to"
}

variable "allowed_accounts" {
    type = string
    description = "Comma seperated list of accounts that can read the KMS Key"
    default = ""
}
