require("express");
require("express-async-errors");

const os = require("os");
const path = require("path");
const session = require("express-session");
const AWS = require("aws-sdk");
const DynamoDBStore = require("connect-dynamodb")(session);

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

const { setup } = require("hmpo-app");

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

let requests = [];
let responseTimes = [];

const { app, router } = setup({
  config: { APP_ROOT: __dirname },
  port: PORT,
  host: "0.0.0.0",
  logs: loggerConfig,
  session: sessionConfig,
  helmet: helmetConfig,
  redis: SESSION_TABLE_NAME ? false : commonExpress.lib.redis(),
  urls: {
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
    app.use((req, res, next) => {
      requests.push({ timestamp: Date.now() });
      const start = Date.now();
      res.on("finish", () => {
        const duration = Date.now() - start;
        responseTimes.push({
          timestamp: Date.now(),
          duration,
        });
      });
      next();
    });

    app.use(setHeaders);
  },
  dev: true,
});

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

// --------- test logging

const getAverageResponseTime = (seconds = 20) => {
  const start = new Date(Date.now() - seconds * 1000);
  responseTimes = responseTimes.filter(({ timestamp }) => timestamp >= start);
  return (
    responseTimes
      .map(({ duration }) => duration)
      .reduce((total, current) => total + current, 0) / responseTimes.length
  );
};

const getRequests = (seconds = 20) => {
  const start = new Date(Date.now() - seconds * 1000);
  requests = requests.filter(({ timestamp }) => timestamp >= start);
  return requests.length;
};

const logStats = () => {
  return {
    event: "",
    cpuUsage: `${os.loadavg()[0].toFixed(2)}%`,
    memoryUsage:
      (
        (process.memoryUsage().heapUsed / process.memoryUsage().heapTotal) *
        100
      ).toFixed(2) + "%",
    requestsLast20Seconds: getRequests(),
    averageResponseTimeLast20Seconds: `${getAverageResponseTime()}ms`,
  };
};

setInterval(() => {
  console.log({
    ...logStats(),
    event: "monitoring",
  });
}, 20000);

process.on("SIGTERM", () => {
  console.log({
    ...logStats(),
    event: "shutdown-initiated",
  });
});
