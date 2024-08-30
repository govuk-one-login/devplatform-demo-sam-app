'use strict';;
import { CodeDeploy } from "@aws-sdk/client-codedeploy";
import { Lambda } from "@aws-sdk/client-lambda";

const asciiDecoder = new TextDecoder('ascii');
const codedeploy = new CodeDeploy({
  // The key apiVersion is no longer supported in v3, and can be removed.
  // @deprecated The client uses the "latest" apiVersion.
  apiVersion: '2014-10-06'
});
var lambda = new Lambda();

export const handler = (event, context, callback) => {

  console.log("Entering PreTraffic Hook!");

  // Read the DeploymentId & LifecycleEventHookExecutionId from the event payload
  var deploymentId = event.DeploymentId;
  var lifecycleEventHookExecutionId = event.LifecycleEventHookExecutionId;

  var functionToTest = process.env.NewVersion;
  console.log("Testing new function version: " + functionToTest);





  // Perform validation of the newly deployed Lambda version
  var lambdaParams = {
    FunctionName: functionToTest,
    InvocationType: "RequestResponse"
  };
  var lambdaResult = "Failed";

  lambda.invoke(lambdaParams, function(err, data) {
    if (err){  // an error occurred
      console.log(err, err.stack);
      lambdaResult = "Failed";
    }
    else{  // successful response
      var result = JSON.parse(asciiDecoder.decode(data.Payload));
      console.log("Result: " +  JSON.stringify(result));


      // Check the response for valid results
      // The response will be a JSON payload with statusCode and body properties. ie:
      // {
      //    "statusCode": 200,
      //    "body": 51
      // }
      if(JSON.parse(result.body).message == "hello world"){
        lambdaResult = "Succeeded";
        console.log ("Validation testing succeeded!");
      }
      else{
        lambdaResult = "Failed";
        console.log ("Validation testing failed!");
      }

      // Complete the PreTraffic Hook by sending CodeDeploy the validation status
      var params = {
        deploymentId: deploymentId,
        lifecycleEventHookExecutionId: lifecycleEventHookExecutionId,
        status: lambdaResult // status can be 'Succeeded' or 'Failed'
      };
      // Pass AWS CodeDeploy the prepared validation test results.
      codedeploy.putLifecycleEventHookExecutionStatus(params, function(err, data) {
        if (err) {
          // Validation failed.
          console.log('CodeDeploy Status update failed');
          console.log(err, err.stack);
          callback("CodeDeploy Status update failed");
        } else {
          // Validation succeeded.
          console.log('Codedeploy status updated successfully');
          callback(null, 'Codedeploy status updated successfully');
        }
      });
    }
  });
}
