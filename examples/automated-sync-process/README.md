<!-- BEGIN_TF_DOCS -->
# Automated Sync For Amazon Bedrock Knowledge Bases

## Overview
This example demonstrates how to configure an automated sync process for S3 data sources where there is both low-volume and low ingestion latency.  The S3 data source sends create/update/delete events to SQS.
The depth of the SQS queue serves as a counter.  When the counter reaches the configured threshold, a CloudWatch alarm invokes an AWS Lambda function to start an ingestion job.
The Lambda function zeroes the counter by purging the SQS queue.  In addition to the counter mechanism, there is an EventBridge scheduler that limits the maximum latency of document ingestion.

## Setup
Before deploying this sample, identify your requirements for document ingestion volume and latency.  Review the `crawlable_event_period`, `crawlable_event_threshold`, and `sync_job_schedule` input parameters below.  At present, the Bedrock Service has [hard quotas](https://docs.aws.amazon.com/general/latest/gr/bedrock.html#limits_bedrock) for concurrent knowledge base ingestion jobs and the number of documents that can be added or deleted during an ingestion job.  Take this into account when configuring the automated ingestion.

## Limitations
This implementation assumes a single S3 datasource for the knowledge base.  This is a consequence of the hard quota mentioned above.

## Monitoring and Operations
This example provides a CloudWatch dashboard for monitoring the ingestion process.  The dashboard includes the count of pending changes, the progress of the associated ingestion job, and metrics for monitoring the Lambda function that orchestrates ingestion jobs.  The dashboard has detailed explanations for metrics present as text displays.  Ingestion metrics are implemented as custom CloudWatch metrics sourced from a CloudWatch metric filter on the knowledge base application logs.  Details of the application logs are available [here](https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-bases-logging.html).

If the default `sync_job_schedule` parameter is used, an ingestion job will be scheduled on successful deployment of the example.

## Costs
The following resources in the solution will incur costs:
* [Amazon OpenSearch Serverless OCUs](https://aws.amazon.com/opensearch-service/pricing/)
* [Bedrock embedding generation](https://aws.amazon.com/bedrock/pricing/)
* [S3 storage of documents](https://aws.amazon.com/s3/pricing/)
* [SQS requests](https://aws.amazon.com/sqs/pricing/)
* [CloudWatch custom metrics](https://aws.amazon.com/cloudwatch/pricing/)
* [CloudWatch logs](https://aws.amazon.com/cloudwatch/pricing/)
* [CloudWatch dashboard](https://aws.amazon.com/cloudwatch/pricing/)
* [CloudWatch alarm](https://aws.amazon.com/cloudwatch/pricing/)
* [Lambda function](https://aws.amazon.com/lambda/pricing/)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.8.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0, < 6.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0.0, < 2.0.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | = 2.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0, < 6.0.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.0.0, < 2.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bedrock"></a> [bedrock](#module\_bedrock) | ../.. | n/a |
| <a name="module_trigger_lambda"></a> [trigger\_lambda](#module\_trigger\_lambda) | terraform-aws-modules/lambda/aws | v7.15.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_dashboard.ingestion_monitoring](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_dashboard) | resource |
| [aws_cloudwatch_log_metric_filter.deleted_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.failed_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_log_metric_filter.indexed_filter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.crawlable_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_role.trigger_lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.trigger_lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket_notification.crawlable_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_scheduler_schedule.scheduled_sync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_sqs_queue.crawlable_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue.sync_job_dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.crawlable_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.crawlable_events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_lambda_invoke](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.trigger_lambda_invoke_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [awscc_bedrock_data_source.ds](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/bedrock_data_source) | data source |
| [awscc_bedrock_knowledge_base.kb](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/bedrock_knowledge_base) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_crawlable_event_period"></a> [crawlable\_event\_period](#input\_crawlable\_event\_period) | Time period (in seconds) over which to evaluate 'crawlable\_event\_threshold' before triggering a sync job | `number` | `60` | no |
| <a name="input_crawlable_event_threshold"></a> [crawlable\_event\_threshold](#input\_crawlable\_event\_threshold) | Number of crawlable events (create/update/delete) required to trigger a sync job | `number` | `1` | no |
| <a name="input_kb_metrics_namespace"></a> [kb\_metrics\_namespace](#input\_kb\_metrics\_namespace) | Namespace under which Bedrock knowledge base sync metrics are published | `string` | `"KnowledgeBaseSync"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-west-2"` | no |
| <a name="input_sync_job_schedule"></a> [sync\_job\_schedule](#input\_sync\_job\_schedule) | Schedule for sync which caps the maximum ingestion latency | `string` | `"rate(1 hours)"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dashboard"></a> [dashboard](#output\_dashboard) | Link to the monitoring dashboard |
<!-- END_TF_DOCS -->