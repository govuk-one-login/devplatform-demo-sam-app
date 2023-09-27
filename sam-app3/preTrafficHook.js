'use strict';
const aws = require('aws-sdk');
const codedeploy = new aws.CodeDeploy({apiVersion: '2014-10-06'});

exports.handler = (event, context, callback) => {
	 console.log("Entering BeforeAllowTraffic Hook!")
	 //Read the DeploymentId from the event payload.
	 var deploymentId = event.DeploymentId;

	 //Read the LifecycleEventHookExecutionId from the event payload
	 var lifecycleEventHookExecutionId = event.LifecycleEventHookExecutionId;

	 /*
	 Enter validation tests here.
	 */

	 // Prepare the validation test results with the deploymentId and
	 // the lifecycleEventHookExecutionId for CodeDeploy.
	 var params = {
			 deploymentId: deploymentId,
			 lifecycleEventHookExecutionId: lifecycleEventHookExecutionId,
			 status: 'Succeeded' // status can be 'Succeeded' or 'Failed'
	   };

	 console.log("PARAMS "+ JSON.stringify(params))

	 // Pass CodeDeploy the prepared validation test results.
	 codedeploy.putLifecycleEventHookExecutionStatus(params, function(err, data) {
		 if (err) {
			 console.log(JSON.stringify(err))
			 // Validation failed.
			 callback('Validation test failed');
		 } else {
		   // Validation succeeded.
		   callback(null, 'Validation test succeeded');
		 }
	 });
};