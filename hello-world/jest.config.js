const config = {
    collectCoverage: true,
    collectCoverageFrom: ["**/*.js"],
    coverageDirectory: "coverage",
    coverageReporters: ["lcov", "text", "html"],
    coveragePathIgnorePatterns: ["/node_modules/", "config.js", "/coverage/"]
  };

  module.exports = config;