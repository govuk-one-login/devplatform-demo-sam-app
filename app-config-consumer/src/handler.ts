import { getAppConfig } from "@aws-lambda-powertools/parameters/appconfig";
import type { APIGatewayProxyEventV2, APIGatewayProxyResultV2 } from "aws-lambda";

interface AppConfig {
  version: string;
  [key: string]: unknown;
}

export const handler = async (
  event: APIGatewayProxyEventV2
): Promise<APIGatewayProxyResultV2> => {
  const { APP_CONFIG_APPLICATION_ID, APP_CONFIG_ENVIRONMENT_ID, APP_CONFIG_PROFILE_ID } =
    process.env;

  const config = await getAppConfig<AppConfig>(APP_CONFIG_PROFILE_ID!, {
    application: APP_CONFIG_APPLICATION_ID!,
    environment: APP_CONFIG_ENVIRONMENT_ID!,
    forceFetch: true,
    transform: "json",
  });

  const expectedVersion = event.queryStringParameters?.expected_version;

  if (expectedVersion !== undefined) {
    if (config?.version === expectedVersion) {
      return { statusCode: 200, body: JSON.stringify({ result: "pass", config }) };
    }
    return {
      statusCode: 409,
      body: JSON.stringify({
        result: "fail",
        expected: expectedVersion,
        actual: config?.version,
        config,
      }),
    };
  }

  return { statusCode: 200, body: JSON.stringify(config) };
};
