require("express");
require("express-async-errors");

const path = require("path");
const session = require("express-session");
const AWS = require("aws-sdk");
const DynamoDBStore = require("connect-dynamodb")(session);
// Create CloudWatch service object
const cloudwatch = new AWS.CloudWatch({ apiVersion: "2010-08-01" });
const os = require("os");
const containerName = os.hostname() 

const commonExpress = require("ipv-cri-common-express");

const setHeaders = commonExpress.lib.headers;
const setScenarioHeaders = commonExpress.lib.scenarioHeaders;
const setAxiosDefaults = commonExpress.lib.axios;

const { setAPIConfig, setOAuthPaths } = require("./lib/settings");
const { setGTM } = require("ipv-cri-common-express/src/lib/settings");
const { getGTM } = require("ipv-cri-common-express/src/lib/locals");
const { setI18n } = require("ipv-cri-common-express/src/lib/i18next");

const {
  API,
  APP,
  PORT,
  SESSION_SECRET,
  SESSION_TABLE_NAME,
  SESSION_TTL,
} = require("./lib/config");

const { setup } = require("./shims/hmpo-app");

const loggerConfig = {
  console: true,
  consoleJSON: true,
  app: false,
};

AWS.config.update({
  region: "eu-west-2",
});
const dynamodb = new AWS.DynamoDB();

const dynamoDBSessionStore = new DynamoDBStore({
  client: dynamodb,
  table: SESSION_TABLE_NAME,
});

const sessionConfig = {
  cookieName: "service_session",
  secret: SESSION_SECRET,
  cookieOptions: { maxAge: SESSION_TTL },
  ...(SESSION_TABLE_NAME && { sessionStore: dynamoDBSessionStore }),
};

const helmetConfig = require("ipv-cri-common-express/src/lib/helmet");
const { monitorMiddleware } = require("./lib/monitor");

const { app, router } = setup({
  config: { APP_ROOT: __dirname },
  port: PORT,
  host: "0.0.0.0",
  logs: loggerConfig,
  session: sessionConfig,
  helmet: helmetConfig,
  redis: SESSION_TABLE_NAME ? false : commonExpress.lib.redis(),
  urls: {
    healthcheck: null,
    public: "/public",
  },
  publicDirs: ["../dist/public"],
  views: [
    path.resolve(
      path.dirname(require.resolve("ipv-cri-common-express")),
      "components"
    ),
    "views",
  ],
  translation: {
    allowedLangs: ["en", "cy"],
    fallbackLang: ["en"],
    cookie: { name: "lng" },
  },
  middlewareSetupFn: (app) => {
    app.use(monitorMiddleware);
    app.use(setHeaders);
  },
  dev: true,
});

router.get("/healthcheck", require("./lib/healthcheck").middleware());

setI18n({
  router,
  config: {
    secure: true,
    cookieDomain: APP.ANALYTICS.DOMAIN,
  },
});

app.set("view engine", "njk");

setAPIConfig({
  app,
  baseUrl: API.BASE_URL,
  sessionPath: API.PATHS.SESSION,
  authorizationPath: API.PATHS.AUTHORIZATION,
});

setOAuthPaths({ app, entryPointPath: APP.PATHS.TOY });

setGTM({
  app,
  id: APP.ANALYTICS.ID,
  analyticsCookieDomain: APP.ANALYTICS.DOMAIN,
});

router.use(getGTM);

router.use(setScenarioHeaders);
router.use(setAxiosDefaults);

router.use("/oauth2", commonExpress.routes.oauth2);

router.use("/toy", require("./app/toy"));

router.use(commonExpress.lib.errorHandling.redirectAsErrorToCallback);


const server = app.listen(8000)
server.keepAliveTimeout = 65000; // Ensure all inactive connections are terminated by the ALB, by setting this a few seconds higher than the ALB idle timeout
server.headersTimeout = 66000; // Ensure the headersTimeout is set higher than the keepAliveTimeout due to this nodejs regression bug: https://github.com/nodejs/node/issues/27363

// Push count every seconds
schedule.scheduleJob('* * * * * *', () => {
  return server.getConnections((error, count) => {
      if (error) {
          console.error('Error while trying to get server connections', error);
          return;
      }
      
      console.log(`Current opened connections count: ${count}`);
      
      const params = {
          MetricData: [
              {
                  MetricName: 'HTTPConnections',
                  Dimensions: [
                      {
                          Name: 'PerNodeId',
                          Value: `${containerName}` 
                          // Set here any dynamic and unique ID 
                          // than can identify easily your running
                          // node app, like its container ID
                      },
                  ],
                  Unit: 'Count',
                  Value: count
              },
          ],
          Namespace: 'FEC/NodeApp'
      };
      //Make sure to set the IAM policy to allow pushing metrics
      cloudwatch.putMetricData(params, (err) => {
          if (err) {
              console.error('Error while trying to push http connections metrics', err);
          }
      });
      
  });
});
