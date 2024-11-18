variable "name_prefix" {
  description = "This value is appended at the beginning of resource names."
  type        = string
  default     = "BedrockAgents"
}

# – Bedrock Agent –
variable "agent_name" {
  description = "The name of your agent."
  type        = string
  default     = "TerraformBedrockAgents"
}

variable "create_agent" {
  description = "Whether or not to deploy an agent."
  type        = bool
  default     = true
}

variable "foundation_model" {
  description = "The foundation model for the Bedrock agent."
  type        = string
}

# instruction must be greater than 40 characters
variable "instruction" {
  description = "A narrative instruction to provide the agent as context."
  type        = string

  validation {
    condition     = length(var.instruction) >= 40
    error_message = "Instruction string length must be at least 40."
  }
}

variable "agent_description" {
  description = "A description of agent."
  type        = string
  default     = null
}

variable "idle_session_ttl" {
  description = "How long sessions should be kept open for the agent."
  type        = number
  default     = 600
}

variable "kms_key_arn" {
  description = "KMS encryption key to use for the agent."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tag bedrock agent resource."
  type        = map(string)
  default     = null
}

# – Prompt Override Configuartion –
variable "prompt_override" {
  description = "Whether to provide prompt override configuration."
  type        = bool
  default     = false
}

variable "prompt_type" {
  description = "The step in the agent sequence that this prompt configuration applies to."
  type        = string
  default     = null

  validation {
    condition     = var.prompt_type == "PRE_PROCESSING" || var.prompt_type == "ORCHESTRATION" || var.prompt_type == "POST_PROCESSING" || var.prompt_type == "KNOWLEDGE_BASE_RESPONSE_GENERATION" || var.prompt_type == null
    error_message = "Not a valid prompt_type."
  }
}

# must contain non-whitespace characters
variable "base_prompt_template" {
  description = "Defines the prompt template with which to replace the default prompt template."
  type        = string
  default     = null
}

variable "parser_mode" {
  description = "Specifies whether to override the default parser Lambda function."
  type        = string
  default     = null

  validation {
    condition     = var.parser_mode == "DEFAULT" || var.parser_mode == "OVERRIDDEN" || var.parser_mode == null
    error_message = "The parser_mode must be set to DEFAULT or OVERRIDDEN."
  }
}

variable "prompt_creation_mode" {
  description = "Specifies whether to override the default prompt template."
  type        = string
  default     = null

  validation {
    condition     = var.prompt_creation_mode == "DEFAULT" || var.prompt_creation_mode == "OVERRIDDEN" || var.prompt_creation_mode == null
    error_message = "The prompt_creation_mode must be set to DEFAULT or OVERRIDDEN."
  }
}

variable "prompt_state" {
  description = "Specifies whether to allow the agent to carry out the step specified in the promptType."
  type        = string
  default     = null

  validation {
    condition     = var.prompt_state == "ENABLED" || var.prompt_state == "DISABLED" || var.prompt_state == null
    error_message = "The prompt_state must be set to ENABLED or DISABLED."
  }
}

variable "override_lambda_arn" {
  description = "The ARN of the Lambda function to use when parsing the raw foundation model output in parts of the agent sequence."
  type        = string
  default     = null
}

# – Inference Configuration –

variable "temperature" {
  description = "The likelihood of the model selecting higher-probability options while generating a response."
  type        = number
  default     = 0

  validation {
    condition     = var.temperature >= 0 && var.temperature <= 1
    error_message = "The temperature must be between 0 and 1."
  }
}

variable "top_p" {
  description = "Cumulative probability cutoff for token selection."
  type        = number
  default     = 0.50

  validation {
    condition     = var.top_p >= 0 && var.top_p <= 1.00
    error_message = "The top_p must be between 0 and 1.00."
  }
}

variable "top_k" {
  description = "Sample from the k most likely next tokens."
  type        = number
  default     = 50

  validation {
    condition     = var.top_k >= 0 && var.top_k <= 500
    error_message = "The top_k must be between 0 and 500."
  }
}

variable "stop_sequences" {
  description = "A list of stop sequences."
  type        = list(string)
  default     = []

  validation {
    condition     = length(var.stop_sequences) >= 0 && length(var.stop_sequences) <= 4
    error_message = "The stop_sequences length must be between 0 and 4."
  }
}

variable "max_length" {
  description = "The maximum number of tokens to generate in the response."
  type        = number
  default     = 0

  validation {
    condition     = var.max_length >= 0 && var.max_length <= 4096
    error_message = "The max_length must be between 0 and 4096."
  }
}

# – Guardrails –

variable "create_guardrail" {
  description = "Whether or not to create a guardrail."
  type        = bool
  default     = false
}

variable "guardrail_name" {
  description = "The name of the guardrail."
  type        = string
  default     = "TerraformBedrockGuardrail"
}

variable "blocked_input_messaging" {
  description = "Messaging for when violations are detected in text."
  type        = string
  default     = "Blocked input"
}

variable "blocked_outputs_messaging" {
  description = "Messaging for when violations are detected in text."
  type        = string
  default     = "Blocked output"
}

variable "guardrail_description" {
  description = "Description of the guardrail."
  type        = string
  default     = null
}

variable "filters_config" {
  description = "List of content filter configs in content policy."
  type        = list(map(string))
  default     = null
}

variable "pii_entities_config" {
  description = "List of entities."
  type        = list(map(string))
  default     = null
}

variable "regexes_config" {
  description = "List of regex."
  type        = list(map(string))
  default     = null
}

variable "managed_word_lists_config" {
  description = "A config for the list of managed words."
  type        = list(map(string))
  default     = null
}

variable "words_config" {
  description = "List of custom word configs."
  type        = list(map(string))
  default     = null
}

variable "topics_config" {
  description = "List of topic configs in topic policy"
  type        = list( object({
                  name       = string
                  examples   = list(string)
                  type       = string
                  definition = string
                }))
  default     = null
}

variable "guardrail_tags" {
  description = "A map of tags keys and values for the knowledge base."
  type        = list(map(string))
  default     = null
}

variable "guardrail_kms_key_arn" {
  description = "KMS encryption key to use for the guardrail."
  type        = string
  default     = null
}


# – Knowledge Base –

variable "existing_kb" {
  description = "The ID of the existing knowledge base."
  type        = string
  default     = null
}

variable "create_kb" {
  description = "Whether or not to attach a knowledge base."
  type        = bool
  default     = false
}

variable "create_default_kb" {
  description = "Whether or not to create the default knowledge base."
  type        = bool
  default     = false
}

variable "kb_s3_data_source" {
  description = "The S3 data source ARN for the knowledge base."
  type        = string
  default     = null
}

variable "kb_s3_data_source_kms_arn" {
  description = "The ARN of the KMS key used to encrypt S3 content"
  type        = string
  default     = null
}

variable "kb_name" {
  description = "Name of the knowledge base."
  type        = string
  default     = "knowledge-base"
}

variable "kb_tags" {
  description = "A map of tags keys and values for the knowledge base."
  type        = map(string)
  default     = null
}

variable "vector_index_name" {
  description = "The name of the vector index."
  type        = string
  default     = "bedrock-knowledge-base-default-index"
}

variable "metadata_field" {
  description = "The name of the field in which Amazon Bedrock stores metadata about the vector store."
  type        = string
  default     = "AMAZON_BEDROCK_METADATA"
}

variable "text_field" {
  description = "The name of the field in which Amazon Bedrock stores the raw text from your data."
  type        = string
  default     = "AMAZON_BEDROCK_TEXT_CHUNK"
}

variable "vector_field" {
  description = "The name of the field where the vector embeddings are stored"
  type        = string
  default     = "bedrock-knowledge-base-default-vector"
}

variable "collection_arn" {
  description = "The ARN of the collection."
  type        = string
  default     = null
}

variable "collection_name" {
  description = "The name of the collection."
  type        = string
  default     = null
}

variable "kb_role_arn" {
  description = "The ARN of the IAM role with permission to invoke API operations on the knowledge base."
  type        = string
  default     = null
}

variable "kb_description" {
  description = "Description of knowledge base."
  type        = string
  default     = "Terraform deployed Knowledge Base"
}

variable "kb_type" {
  description = "The type of a knowledge base."
  type        = string
  default     = null
}

variable "kb_embedding_model_arn" {
  description = "The ARN of the model used to create vector embeddings for the knowledge base."
  type        = string
  default     = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"
}

variable "kb_storage_type" {
  description = "The storage type of a knowledge base."
  type        = string
  default     = null
}

variable "kb_state" {
  description = "State of knowledge base; whether it is enabled or disabled"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = var.kb_state == "ENABLED" || var.kb_state == "DISABLED"
    error_message = "Not a valid kb_state."
  }
}

variable "credentials_secret_arn" {
  description = "The ARN of the secret in Secrets Manager that is linked to your database"
  type        = string
  default     = null
}

variable "database_name" {
  description = "Name of the database."
  type        = string
  default     = null
}

variable "endpoint" {
  description = "Database endpoint"
  type        = string
  default     = null
}

variable "kb_monitoring_arn" {
  description = "The ARN of the target for delivery of knowledge base application logs"
  type        = string
  default     = null
}

variable "create_kb_log_group" {
  description = "Whether or not to create a log group for the knowledge base."
  type        = bool
  default     = false
}

variable "kb_log_group_retention_in_days" {
  description = "The retention period of the knowledge base log group."
  type        = number
  default     = 0
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653, 0], var.kb_log_group_retention_in_days)
    error_message = "The provided retention period is not a valid CloudWatch logs retention period"
  }
}

# – MongoDB Atlas Configuration –

variable "create_mongo_config" {
  description = "Whether or not to use MongoDB Atlas configuration"
  type        = bool
  default     = false
}

variable "endpoint_service_name" {
  description = "MongoDB Atlas endpoint service name."
  type        = string
  default     = null
}


# – Opensearch Serverless Configuration –
# the default vector database

variable "create_opensearch_config" {
  description = "Whether or not to use Opensearch Serverless configuration"
  type        = bool
  default     = false
}

# – Pinecone Configuration –

variable "create_pinecone_config" {
  description = "Whether or not to use Pinecone configuration"
  type        = bool
  default     = false
}

variable "connection_string" {
  description = "The endpoint URL for your index management page."
  type        = string
  default     = null
}

variable "namespace" {
  description = "The namespace to be used to write new data to your pinecone database"
  type        = string
  default     = null
}

# – RDS Configuration –

variable "create_rds_config" {
  description = "Whether or not to use RDS configuration"
  type        = bool
  default     = false
}

variable "resource_arn" {
  description = "The ARN of the vector store."
  type        = string
  default     = null
}

variable "table_name" {
  description = "The name of the table in the database."
  type        = string
  default     = null
}

variable "primary_key_field" {
  description = "The name of the field in which Bedrock stores the ID for each entry."
  type        = string
  default     = null
}

# – Action Group –

variable "create_ag" {
  description = "Whether or not to create an action group."
  type        = bool
  default     = false
}

variable "action_group_name" {
  description = "Name of the action group."
  type        = string
  default     = null
}

variable "action_group_state" {
  description = "State of the action group."
  type        = string
  default     = null
}

variable "action_group_description" {
  description = "Description of the action group."
  type        = string
  default     = null
}

variable "parent_action_group_signature" {
  description = "Action group signature for a builtin action."
  type        = string
  default     = null
}

variable "skip_resource_in_use" {
  description = "Specifies whether to allow deleting action group while it is in use."
  type        = bool
  default     = null
}

# – Action Group Executor –

variable "custom_control" {
  description = "Custom control of action execution."
  type        = string
  default     = null
}

variable "lambda_action_group_executor" {
  description = "ARN of Lambda."
  type        = string
  default     = null
}

# – Action Group API Schema –

variable "api_schema_payload" {
  description = "String OpenAPI Payload."
  type        = string
  default     = null
}

variable "api_schema_s3_bucket_name" {
  description = "A bucket in S3."
  type        = string
  default     = null
}

variable "api_schema_s3_object_key" {
  description = "An object key in S3."
  type        = string
  default     = null
}

# – Function Schema –

variable "function_name" {
  description = "Name for a resource."
  type        = string
  default     = null
}

variable "function_description" {
  description = "Description of function."
  type        = string
  default     = null
}

variable "function_parameters_description" {
  description = "Description of function parameter."
  type        = string
  default     = null
}

variable "function_parameters_required" {
  description = "If a parameter is required for a function call."
  type        = bool
  default     = false
}

variable "function_parameters_type" {
  description = "Parameter type."
  type        = string
  default     = null
}
