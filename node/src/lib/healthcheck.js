const nodeOS = require("os");

const posix = require("posix");
const limits = [
  "core",
  "cpu",
  "data",
  "fsize",
  "nofile",
  "nproc",
  "stack",
  "as",
];

const middleware = () => (req, res, next) => {
  let id = nodeOS.hostname();

  if (process.env.pm_id) {
    id += "-" + process.env.pm_id;
  }

  let status = {
    endpoint: "/healthcheck",
    posixLimits: limits.map((limit) => ({
      id: limit,
      value: posix.getrlimit(limit),
    })),
    id: id,
    status: "OK",
    timestamp: Date.now(),
    uptime: process.uptime(),
  };

  console.log(JSON.stringify(status));

  res.setHeader("Connection", "close");
  res.status(status.status === "OK" ? 200 : 500).json(status);
};

module.exports = {
  middleware,
};
