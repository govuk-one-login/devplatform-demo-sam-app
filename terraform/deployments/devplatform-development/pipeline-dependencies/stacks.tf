data "aws_organizations_organization" "gds" {}

data "aws_cloudformation_stack" "aws-signer" {
  name = "aws-signer"
}

module "devplatform-cloudfront-distribution" {
    source = "../../../modules/devplatform-cloudfront-distribution"
    stack_name = "devplatform-cf-dist"
    parameters = {
        DistributionAlias = "cloudfront-estimate.dev.platform.sandpit.account.gov.uk"
        DistributionCertificateArn = "arn:aws:acm:us-east-1:842766856468:certificate/ece18c99-4a54-42c2-8da6-5e0acd244f60"
        OriginDomain = "1fu1mudkf6.execute-api.eu-west-2.amazonaws.com"
        OriginPath = "/cloudfront-estimate-RestApiGatewayStage-301df360-aa32-11ee-bcd0-06a53b5f56c2"
    }

    tags_custom = {
      System = "DevPlatform"
    }

}