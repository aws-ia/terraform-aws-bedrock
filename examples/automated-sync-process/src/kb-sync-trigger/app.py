"""Lambda function to start Bedrock knowledge base ingestion job."""
import os
import logging
from copy import deepcopy
from time import sleep

import boto3

class KBSyncTriggerError(Exception):
    pass


# It is the caller's responsibility to ensure that a valid log level is provided
LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO').upper()
LOGGER = logging.getLogger()
LOGGER.setLevel(LOG_LEVEL)

sqs = boto3.client('sqs')
bedrock_agent = boto3.client('bedrock-agent')

# 3 variables from environment
# KB ID, Data Source ID, SQS queue (for purge)
# The associated Terraform sets these, but the default value can be modified for use with the command line __main__
KB_IDENTIFIER = os.environ.get('KB_IDENTIFIER', 'AAAAAAAAAA')
DATA_SOURCE_IDENTIFIER = os.environ.get('DATA_SOURCE_IDENTIFIER', 'ZZZZZZZZZZ')
SQS_QUEUE = os.environ.get('SQS_QUEUE', 'https://sqs.us-west-2.amazonaws.com/123456789012/crawlable-events')

INGESTION_JOB_ARGS = {
    'dataSourceId': DATA_SOURCE_IDENTIFIER,
    'description': 'Automated sync process',
    'knowledgeBaseId': KB_IDENTIFIER,
}

def start_ingestion_job(client_token: str=None) -> str:
    """Start a Bedrock knowledge base ingestion job.

    Args:
        client_token (str, optional): Idempotency token used by the underlying API. Defaults to None.

    Raises:
        KBSyncTriggerError:  If ingestion job start fails or returns a malformed response.

    Returns:
        str: Job ID of the started ingestion job
    """
    kwargs = deepcopy(INGESTION_JOB_ARGS)
    if client_token:
        kwargs['clientToken'] = client_token
    LOGGER.debug(
        'Starting ingestion job for KB %s and datasource %s',
        KB_IDENTIFIER,
        DATA_SOURCE_IDENTIFIER
    )
    response = bedrock_agent.start_ingestion_job(**kwargs)
    job = response.get('ingestionJob', {})
    if not job:
        raise KBSyncTriggerError('No ingestion job returned')

    if job['status'] == 'FAILED':
        # Raise if status is failure, return jobId otherwise
        reasons = job.get('failureReasons', ['Unknown'])
        raise KBSyncTriggerError(','.join(reasons))
    return job['ingestionJobId']

def is_sync_running() -> bool:
    """Check for a running ingestion job.

    Returns:
        bool: True if a sync is already running, False otherwise.
    """
    response = bedrock_agent.list_ingestion_jobs(
        knowledgeBaseId=KB_IDENTIFIER,
        dataSourceId=DATA_SOURCE_IDENTIFIER,
        filters=[
            {
                'operator': 'EQ',
                'attribute': 'STATUS',
                'values': [
                    'STARTING',
                    'IN_PROGRESS',
                    'STOPPING',
                ]
            }
        ],
        sortBy={
            'attribute': 'STARTED_AT',
            'order': 'DESCENDING'
        },
    )
    LOGGER.debug('List ingestion jobs response: %s', response)
    return len(response['ingestionJobSummaries']) > 0


def lambda_handler(event, context):
    """Lambda function entry point.

    Args:
        event (_type_): Incoming event data
        context (_type_): Lambda function context
    """
    if is_sync_running():
        LOGGER.info('Sync already running')
        return

    # We don't care about the content of the queue messages.  They are important in aggregate as a signal.
    # Once we have decided to run a sync, we need to clear the queue to reset the signal.
    LOGGER.info('Purging queue %s', SQS_QUEUE)
    sqs.purge_queue(QueueUrl=SQS_QUEUE)
    # SQS API docs explain that this takes up to 60 seconds, with messages that arrive during the
    # period also being deleted.  With a Lambda concurrency of 1 and this sleep, we ensure that
    # we don't drop any signals that are in flight at the same time as this pause
    LOGGER.info('Pausing for 60s to allow SQS purge to complete')
    sleep(60)
    # We let this raise rather than catching the exception.  The raise results in a DLQ entry which
    # then signals to the responsible party that there is an issue with the KB sync process.
    LOGGER.info('Starting ingestion job')
    job_id = start_ingestion_job()
    LOGGER.info(f'Started ingestion job {job_id}')


# This allows testing on the command line.
if __name__ == "__main__":
    lambda_handler(None, None)
