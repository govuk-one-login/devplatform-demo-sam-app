const express = require("express");
const config = require("hmpo-app/lib/config");
const logger = require("hmpo-app/lib/logger");
const middleware = require("./hmpo-app-middleware");
const redisClient = require("hmpo-app/lib/redis-client");

const setup = (
  options = {
    middlewareSetupFn: undefined,
  }
) => {
  if (options.config !== false) config.setup(options.config);

  if (options.logs !== false)
    logger.setup({
      ...config.get("logs"),
      ...options.logs,
    });

  if (options.redis !== false)
    redisClient.setup({
      ...config.get("redis"),
      ...options.redis,
    });

  const app = middleware.setup({
    ...config.get(),
    ...options,
  });

  if (
    options.middlewareSetupFn &&
    typeof options.middlewareSetupFn === "function"
  ) {
    options.middlewareSetupFn(app);
  }

  const staticRouter = express.Router();
  app.use(staticRouter);

  if (options.session !== false)
    middleware.session(app, {
      ...config.get("session"),
      ...options.session,
    });

  const router = express.Router();
  app.use(router);

  const errorRouter = express.Router();
  app.use(errorRouter);

  if (options.errors !== false)
    middleware.errorHandler(app, {
      ...config.get("errors"),
      ...options.errors,
    });

  if (options.port !== false)
    middleware.listen(app, {
      port: options.port || config.get("port"),
      host: options.host || config.get("host"),
    });

  return { app, staticRouter, router, errorRouter };
};

module.exports = {
  setup,
  middleware,
  config,
  logger,
  redisClient,
  translation: require("hmpo-app/middleware/translation"),
  nunjucks: require("hmpo-app/middleware/nunjucks"),
  linkedFiles: require("hmpo-app/middleware/linked-files"),
  featureFlag: require("hmpo-app/middleware/feature-flag"),
};
