import { SFN } from '@aws-sdk/client-sfn';

export const sfnClient = new SFN({ region: process.env.AWS_REGION });

export const triggerHandler = async () => {
    const stateMachineArn: string = process.env.STATE_MACHINE!
    await sfnClient.startExecution({ stateMachineArn: stateMachineArn });
    return 'done';
};
