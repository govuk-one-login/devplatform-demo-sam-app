const os = require("os");

let requests = [];
let responseTimes = [];
let requestsInProgress = 0;
let timedOutRequests = 0;

module.exports = {
  monitorMiddleware: (req, res, next) => {
    requestsInProgress += 1;

    req.setTimeout(29000, (socket) => {
      timedOutRequests += 1;
      requestsInProgress -= 1;
      logStats("request-timeout");
      let err = new Error("Request Timeout");
      err.status = 408;
      socket.destroy();
      // next(err);
    });
    res.setTimeout(29000, (socket) => {
      timedOutRequests += 1;
      requestsInProgress -= 1;
      logStats("response-timeout");
      let err = new Error("Service Unavailable");
      err.status = 503;
      socket.destroy();
      // next(err);
    });

    requests.push({ timestamp: Date.now() });
    const start = Date.now();
    res.on("finish", () => {
      requestsInProgress -= 1;
      const duration = Date.now() - start;
      responseTimes.push({
        timestamp: Date.now(),
        duration,
      });
    });
    next();
  },
};

const getAverageResponseTime = (seconds = 10) => {
  const start = new Date(Date.now() - seconds * 1000);
  responseTimes = responseTimes.filter(({ timestamp }) => timestamp >= start);
  return (
    responseTimes
      .map(({ duration }) => duration)
      .reduce((total, current) => total + current, 0) / responseTimes.length
  );
};

const getRequests = (seconds = 10) => {
  const start = new Date(Date.now() - seconds * 1000);
  requests = requests.filter(({ timestamp }) => timestamp >= start);
  return requests.length;
};

const logStats = (event) => {
  console.log(
    JSON.stringify({
      event,
      cpuUsage: `${os.loadavg()[0].toFixed(2)}%`,
      memoryUsage:
        (
          (process.memoryUsage().heapUsed / process.memoryUsage().heapTotal) *
          100
        ).toFixed(2) + "%",
      newRequestsLast10Seconds: getRequests(),
      averageResponseTimeLast10Seconds: `${getAverageResponseTime()}ms`,
      requestsInProgress,
      timedOutRequests,
    })
  );
};

const interval = setInterval(() => {
  logStats("monitoring");
}, 10000);

process.on("SIGTERM", () => {
  clearInterval(interval);
  logStats("sigterm-shutdown");
  process.exit();
});

process.on("SIGINT", () => {
  clearInterval(interval);
  logStats("sigint-shutdown");
  process.exit();
});

process.on("exit", function (code) {
  clearInterval(interval);
  logStats("kill-shutdown");
});
