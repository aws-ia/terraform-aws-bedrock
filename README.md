<!-- BEGIN_TF_DOCS -->
# Terraform Bedrock Module

Amazon Bedrock is a fully managed service that offers a choice of foundation models (FMs) along with a broad set of capabilities for building generative AI applications.

This module includes resources to deploy Bedrock features.

## Knowledge Bases

With Knowledge Bases for Amazon Bedrock, you can give FMs and agents contextual information from your company’s private data sources for Retrieval Augmented Generation (RAG) to deliver more relevant, accurate, and customized responses.

### Create a Knowledge Base

A vector index on a vector store is required to create a Knowledge Base. This construct currently supports Amazon OpenSearch Serverless, Amazon RDS Aurora PostgreSQL, Pinecone, and MongoDB. By default, this resource will create an OpenSearch Serverless vector collection and index for each Knowledge Base you create, but you can provide an existing collection to have more control. For other resources you need to have the vector stores already created and credentials stored in AWS Secrets Manager.

The resource accepts an instruction prop that is provided to any Bedrock Agent it is associated with so the agent can decide when to query the Knowledge Base.

To create a knowledge base, make sure you pass in the appropriate variables and set the `create_kb` variable to `true`.

Example default Opensearch Serverless Agent with Knowledgebase

```
provider "opensearch" {
  url         = module.bedrock.default_collection[0].collection_endpoint
  healthcheck = false
}

module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.1"
  create_kb = true
  create_default_kb = true
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}
```

### Knowledge Base - Data Sources

Data sources are the various repositories or systems from which information is extracted and ingested into the knowledge base. These sources provide the raw content that will be processed, indexed, and made available for querying within the knowledge base system. Data sources can include various types of systems such as document management systems, databases, file storage systems, and content management platforms. Supported Data Sources include Amazon S3 buckets.

- Amazon S3. You can either create a new data source by passing in the existing data source arn to the input variable `kb_s3_data_source` or create a new one by leaving that value as `null` when `create_default_kb` is set to true.

## Agents

Enable generative AI applications to execute multistep tasks across company systems and data sources.

### Create an Agent

The following example creates an Agent with a simple instruction and without any action groups or knowedlge bases.

```
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.1"
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}
```

To create an Agent with a default Knowledge Base you simply set `create_kb` and `create_default_kb` to `true`:

```
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.1"
  create_kb = true
  create_default_kb = true
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}
```

### Action Groups

An action group defines functions your agent can call. The functions are Lambda functions. The action group uses an OpenAPI schema to tell the agent what your functions do and how to call them. You can configure an action group by passing in the appropriate input variables.

### Prepare the Agent

The Agent constructs take an optional parameter shouldPrepareAgent to indicate that the Agent should be prepared after any updates to an agent, Knowledge Base association, or action group. This may increase the time to create and update those resources. By default, this value is true.

### Prompt Overrides

Bedrock Agents allows you to customize the prompts and LLM configuration for its different steps. You can disable steps or create a new prompt template. Prompt templates can be inserted from plain text files.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | = 2.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~>5.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.0.0 |
| <a name="provider_opensearch"></a> [opensearch](#provider\_opensearch) | = 2.2.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.6 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagent_data_source.knowledge_base_ds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_data_source) | resource |
| [aws_iam_policy.bedrock_kb_s3_decryption_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_knowledge_base_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agent_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.bedrock_knowledge_base_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.bedrock_kb_oss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.bedrock_kb_s3_decryption_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_opensearchserverless_access_policy.data_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [aws_opensearchserverless_security_policy.nw_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [aws_opensearchserverless_security_policy.security_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_security_policy) | resource |
| [awscc_bedrock_agent.bedrock_agent](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_agent) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_default](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_mongo](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_opensearch](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_pinecone](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_rds](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_opensearchserverless_collection.default_collection](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/opensearchserverless_collection) | resource |
| [awscc_s3_bucket.s3_data_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/s3_bucket) | resource |
| [opensearch_index.default_oss_index](https://registry.terraform.io/providers/opensearch-project/opensearch/2.2.0/docs/resources/index) | resource |
| [random_string.solution_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_before_index_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.agent_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.agent_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.knowledge_base_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_foundation_model"></a> [foundation\_model](#input\_foundation\_model) | The foundation model for the Bedrock agent. | `string` | n/a | yes |
| <a name="input_instruction"></a> [instruction](#input\_instruction) | A narrative instruction to provide the agent as context. | `string` | n/a | yes |
| <a name="input_action_group_description"></a> [action\_group\_description](#input\_action\_group\_description) | Description of the action group. | `string` | `null` | no |
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | Name of the action group. | `string` | `null` | no |
| <a name="input_action_group_state"></a> [action\_group\_state](#input\_action\_group\_state) | State of the action group. | `string` | `null` | no |
| <a name="input_agent_description"></a> [agent\_description](#input\_agent\_description) | A description of agent. | `string` | `null` | no |
| <a name="input_agent_name"></a> [agent\_name](#input\_agent\_name) | The name of your agent. | `string` | `"TerraformBedrockAgents"` | no |
| <a name="input_api_schema_payload"></a> [api\_schema\_payload](#input\_api\_schema\_payload) | String OpenAPI Payload. | `string` | `null` | no |
| <a name="input_api_schema_s3_bucket_name"></a> [api\_schema\_s3\_bucket\_name](#input\_api\_schema\_s3\_bucket\_name) | A bucket in S3. | `string` | `null` | no |
| <a name="input_api_schema_s3_object_key"></a> [api\_schema\_s3\_object\_key](#input\_api\_schema\_s3\_object\_key) | An object key in S3. | `string` | `null` | no |
| <a name="input_base_prompt_template"></a> [base\_prompt\_template](#input\_base\_prompt\_template) | Defines the prompt template with which to replace the default prompt template. | `string` | `null` | no |
| <a name="input_collection_arn"></a> [collection\_arn](#input\_collection\_arn) | The ARN of the collection. | `string` | `null` | no |
| <a name="input_collection_name"></a> [collection\_name](#input\_collection\_name) | The name of the collection. | `string` | `null` | no |
| <a name="input_connection_string"></a> [connection\_string](#input\_connection\_string) | The endpoint URL for your index management page. | `string` | `null` | no |
| <a name="input_create_ag"></a> [create\_ag](#input\_create\_ag) | Whether or not to create an action group. | `bool` | `false` | no |
| <a name="input_create_agent"></a> [create\_agent](#input\_create\_agent) | Whether or not to deploy an agent. | `bool` | `true` | no |
| <a name="input_create_default_kb"></a> [create\_default\_kb](#input\_create\_default\_kb) | Whether or not to create the default knowledge base. | `bool` | `false` | no |
| <a name="input_create_kb"></a> [create\_kb](#input\_create\_kb) | Whether or not to attach a knowledge base. | `bool` | `false` | no |
| <a name="input_create_mongo_config"></a> [create\_mongo\_config](#input\_create\_mongo\_config) | Whether or not to use MongoDB Atlas configuration | `bool` | `false` | no |
| <a name="input_create_opensearch_config"></a> [create\_opensearch\_config](#input\_create\_opensearch\_config) | Whether or not to use Opensearch Serverless configuration | `bool` | `false` | no |
| <a name="input_create_pinecone_config"></a> [create\_pinecone\_config](#input\_create\_pinecone\_config) | Whether or not to use Pinecone configuration | `bool` | `false` | no |
| <a name="input_create_rds_config"></a> [create\_rds\_config](#input\_create\_rds\_config) | Whether or not to use RDS configuration | `bool` | `false` | no |
| <a name="input_credentials_secret_arn"></a> [credentials\_secret\_arn](#input\_credentials\_secret\_arn) | The ARN of the secret in Secrets Manager that is linked to your database | `string` | `null` | no |
| <a name="input_custom_control"></a> [custom\_control](#input\_custom\_control) | Custom control of action execution. | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database. | `string` | `null` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Database endpoint | `string` | `null` | no |
| <a name="input_endpoint_service_name"></a> [endpoint\_service\_name](#input\_endpoint\_service\_name) | MongoDB Atlas endpoint service name. | `string` | `null` | no |
| <a name="input_existing_kb"></a> [existing\_kb](#input\_existing\_kb) | The ID of the existing knowledge base. | `string` | `null` | no |
| <a name="input_function_description"></a> [function\_description](#input\_function\_description) | Description of function. | `string` | `null` | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name for a resource. | `string` | `null` | no |
| <a name="input_function_parameters_description"></a> [function\_parameters\_description](#input\_function\_parameters\_description) | Description of function parameter. | `string` | `null` | no |
| <a name="input_function_parameters_required"></a> [function\_parameters\_required](#input\_function\_parameters\_required) | If a parameter is required for a function call. | `bool` | `false` | no |
| <a name="input_function_parameters_type"></a> [function\_parameters\_type](#input\_function\_parameters\_type) | Parameter type. | `string` | `null` | no |
| <a name="input_idle_session_ttl"></a> [idle\_session\_ttl](#input\_idle\_session\_ttl) | How long sessions should be kept open for the agent. | `number` | `600` | no |
| <a name="input_kb_description"></a> [kb\_description](#input\_kb\_description) | Description of knowledge base. | `string` | `"Terraform deployed Knowledge Base"` | no |
| <a name="input_kb_embedding_model_arn"></a> [kb\_embedding\_model\_arn](#input\_kb\_embedding\_model\_arn) | The ARN of the model used to create vector embeddings for the knowledge base. | `string` | `"arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v1"` | no |
| <a name="input_kb_name"></a> [kb\_name](#input\_kb\_name) | Name of the knowledge base. | `string` | `"knowledge-base"` | no |
| <a name="input_kb_role_arn"></a> [kb\_role\_arn](#input\_kb\_role\_arn) | The ARN of the IAM role with permission to invoke API operations on the knowledge base. | `string` | `null` | no |
| <a name="input_kb_s3_data_source"></a> [kb\_s3\_data\_source](#input\_kb\_s3\_data\_source) | The S3 data source ARN for the knowledge base. | `string` | `null` | no |
| <a name="input_kb_s3_data_source_kms_arn"></a> [kb\_s3\_data\_source\_kms\_arn](#input\_kb\_s3\_data\_source\_kms\_arn) | The ARN of the KMS key used to encrypt S3 content | `string` | `null` | no |
| <a name="input_kb_state"></a> [kb\_state](#input\_kb\_state) | State of knowledge base; whether it is enabled or disabled | `string` | `"ENABLED"` | no |
| <a name="input_kb_storage_type"></a> [kb\_storage\_type](#input\_kb\_storage\_type) | The storage type of a knowledge base. | `string` | `null` | no |
| <a name="input_kb_tags"></a> [kb\_tags](#input\_kb\_tags) | A map of tags keys and values for the knowledge base. | `map(string)` | `null` | no |
| <a name="input_kb_type"></a> [kb\_type](#input\_kb\_type) | The type of a knowledge base. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS encryption key to use for the agent. | `string` | `null` | no |
| <a name="input_lambda_action_group_executor"></a> [lambda\_action\_group\_executor](#input\_lambda\_action\_group\_executor) | ARN of Lambda. | `string` | `null` | no |
| <a name="input_max_length"></a> [max\_length](#input\_max\_length) | The maximum number of tokens to generate in the response. | `number` | `0` | no |
| <a name="input_metadata_field"></a> [metadata\_field](#input\_metadata\_field) | The name of the field in which Amazon Bedrock stores metadata about the vector store. | `string` | `"AMAZON_BEDROCK_METADATA"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | This value is appended at the beginning of resource names. | `string` | `"BedrockAgents"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to be used to write new data to your pinecone database | `string` | `null` | no |
| <a name="input_override_lambda_arn"></a> [override\_lambda\_arn](#input\_override\_lambda\_arn) | The ARN of the Lambda function to use when parsing the raw foundation model output in parts of the agent sequence. | `string` | `null` | no |
| <a name="input_parent_action_group_signature"></a> [parent\_action\_group\_signature](#input\_parent\_action\_group\_signature) | Action group signature for a builtin action. | `string` | `null` | no |
| <a name="input_parser_mode"></a> [parser\_mode](#input\_parser\_mode) | Specifies whether to override the default parser Lambda function. | `string` | `null` | no |
| <a name="input_primary_key_field"></a> [primary\_key\_field](#input\_primary\_key\_field) | The name of the field in which Bedrock stores the ID for each entry. | `string` | `null` | no |
| <a name="input_prompt_creation_mode"></a> [prompt\_creation\_mode](#input\_prompt\_creation\_mode) | Specifies whether to override the default prompt template. | `string` | `null` | no |
| <a name="input_prompt_override"></a> [prompt\_override](#input\_prompt\_override) | Whether to provide prompt override configuration. | `bool` | `false` | no |
| <a name="input_prompt_state"></a> [prompt\_state](#input\_prompt\_state) | Specifies whether to allow the agent to carry out the step specified in the promptType. | `string` | `null` | no |
| <a name="input_prompt_type"></a> [prompt\_type](#input\_prompt\_type) | The step in the agent sequence that this prompt configuration applies to. | `string` | `null` | no |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | The ARN of the vector store. | `string` | `null` | no |
| <a name="input_skip_resource_in_use"></a> [skip\_resource\_in\_use](#input\_skip\_resource\_in\_use) | Specifies whether to allow deleting action group while it is in use. | `bool` | `null` | no |
| <a name="input_stop_sequences"></a> [stop\_sequences](#input\_stop\_sequences) | A list of stop sequences. | `list(string)` | `[]` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | The name of the table in the database. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tag bedrock agent resource. | `map(string)` | `null` | no |
| <a name="input_temperature"></a> [temperature](#input\_temperature) | The likelihood of the model selecting higher-probability options while generating a response. | `number` | `0` | no |
| <a name="input_text_field"></a> [text\_field](#input\_text\_field) | The name of the field in which Amazon Bedrock stores the raw text from your data. | `string` | `"AMAZON_BEDROCK_TEXT_CHUNK"` | no |
| <a name="input_top_k"></a> [top\_k](#input\_top\_k) | Sample from the k most likely next tokens. | `number` | `50` | no |
| <a name="input_top_p"></a> [top\_p](#input\_top\_p) | Cumulative probability cutoff for token selection. | `number` | `0.5` | no |
| <a name="input_vector_field"></a> [vector\_field](#input\_vector\_field) | The name of the field where the vector embeddings are stored | `string` | `"bedrock-knowledge-base-default-vector"` | no |
| <a name="input_vector_index_name"></a> [vector\_index\_name](#input\_vector\_index\_name) | The name of the vector index. | `string` | `"bedrock-knowledge-base-default-index"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_default_collection"></a> [default\_collection](#output\_default\_collection) | Opensearch default collection value. |
<!-- END_TF_DOCS -->