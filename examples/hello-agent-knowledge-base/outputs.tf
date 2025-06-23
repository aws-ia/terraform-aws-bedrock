output "agent_id" {
  description = "The ID of the Bedrock Agent"
  value       = module.bedrock.bedrock_agent[0].id
}

output "agent_alias_id" {
  description = "The ID of the Bedrock Agent Alias"
  value       = module.bedrock.bedrock_agent_alias[0].id
}

output "knowledge_base_id" {
  description = "The ID of the Amazon Bedrock Knowledge Base."
  # CORRECTED: Uses the specific output from your list.
  value       = module.bedrock.default_kb_identifier
}

output "knowledge_base_data_source_id" {
  description = "The ID of the Knowledge Base's data source."
  # CORRECTED: Uses the specific output from your list.
  value       = module.bedrock.datasource_identifier
}

output "knowledge_base_s3_bucket_name" {
  description = "The name of the S3 bucket created for the Knowledge Base data source."
  value       = module.bedrock.s3_data_source_name
}