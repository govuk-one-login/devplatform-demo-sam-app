
# app-config-consumer

## Overview

The `app-config-consumer` is a minimal AWS SAM application that validates the
`app-config-deploy-pipeline` template end-to-end. It provisions a Node.js 24 Lambda function
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
│         │                               │  Runtime: nodejs24.x           │  │
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
