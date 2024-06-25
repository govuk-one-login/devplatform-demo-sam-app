import { SQSEvent, SQSRecord } from 'aws-lambda';
import { SQS } from '@aws-sdk/client-sqs';
import { SFN } from '@aws-sdk/client-sfn';
// import { logInfo, logRejection } from '../common/logging';
// import { LogIds } from '../common/model/log-ids';
// import { RejectionReason } from '../common/model/rejection-reason';
// import { UNKNOWN_LOG_IDS, UNKNOWN_SUB } from '../common/constants';
// import { auditStartMessage, handleRejection } from '../common/queue';
// import { unexpectedRejection } from '../common/model/rejection-response';

export const sfnClient = new SFN({ region: process.env.AWS_REGION });
export const sqsClient = new SQS({ region: process.env.AWS_REGION });

export const helloWorldTriggerHandler = async (sqsEvent: SQSEvent) => {
    await Promise.all(sqsEvent.Records.map(handleRecord));
    return 'done';
};

const handleRecord: (record: SQSRecord) => Promise<void> = async (record: SQSRecord) => {
    try {
        const body = JSON.parse(record.body);

        await sfnClient.startExecution(stateMachineTrigger());
    } catch (e: any) {
        console.log(e);
    }
};

const stateMachineTrigger = () => ({
    input: record.body,
    name: 'trigger',
    stateMachineArn: process.env.HELLO_WORLD_STATE_MACHINE!,
});