.PHONY: help

help: 		## List targets and description
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

##
login: 			## Login into aws running `make login account={account-demo-name}`
	@./scripts/deployment_helper.sh login "${account}"

login-build: 		## Login into GDS Build aws account `make login-build`
	$(MAKE) login "account=di-devplatform-build-demo"

login-staging: 		## Login into GDS Staging aws account `make login-staging`
	$(MAKE) login "account=di-devplatform-staging-demo"

deploy-sam-build: 		## Deploy the specified app running `make deploy app={app_to_deploy} src_bucket={s3_src_bucket} signing_profile={signing_profile_name}`
	@./scripts/deployment_helper.sh deploy "di-devplatform-build-demo" "${app}" "${src_bucket}" "${signing_profile}"