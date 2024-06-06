# Keeping the Dev Platform managed stacks up to date in all demo environments

Terraform orchestration to manage base stacks and demo apps pipeline stacks in devplatform build-demo, staging-demo, and prod-demo accounts only. This is intended for DevPlatform internal use: eliminating toil on keeping the pipeline stacks up-to-date in demo environments.

## Directory structure

The contents will change as we add more features and functionality. The basic structure will remain the same. Divided into two sections:

- `modules` section - reusable deployment configuration templates for demo apps
- `deployments` section - environment/account-specific variables and parameters passed onto the modules. Execute terraform init/plan/apply commands from environment-specific directories

```bash
terraform/
├── README.md
├── deployments
│   ├── devplatform-build-demo
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── site.tf
│   ├── devplatform-prod-demo
│   │   ├── main.tf
│   │   └── site.tf
│   └── devplatform-staging-demo
│       ├── main.tf
│       ├── outputs.tf
│       └── site.tf
└── modules
    ├── base-stacks
    │   ├── main.tf
    │   ├── outputs.tf
    │   └── variables.tf
    └── pipelines
        ├── data.tf
        ├── locals.tf
        ├── main.tf
        ├── outputs.tf
        └── variables.tf
```

## How to keep stacks up-to-date

Simply running terraform init/plan/apply from each `terraform/deployments/<Account Alias>` location should be sufficient to keep the Cloudformation Stacks in that account up-to-date with the latest versions.

Run order: build-demo, then staging-demo, and finally prod-demo
