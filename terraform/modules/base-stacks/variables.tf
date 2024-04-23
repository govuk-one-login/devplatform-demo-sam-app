variable "environment" {
    type        = string
    description = "The name of the environment to deploy to"
}

variable "allowed_accounts" {
    type        = string
    description = "Comma seperated list of accounts that can read the KMS Key"
    default     = ""
}

variable "aws-signer-template_url" {
    type        = string
    default     = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/signer/template.yaml"
}

variable "container-signer-template_url" {
    type        = string
    default     = "https://template-storage-templatebucket-1upzyw6v9cs42.s3.amazonaws.com/container-signer/template.yaml"
}
