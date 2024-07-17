//require('source-map-support/register')
const serverlessExpress = require('@codegenie/serverless-express')
const app = require('./app')

let serverlessExpressInstance;

async function setup (event, context) {
  serverlessExpressInstance = serverlessExpress({ app })
  return serverlessExpressInstance(event, context)
}

function handler (event, context) {
  if (serverlessExpressInstance) return serverlessExpressInstance(event, context)

  return setup(event, context)
}

exports.handler = handler