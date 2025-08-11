const basicCustomEntryPoint = async function () {
  let fail = false;
  if (fail) {
    throw "Failed basicCanary check.";
  }

  return "Successfully completed basicCanary checks.";
};

exports.handler = async () => {
  return await basicCustomEntryPoint();
};
