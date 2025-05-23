const path = require("path");
const express = require("express");
const logger = require("hmpo-app/lib/logger");

const requiredArgument = (argName) => {
  throw new Error(`Argument '${argName}' must be specified`);
};

const middleware = {
  setup({
    env = process.env.NODE_ENV,
    urls = {},
    featureFlags,
    publicDirs,
    publicImagesDirs,
    public: publicOptions,
    disableCompression = false,
    trustProxy = true,
    requestLogging = true,
    helmet,
    views,
    locales,
    nunjucks: nunjucksOptions,
    translation: translationOptions,
    modelOptions: modelOptionsConfig,
    cookies: cookieOptions,
  } = {}) {
    const hmpoLogger = require("hmpo-logger");
    const healthcheck = require("hmpo-app/middleware/healthcheck");
    const modelOptions = require("hmpo-app/middleware/model-options");
    const featureFlag = require("hmpo-app/middleware/feature-flag");
    const version = require("hmpo-app/middleware/version");
    const cookies = require("hmpo-app/middleware/cookies");
    const bodyParser = require("body-parser");
    const translation = require("hmpo-app/middleware/translation");
    const hmpoComponents = require("hmpo-components");
    const public = require("hmpo-app/middleware/public");
    const nunjucks = require("hmpo-app/middleware/nunjucks");
    const headers = require("hmpo-app/middleware/headers");

    urls.public = urls.public || "/public";
    urls.publicImages =
      urls.publicImages || path.posix.join(urls.public, "/images");
    urls.version = urls.version === undefined ? "/version" : urls.version;
    urls.healthcheck =
      urls.healthcheck === undefined ? "/healthcheck" : urls.healthcheck;

    // create new express app
    const app = express();

    // environment
    env = (env || "development").toLowerCase();
    app.set("env", env);
    app.set("dev", env !== "production");

    // security and headers
    headers.setup(app, {
      disableCompression,
      trustProxy,
      publicPath: urls.public,
      helmet,
    });

    // version, healthcheck
    if (urls.version) app.get(urls.version, version.middleware());
    if (urls.healthcheck) app.get(urls.healthcheck, healthcheck.middleware());

    // public static assets
    if (publicOptions !== false)
      app.use(
        public.middleware({
          urls,
          publicDirs,
          publicImagesDirs,
          public: publicOptions,
        })
      );

    app.use(featureFlag.middleware({ featureFlags }));
    app.use(cookies.middleware(cookieOptions));
    app.use(modelOptions.middleware(modelOptionsConfig));
    app.use(bodyParser.urlencoded({ extended: true }));

    // logging
    if (requestLogging) app.use(hmpoLogger.middleware(":request"));

    Object.assign(app.locals, {
      baseUrl: "/",
      assetPath: urls.public,
      urls: urls,
    });

    app.use((req, res, next) => {
      res.locals.baseUrl = req.baseUrl;
      next();
    });

    const nunjucksEnv = nunjucks.setup(app, { views, ...nunjucksOptions });
    translation.setup(app, { locales, ...translationOptions });
    hmpoComponents.setup(app, nunjucksEnv);

    return app;
  },

  session(app = requiredArgument("app"), sessionOptions) {
    const session = require("hmpo-app/middleware/session");
    const featureFlag = require("hmpo-app/middleware/feature-flag");
    const linkedFiles = require("hmpo-app/middleware/linked-files");

    app.use(session.middleware(sessionOptions));
    app.use(featureFlag.middleware());
    app.use(linkedFiles.middleware(sessionOptions));
  },

  errorHandler(app = requiredArgument("app"), errorHandleroptions) {
    const pageNotFound = require("hmpo-app/middleware/page-not-found");
    const errorHandler = require("hmpo-app/middleware/error-handler");

    app.use(pageNotFound.middleware(errorHandleroptions));
    app.use(errorHandler.middleware(errorHandleroptions));
  },

  listen(
    app = requiredArgument("app"),
    { port = 3000, host = "0.0.0.0" } = {}
  ) {
    const server = app.listen(port, host, () => {
      logger.get().info("Listening on http://:listen", {
        bind: host,
        port,
        listen: (host === "0.0.0.0" ? "localhost" : host) + ":" + port,
      });
    });

    server.keepAliveTimeout = 65000;
    server.headersTimeout = 66000;
  },
};

module.exports = middleware;
