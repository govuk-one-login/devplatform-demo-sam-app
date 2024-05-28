data "aws_organizations_organization" "gds" {}

data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

#module "devplatform-cloudfront-distribution" {
#    source = "../../../modules/devplatform-cloudfront-distribution"
#    stack_name = "devplatform-cf-dist"
#    parameters = {
#        DistributionAlias = "cloudfront-estimate.dev.platform.sandpit.account.gov.uk"
#        HostedZoneID = "Z0523977PEWYQWQ6TINO"
#        AddWWWPrefix = "true"
#    }
#
#    tags_custom = {
#      System = "DevPlatform"
#    }
#
#}

module "node-ww-vpc" {
    source           = "git@github.com:govuk-one-login/ipv-terraform-modules.git//secure-pipeline/vpc"
    stack_name       = "node-ww-vpc"
    allow_rules_file = "firewall_rules.txt"
    parameters = {
        CidrBlock                 = "10.0.0.0/16"
        AvailabilityZoneCount     = 2
        ZoneAEIPAllocationId      = "none"
        ZoneBEIPAllocationId      = "none"
        ZoneCEIPAllocationId      = "none"
        VpcLinkEnabled            = "Yes"
        AllowedDomains            = "none"
        LogsApiEnabled            = "Yes"
        CloudWatchApiEnabled      = "Yes"
        XRayApiEnabled            = "Yes"
        SSMApiEnabled             = "Yes"
        SecretsManagerApiEnabled  = "Yes" #pragma: allowlist secret
        KMSApiEnabled             = "Yes"
        DynamoDBApiEnabled        = "Yes"
        S3ApiEnabled              = "Yes"
        SQSApiEnabled             = "Yes"
        SNSApiEnabled             = "Yes"
        KinesisApiEnabled         = "Yes"
        FirehoseApiEnabled        = "Yes"
        EventsApiEnabled          = "No"
        StatesApiEnabled          = "Yes"
        ECRApiEnabled             = "Yes"
        LambdaApiEnabled          = "Yes"
        CodeDeployApiEnabled      = "No"
        ExecuteApiGatewayEnabled  = "Yes"
        SSMParametersStoreEnabled = "Yes"
        RestAPIGWVpcLinkEnabled   = "Yes"
        DynatraceApiEnabled       = "Yes"
    }

    tags = {
        System = "DIDevPlatform"
    }
}