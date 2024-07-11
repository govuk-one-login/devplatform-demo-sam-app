import { SFN } from '@aws-sdk/client-sfn';

export const sfnClient = new SFN({ region: process.env.AWS_REGION });

export const triggerHandler = async () => {
    const triggerLambdaVersion = process.env.AWS_LAMBDA_FUNCTION_VERSION!
    await sfnClient.startExecution( stateMachineTrigger(triggerLambdaVersion) );
    const message: string = `Trigger lambda version ${ triggerLambdaVersion } started execution`;
    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(message)
    }
};

const stateMachineTrigger = ( triggerLambdaVersion: string ) => ({
    stateMachineArn: process.env.STATE_MACHINE!,
    input: JSON.stringify({ "triggerLambdaVersion": triggerLambdaVersion })
})
