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
  default     = null
}

# instruction must be greater than 40 characters
variable "instruction" {
  description = "A narrative instruction to provide the agent as context."
  type        = string
  default     = ""

  validation {
    condition     = length(var.instruction) == 0 || length(var.instruction) >= 40
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

# – Orchestration Configuration –
variable "orchestration_type" {
  description = "The type of orchestration strategy for the agent. Valid values: DEFAULT, CUSTOM_ORCHESTRATION"
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "CUSTOM_ORCHESTRATION"], var.orchestration_type)
    error_message = "The orchestration_type must be either DEFAULT or CUSTOM_ORCHESTRATION."
  }
}

variable "custom_orchestration_lambda_arn" {
  description = "ARN of the Lambda function to use for custom orchestration. Required when orchestration_type is set to CUSTOM."
  type        = string
  default     = null
}

# – Prompt Override Configuration –
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

variable "additional_model_request_fields" {
  description = "Additional model request fields for prompt configuration in JSON format."
  type        = string
  default     = null
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

# – Agent Alias – 

variable "create_agent_alias" {
  description = "Whether or not to create an agent alias."
  type        = bool
  default     = false
}

variable "agent_alias_name" {
  description = "The name of the agent alias."
  type        = string
  default     = "TerraformBedrockAgentAlias"
}

variable "agent_id" {
  description = "Agent identifier."
  type        = string
  default     = null
}

variable "agent_alias_description" {
  description = "Description of the agent alias."
  type        = string
  default     = null
}

variable "use_aws_provider_alias" {
  description = "Whether or not to use the aws or awscc provider for the agent alias. Defaults to using the awscc provider."
  type        = bool
  default     = false
}

variable "bedrock_agent_alias_provisioned_throughput" {
  description = "ARN of the Provisioned Throughput assigned to the agent alias."
  type        = string
  default     = null
}

variable "bedrock_agent_version" {
  description = "Agent version."
  type        = string
  default     = null
}

variable "agent_alias_tags" {
  description = "Tag bedrock agent alias resource."
  type        = map(string)
  default     = null
}

# – Agent Collaborator – 

variable "create_collaborator" {
  description = "Whether or not to create an agent collaborator."
  type        = bool
  default     = false
}

variable "collaboration_instruction" {
  description = "Instruction to give the collaborator."
  type        = string
  default     = null
}

variable "collaborator_name" {
  description = "The name of the collaborator."
  type        = string
  default     = "TerraformBedrockAgentCollaborator"
}

variable "relay_conversation_history" {
  description = "Relay conversation history setting will share conversation history to collaborator if enabled."
  type        = string
  default     = "TO_COLLABORATOR" # TO_COLLABORATOR or DISABLED
}

variable "create_supervisor" {
  description = "Whether or not to create an agent supervisor."
  type        = bool
  default     = false
}

variable "supervisor_id" {
  description = "The ID of the supervisor."
  type        = string
  default     = null
}

variable "supervisor_name" {
  description = "The name of the supervisor."
  type        = string
  default     = "TerraformBedrockAgentSupervisor"
}

variable "supervisor_idle_session_ttl" {
  description = "How long sessions should be kept open for the supervisor agent."
  type        = number
  default     = 600
}

variable "supervisor_model" {
  description = "The foundation model for the Bedrock supervisor agent."
  type        = string
  default     = null
}

variable "supervisor_instruction" {
  description = "A narrative instruction to provide the agent as context."
  type        = string
  default     = ""

  validation {
    condition     = length(var.supervisor_instruction) == 0 || length(var.supervisor_instruction) >= 40
    error_message = "Instruction string length must be at least 40."
  }
}

variable "agent_collaboration" {
  description = "Agents collaboration role."
  type        = string
  default     = "SUPERVISOR"

  validation {
    condition     = var.agent_collaboration == "SUPERVISOR" || var.agent_collaboration == "SUPERVISOR_ROUTER"
    error_message = "Valid values: SUPERVISOR or SUPERVISOR_ROUTER"
  }
}

variable "supervisor_kms_key_arn" {
  description = "KMS encryption key to use for the supervisor agent."
  type        = string
  default     = null
}

variable "create_supervisor_guardrail" {
  description = "Whether or not to create a guardrail for the supervisor agent."
  type        = bool
  default     = false
}

variable "supervisor_guardrail_id" {
  description = "The ID of the guardrail for the supervisor agent."
  type        = string
  default     = null
}

variable "supervisor_guardrail_version" {
  description = "The version of the guardrail for the supervisor agent."
  type        = string
  default     = null
}

# Memory Configuration 

variable "memory_configuration" {
  description = "Configuration for agent memory storage"
  type = object({
    enabled_memory_types = optional(list(string))
    session_summary_configuration = optional(object({
      max_recent_sessions = optional(number)
    }))
    storage_days = optional(number)
  })
  default = null
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
  description = "List of content filter configs in content policy. Supports both text and image filters. Use 'input_modalities' and 'output_modalities' (list of strings) to specify content types: ['TEXT'] for text-only, ['IMAGE'] for image-only, or ['TEXT', 'IMAGE'] to apply the same filter to both text and image content in a single filter configuration. Filter types include: HATE, INSULTS, MISCONDUCT, PROMPT_ATTACK, SEXUAL, VIOLENCE."
  type = list(object({
    input_action      = optional(string)
    input_enabled     = optional(bool)
    input_modalities  = optional(list(string))
    input_strength    = optional(string)
    output_action     = optional(string)
    output_enabled    = optional(bool)
    output_modalities = optional(list(string))
    output_strength   = optional(string)
    type              = optional(string)
  }))
  default = null
}

variable "contextual_grounding_policy_filters" {
  description = "The contextual grounding policy filters for the guardrail."
  type = list(object({
    action    = optional(string)
    enabled   = optional(bool)
    threshold = optional(number)
    type      = optional(string)
  }))
  default = null
}

variable "pii_entities_config" {
  description = "List of PII entities configuration for sensitive information policy."
  type = list(object({
    action         = optional(string)
    input_action   = optional(string)
    input_enabled  = optional(bool)
    output_action  = optional(string)
    output_enabled = optional(bool)
    type           = optional(string)
  }))
  default = null
}

variable "regexes_config" {
  description = "List of regex patterns for sensitive information policy."
  type = list(object({
    action         = optional(string)
    description    = optional(string)
    input_action   = optional(string)
    input_enabled  = optional(bool)
    name           = optional(string)
    output_action  = optional(string)
    output_enabled = optional(bool)
    pattern        = optional(string)
  }))
  default = null
}

variable "managed_word_lists_config" {
  description = "A config for the list of managed words in word policy."
  type = list(object({
    input_action   = optional(string)
    input_enabled  = optional(bool)
    output_action  = optional(string)
    output_enabled = optional(bool)
    type           = optional(string)
  }))
  default = null
}

variable "words_config" {
  description = "List of custom word configs in word policy."
  type = list(object({
    input_action   = optional(string)
    input_enabled  = optional(bool)
    output_action  = optional(string)
    output_enabled = optional(bool)
    text           = optional(string)
  }))
  default = null
}

variable "topics_config" {
  description = "List of topic configs in topic policy."
  type = list(object({
    definition     = optional(string)
    examples       = optional(list(string))
    input_action   = optional(string)
    input_enabled  = optional(bool)
    name           = optional(string)
    output_action  = optional(string)
    output_enabled = optional(bool)
    type           = optional(string)
  }))
  default = null
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

# – Guardrail Automated Reasoning Policy Configuration –
variable "automated_reasoning_policy_config" {
  description = "Optional configuration for integrating Automated Reasoning policies with the guardrail."
  type = object({
    confidence_threshold = optional(number)
    policies             = optional(list(string))
  })
  default = null
}

# – Guardrail Cross Region Configuration –
variable "guardrail_cross_region_config" {
  description = "The system-defined guardrail profile to use with your guardrail."
  type = object({
    guardrail_profile_arn = optional(string)
  })
  default = null
}

# – Guardrail Content Policy Tier Configuration –
variable "content_filters_tier_config" {
  description = "Guardrail tier config for content policy."
  type = object({
    tier_name = optional(string)
  })
  default = null
}

# – Guardrail Topic Policy Tier Configuration –
variable "topics_tier_config" {
  description = "Guardrail tier config for topic policy."
  type = object({
    tier_name = optional(string)
  })
  default = null
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

variable "data_deletion_policy" {
  description = "Policy for deleting data from the data source. Can be either DELETE or RETAIN."
  type        = string
  default     = "DELETE"
}

# – OpenSearch Managed Cluster Configuration –
variable "create_opensearch_managed_config" {
  description = "Whether or not to use OpenSearch Managed Cluster configuration"
  type        = bool
  default     = false
}

variable "domain_arn" {
  description = "The Amazon Resource Name (ARN) of the OpenSearch domain."
  type        = string
  default     = null
}

variable "domain_endpoint" {
  description = "The endpoint URL the OpenSearch domain."
  type        = string
  default     = null
}

# – S3 Data Source –

variable "create_s3_data_source" {
  description = "Whether or not to create the S3 data source."
  type        = bool
  default     = false
}

variable "use_existing_s3_data_source" {
  description = "Whether or not to use an existing S3 data source."
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

variable "bucket_owner_account_id" {
  description = "Bucket account owner ID for the S3 bucket."
  type        = string
  default     = null
}

variable "s3_inclusion_prefixes" {
  description = "List of S3 prefixes that define the object containing the data sources."
  type        = list(string)
  default     = null
}

# – Web Crawler Data Source – 

variable "create_web_crawler" {
  description = "Whether or not create a web crawler data source."
  type        = bool
  default     = false
}

variable "rate_limit" {
  description = "Rate of web URLs retrieved per minute."
  type        = number
  default     = null
}

variable "exclusion_filters" {
  description = "A set of regular expression filter patterns for a type of object."
  type        = list(string)
  default     = []
}

variable "inclusion_filters" {
  description = "A set of regular expression filter patterns for a type of object."
  type        = list(string)
  default     = []
}

variable "crawler_scope" {
  description = "The scope that a web crawl job will be restricted to."
  type        = string
  default     = null
}

variable "seed_urls" {
  description = "A list of web urls."
  type        = list(object({ url = string }))
  default     = []
}

variable "user_agent" {
  description = "The suffix that will be included in the user agent header for web crawling."
  type        = string
  default     = null
}

variable "max_pages" {
  description = "Maximum number of pages the crawler can crawl."
  type        = number
  default     = null
}

# – Confluence Data Source – 

variable "create_confluence" {
  description = "Whether or not create a Confluence data source."
  type        = bool
  default     = false
}

variable "pattern_object_filter_list" {
  description = "List of pattern object information."
  type = list(object({
    exclusion_filters = optional(list(string))
    inclusion_filters = optional(list(string))
    object_type       = optional(string)

  }))
  default = []
}

variable "crawl_filter_type" {
  description = "The crawl filter type."
  type        = string
  default     = null
}

variable "auth_type" {
  description = "The supported authentication type."
  type        = string
  default     = null
}

variable "confluence_credentials_secret_arn" {
  description = "The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your Confluence instance URL."
  type        = string
  default     = null
}

variable "host_type" {
  description = "The supported host type, whether online/cloud or server/on-premises."
  type        = string
  default     = null
}

variable "host_url" {
  description = "The host URL or instance URL."
  type        = string
  default     = null
}

# – Sharepoint Data Source – 

variable "create_sharepoint" {
  description = "Whether or not create a Share Point data source."
  type        = bool
  default     = false
}

variable "share_point_credentials_secret_arn" {
  description = "The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your SharePoint site/sites."
  type        = string
  default     = null
}

variable "share_point_domain" {
  description = "The domain of your SharePoint instance or site URL/URLs."
  type        = string
  default     = null
}

variable "share_point_site_urls" {
  description = "A list of one or more SharePoint site URLs."
  type        = list(string)
  default     = []
}

variable "tenant_id" {
  description = "The identifier of your Microsoft 365 tenant."
  type        = string
  default     = null
}

# – Salesforce Data Source –

variable "create_salesforce" {
  description = "Whether or not create a Salesforce data source."
  type        = bool
  default     = false
}

variable "salesforce_credentials_secret_arn" {
  description = "The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your Salesforce instance URL."
  type        = string
  default     = null
}

# – Server-Side Encryption Configuration –
variable "create_server_side_encryption_config" {
  description = "Whether or not to create server-side encryption configuration for the data source."
  type        = bool
  default     = false
}

variable "data_source_kms_key_arn" {
  description = "The ARN of the AWS KMS key used to encrypt the data source."
  type        = string
  default     = null
}

# – Context Enrichment Configuration –
variable "create_context_enrichment_config" {
  description = "Whether or not to create context enrichment configuration for the data source."
  type        = bool
  default     = false
}

variable "context_enrichment_type" {
  description = "Enrichment type to be used for the vector database."
  type        = string
  default     = null
}

variable "context_enrichment_model_arn" {
  description = "The model's ARN for context enrichment."
  type        = string
  default     = null
}

variable "enrichment_strategy_method" {
  description = "Enrichment Strategy method."
  type        = string
  default     = null
}

# – Bedrock Data Automation Configuration –
variable "create_bedrock_data_automation_config" {
  description = "Whether or not to create Bedrock Data Automation configuration for the data source."
  type        = bool
  default     = false
}

variable "parsing_modality" {
  description = "Determine how parsed content will be stored."
  type        = string
  default     = null
}

variable "data_source_description" {
  description = "Description of the data source."
  type        = string
  default     = null
}

# – Data Source Vector Ingestion – 

variable "create_vector_ingestion_configuration" {
  description = "Whether or not to create a vector ingestion configuration."
  type        = bool
  default     = false
}

variable "create_custom_tranformation_config" {
  description = "Whether or not to create a custom transformation configuration."
  type        = bool
  default     = false
}

variable "create_parsing_configuration" {
  description = "Whether or not to create a parsing configuration."
  type        = bool
  default     = false
}

variable "chunking_strategy" {
  description = "Knowledge base can split your source data into chunks. A chunk refers to an excerpt from a data source that is returned when the knowledge base that it belongs to is queried. You have the following options for chunking your data. If you opt for NONE, then you may want to pre-process your files by splitting them up such that each file corresponds to a chunk."
  type        = string
  default     = null
}

variable "chunking_strategy_max_tokens" {
  description = "The maximum number of tokens to include in a chunk."
  type        = number
  default     = null
}

variable "chunking_strategy_overlap_percentage" {
  description = "The percentage of overlap between adjacent chunks of a data source."
  type        = number
  default     = null
}

variable "level_configurations_list" {
  description = "Token settings for each layer."
  type        = list(object({ max_tokens = number }))
  default     = null
}

variable "heirarchical_overlap_tokens" {
  description = "The number of tokens to repeat across chunks in the same layer."
  type        = number
  default     = null
}

variable "breakpoint_percentile_threshold" {
  description = "The dissimilarity threshold for splitting chunks."
  type        = number
  default     = null
}

variable "semantic_buffer_size" {
  description = "The buffer size."
  type        = number
  default     = null
}

variable "semantic_max_tokens" {
  description = "The maximum number of tokens that a chunk can contain."
  type        = number
  default     = null
}

variable "s3_location_uri" {
  description = "A location for storing content from data sources temporarily as it is processed by custom components in the ingestion pipeline."
  type        = string
  default     = null
}

variable "transformations_list" {
  description = "A list of Lambda functions that process documents."
  type = list(object({
    step_to_apply = optional(string)
    transformation_function = optional(object({
      transformation_lambda_configuration = optional(object({
        lambda_arn = optional(string)
      }))
    }))
  }))
  default = null
}

variable "parsing_config_model_arn" {
  description = "The model's ARN."
  type        = string
  default     = null
}

variable "parsing_prompt_text" {
  description = "Instructions for interpreting the contents of a document."
  type        = string
  default     = null
}

variable "parsing_strategy" {
  description = "The parsing strategy for the data source."
  type        = string
  default     = null
}

# – Knowledge base – 

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
  default     = "VECTOR"

  validation {
    condition     = var.kb_type == "VECTOR" || var.kb_type == "KENDRA" || var.kb_type == "SQL" || var.kb_type == null
    error_message = "kb_type must be either VECTOR, KENDRA, or SQL"
  }
}

variable "kb_embedding_model_arn" {
  description = "The ARN of the model used to create vector embeddings for the knowledge base."
  type        = string
  default     = "arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"
}

variable "vector_dimension" {
  description = "The dimension of vectors in the OpenSearch index. Use 1024 for Titan Text Embeddings V2, 1536 for V1"
  type        = number
  default     = 1024
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
    error_message = "The provided retention period is not a valid CloudWatch logs retention period."
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

variable "allow_opensearch_public_access" {
  description = "Whether or not to allow public access to the OpenSearch collection endpoint and the Dashboards endpoint."
  type        = bool
  default     = true
}

variable "number_of_shards" {
  description = "The number of shards for the OpenSearch index. This setting cannot be changed after index creation."
  type        = string
  default     = "1"
}

variable "number_of_replicas" {
  description = "The number of replica shards for the OpenSearch index."
  type        = string
  default     = "1"
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

# – Prompt Management – 

variable "prompt_name" {
  description = "Name for a prompt resource."
  type        = string
  default     = null
}

variable "prompt_description" {
  description = "Description for a prompt resource."
  type        = string
  default     = null
}

variable "customer_encryption_key_arn" {
  description = "A KMS key ARN."
  type        = string
  default     = null
}

variable "default_variant" {
  description = "Name for a variant."
  type        = string
  default     = null
}

variable "create_prompt" {
  description = "Whether or not to create a prompt resource."
  type        = bool
  default     = false
}

variable "prompt_tags" {
  description = "A map of tag keys and values for prompt resource."
  type        = map(string)
  default     = null
}

variable "variants_list" {
  description = "List of prompt variants."
  type = list(object({
    name                            = optional(string)
    template_type                   = optional(string)
    model_id                        = optional(string)
    additional_model_request_fields = optional(string)
    metadata = optional(list(object({
      key   = optional(string)
      value = optional(string)
    })))
    gen_ai_resource = optional(object({
      agent = optional(object({
        agent_identifier = optional(string)
      }))
    }))

    inference_configuration = optional(object({
      text = optional(object({
        max_tokens     = optional(number)
        stop_sequences = optional(list(string))
        temperature    = optional(number)
        top_p          = optional(number)
        top_k          = optional(number)
      }))
    }))

    template_configuration = optional(object({
      chat = optional(object({
        input_variables = optional(list(object({
          name = optional(string)
        })))
        messages = optional(list(object({
          content = optional(list(object({
            cache_point = optional(object({
              type = optional(string)
            }))
            text = optional(string)
          })))
          role = optional(string)
        })))
        system = optional(list(object({
          cache_point = optional(object({
            type = optional(string)
          }))
          text = optional(string)
        })))
        tool_configuration = optional(object({
          tool_choice = optional(object({
            any  = optional(string)
            auto = optional(string)
            tool = optional(object({
              name = optional(string)
            }))
          }))
          tools = optional(list(object({
            cache_point = optional(object({
              type = optional(string)
            }))
            tool_spec = optional(object({
              description = optional(string)
              input_schema = optional(object({
                json = optional(string)
              }))
              name = optional(string)
            }))
          })))
        }))
      })),

      text = optional(object({
        input_variables = optional(list(object({ name = optional(string) })))
        text            = optional(string)
        cache_point = optional(object({
          type = optional(string)
        }))
        text_s3_location = optional(object({
          bucket  = optional(string)
          key     = optional(string)
          version = optional(string)
        }))
      }))
    }))
  }))
  default = null
}

variable "create_prompt_version" {
  description = "Whether or not to create a prompt version."
  type        = bool
  default     = false
}

variable "prompt_version_description" {
  description = "Description for a prompt version resource."
  type        = string
  default     = null
}

variable "prompt_version_tags" {
  description = "A map of tag keys and values for a prompt version resource."
  type        = map(string)
  default     = null
}

# – Application Inference Profile –

variable "create_app_inference_profile" {
  description = "Whether or not to create an application inference profile."
  type        = bool
  default     = false
}

variable "use_app_inference_profile" {
  description = "Whether or not to attach to the app_inference_profile_model_source."
  type        = bool
  default     = false
}

variable "app_inference_profile_name" {
  description = "The name of your application inference profile."
  type        = string
  default     = "AppInferenceProfile"
}

variable "app_inference_profile_description" {
  description = "A description of application inference profile."
  type        = string
  default     = null
}

variable "app_inference_profile_model_source" {
  description = "Source arns for a custom inference profile to copy its regional load balancing config from. This can either be a foundation model or predefined inference profile ARN."
  type        = string
  default     = null
}

variable "app_inference_profile_tags" {
  description = "A map of tag keys and values for application inference profile."
  type        = list(map(string))
  default     = null
}

# – Bedrock Flow – 

variable "create_flow_alias" {
  description = "Whether or not to create a flow alias resource."
  type        = bool
  default     = false
}

variable "flow_alias_name" {
  description = "The name of your flow alias."
  type        = string
  default     = "BedrockFlowAlias"
}

variable "flow_arn" {
  description = "ARN representation of the flow."
  type        = string
  default     = null
}

variable "flow_alias_description" {
  description = "A description of the flow alias."
  type        = string
  default     = null
}

variable "flow_version" {
  description = "Version of the flow."
  type        = string
  default     = null
}

variable "flow_version_description" {
  description = "A description of flow version."
  type        = string
  default     = null
}

# – Custom Model – 

variable "create_custom_model" {
  description = "Whether or not to create a custom model."
  type        = bool
  default     = false
}

variable "custom_model_id" {
  description = "The base model id for a custom model."
  type        = string
  default     = "amazon.titan-text-express-v1"
}

variable "custom_model_name" {
  description = "Name for the custom model."
  type        = string
  default     = "custom-model"
}

variable "custom_model_job_name" {
  description = "A name for the model customization job."
  type        = string
  default     = "custom-model-job"
}

variable "custom_model_kms_key_id" {
  description = "The custom model is encrypted at rest using this key. Specify the key ARN."
  type        = string
  default     = null
}

variable "customization_type" {
  description = "The customization type. Valid values: FINE_TUNING, CONTINUED_PRE_TRAINING."
  type        = string
  default     = "FINE_TUNING"

  validation {
    condition     = var.customization_type == "FINE_TUNING" || var.customization_type == "CONTINUED_PRE_TRAINING"
    error_message = "Customization type valid values are FINE_TUNING or CONTINUED_PRE_TRAINING."
  }
}

variable "custom_model_hyperparameters" {
  description = "Parameters related to tuning the custom model."
  type        = map(string)
  default = {
    "epochCount"              = "2"
    "batchSize"               = "1"
    "learningRate"            = "0.00001"
    "learningRateWarmupSteps" = "10"
  }
}

variable "custom_model_tags" {
  description = "A map of tag keys and values for the custom model."
  type        = map(string)
  default     = null
}

variable "custom_model_output_uri" {
  description = "The S3 URI where the output data is stored for custom model."
  type        = string
  default     = null
}

variable "custom_model_training_uri" {
  description = "The S3 URI where the training data is stored for custom model."
  type        = string
  default     = null
}

# – Kendra GenAI Knowledge Base – 

variable "create_kendra_config" {
  description = "Whether or not to create a Kendra GenAI knowledge base."
  type        = bool
  default     = false
}

variable "kendra_index_arn" {
  description = "The ARN of the existing Kendra index."
  type        = string
  default     = null
}

variable "kendra_index_id" {
  description = "The ID of the existing Kendra index."
  type        = string
  default     = null
}

variable "kendra_index_name" {
  description = "The name of the Kendra index."
  type        = string
  default     = "kendra-genai-index"
}

variable "kendra_index_edition" {
  description = "The Amazon Kendra Edition to use for the index."
  type        = string
  default     = "GEN_AI_ENTERPRISE_EDITION"

  validation {
    condition     = var.kendra_index_edition == "DEVELOPER_EDITION" || var.kendra_index_edition == "ENTERPRISE_EDITION" || var.kendra_index_edition == "GEN_AI_ENTERPRISE_EDITION"
    error_message = "Kendra index edition must be DEVELOPER_EDITION, ENTERPRISE_EDITION or GEN_AI_ENTERPRISE_EDITION."
  }
}

variable "kendra_index_description" {
  description = "A description for the Kendra index."
  type        = string
  default     = null
}

variable "kendra_index_query_capacity" {
  description = "The number of queries per second allowed for the Kendra index."
  type        = number
  default     = 1

  validation {
    condition     = var.kendra_index_query_capacity >= 1 && var.kendra_index_query_capacity <= 100
    error_message = "Kendra index query capacity must be between 1 and 100."
  }
}

variable "kendra_index_storage_capacity" {
  description = "The storage capacity of the Kendra index."
  type        = number
  default     = 1

  validation {
    condition     = var.kendra_index_storage_capacity >= 1 && var.kendra_index_storage_capacity <= 50
    error_message = "Kendra index storage capacity must be between 1 and 50."
  }
}

variable "kendra_index_tags" {
  description = "A map of tag keys and values for Kendra index."
  type        = list(map(string))
  default     = null
}

variable "user_token_configurations" {
  description = "List of user token configurations for Kendra."
  type = list(object({

    json_token_type_configurations = optional(object({
      group_attribute_field     = string
      user_name_attribute_field = string
    }))

    jwt_token_type_configuration = optional(object({
      claim_regex               = optional(string)
      key_location              = optional(string)
      group_attribute_field     = optional(string)
      user_name_attribute_field = optional(string)
      issuer                    = optional(string)
      secret_manager_arn        = optional(string)
      url                       = optional(string)
    }))

  }))
  default = null
}

variable "kendra_kms_key_id" {
  description = "The Kendra index is encrypted at rest using this key. Specify the key ARN."
  type        = string
  default     = null
}

variable "kendra_index_user_context_policy" {
  description = "The Kendra index user context policy."
  type        = string
  default     = null
}

variable "document_metadata_configurations" {
  description = "List of document metadata configurations for Kendra."
  type = list(object({
    name = optional(string)
    type = optional(string)
    search = optional(object({
      facetable   = optional(bool)
      searchable  = optional(bool)
      displayable = optional(bool)
      sortable    = optional(bool)
    }))
    relevance = optional(object({
      duration   = optional(string)
      freshness  = optional(bool)
      importance = optional(number)
      rank_order = optional(string)
      value_importance_items = optional(list(object({
        key   = optional(string)
        value = optional(number)
      })))
    }))
  }))
  default = null
}

# – Kendra Data Source –

variable "kendra_data_source_name" {
  description = "The name of the Kendra data source."
  type        = string
  default     = "kendra-data-source"
}

variable "kendra_data_source_language_code" {
  description = "The code for the language of the Kendra data source content."
  type        = string
  default     = "en"
}

variable "kendra_data_source_description" {
  description = "A description for the Kendra data source."
  type        = string
  default     = null
}

variable "kendra_data_source_tags" {
  description = "A map of tag keys and values for Kendra data source."
  type        = list(map(string))
  default     = null
}

variable "kendra_data_source_schedule" {
  description = "The schedule for Amazon Kendra to update the index."
  type        = string
  default     = null
}

variable "s3_data_source_exclusion_patterns" {
  description = "A list of glob patterns to exclude from the data source."
  type        = list(string)
  default     = null
}

variable "s3_data_source_inclusion_patterns" {
  description = "A list of glob patterns to include in the data source."
  type        = list(string)
  default     = null
}

variable "s3_data_source_document_metadata_prefix" {
  description = "The prefix for the S3 data source."
  type        = string
  default     = null
}

variable "s3_data_source_key_path" {
  description = "The S3 key path where for the data source."
  type        = string
  default     = null
}

variable "s3_data_source_bucket_name" {
  description = "The name of the S3 bucket where the data source is stored."
  type        = string
  default     = null
}

variable "create_kendra_s3_data_source" {
  description = "Whether or not to create a Kendra S3 data source."
  type        = bool
  default     = false
}

# SQL Knowledge Base

variable "create_sql_config" {
  description = "Whether or not to create a SQL knowledge base."
  type        = bool
  default     = false
}

variable "sql_kb_workgroup_arn" {
  description = "The ARN of the existing workgroup."
  type        = string
  default     = null
}

# Auth Configuration Types
variable "provisioned_auth_configuration" {
  description = "Configurations for provisioned Redshift query engine"
  type = object({
    database_user                = optional(string)
    type                         = optional(string) # Auth type explicitly defined
    username_password_secret_arn = optional(string)
  })
  default = null
}

variable "provisioned_config_cluster_identifier" {
  description = "The cluster identifier for the provisioned Redshift query engine."
  type        = string
  default     = null
}

# Auth Configuration Types
variable "serverless_auth_configuration" {
  description = "Configuration for the Redshift serverless query engine."
  type = object({
    type                         = optional(string) # Auth type explicitly defined
    username_password_secret_arn = optional(string)
  })
  default = null
}

# Query Generation Configuration with Curated Queries and Tables/Columns
variable "query_generation_configuration" {
  description = "Configurations for generating Redshift engine queries."
  type = object({
    generation_context = optional(object({
      curated_queries = optional(list(object({
        natural_language = optional(string) # Question for the query
        sql              = optional(string) # SQL answer for the query
      })))
      tables = optional(list(object({
        columns = optional(list(object({
          description = optional(string) # Column description
          inclusion   = optional(string) # Include or exclude status
          name        = optional(string) # Column name
        })))
        description = optional(string) # Table description
        inclusion   = optional(string) # Include or exclude status
        name        = optional(string) # Table name (three-part notation)
      })))
    }))
    execution_timeout_seconds = optional(number) # Max query execution timeout
  })
  default = null
}

variable "redshift_storage_configuration" {
  description = "List of configurations for available Redshift query engine storage types."
  type = list(object({
    aws_data_catalog_configuration = optional(object({
      table_names = optional(list(string)) # List of table names in AWS Data Catalog
    }))
    redshift_configuration = optional(object({
      database_name = optional(string)
    }))
    type = optional(string)
  }))
  default = null
}

variable "redshift_query_engine_type" {
  description = "Redshift query engine type for the knowledge base. Defaults to SERVERLESS"
  type        = string
  default     = "SERVERLESS"

  validation {
    condition     = var.redshift_query_engine_type == "SERVERLESS" || var.redshift_query_engine_type == "PROVISIONED"
    error_message = "Redshift query engine type must be SERVERLESS or PROVISIONED."
  }
}

# Action Groups list

variable "action_group_list" {
  description = "List of configurations for available action groups."
  type = list(object({
    action_group_name                    = optional(string)
    description                          = optional(string)
    action_group_state                   = optional(string)
    parent_action_group_signature        = optional(string)
    skip_resource_in_use_check_on_delete = optional(bool)
    action_group_executor = optional(object({
      custom_control = optional(string)
      lambda         = optional(string)
    }))
    api_schema = optional(object({
      payload = optional(string)
      s3 = optional(object({
        s3_bucket_name = optional(string)
        s3_object_key  = optional(string)
      }))
    }))
    function_schema = optional(object({
      functions = optional(list(object({
        description = optional(string)
        name        = optional(string)
        parameters = optional(map(object({
          description = optional(string)
          required    = optional(bool)
          type        = optional(string)
        })))
        require_confirmation = optional(string)
      })))
    }))
  }))
  default = []
}

variable "action_group_lambda_arns_list" {
  description = "List of Lambda ARNs for action groups."
  type        = list(string)
  default     = []
}

variable "action_group_lambda_names_list" {
  description = "List of Lambda names for action groups."
  type        = list(string)
  default     = []
}

# – Bedrock Data Automation – 

variable "create_bda" {
  description = "Whether or not to create a Bedrock data automatio project."
  type        = bool
  default     = false
}

variable "bda_project_name" {
  description = "The name of the Bedrock data automation project."
  type        = string
  default     = "bda-project"
}

variable "bda_project_description" {
  description = "The description of the Bedrock data automation project."
  type        = string
  default     = null
}

variable "bda_kms_encryption_context" {
  description = "The KMS encryption context for the Bedrock data automation project."
  type        = map(string)
  default     = null
}

variable "bda_kms_key_id" {
  description = "The KMS key ID for the Bedrock data automation project."
  type        = string
  default     = null
}

variable "bda_tags" {
  description = "A list of tag keys and values for the Bedrock data automation project."
  type = list(object({
    key   = string
    value = string
  }))
  default = null

}

variable "bda_custom_output_config" {
  description = "A list of the BDA custom output configuartion blueprint(s)."
  type = list(object({
    blueprint_arn     = optional(string)
    blueprint_stage   = optional(string)
    blueprint_version = optional(string)
  }))
  default = null
}

variable "bda_override_config_state" {
  description = "Configuration state for the BDA override."
  type        = string
  default     = null
}

variable "bda_standard_output_configuration" {
  description = "Standard output is pre-defined extraction managed by Bedrock. It can extract information from documents, images, videos, and audio."
  type = object({
    audio = optional(object({
      extraction = optional(object({
        category = optional(object({
          state = optional(string)
          types = optional(list(string))
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
        types = optional(list(string))
      }))
    }))
    document = optional(object({
      extraction = optional(object({
        bounding_box = optional(object({
          state = optional(string)
        }))
        granularity = optional(object({
          types = optional(list(string))
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
      }))
      output_format = optional(object({
        additional_file_format = optional(object({
          state = optional(string)
        }))
        text_format = optional(object({
          types = optional(list(string))
        }))
      }))
    }))
    image = optional(object({
      extraction = optional(object({
        category = optional(object({
          state = optional(string)
          types = optional(list(string))
        }))
        bounding_box = optional(object({
          state = optional(string)
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
        types = optional(list(string))
      }))
    }))
    video = optional(object({
      extraction = optional(object({
        category = optional(object({
          state = optional(string)
          types = optional(list(string))
        }))
        bounding_box = optional(object({
          state = optional(string)
        }))
      }))
      generative_field = optional(object({
        state = optional(string)
        types = optional(list(string))
      }))
    }))
  })
  default = null
}

# – BDA Blueprint – 

variable "create_blueprint" {
  description = "Whether or not to create a BDA blueprint."
  type        = bool
  default     = false
}

variable "blueprint_name" {
  description = "The name of the BDA blueprint."
  type        = string
  default     = "bda-blueprint"
}

variable "blueprint_schema" {
  description = "The schema for the blueprint."
  type        = string
  default     = null
}

variable "blueprint_type" {
  description = "The modality type of the blueprint."
  type        = string
  default     = "DOCUMENT"

  validation {
    condition     = var.blueprint_type == "DOCUMENT" || var.blueprint_type == "IMAGE"
    error_message = "Blueprint type must be DOCUMENT or IMAGE."
  }
}

variable "blueprint_kms_encryption_context" {
  description = "The KMS encryption context for the blueprint."
  type        = map(string)
  default     = null
}

variable "blueprint_kms_key_id" {
  description = "The KMS key ID for the blueprint."
  type        = string
  default     = null
}

variable "blueprint_tags" {
  description = "A list of tag keys and values for the blueprint."
  type = list(object({
    key   = string
    value = string
  }))
  default = null
}

# - IAM -
variable "permissions_boundary_arn" {
  description = "The ARN of the IAM permission boundary for the role."
  type        = string
  default     = null
}

variable "agent_resource_role_arn" {
  description = "Optional external IAM role ARN for the Bedrock agent resource role. If empty, the module will create one internally."
  type        = string
  default     = null
}

# – MongoDB Atlas Configuration –
variable "text_index_name" {
  description = "Name of a MongoDB Atlas text index."
  type        = string
  default     = null
}

# – Neptune Analytics Configuration –
variable "create_neptune_analytics_config" {
  description = "Whether or not to use Neptune Analytics configuration"
  type        = bool
  default     = false
}

variable "graph_arn" {
  description = "ARN for Neptune Analytics graph database."
  type        = string
  default     = null
}

# – S3 Vectors Configuration –
variable "create_s3_vectors_config" {
  description = "Whether or not to use S3 Vectors configuration"
  type        = bool
  default     = false
}

variable "s3_vectors_index_arn" {
  description = "ARN of the S3 Vectors index"
  type        = string
  default     = null
}

variable "s3_vectors_index_name" {
  description = "Name of the S3 Vectors index (used with vector_bucket_arn)"
  type        = string
  default     = null
}

variable "s3_vectors_bucket_arn" {
  description = "ARN of the S3 Vectors bucket (used with index_name)"
  type        = string
  default     = null
}

# – RDS Configuration –
variable "custom_metadata_field" {
  description = "The name of the field in which Amazon Bedrock stores custom metadata about the vector store."
  type        = string
  default     = null
}

# – Vector Knowledge Base Configuration –
variable "embedding_model_dimensions" {
  description = "The dimensions details for the vector configuration used on the Bedrock embeddings model."
  type        = number
  default     = null
}

variable "embedding_data_type" {
  description = "The data type for the vectors when using a model to convert text into vector embeddings."
  type        = string
  default     = null
}

# – Supplemental Data Storage Configuration –
variable "create_supplemental_data_storage" {
  description = "Whether or not to create supplemental data storage configuration."
  type        = bool
  default     = false
}

variable "supplemental_data_s3_uri" {
  description = "The S3 URI for supplemental data storage."
  type        = string
  default     = null
}
