# Platform Hosted Zone

This stack supports sam-app by creating the below zones:
- `dev.platform.sandpit.account.gov.uk`
    - Deployed into di-devplatform-development
    - Delegation is managed within this stack

- `build.platform.sandpit.account.gov.uk`
    - Deployed in di-devplatform-build-demo
    - Delegation is managed within this stack

- `staging.platform.sandpit.account.gov.uk`
    - Deployed in di-devplatform-staging-demo
    - Delegation is managed within this stack

- `platform.sandpit.account.gov.uk`
    - Deployed in di-devplatform-prod-demo.
    - Delegation is managed in [di-domains repo][1]

### Parameters
The list of parameters for this template:
| Parameter        | Type   | Default   | Description |
|------------------|--------|-----------|-------------|
| Environment | String |  |  The name of the environment to deploy to

### Resources
The list of resources this template creates:
| Resource         | Type   |
|------------------|--------|
| PlatformHostedZone | AWS::Route53::HostedZone
| PlatformStagingDelegation | AWS::Route53::RecordSet
| PlatformBuildDelegation | AWS::Route53::RecordSet
| ZoneRootCertificate | AWS::CertificateManager::Certificate

### Outputs
The list of outputs this template exposes:
| Output           | Description   |
|------------------|---------------|
| PlatformHostedZoneId | |

[1]: https://github.com/govuk-one-login/domains/tree/main