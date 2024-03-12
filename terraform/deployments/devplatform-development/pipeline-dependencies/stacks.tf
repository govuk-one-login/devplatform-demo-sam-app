data "aws_organizations_organization" "gds" {}

data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

module "devplatform-cloudfront-distribution" {
    source = "../../../modules/devplatform-cloudfront-distribution"
    stack_name = "devplatform-cf-dist"
    parameters = {
        DistributionAlias = "cloudfront-estimate.dev.platform.sandpit.account.gov.uk"
        HostedZoneID = "Z0523977PEWYQWQ6TINO"
        AddWWWPrefix = "true"
    }

    tags_custom = {
      System = "DevPlatform"
    }

}