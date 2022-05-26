# Route53

This stack defines a public hosted zone for use within the demo app. The zone
is `platform.sandpit.account.gov.uk`. The zone delegation is configured in the
[di-infrastructure](https://github.com/alphagov/di-infrastructure) repository.
It is important that the zone is not deleted, otherwise the name servers will
be changed and the zone delegation will fail.