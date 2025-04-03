output "default_collection" {
  value       = var.create_default_kb ? module.oss_knowledgebase[0].opensearch_serverless_collection : null
  description = "Opensearch default collection value."
}

output "default_kb_identifier" {
  value       = length(awscc_bedrock_knowledge_base.knowledge_base_default) > 0 ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : null
  description = "The unique identifier of the default knowledge base that was created.  If no default KB was requested, value will be null"
}

output "mongo_kb_identifier" {
  value       = length(awscc_bedrock_knowledge_base.knowledge_base_mongo) > 0 ? awscc_bedrock_knowledge_base.knowledge_base_mongo[0].id : null
  description = "The unique identifier of the MongoDB knowledge base that was created.  If no MongoDB KB was requested, value will be null"
}

output "opensearch_kb_identifier" {
  value       = length(awscc_bedrock_knowledge_base.knowledge_base_opensearch) > 0 ? awscc_bedrock_knowledge_base.knowledge_base_opensearch[0].id : null
  description = "The unique identifier of the OpenSearch knowledge base that was created.  If no OpenSearch KB was requested, value will be null"
}

output "pinecone_kb_identifier" {
  value       = length(awscc_bedrock_knowledge_base.knowledge_base_pinecone) > 0 ? awscc_bedrock_knowledge_base.knowledge_base_pinecone[0].id : null
  description = "The unique identifier of the Pinecone knowledge base that was created.  If no Pinecone KB was requested, value will be null"
}

output "rds_kb_identifier" {
  value       = length(awscc_bedrock_knowledge_base.knowledge_base_rds) > 0 ? awscc_bedrock_knowledge_base.knowledge_base_rds[0].id : null
  description = "The unique identifier of the RDS knowledge base that was created.  If no RDS KB was requested, value will be null"
}

output "datasource_identifier" {
  value       = length(aws_bedrockagent_data_source.knowledge_base_ds) > 0 ? aws_bedrockagent_data_source.knowledge_base_ds[0].data_source_id : null
  description = "The unique identifier of the data source."
}

output "cloudwatch_log_group" {
  value       = length(aws_cloudwatch_log_group.knowledge_base_cwl) > 0 ? aws_cloudwatch_log_group.knowledge_base_cwl[0].name : null
  description = "The name of the CloudWatch log group for the knowledge base.  If no log group was requested, value will be null"
}

output "bedrock_agent" {
  value       = var.create_agent == true ? awscc_bedrock_agent.bedrock_agent : null
  description = "The Amazon Bedrock Agent if it is created."
}

output "s3_data_source_arn" {
  value       = var.kb_s3_data_source != null ? var.kb_s3_data_source : var.create_default_kb ? length(awscc_s3_bucket.s3_data_source) > 0 ? awscc_s3_bucket.s3_data_source[0].arn : null : null
  description = "The Amazon Bedrock Data Source for S3."
}

output "s3_data_source_name" {
  value       = var.kb_s3_data_source != null ? split(":", var.kb_s3_data_source)[5] : var.create_default_kb ? length(awscc_s3_bucket.s3_data_source) > 0 ? awscc_s3_bucket.s3_data_source[0].id : null : null
  description = "The name of the Amazon Bedrock Data Source for S3."
}

output "supervisor_id" {
  value       = var.create_supervisor ? aws_bedrockagent_agent.agent_supervisor[0].agent_id : null
  description = "The identifier of the supervisor agent."
}

output "bda_blueprint" {
  value       = var.create_blueprint ? awscc_bedrock_blueprint.bda_blueprint[0] : null
  description = "The BDA blueprint."
}


output "agent_resource_role_arn" {
  value       = var.agent_resource_role_arn != null ? var.agent_resource_role_arn : (var.create_agent ? aws_iam_role.agent_role[0].arn : null)
  description = "The ARN of the Bedrock agent resource role."
}

output "agent_resource_role_name" {
  value       = var.agent_resource_role_arn != null ? split("/", var.agent_resource_role_arn)[1] : (var.create_agent ? aws_iam_role.agent_role[0].name : null)
  description = "The name of the Bedrock agent resource role."
}

output "custom_model" {
  value       = var.create_custom_model ? aws_bedrock_custom_model.custom_model[0] : null
  description = "The custom model. If no custom model was requested, value will be null."
}

output "knowledge_base_role_name" {
  description = "The name of the IAM role used by the knowledge base."
  value       = local.create_kb_role ? aws_iam_role.bedrock_knowledge_base_role[0].name : null
}
