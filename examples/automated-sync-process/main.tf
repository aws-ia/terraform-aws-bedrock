#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################
provider "aws" {
  region = var.region
}

provider "awscc" {
  region = var.region
}

provider "opensearch" {
  url         = module.bedrock.default_collection[0].collection_endpoint
  healthcheck = false
}

data "aws_caller_identity" "current" {}

// NOTE: Although awscc provider documentation calls out that 'id' is a string, this resource hits the same (closed) bug referenced here:
// https://github.com/hashicorp/terraform-provider-awscc/issues/1259
// As a consequence, the *ONLY* way to import this in Terraform code is shown below.
data "awscc_bedrock_data_source" "ds" {
  id = jsonencode({ KnowledgeBaseId = module.bedrock.default_kb_identifier, DataSourceId = module.bedrock.datasource_identifier })
}

data "awscc_bedrock_knowledge_base" "kb" {
  id = module.bedrock.default_kb_identifier
}

locals {
  bucket_arn  = data.awscc_bedrock_data_source.ds.data_source_configuration.s3_configuration.bucket_arn
  bucket_name = provider::aws::arn_parse(data.awscc_bedrock_data_source.ds.data_source_configuration.s3_configuration.bucket_arn).resource
  // event_name will be used for both the primary SQS queue and the associated CloudWatch alarm
  event_name = "crawlable-events-${module.bedrock.default_kb_identifier}"
}

module "bedrock" {
  source                 = "../.." # local example
  create_kb              = true
  create_default_kb      = true
  create_kb_log_group    = true
  kb_embedding_model_arn = "arn:aws:bedrock:${var.region}::foundation-model/amazon.titan-embed-text-v1"
  create_agent           = false
  foundation_model       = "anthropic.claude-v2"
  instruction            = "You are an automotive assisant who can provide detailed information about cars to a customer."
}

# This receives the events from S3
resource "aws_sqs_queue" "crawlable_events" {
  name = local.event_name
  // 14 days (AWS maximum)
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

data "aws_iam_policy_document" "crawlable_events" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.crawlable_events.arn]
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [local.bucket_arn]
    }
  }
}

resource "aws_sqs_queue_policy" "crawlable_events" {
  queue_url = aws_sqs_queue.crawlable_events.id
  policy    = data.aws_iam_policy_document.crawlable_events.json
}

resource "aws_s3_bucket_notification" "crawlable_events" {
  bucket = local.bucket_name
  queue {
    queue_arn = aws_sqs_queue.crawlable_events.arn
    events = [
      "s3:ObjectCreated:*",
      "s3:ObjectRemoved:*",
      "s3:ObjectRestore:*"
    ]
  }
  depends_on = [aws_sqs_queue_policy.crawlable_events]
}

resource "aws_cloudwatch_metric_alarm" "crawlable_events" {
  alarm_name          = local.event_name
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = var.crawlable_event_period
  statistic           = "Sum"
  threshold           = var.crawlable_event_threshold
  treat_missing_data  = "notBreaching"
  dimensions = {
    QueueName = aws_sqs_queue.crawlable_events.name
  }
  alarm_actions = [module.trigger_lambda.lambda_function_arn]
}

resource "aws_sqs_queue" "sync_job_dlq" {
  name                    = "sync-job-dlq-${module.bedrock.default_kb_identifier}"
  sqs_managed_sse_enabled = true
}

data "aws_iam_policy_document" "trigger_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:PurgeQueue"]
    resources = [aws_sqs_queue.crawlable_events.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "bedrock:ListIngestionJobs",
      "bedrock:StartIngestionJob"
    ]
    resources = [data.awscc_bedrock_knowledge_base.kb.knowledge_base_arn]
  }
}

module "trigger_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "v7.15.0"

  function_name = "kb-sync-trigger-${module.bedrock.default_kb_identifier}"
  description   = "Trigger Bedrock knowledge base source sync"

  handler                  = "app.lambda_handler"
  runtime                  = "python3.12"
  architectures            = ["arm64"]
  logging_system_log_level = "INFO"
  policy_json              = data.aws_iam_policy_document.trigger_lambda.json
  attach_policy_json       = true

  attach_dead_letter_policy = true
  dead_letter_target_arn    = aws_sqs_queue.sync_job_dlq.arn
  # Critical that this stays at 1
  reserved_concurrent_executions = 1
  # Needs to at least be 60
  timeout = 120

  environment_variables = {
    "SQS_QUEUE"              = aws_sqs_queue.crawlable_events.url
    "KB_IDENTIFIER"          = module.bedrock.default_kb_identifier,
    "DATA_SOURCE_IDENTIFIER" = module.bedrock.datasource_identifier
  }

  source_path = "src/kb-sync-trigger"
  publish     = true
  // No trigger policy required for scheduler because it uses an IAM role with
  // explicit invoke permissions
  allowed_triggers = {
    CWAlarm = {
      principal  = "lambda.alarms.cloudwatch.amazonaws.com"
      source_arn = aws_cloudwatch_metric_alarm.crawlable_events.arn
    }
  }
}

// Scheduled invocation resources
data "aws_iam_policy_document" "trigger_lambda_invoke" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = [module.trigger_lambda.lambda_function_arn]
  }
}

data "aws_iam_policy_document" "trigger_lambda_invoke_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "trigger_lambda_invoke" {
  name   = "trigger-sync-lambda"
  role   = aws_iam_role.trigger_lambda_invoke.id
  policy = data.aws_iam_policy_document.trigger_lambda_invoke.json
}

resource "aws_iam_role" "trigger_lambda_invoke" {
  name               = "trigger-lambda-invoke-${module.bedrock.default_kb_identifier}"
  assume_role_policy = data.aws_iam_policy_document.trigger_lambda_invoke_assume.json
}

resource "aws_scheduler_schedule" "scheduled_sync" {
  name                = "kb-sync-schedule-${module.bedrock.default_kb_identifier}"
  description         = "Backup schedule that will trigger sync for KB ${module.bedrock.default_kb_identifier} if document event threshold is not met"
  schedule_expression = var.sync_job_schedule
  flexible_time_window {
    mode = "OFF"
  }
  target {
    arn      = module.trigger_lambda.lambda_function_arn
    role_arn = aws_iam_role.trigger_lambda_invoke.arn
  }
}

// Ingestion monitoring resources
resource "aws_cloudwatch_log_metric_filter" "indexed_filter" {
  name           = "IndexedFilter"
  pattern        = "{ $.event_type = \"StartIngestionJob.ResourceStatusChanged\" && ($.event.status = %INDEXED%)}"
  log_group_name = module.bedrock.cloudwatch_log_group

  metric_transformation {
    name       = "IndexedCount"
    namespace  = var.kb_metrics_namespace
    value      = 1
    unit       = "Count"
    dimensions = { "DataSourceId" = "$.event.data_source_id" }
  }
}

resource "aws_cloudwatch_log_metric_filter" "deleted_filter" {
  name           = "DeletedFilter"
  pattern        = "{ $.event_type = \"StartIngestionJob.ResourceStatusChanged\" && ($.event.status = \"DELETED\")}"
  log_group_name = module.bedrock.cloudwatch_log_group

  metric_transformation {
    name       = "DeletedCount"
    namespace  = var.kb_metrics_namespace
    value      = 1
    unit       = "Count"
    dimensions = { "DataSourceId" = "$.event.data_source_id" }
  }
}

resource "aws_cloudwatch_log_metric_filter" "failed_filter" {
  name           = "FailedFilter"
  pattern        = "{ $.event_type = \"StartIngestionJob.ResourceStatusChanged\" && ($.event.status = \"FAILED\")}"
  log_group_name = module.bedrock.cloudwatch_log_group

  metric_transformation {
    name       = "FailedCount"
    namespace  = var.kb_metrics_namespace
    value      = 1
    unit       = "Count"
    dimensions = { "DataSourceId" = "$.event.data_source_id" }
  }
}

resource "aws_cloudwatch_dashboard" "ingestion_monitoring" {
  dashboard_name = "KB-Sync-Process-${module.bedrock.default_kb_identifier}"
  dashboard_body = templatefile("${path.module}/templates/dashboard.json.tftpl", {
    sqs_queue_name       = aws_sqs_queue.crawlable_events.name,
    dlq_name             = aws_sqs_queue.sync_job_dlq.name,
    region               = var.region,
    alarm_arn            = aws_cloudwatch_metric_alarm.crawlable_events.arn,
    data_source_id       = module.bedrock.datasource_identifier,
    lambda_function_name = module.trigger_lambda.lambda_function_name,
    kb_metrics_namespace = var.kb_metrics_namespace
  })
}

