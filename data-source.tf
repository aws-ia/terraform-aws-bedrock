locals {
  create_cwl      = var.create_default_kb && var.create_kb_log_group
  create_delivery = local.create_cwl || var.kb_monitoring_arn != null
  create_s3_data_source = var.create_default_kb == true || var.create_s3_data_source == true
}

# - Knowledge Base S3 Data Source –
resource "awscc_s3_bucket" "s3_data_source" {
  count       = local.create_s3_data_source && var.kb_s3_data_source == null ? 1 : 0
  bucket_name = "${random_string.solution_prefix.result}-${var.kb_name}-default-bucket"

  public_access_block_configuration = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  bucket_encryption = {
    server_side_encryption_configuration = [{
      bucket_key_enabled = true
      server_side_encryption_by_default = {
        sse_algorithm     = var.kb_s3_data_source_kms_arn == null ? "AES256" : "aws:kms"
        kms_master_key_id = var.kb_s3_data_source_kms_arn
      }
    }]
  }

  tags = [{
    key   = "Name"
    value = "S3 Data Source"
  }]

}

resource "aws_bedrockagent_data_source" "knowledge_base_ds" {
  count             = local.create_s3_data_source ? 1 : 0
  knowledge_base_id = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name              = "${random_string.solution_prefix.result}-${var.kb_name}DataSource"
  data_source_configuration {
    type = "S3"
    s3_configuration {
      bucket_arn = var.kb_s3_data_source == null ? awscc_s3_bucket.s3_data_source[0].arn : var.kb_s3_data_source # Create an S3 bucket or reference existing
    }
  }
}

resource "aws_cloudwatch_log_group" "knowledge_base_cwl" {
  #tfsec:ignore:log-group-customer-key
  #checkov:skip=CKV_AWS_158:Encryption not required for log group
  count             = local.create_cwl ? 1 : 0
  name              = "/aws/vendedlogs/bedrock/knowledge-base/APPLICATION_LOGS/${awscc_bedrock_knowledge_base.knowledge_base_default[0].id}"
  retention_in_days = var.kb_log_group_retention_in_days
}

resource "awscc_logs_delivery_source" "knowledge_base_log_source" {
  count        = local.create_delivery ? 1 : 0
  name         = "${random_string.solution_prefix.result}-${var.kb_name}-delivery-source"
  log_type     = "APPLICATION_LOGS"
  resource_arn = awscc_bedrock_knowledge_base.knowledge_base_default[0].knowledge_base_arn
}

resource "awscc_logs_delivery_destination" "knowledge_base_log_destination" {
  count                    = local.create_delivery ? 1 : 0
  name                     = "${random_string.solution_prefix.result}-${var.kb_name}-delivery-destination"
  output_format            = "json"
  destination_resource_arn = local.create_cwl ? aws_cloudwatch_log_group.knowledge_base_cwl[0].arn : var.kb_monitoring_arn
  tags = [{
    key   = "Name"
    value = "${random_string.solution_prefix.result}-${var.kb_name}-delivery-destination"
  }]
}

resource "awscc_logs_delivery" "knowledge_base_log_delivery" {
  count                    = local.create_delivery ? 1 : 0
  delivery_destination_arn = awscc_logs_delivery_destination.knowledge_base_log_destination[0].arn
  delivery_source_name     = awscc_logs_delivery_source.knowledge_base_log_source[0].name
  tags = [{
    key   = "Name"
    value = "${random_string.solution_prefix.result}-${var.kb_name}-delivery"
  }]
}

# – Knowledge Base Web Crawler Data Source
resource "awscc_bedrock_data_source" "knowledge_base_web_crawler" {
  count             = var.create_web_crawler ? 1 : 0
  knowledge_base_id = var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : var.existing_kb
  name              = "${random_string.solution_prefix.result}-${var.kb_name}DataSourceWebCrawler"
  data_source_configuration = {
    type = "WEB"
    web_configuration = {
      crawler_configuration = {
        crawler_limits = {
          rate_limit = var.rate_limit
        }
        exclusion_filters = var.exclusion_filters
        inclusion_filters = var.inclusion_filters
        scope             = var.crawler_scope
      }
      source_configuration = {
        url_configuration = {
          seed_urls = var.seed_urls
        }
      }
    }
  }
}
