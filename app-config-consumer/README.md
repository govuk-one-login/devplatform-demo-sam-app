# app-config-deploy-pipeline

## Overview

The `app-config-deploy-pipeline` is a CloudFormation template that provisions a fully automated,
signed-artifact configuration delivery pipeline. It takes a configuration file uploaded by GitHub
Actions to an S3 bucket, verifies its cryptographic signature using AWS KMS, and deploys it to
AWS AppConfig using a configurable staged deployment strategy.

It is designed to work across multiple AWS accounts, supporting a build → staging → production
promotion model via cross-account EventBridge events and S3 bucket policies.

The companion stack `app-config-consumer` imports the outputs of this pipeline to demonstrate
and validate end-to-end configuration delivery.

---

## Block Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     app-config-deploy-pipeline (Stack 1)                    │
│                                                                             │
│  ┌──────────────┐    S3 PutObject     ┌──────────────────────────────────┐  │
│  │   GitHub     │ ──────────────────► │   GitHubArtifactSourceBucket     │  │
│  │   Actions    │  (signed config.zip)│   (S3)                           │  │
│  │  (OIDC Role) │                     └──────────────┬───────────────────┘  │
│  └──────────────┘                                    │ S3 event             │
│                                                      ▼                      │
│                                        ┌─────────────────────────┐         │
│                                        │  EventBridge Rule       │         │
│                                        │  (CloudWatch Events)    │         │
│                                        └────────────┬────────────┘         │
│                                                     │ triggers             │
│                                                     ▼                      │
│                              ┌──────────────────────────────────────────┐  │
│                              │         CodePipeline                     │  │
│                              │                                          │  │
│                              │  ┌──────────┐  ┌────────┐  ┌─────────┐  │  │
│                              │  │  Fetch   │─►│ Verify │─►│ Deploy  │  │  │
│                              │  │  (S3)    │  │  (KMS) │  │(AppCfg) │  │  │
│                              │  └──────────┘  └────────┘  └────┬────┘  │  │
│                              └──────────────────────────────────┼───────┘  │
│                                                                 │          │
│  ┌──────────────────────────────────────────────────────────┐   │          │
│  │  AWS AppConfig                                           │◄──┘ deploys  │
│  │                                                          │              │
│  │  ┌─────────────┐  ┌──────────────────┐  ┌────────────┐  │              │
│  │  │ Application │  │  Config Profile  │  │Environment │  │              │
│  │  │             │  │  (+ optional     │  │(+ optional │  │              │
│  │  │             │  │  Lambda          │  │ CW Alarms) │  │              │
│  │  │             │  │  Validator)      │  │            │  │              │
│  │  └─────────────┘  └──────────────────┘  └────────────┘  │              │
│  └──────────────────────────────────────────────────────────┘              │
│                                                                             │
│  Exports: AppConfigApplicationId, AppConfigEnvironmentId,                  │
│           AppConfigProfileId, AppConfigClientPolicyArn                     │
└─────────────────────────────────────────────────────────────────────────────┘
                          │ CloudFormation Imports
                          ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     app-config-consumer (Stack 2)                           │
│                                                                             │
│  ┌──────────────┐   GET /config    ┌──────────────────────────────────────┐ │
│  │   HTTP       │ ───────────────► │  ConfigFunction (Lambda)             │ │
│  │   Client     │                  │                                      │ │
│  │  (CI / test) │ ◄─────────────── │  - Reads APP_CONFIG_APPLICATION_ID  │ │
│  └──────────────┘  200 / 409       │  - Reads APP_CONFIG_ENVIRONMENT_ID  │ │
│                                    │  - Reads APP_CONFIG_PROFILE_ID       │ │
│                    ┌───────────────┤  (via @aws-lambda-powertools)        │ │
│                    │ API Gateway   └──────────────────┬───────────────────┘ │
│                    │ (HTTP API v2,                    │ AppConfig API call  │
│                    │  auto-created                    ▼                     │
│                    │  by SAM)       ┌──────────────────────────────────┐    │
│                    └───────────────►│  AWS AppConfig                   │    │
│                                    │  StartConfigurationSession /      │    │
│                                    │  GetLatestConfiguration           │    │
│                                    │  (allowed via imported policy)    │    │
│                                    └──────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────┘
```

## End-to-End Flow

```
1. GitHub Actions
   ├── Signs config.json using KMS (ECC_NIST_P256) → produces config.json.sig
   └── Uploads {env}/config.zip (containing config.json + config.json.sig) to S3

2. S3 PutObject event
   └── EventBridge Rule fires → starts CodePipeline execution

3. CodePipeline — Stage 1: Fetch
   └── Pulls {env}/config.zip from S3 as config-artifact

4. CodePipeline — Stage 2: Verify
   ├── Extracts signing algorithm and signature from config.json.sig
   ├── Computes SHA-256 digest of config.json
   ├── Calls aws kms verify against the KMS signing key
   └── Pipeline fails and stops here if signature is invalid

5. CodePipeline — Stage 3: Deploy
   ├── AppConfig action picks up config.json from the artifact
   ├── Optional Lambda validator runs → rejects invalid config before deployment
   ├── Staged rollout begins (AllAtOnce / LINEAR / EXPONENTIAL)
   ├── CloudWatch alarms monitored throughout rollout
   └── Auto-rollback triggered if any monitored alarm breaches

6. AWS AppConfig serves the latest configuration
   └── app-config-consumer Lambda calls GetLatestConfiguration
       └── CI hits GET /config?expected_version=x to assert the correct version was deployed
           ├── 200 { "result": "pass", "config": { ... } }  → version matches
           └── 409 { "result": "fail", "expected": "...", "actual": "..." } → version mismatch
```

---

## Cross-Account Promotion

When `ArtifactSourceBucketAllowedAccounts` is provided, the pipeline supports multi-environment
promotion across AWS accounts:

```
Build Account
  └── Uploads config.zip to GitHubArtifactSourceBucket
  └── HigherEnvironmentEventRule forwards S3 events to downstream account event buses

Staging Account (AllowedAccounts[0])
  └── Receives EventBridge event → triggers its own app-config-deploy-pipeline
  └── Reads config.zip from the build account S3 bucket (cross-account bucket policy)
  └── Verifies signature using cross-account kms:Verify permission
  └── Deploys to its own AppConfig environment

Production Account (AllowedAccounts[1])
  └── Same flow as staging
```

The `GitHubArtifactSourceBucketEventTriggerRoleArn` output from the build account stack is
passed as the `ArtifactSourceBucketEventTriggerRoleArn` parameter to each downstream stack,
completing the event-driven cross-account trigger chain.


# app-config-consumer

## Overview

The `app-config-consumer` is a minimal AWS SAM application that validates the
`app-config-deploy-pipeline` template end-to-end. It provisions a Node.js 20 Lambda function
exposed via an HTTP API Gateway (v2) that fetches the current AppConfig configuration at
runtime and returns it over HTTP. It is used by CI to assert that configuration pushed through
the pipeline is correctly delivered and that the expected version is live.

It has no standalone purpose — it is entirely dependent on the `app-config-deploy-pipeline`
stack being deployed first, and consumes its CloudFormation exports directly.

---

## Block Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                     app-config-deploy-pipeline (Stack 1)                    │
│                                                                             │
│  Exports:                                                                   │
│    {StackName}-AppConfigApplicationId                                       │
│    {StackName}-AppConfigEnvironmentId                                       │
│    {StackName}-AppConfigProfileId                                           │
│    {StackName}-AppConfigClientPolicyArn                                     │
└───────────────────────────────┬─────────────────────────────────────────────┘
                                │ Fn::ImportValue (ConfigPipelineStackName)
                                ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     app-config-consumer (Stack 2)                           │
│                                                                             │
│  ┌──────────────┐   GET /config         ┌────────────────────────────────┐  │
│  │  HTTP Client │ ────────────────────► │  API Gateway (HTTP API v2)     │  │
│  │  (CI / test) │                       │  (auto-created by SAM HttpApi) │  │
│  └──────────────┘                       └───────────────┬────────────────┘  │
│         ▲                                               │                   │
│         │  200 / 409                                    ▼                   │
│         │                               ┌────────────────────────────────┐  │
│         │                               │  ConfigFunction (Lambda)       │  │
│         │                               │  Runtime: nodejs20.x           │  │
│         │                               │  Memory:  128 MB               │  │
│         │                               │  Timeout: 10s                  │  │
│         │                               │                                │  │
│         │                               │  Env Vars (from CF exports):   │  │
│         │                               │  - APP_CONFIG_APPLICATION_ID   │  │
│         │                               │  - APP_CONFIG_ENVIRONMENT_ID   │  │
│         │                               │  - APP_CONFIG_PROFILE_ID       │  │
│         │                               │                                │  │
│         │                               │  IAM Policy (from CF export):  │  │
│         │                               │  - AppConfigClientPolicyArn    │  │
│         └───────────────────────────────┤    appconfig:StartConfiguration│  │
│                                         │    Session                     │  │
│                                         │    appconfig:GetLatestConfig   │  │
│                                         └───────────────┬────────────────┘  │
│                                                         │                   │
│                                                         │ AppConfig API     │
│                                                         ▼                   │
│                                         ┌────────────────────────────────┐  │
│                                         │  AWS AppConfig                 │  │
│                                         │  GetLatestConfiguration        │  │
│                                         │  (forceFetch: true)            │  │
│                                         └────────────────────────────────┘  │
│                                                                             │
│  Output:                                                                    │
│    ApiEndpoint: https://{id}.execute-api.{region}.amazonaws.com/config     │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Handler Logic (src/handler.ts)

The handler is written in TypeScript and uses `@aws-lambda-powertools/parameters` to fetch
AppConfig configuration.

```
Request received: GET /config[?expected_version=x]
        │
        ▼
getAppConfig(PROFILE_ID, {
  application: APPLICATION_ID,
  environment: ENVIRONMENT_ID,
  forceFetch: true,       ← always fetches latest, bypasses cache
  transform: "json"       ← parses the raw config bytes as JSON
})
        │
        ▼
expected_version query param present?
        │
   ┌────┴────┐
  YES        NO
   │          │
   ▼          ▼
config.version   Return 200
=== expected?    { ...config }
   │
 ┌─┴──┐
YES   NO
 │     │
 ▼     ▼
200   409
{ result: "pass",    { result: "fail",
  config }             expected,
                       actual: config.version,
                       config }
```


## Deployment

Prerequisites:
- The `app-config-deploy-pipeline` stack must already be deployed in the same account and region.
- The stack name must match the `ConfigPipelineStackName` parameter (default: `app-config-deploy-pipeline`).

```bash
cd app-config-deploy-pipeline/app-config-consumer
sam build
sam deploy
```

Override the pipeline stack name if needed:

```bash
sam deploy --parameter-overrides ConfigPipelineStackName=<your-stack-name>
```

---

## API Usage

### Fetch current config

```
GET /config
```

Returns the raw AppConfig JSON:

```json
{ "version": "1.0.0", "message": "Hello from app config pipeline!" }
```

### Assert a specific version (CI use case)

```
GET /config?expected_version=1.0.0
```

| Condition       | Status | Body                                                                              |
|-----------------|--------|-----------------------------------------------------------------------------------|
| Version matches | 200    | { "result": "pass", "config": { ... } }                                           |
| Version differs | 409    | { "result": "fail", "expected": "1.0.0", "actual": "0.9.0", "config": { ... } }  |

The 409 response enables automated assertions in CI after a config deployment — a pipeline can
poll this endpoint until it receives a 200, confirming the new configuration version is live.
