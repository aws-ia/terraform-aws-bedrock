#!/bin/bash

KB_ID="HJKKKPHCXE"
DS_ID="ZBS0X9GKPA"

INGEST_JOB_ID=$(aws bedrock-agent start-ingestion-job \
    --knowledge-base-id $KB_ID \
    --data-source-id $DS_ID \
    | grep ingestionJobId \
    | awk -F '"' '{print $4}')

DONE_CT=0; printf "Ingesting... "

while [ $DONE_CT -eq 0 ]; do
    DONE_CT=$(aws bedrock-agent get-ingestion-job \
        --knowledge-base-id $KB_ID \
        --data-source-id $DS_ID \
        --ingestion-job-id $INGEST_JOB_ID \
        | grep status \
        | awk -F '"' '{print $4}' \
        | grep -c COMPLETE)
    
    sleep 1
done

echo "Done."