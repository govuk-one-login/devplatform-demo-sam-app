//require('source-map-support/register')
const serverlessExpress = require('@codegenie/serverless-express')
const app = require('./src/app')

let serverlessExpressInstance;

async function setup (event, context) {
  // Async connection pooling .etc can be setup here
  serverlessExpressInstance = serverlessExpress({ app })
  return serverlessExpressInstance(event, context)
}

function handler (event, context) {
  if (serverlessExpressInstance) return serverlessExpressInstance(event, context)

  return setup(event, context)
}

exports.handler = handler