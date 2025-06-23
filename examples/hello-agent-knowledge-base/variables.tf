variable "aws_region" {
  description = "AWS region to deploy Bedrock resources"
  type        = string
  default     = "us-gov-west-1"
}

variable "agent_name" {
  description = "Name of the Bedrock Agent"
  type        = string
  default     = "demo-agent"
}

variable "knowledge_base_name" {
  description = "Name of the Knowledge Base"
  type        = string
  default     = "demo-kb"
}
