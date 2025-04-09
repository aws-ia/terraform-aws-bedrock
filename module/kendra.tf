# Kendra Index
resource "awscc_kendra_index" "genai_kendra_index" {
  count       = var.create_kendra_config && var.kendra_index_arn == null ? 1 : 0
  edition     = var.kendra_index_edition
  name        = "${random_string.solution_prefix.result}-${var.kendra_index_name}"
  role_arn    = awscc_iam_role.kendra_index_role[0].arn
  description = var.kendra_index_description
  capacity_units = {
    query_capacity_units  = var.kendra_index_query_capacity
    storage_capacity_units = var.kendra_index_storage_capacity
  }
  document_metadata_configurations = var.document_metadata_configurations
  server_side_encryption_configuration = {
    kms_key_id = var.kendra_kms_key_id
  }
  user_context_policy = var.kendra_index_user_context_policy
  user_token_configurations = var.user_token_configurations
  tags = var.kendra_index_tags
}

resource "time_sleep" "wait_after_kendra_index_creation" {
  count           = var.create_kendra_config && var.kendra_index_arn == null ? 1 : 0
  depends_on      = [ awscc_kendra_index.genai_kendra_index[0] ]
  create_duration = "60s" # Wait for 60 seconds
}


# Create Kendra Data Source
resource "awscc_kendra_data_source" "kendra_s3_data_source" {
  count    = var.create_kendra_s3_data_source == true ? 1 : 0
  index_id = var.kendra_index_arn != null ? var.kendra_index_arn : awscc_kendra_index.genai_kendra_index[0].id
  name     = "${random_string.solution_prefix.result}-${var.kendra_data_source_name}"
  type     = "S3"
  role_arn = awscc_iam_role.kendra_s3_datasource_role[0].arn
  language_code = var.kendra_data_source_language_code
  schedule = var.kendra_data_source_schedule
  description = var.kendra_data_source_description
  tags = var.kendra_data_source_tags
  data_source_configuration = {
    s3_configuration = {
      bucket_name = var.s3_data_source_bucket_name != null ? var.s3_data_source_bucket_name : awscc_s3_bucket.s3_data_source[0].bucket_name
      exclusion_patterns = var.s3_data_source_exclusion_patterns
      inclusion_patterns = var.s3_data_source_inclusion_patterns
      documents_metadata_configuration = {
        s3_prefix = var.s3_data_source_document_metadata_prefix
      }
      access_control_list_documents = {
        key_path = var.s3_data_source_key_path
      }
    } 
  }
}

resource "time_sleep" "wait_after_kendra_s3_data_source_creation" {
  count           = var.create_kendra_s3_data_source ? 1 : 0
  depends_on      = [ awscc_kendra_data_source.kendra_s3_data_source[0] ]
  create_duration = "60s" # Wait for 60 seconds
}