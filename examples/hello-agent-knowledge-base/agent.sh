#!/bin/bash

AGENT_NAME=1evh-demo-agent
KB_NAME=1evh-knowledge-base

AGENT_ID=$(aws bedrock-agent list-agents \
    --query "agentSummaries[?agentName=='$AGENT_NAME'].agentId" \
    --output text)

AGENT_VERSION=$(aws bedrock-agent list-agent-versions \
    --agent-id "$AGENT_ID" \
    --query "agentVersionSummaries[-1].agentVersion" \
    --output text)

KB_ID=$(aws bedrock-agent list-knowledge-bases \
    --query "knowledgeBaseSummaries[?name=='$KB_NAME'].knowledgeBaseId" \
    --output text)

DS_ID=$(aws bedrock-agent list-data-sources \
  --knowledge-base-id "$KB_ID" \
  --query "dataSourceSummaries[0].dataSourceId" \
  --output text)

DS_S3="s3://$(terraform output \
    | grep knowledge_base_s3_bucket_name \
    | awk -F '"' '{print $2}')"