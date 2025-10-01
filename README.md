<!-- BEGIN_TF_DOCS -->
# Terraform Bedrock Module

Amazon Bedrock is a fully managed service that offers a choice of foundation models (FMs) along with a broad set of capabilities for building generative AI applications.

This module includes resources to deploy Bedrock features.

You can control which features to use with your input variables. The resources are created based on boolean logic. The default behavior is to deploy a Bedrock Agent. To disable this behavior you can turn `create_agent` to false. To deploy other features such as guardrails or knowledge bases, you can use the input variables to set their respective create booleans to `true` and then pass in the appropriate values.

The main features of the Bedrock module include:

- Bedrock Agents
  - Agent Action Groups
  - Agent Alias
  - Agent Collaborators
- Knowledge Bases
  - Vector Knowledge Base (OpenSearch Serverless, Neptune Analytics, MongoDB Atlas, Pinecone, RDS)
  - Kendra Knowledge Base
  - SQL Knowledge Base
- Guardrails
- Prompt Management
  - Prompt Versions
- Application Inference Profiles
- Custom Models
- Bedrock Data Automation

## Bedrock Agents

Enable generative AI applications to execute multistep tasks across company systems and data sources.

### Create an Agent

The following example creates an Agent, where you must define at a minimum the desired foundtaion model and the instruction for the agent.

```hcl
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}
```

See the additional input variables for deploying an Agent [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L7)

### Action Groups

An action group defines functions your agent can call. The functions are Lambda functions. The action group uses an OpenAPI schema to tell the agent what your functions do and how to call them. You can configure an action group by setting `create_ag` to `true` and passing in the appropriate input variables. You can see an example of an an agent being deployed with an action group in [this samples repository](https://github.com/aws-samples/aws-generative-ai-terraform-samples/blob/main/samples/bedrock-agent/main.tf)

### Prepare the Agent

The Agent constructs take an optional parameter shouldPrepareAgent to indicate that the Agent should be prepared after any updates to an agent, Knowledge Base association, or action group. This may increase the time to create and update those resources. By default, this value is true.

### Prompt Overrides

Bedrock Agents allows you to customize the prompts and LLM configuration for its different steps. You can disable steps or create a new prompt template. Prompt templates can be inserted from plain text files.

### Agent Alias

After you have sufficiently iterated on your working draft and are satisfied with the behavior of your agent, you can set it up for deployment and integration into your application by creating aliases of your agent.

To deploy your agent, you need to create an alias. During alias creation, Amazon Bedrock automatically creates a version of your agent. The alias points to this newly created version. You can point the alias to a previously created version if necessary. You then configure your application to make API calls to that alias.

By default, the Agent resource does not create any aliases, and you can use the 'DRAFT' version.

You can creat an Agent Alias by setting `create_agent_alias` to `true`.

See the additional input variables for deploying an Agent Alias [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L183)

### Agent Collaborators

Multi-agent collaboration in Amazon Bedrock enables you to create teams of specialized agents that work together to solve complex tasks. You can designate a supervisor agent to coordinate with collaborator agents, each optimized for specific functions.

To set up agent collaboration, you'll need:

- A supervisor agent that coordinates the team
- One or more collaborator agents with specialized capabilities
- Collaboration instructions that define when each agent should be used

Example configuration with a supervisor agent and a collaborator agent:

```hcl
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  create_agent_alias = true
  foundation_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"
  instruction = "You are an agent. Do what the supervisor tells you to do"

  # Setting up the collaboration
  create_collaborator = true
  collaboration_instruction = "Tell the other agent what to do"
  supervisor_model = "anthropic.claude-3-5-sonnet-20241022-v2:0"
  supervisor_instruction = "You are a supervisor who can provide detailed information about cars to an agent."
}
```

See the additional input variables for deploying Agent Collaborators [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L221)

## Knowledge Bases

With Knowledge Bases for Amazon Bedrock, you can give FMs and agents contextual information from your company's private data sources for Retrieval Augmented Generation (RAG) to deliver more relevant, accurate, and customized responses.

### Create a Vector Knowledge Base

A vector index on a vector store is required to create a vector Knowledge Base. This construct supports multiple vector store options:

- **Amazon OpenSearch Serverless**: Default option with automatic collection and index creation
- **Amazon OpenSearch Managed Cluster**: For using existing OpenSearch domains
- **Neptune Analytics**: For graph database integration
- **MongoDB Atlas**: For MongoDB vector search
- **Pinecone**: For Pinecone vector database
- **Amazon RDS Aurora PostgreSQL**: For PostgreSQL with pgvector

By default, this resource will create an OpenSearch Serverless vector collection and index for each Knowledge Base you create, but you can provide an existing collection to have more control. For other resources you need to have the vector stores already created and credentials stored in AWS Secrets Manager.

The resource accepts an instruction prop that is provided to any Bedrock Agent it is associated with so the agent can decide when to query the Knowledge Base.

To create different types of knowledge bases, set the appropriate variable to `true`:

- OpenSearch Serverless: `create_default_kb = true`
- OpenSearch Managed Cluster: `create_opensearch_managed_config = true`
- Neptune Analytics: `create_neptune_analytics_config = true`
- MongoDB Atlas: `create_mongo_config = true`
- Pinecone: `create_pinecone_config = true`
- RDS: `create_rds_config = true`

#### Advanced Vector Knowledge Base Features

This module supports advanced vector knowledge base features:

- **Embedding Model Configuration**: Fine-tune your embedding model settings with:
  - `embedding_model_dimensions`: Specify vector dimensions explicitly
  - `embedding_data_type`: Define the data type for vectors

- **Supplemental Data Storage**: Store additional data alongside vector embeddings:
  - `create_supplemental_data_storage = true`
  - `supplemental_data_s3_uri`: S3 URI for supplemental data storage

Example default Opensearch Serverless Agent with Knowledge Base:

```hcl
provider "opensearch" {
  url         = module.bedrock.default_collection.collection_endpoint
  healthcheck = false
}

module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  create_default_kb = true
  create_s3_data_source = true
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}
```

Example using Neptune Analytics with advanced features:

```hcl
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"

  # Create Neptune Analytics knowledge base
  create_neptune_analytics_config = true
  graph_arn = "arn:aws:neptune-graph:us-east-1:123456789012:graph/my-graph"

  # Advanced embedding model configuration
  embedding_model_dimensions = 1024
  embedding_data_type = "FLOAT32"

  # Supplemental data storage
  create_supplemental_data_storage = true
  supplemental_data_s3_uri = "s3://my-bucket/supplemental-data/"

  # Agent configuration
  foundation_model = "anthropic.claude-3-sonnet-20240229-v1:0"
  instruction = "You are a graph database expert who can analyze relationships in data."
}
```

See the additional input variables for deploying Knowledge Bases [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L693)

### Vector Knowledge Base - Data Sources

Data sources are the various repositories or systems from which information is extracted and ingested into the knowledge base. These sources provide the raw content that will be processed, indexed, and made available for querying within the knowledge base system. Data sources can include various types of systems such as document management systems, databases, file storage systems, and content management platforms. Suuported Data Sources include Amazon S3 buckets, Web Crawlers, SharePoint sites, Salesforce instances, and Confluence spaces.

- Amazon S3. You can either create a new data source by passing in the existing data source arn to the input variable `kb_s3_data_source` or create a new one by setting `create_s3_data_source` to true.

- Web Crawler. You can create a new web crawler data source by setting the `create_web_crawler` input variable to true and passing in the necessary variables for urls, scope, etc.

- SharePoint. You can create a new SharePoint data source by setting the `create_sharepoint` input variable to true and passing in the necessary variables for site urls, filter patterns, etc.

- Salesforce. You can create a new Salesforce data source by setting the `create_salesforce` input variable to true and passing in the necessary variables for site urls, filter patterns, etc.

- Confluence. You can create a new Confluence data source by setting the `create_confluence` input variable to true and passing in the necessary variables for site urls, filter patterns, etc.

See the additional input variables for deploying Knowledge Base Data Sources [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L423)

### Create a Kendra Knowledge Base

With Amazon Bedrock Knowledge Bases, you can build a knowledge base from an Amazon Kendra GenAI index to create more sophisticated and accurate Retrieval Augmented Generation (RAG)-powered digital assistants. By combining an Amazon Kendra GenAI index with Amazon Bedrock Knowledge Bases, you can:

- Reuse your indexed content across multiple Amazon Bedrock applications without rebuilding indexes or re-ingesting data.
- Leverage the advanced GenAI capabilities of Amazon Bedrock while benefiting from the high-accuracy information retrieval of Amazon Kendra.
- Customize your digital assistant's behavior using the tools of Amazon Bedrock while maintaining the semantic accuracy of an Amazon Kendra GenAI index.

Example Kendra Knowledge Base:

```
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  create_kendra_config = true
  create_kendra_s3_data_source = true
  create_agent = false
}
```

See the additional input variables for deploying a Kendra Knowledge Base [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L1199)

### Create a SQL Knowledge Base

Amazon Bedrock Knowledge Bases provides direct integration with structured data stores, allowing natural language queries to be automatically converted into SQL queries for data retrieval. This feature enables you to query your structured data sources without the need for vector embeddings or data preprocessing.

- Amazon Bedrock Knowledge Bases analyzes:
  - Query patterns
  - Query history
  - Schema metadata
- Converts natural language queries into SQL
- Retrieves relevant information directly from supported data sources

See the additional input variables for deploying a SQL Knowledge Base [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L1398)

### Using an Existing Knowledge Base

If you already have an Amazon Bedrock Knowledge Base created and want to attach it to a Bedrock Agent using this module, you can configure the module to reference the existing resource instead of creating a new one.

#### Configuration

To use an existing Knowledge Base:

```hcl
module "bedrock_agent" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  # ID of the existing Knowledge Base
  existing_kb     = "kb-abc123"          # Required
  kb_state        = "ENABLED"
  # ... other required variables
}
```

#### Notes

- existing\_kb: The Knowledge Base ID (e.g., kb-abc123) that you want to attach to the Bedrock Agent.

- kb\_state: Set this to the current state of the KB (typically "ENABLED").

## Bedrock Guardrails

Amazon Bedrock's Guardrails feature enables you to implement robust governance and control mechanisms for your generative AI applications, ensuring alignment with your specific use cases and responsible AI policies. Guardrails empowers you to create multiple tailored policy configurations, each designed to address the unique requirements and constraints of different use cases. These policy configurations can then be seamlessly applied across multiple foundation models (FMs) and Agents, ensuring a consistent user experience and standardizing safety, security, and privacy controls throughout your generative AI ecosystem.

With Guardrails, you can define and enforce granular, customizable policies to precisely govern the behavior of your generative AI applications. You can configure the following policies in a guardrail to avoid undesirable and harmful content and remove sensitive information for privacy protection.

Content filters – Adjust filter strengths to block input prompts or model responses containing harmful content.

Denied topics – Define a set of topics that are undesirable in the context of your application. These topics will be blocked if detected in user queries or model responses.

Word filters – Configure filters to block undesirable words, phrases, and profanity. Such words can include offensive terms, competitor names etc.

Sensitive information filters – Block or mask sensitive information such as personally identifiable information (PII) or custom regex in user inputs and model responses.

You can create a Guardrail by setting `create_guardrail` to true and passing in the appropriate input variables:

```hcl
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  create_guardrail = true
  blocked_input = "I can provide general info about services, but can't fully address your request here. For personalized help or detailed questions, please contact our customer service team directly. For security reasons, avoid sharing sensitive information through this channel. If you have a general product question, feel free to ask without including personal details."
  blocked_output = "I can provide general info about services, but can't fully address your request here. For personalized help or detailed questions, please contact our customer service team directly. For security reasons, avoid sharing sensitive information through this channel. If you have a general product question, feel free to ask without including personal details."
  filters_config = [
      {
        input_strength  = "MEDIUM"
        output_strength = "MEDIUM"
        type            = "HATE"
      },
      {
        input_strength  = "HIGH"
        output_strength = "HIGH"
        type            = "VIOLENCE"
      }
  ]
  pii_entities_config = [
      {
        action = "BLOCK"
        type   = "NAME"
      },
      {
        action = "BLOCK"
        type   = "DRIVER_ID"
      },
      {
        action = "ANONYMIZE"
        type   = "USERNAME"
      },
  ]
  regexes_config = [{
      action      = "BLOCK"
      description = "example regex"
      name        = "regex_example"
      pattern     = "^\\d{3}-\\d{2}-\\d{4}$"
  }]
  managed_word_lists_config = [{
      type = "PROFANITY"
  }]
  words_config = [{
    text = "HATE"
  }]
  topics_config = [{
      name       = "investment_topic"
      examples   = ["Where should I invest my money ?"]
      type       = "DENY"
      definition = "Investment advice refers to inquiries, guidance, or recommendations regarding the management or allocation of funds or assets with the goal of generating returns ."
  }]
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}
```

See the additional input variables for deploying guardrails [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L317)

## Prompt Management

Amazon Bedrock provides the ability to create and save prompts using Prompt management so that you can save time by applying the same prompt to different workflows. You can include variables in the prompt so that you can adjust the prompt for different use case. To create a prompt, you set the `create_prompt` variable to `true` and pass in the appropriate values.

### Prompt Variants

Prompt variants in the context of Amazon Bedrock refer to alternative configurations of a prompt, including its message or the model and inference configurations used. Prompt variants allow you to create different versions of a prompt, test them, and save the variant that works best for your use case. You can add prompt variants to a prompt by passing in the values for the `variants_list` variable:

```hcl
  variants_list = [
    {
      name          = "variant-example"
      template_type = "TEXT"
      model_id      = "amazon.titan-text-express-v1"
      inference_configuration = {
        text = {
          temperature    = 1
          top_p          = 0.9900000095367432
          max_tokens     = 300
          stop_sequences = ["User:"]
          top_k          = 250
        }
      }
      template_configuration = {
        text = {
          input_variables = [
            {
              name = "topic"
            }
          ]
          text = "Make me a {{genre}} playlist consisting of the following number of songs: {{number}}."
        }
      }
    }
  ]
```

### Prompt Version

A prompt version is a snapshot of a prompt at a specific point in time that you create when you are satisfied with a set of configurations. Versions allow you to deploy your prompt and easily switch between different configurations for your prompt and update your application with the most appropriate version for your use-case.

You can create a Prompt version by setting `create_prompt_version` to `true` and adding an optional `prompt_version_description` and optional `prompt_version_tags`.

Creating a prompt with a prompt version would look like:

```hcl
module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  create_agent = false

  # Prompt Management
  prompt_name = "prompt"
  default_variant = "variant-example"
  create_prompt = true
  create_prompt_version = true
  prompt_version_description = "Example prompt version"
  variants_list = [
    {
      name          = "variant-example"
      template_type = "TEXT"
      model_id      = "amazon.titan-text-express-v1"
      inference_configuration = {
        text = {
          temperature    = 1
          top_p          = 0.9900000095367432
          max_tokens     = 300
          stop_sequences = ["User:"]
          top_k          = 250
        }
      }
      template_configuration = {
        text = {
          input_variables = [
            {
              name = "topic"
            }
          ]
          text = "Make me a {{genre}} playlist consisting of the following number of songs: {{number}}."
        }
      }
    }

  ]

}
```

See the additional input variables for deploying prompt management [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L971)

## Application Inference Profile

You can create an application inference profile with one or more Regions to track usage and costs when invoking a model.

To create an application inference profile for one Region, specify a foundation model. Usage and costs for requests made to that Region with that model will be tracked.

To create an application inference profile for multiple Regions, specify a cross region (system-defined) inference profile. The inference profile will route requests to the Regions defined in the cross region (system-defined) inference profile that you choose. Usage and costs for requests made to the Regions in the inference profile will be tracked. You can find the system defined inference profiles by navigating to your console (Amazon Bedrock -> Cross-region inference).

```hcl
# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

module "bedrock" {
  source  = "aws-ia/bedrock/aws"
  version = "0.0.31"
  create_agent = false

  # Application Inference Profile
  create_app_inference_profile = true
  app_inference_profile_model_source = "arn:aws:bedrock:${data.aws_region.current.name}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
}
```

See the additional input variables for deploying application inference profiles [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L1057)

## Custom Models

Model customization is the process of providing training data to a base model in order to improve its performance for specific use-cases.  Custom models help improve performance on domain-specific tasks while maintaining the base capabilities of the foundation model. With custom models, you can do a continued pre-training or fine-tuning job which is started when the Terraform resource is created.

To create a custom model, set the `create_custom_model` variable to `true` and pass in the necessary values for custom models:

- `custom_model_id`
  - Defaults to `amazon.titan-text-express-v1`
- `custom_model_name`
  - Defaults to `custom-model`
- `custom_model_job_name`
  - Defaults to `custom-model-job`
- `customization_type`
  - Defaults to `FINE_TUNING` but the other valid value is `CONTINUED_PRE_TRAINING`
- `custom_model_hyperparameters`
  - Defaults to:
  {
    "epochCount"              = "2",
    "batchSize"               = "1",
    "learningRate"            = "0.00001",
    "learningRateWarmupSteps" = "10"
  }
- `custom_model_training_uri`

See the additional input variables for deploying custom models [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L1127)

## Bedrock Data Automation (BDA)

### BDA Project

Amazon Bedrock Data AAutomation (BDA) helps you extract information and insights from your documents, images, videos, and audio files using foundation models (FMs). BDA provides both standard output and custom output through blueprints.

BDA supports different extraction capabilities for each file type:

- Documents
  - Text extraction with different granularity levels (word, line, page)
  - Bounding box information
  - Custom output formats
- Images
  - Object and scene detection
  - Text extraction
  - Bounding box information
  - Custom generative fields
- Video
  - Object and action detection
  - Scene analysis
  - Bounding box tracking
  - Custom generative fields
- Audio
  - Speaker identification
  - Sentiment analysis
  - Language detection
  - Transcription
  - Custom generative fields

### Standard Output

Standard output is pre-defined extraction managed by Bedrock. It can extract information from documents, images, videos, and audio files. You can configure what information to extract for each file type.

```hcl
module "bedrock" {
  source     = "aws-ia/bedrock/aws"
  version    = "0.0.31"
  create_agent = false
  create_bda = true

  bda_standard_output_configuration = {
    document = {
      extraction = {
        bounding_box = {
          state = "ENABLED"
        }
        granularity = {
          types = ["WORD", "PAGE"]
        }
      }
      generative_field = {
        state = "ENABLED"
      }
      output_format = {
        additional_file_format = {
          state = "ENABLED"
        }
        text_format = {
          types = ["PLAIN_TEXT"]
        }
      }
    }
  }
}
```

### Blueprints

Blueprints allow you to define custom extraction schemas for your specific use cases. You can specify what information to extract and how to structure the output.

```hcl
module "bedrock" {
  source     = "aws-ia/bedrock/aws"
  version    = "0.0.31"
  create_agent = false

  create_blueprint = true
  blueprint_name   = "advertisement-analysis"
  blueprint_schema = jsonencode({
    "$schema"     = "http://json-schema.org/draft-07/schema#"
    description   = "Extract key information from advertisement images"
    class         = "advertisement image"
    type          = "object"
    properties = {
      image_sentiment = {
        type          = "string"
        inferenceType = "explicit"
        instruction   = "What is the overall sentiment of the image?"
      }
      # Additional properties as needed
    }
  })
}
```

See the additional input variables for deploying BDA projects and blueprints [here](https://github.com/aws-ia/terraform-aws-bedrock/blob/12b2681ce9a0ee5c7acd6d44289e5e1b98203a8a/variables.tf#L1530)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, ~> 6.2.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | >= 2.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.6 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, ~> 6.2.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.0.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.6.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_oss_knowledgebase"></a> [oss\_knowledgebase](#module\_oss\_knowledgebase) | aws-ia/opensearch-serverless/aws | 0.0.5 |

## Resources

| Name | Type |
|------|------|
| [aws_bedrock_custom_model.custom_model](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrock_custom_model) | resource |
| [aws_bedrockagent_agent.agent_supervisor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_agent) | resource |
| [aws_bedrockagent_agent_alias.bedrock_agent_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_agent_alias) | resource |
| [aws_bedrockagent_agent_collaborator.agent_collaborator](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagent_agent_collaborator) | resource |
| [aws_cloudwatch_log_group.knowledge_base_cwl](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_policy.bedrock_kb_kendra](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_opensearch_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_s3_decryption_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_sql](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_sql_provisioned](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_kb_sql_serverless](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_knowledge_base_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.bedrock_knowledge_base_policy_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agent_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.application_inference_profile_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.bedrock_knowledge_base_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.custom_model_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.action_group_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.agent_alias_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.agent_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.app_inference_profile_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.app_inference_profile_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.bedrock_kb_oss](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.custom_model_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.guardrail_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.guardrail_policy_supervisor_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.kb_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.bedrock_kb_s3_decryption_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_kendra_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_opensearch_managed_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_policy_s3_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_sql_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_sql_provision_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.bedrock_knowledge_base_sql_serverless_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.allow_bedrock_agent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_opensearchserverless_access_policy.updated_data_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/opensearchserverless_access_policy) | resource |
| [awscc_bedrock_agent.bedrock_agent](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_agent) | resource |
| [awscc_bedrock_agent_alias.bedrock_agent_alias](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_agent_alias) | resource |
| [awscc_bedrock_application_inference_profile.application_inference_profile](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_application_inference_profile) | resource |
| [awscc_bedrock_blueprint.bda_blueprint](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_blueprint) | resource |
| [awscc_bedrock_data_automation_project.bda_project](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_automation_project) | resource |
| [awscc_bedrock_data_source.knowledge_base_confluence](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_ds](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_salesforce](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_sharepoint](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_data_source.knowledge_base_web_crawler](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_data_source) | resource |
| [awscc_bedrock_flow_alias.flow_alias](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_flow_alias) | resource |
| [awscc_bedrock_flow_version.flow_version](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_flow_version) | resource |
| [awscc_bedrock_guardrail.guardrail](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_guardrail) | resource |
| [awscc_bedrock_guardrail_version.guardrail](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_guardrail_version) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_default](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_kendra](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_mongo](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_neptune_analytics](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_opensearch](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_opensearch_managed](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_pinecone](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_rds](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_knowledge_base.knowledge_base_sql](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_knowledge_base) | resource |
| [awscc_bedrock_prompt.prompt](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_prompt) | resource |
| [awscc_bedrock_prompt_version.prompt_version](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/bedrock_prompt_version) | resource |
| [awscc_iam_role.kendra_index_role](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/iam_role) | resource |
| [awscc_iam_role.kendra_s3_datasource_role](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/iam_role) | resource |
| [awscc_iam_role_policy.kendra_role_policy](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/iam_role_policy) | resource |
| [awscc_kendra_data_source.kendra_s3_data_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/kendra_data_source) | resource |
| [awscc_kendra_index.genai_kendra_index](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/kendra_index) | resource |
| [awscc_logs_delivery.knowledge_base_log_delivery](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/logs_delivery) | resource |
| [awscc_logs_delivery_destination.knowledge_base_log_destination](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/logs_delivery_destination) | resource |
| [awscc_logs_delivery_source.knowledge_base_log_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/logs_delivery_source) | resource |
| [awscc_s3_bucket.custom_model_output](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/s3_bucket) | resource |
| [awscc_s3_bucket.s3_data_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/s3_bucket) | resource |
| [random_string.solution_prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [time_sleep.wait_after_index_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_after_kendra_index_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_after_kendra_s3_data_source_creation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_inference_profile](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [time_sleep.wait_for_use_inference_profile_role_policy](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_bedrock_foundation_model.model_identifier](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/bedrock_foundation_model) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.agent_alias_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.agent_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.agent_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.app_inference_profile_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.custom_model_trust](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.knowledge_base_permissions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_description"></a> [action\_group\_description](#input\_action\_group\_description) | Description of the action group. | `string` | `null` | no |
| <a name="input_action_group_lambda_arns_list"></a> [action\_group\_lambda\_arns\_list](#input\_action\_group\_lambda\_arns\_list) | List of Lambda ARNs for action groups. | `list(string)` | `[]` | no |
| <a name="input_action_group_lambda_names_list"></a> [action\_group\_lambda\_names\_list](#input\_action\_group\_lambda\_names\_list) | List of Lambda names for action groups. | `list(string)` | `[]` | no |
| <a name="input_action_group_list"></a> [action\_group\_list](#input\_action\_group\_list) | List of configurations for available action groups. | <pre>list(object({<br/>    action_group_name                    = optional(string)<br/>    description                          = optional(string)<br/>    action_group_state                   = optional(string)<br/>    parent_action_group_signature        = optional(string)<br/>    skip_resource_in_use_check_on_delete = optional(bool)<br/>    action_group_executor = optional(object({<br/>      custom_control = optional(string)<br/>      lambda         = optional(string)<br/>    }))<br/>    api_schema = optional(object({<br/>      payload = optional(string)<br/>      s3 = optional(object({<br/>        s3_bucket_name = optional(string)<br/>        s3_object_key  = optional(string)<br/>      }))<br/>    }))<br/>    function_schema = optional(object({<br/>      functions = optional(list(object({<br/>        description = optional(string)<br/>        name        = optional(string)<br/>        parameters = optional(map(object({<br/>          description = optional(string)<br/>          required    = optional(bool)<br/>          type        = optional(string)<br/>        })))<br/>        require_confirmation = optional(string)<br/>      })))<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_action_group_name"></a> [action\_group\_name](#input\_action\_group\_name) | Name of the action group. | `string` | `null` | no |
| <a name="input_action_group_state"></a> [action\_group\_state](#input\_action\_group\_state) | State of the action group. | `string` | `null` | no |
| <a name="input_additional_model_request_fields"></a> [additional\_model\_request\_fields](#input\_additional\_model\_request\_fields) | Additional model request fields for prompt configuration in JSON format. | `string` | `null` | no |
| <a name="input_agent_alias_description"></a> [agent\_alias\_description](#input\_agent\_alias\_description) | Description of the agent alias. | `string` | `null` | no |
| <a name="input_agent_alias_name"></a> [agent\_alias\_name](#input\_agent\_alias\_name) | The name of the agent alias. | `string` | `"TerraformBedrockAgentAlias"` | no |
| <a name="input_agent_alias_tags"></a> [agent\_alias\_tags](#input\_agent\_alias\_tags) | Tag bedrock agent alias resource. | `map(string)` | `null` | no |
| <a name="input_agent_collaboration"></a> [agent\_collaboration](#input\_agent\_collaboration) | Agents collaboration role. | `string` | `"SUPERVISOR"` | no |
| <a name="input_agent_description"></a> [agent\_description](#input\_agent\_description) | A description of agent. | `string` | `null` | no |
| <a name="input_agent_id"></a> [agent\_id](#input\_agent\_id) | Agent identifier. | `string` | `null` | no |
| <a name="input_agent_name"></a> [agent\_name](#input\_agent\_name) | The name of your agent. | `string` | `"TerraformBedrockAgents"` | no |
| <a name="input_agent_resource_role_arn"></a> [agent\_resource\_role\_arn](#input\_agent\_resource\_role\_arn) | Optional external IAM role ARN for the Bedrock agent resource role. If empty, the module will create one internally. | `string` | `null` | no |
| <a name="input_allow_opensearch_public_access"></a> [allow\_opensearch\_public\_access](#input\_allow\_opensearch\_public\_access) | Whether or not to allow public access to the OpenSearch collection endpoint and the Dashboards endpoint. | `bool` | `true` | no |
| <a name="input_api_schema_payload"></a> [api\_schema\_payload](#input\_api\_schema\_payload) | String OpenAPI Payload. | `string` | `null` | no |
| <a name="input_api_schema_s3_bucket_name"></a> [api\_schema\_s3\_bucket\_name](#input\_api\_schema\_s3\_bucket\_name) | A bucket in S3. | `string` | `null` | no |
| <a name="input_api_schema_s3_object_key"></a> [api\_schema\_s3\_object\_key](#input\_api\_schema\_s3\_object\_key) | An object key in S3. | `string` | `null` | no |
| <a name="input_app_inference_profile_description"></a> [app\_inference\_profile\_description](#input\_app\_inference\_profile\_description) | A description of application inference profile. | `string` | `null` | no |
| <a name="input_app_inference_profile_model_source"></a> [app\_inference\_profile\_model\_source](#input\_app\_inference\_profile\_model\_source) | Source arns for a custom inference profile to copy its regional load balancing config from. This can either be a foundation model or predefined inference profile ARN. | `string` | `null` | no |
| <a name="input_app_inference_profile_name"></a> [app\_inference\_profile\_name](#input\_app\_inference\_profile\_name) | The name of your application inference profile. | `string` | `"AppInferenceProfile"` | no |
| <a name="input_app_inference_profile_tags"></a> [app\_inference\_profile\_tags](#input\_app\_inference\_profile\_tags) | A map of tag keys and values for application inference profile. | `list(map(string))` | `null` | no |
| <a name="input_auth_type"></a> [auth\_type](#input\_auth\_type) | The supported authentication type. | `string` | `null` | no |
| <a name="input_base_prompt_template"></a> [base\_prompt\_template](#input\_base\_prompt\_template) | Defines the prompt template with which to replace the default prompt template. | `string` | `null` | no |
| <a name="input_bda_custom_output_config"></a> [bda\_custom\_output\_config](#input\_bda\_custom\_output\_config) | A list of the BDA custom output configuartion blueprint(s). | <pre>list(object({<br/>    blueprint_arn     = optional(string)<br/>    blueprint_stage   = optional(string)<br/>    blueprint_version = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_bda_kms_encryption_context"></a> [bda\_kms\_encryption\_context](#input\_bda\_kms\_encryption\_context) | The KMS encryption context for the Bedrock data automation project. | `map(string)` | `null` | no |
| <a name="input_bda_kms_key_id"></a> [bda\_kms\_key\_id](#input\_bda\_kms\_key\_id) | The KMS key ID for the Bedrock data automation project. | `string` | `null` | no |
| <a name="input_bda_override_config_state"></a> [bda\_override\_config\_state](#input\_bda\_override\_config\_state) | Configuration state for the BDA override. | `string` | `null` | no |
| <a name="input_bda_project_description"></a> [bda\_project\_description](#input\_bda\_project\_description) | The description of the Bedrock data automation project. | `string` | `null` | no |
| <a name="input_bda_project_name"></a> [bda\_project\_name](#input\_bda\_project\_name) | The name of the Bedrock data automation project. | `string` | `"bda-project"` | no |
| <a name="input_bda_standard_output_configuration"></a> [bda\_standard\_output\_configuration](#input\_bda\_standard\_output\_configuration) | Standard output is pre-defined extraction managed by Bedrock. It can extract information from documents, images, videos, and audio. | <pre>object({<br/>    audio = optional(object({<br/>      extraction = optional(object({<br/>        category = optional(object({<br/>          state = optional(string)<br/>          types = optional(list(string))<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>        types = optional(list(string))<br/>      }))<br/>    }))<br/>    document = optional(object({<br/>      extraction = optional(object({<br/>        bounding_box = optional(object({<br/>          state = optional(string)<br/>        }))<br/>        granularity = optional(object({<br/>          types = optional(list(string))<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>      }))<br/>      output_format = optional(object({<br/>        additional_file_format = optional(object({<br/>          state = optional(string)<br/>        }))<br/>        text_format = optional(object({<br/>          types = optional(list(string))<br/>        }))<br/>      }))<br/>    }))<br/>    image = optional(object({<br/>      extraction = optional(object({<br/>        category = optional(object({<br/>          state = optional(string)<br/>          types = optional(list(string))<br/>        }))<br/>        bounding_box = optional(object({<br/>          state = optional(string)<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>        types = optional(list(string))<br/>      }))<br/>    }))<br/>    video = optional(object({<br/>      extraction = optional(object({<br/>        category = optional(object({<br/>          state = optional(string)<br/>          types = optional(list(string))<br/>        }))<br/>        bounding_box = optional(object({<br/>          state = optional(string)<br/>        }))<br/>      }))<br/>      generative_field = optional(object({<br/>        state = optional(string)<br/>        types = optional(list(string))<br/>      }))<br/>    }))<br/>  })</pre> | `null` | no |
| <a name="input_bda_tags"></a> [bda\_tags](#input\_bda\_tags) | A list of tag keys and values for the Bedrock data automation project. | <pre>list(object({<br/>    key   = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_bedrock_agent_alias_provisioned_throughput"></a> [bedrock\_agent\_alias\_provisioned\_throughput](#input\_bedrock\_agent\_alias\_provisioned\_throughput) | ARN of the Provisioned Throughput assigned to the agent alias. | `string` | `null` | no |
| <a name="input_bedrock_agent_version"></a> [bedrock\_agent\_version](#input\_bedrock\_agent\_version) | Agent version. | `string` | `null` | no |
| <a name="input_blocked_input_messaging"></a> [blocked\_input\_messaging](#input\_blocked\_input\_messaging) | Messaging for when violations are detected in text. | `string` | `"Blocked input"` | no |
| <a name="input_blocked_outputs_messaging"></a> [blocked\_outputs\_messaging](#input\_blocked\_outputs\_messaging) | Messaging for when violations are detected in text. | `string` | `"Blocked output"` | no |
| <a name="input_blueprint_kms_encryption_context"></a> [blueprint\_kms\_encryption\_context](#input\_blueprint\_kms\_encryption\_context) | The KMS encryption context for the blueprint. | `map(string)` | `null` | no |
| <a name="input_blueprint_kms_key_id"></a> [blueprint\_kms\_key\_id](#input\_blueprint\_kms\_key\_id) | The KMS key ID for the blueprint. | `string` | `null` | no |
| <a name="input_blueprint_name"></a> [blueprint\_name](#input\_blueprint\_name) | The name of the BDA blueprint. | `string` | `"bda-blueprint"` | no |
| <a name="input_blueprint_schema"></a> [blueprint\_schema](#input\_blueprint\_schema) | The schema for the blueprint. | `string` | `null` | no |
| <a name="input_blueprint_tags"></a> [blueprint\_tags](#input\_blueprint\_tags) | A list of tag keys and values for the blueprint. | <pre>list(object({<br/>    key   = string<br/>    value = string<br/>  }))</pre> | `null` | no |
| <a name="input_blueprint_type"></a> [blueprint\_type](#input\_blueprint\_type) | The modality type of the blueprint. | `string` | `"DOCUMENT"` | no |
| <a name="input_breakpoint_percentile_threshold"></a> [breakpoint\_percentile\_threshold](#input\_breakpoint\_percentile\_threshold) | The dissimilarity threshold for splitting chunks. | `number` | `null` | no |
| <a name="input_bucket_owner_account_id"></a> [bucket\_owner\_account\_id](#input\_bucket\_owner\_account\_id) | Bucket account owner ID for the S3 bucket. | `string` | `null` | no |
| <a name="input_chunking_strategy"></a> [chunking\_strategy](#input\_chunking\_strategy) | Knowledge base can split your source data into chunks. A chunk refers to an excerpt from a data source that is returned when the knowledge base that it belongs to is queried. You have the following options for chunking your data. If you opt for NONE, then you may want to pre-process your files by splitting them up such that each file corresponds to a chunk. | `string` | `null` | no |
| <a name="input_chunking_strategy_max_tokens"></a> [chunking\_strategy\_max\_tokens](#input\_chunking\_strategy\_max\_tokens) | The maximum number of tokens to include in a chunk. | `number` | `null` | no |
| <a name="input_chunking_strategy_overlap_percentage"></a> [chunking\_strategy\_overlap\_percentage](#input\_chunking\_strategy\_overlap\_percentage) | The percentage of overlap between adjacent chunks of a data source. | `number` | `null` | no |
| <a name="input_collaboration_instruction"></a> [collaboration\_instruction](#input\_collaboration\_instruction) | Instruction to give the collaborator. | `string` | `null` | no |
| <a name="input_collaborator_name"></a> [collaborator\_name](#input\_collaborator\_name) | The name of the collaborator. | `string` | `"TerraformBedrockAgentCollaborator"` | no |
| <a name="input_collection_arn"></a> [collection\_arn](#input\_collection\_arn) | The ARN of the collection. | `string` | `null` | no |
| <a name="input_collection_name"></a> [collection\_name](#input\_collection\_name) | The name of the collection. | `string` | `null` | no |
| <a name="input_confluence_credentials_secret_arn"></a> [confluence\_credentials\_secret\_arn](#input\_confluence\_credentials\_secret\_arn) | The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your Confluence instance URL. | `string` | `null` | no |
| <a name="input_connection_string"></a> [connection\_string](#input\_connection\_string) | The endpoint URL for your index management page. | `string` | `null` | no |
| <a name="input_content_filters_tier_config"></a> [content\_filters\_tier\_config](#input\_content\_filters\_tier\_config) | Guardrail tier config for content policy. | <pre>object({<br/>    tier_name = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_context_enrichment_model_arn"></a> [context\_enrichment\_model\_arn](#input\_context\_enrichment\_model\_arn) | The model's ARN for context enrichment. | `string` | `null` | no |
| <a name="input_context_enrichment_type"></a> [context\_enrichment\_type](#input\_context\_enrichment\_type) | Enrichment type to be used for the vector database. | `string` | `null` | no |
| <a name="input_contextual_grounding_policy_filters"></a> [contextual\_grounding\_policy\_filters](#input\_contextual\_grounding\_policy\_filters) | The contextual grounding policy filters for the guardrail. | `list(map(string))` | `null` | no |
| <a name="input_crawl_filter_type"></a> [crawl\_filter\_type](#input\_crawl\_filter\_type) | The crawl filter type. | `string` | `null` | no |
| <a name="input_crawler_scope"></a> [crawler\_scope](#input\_crawler\_scope) | The scope that a web crawl job will be restricted to. | `string` | `null` | no |
| <a name="input_create_ag"></a> [create\_ag](#input\_create\_ag) | Whether or not to create an action group. | `bool` | `false` | no |
| <a name="input_create_agent"></a> [create\_agent](#input\_create\_agent) | Whether or not to deploy an agent. | `bool` | `true` | no |
| <a name="input_create_agent_alias"></a> [create\_agent\_alias](#input\_create\_agent\_alias) | Whether or not to create an agent alias. | `bool` | `false` | no |
| <a name="input_create_app_inference_profile"></a> [create\_app\_inference\_profile](#input\_create\_app\_inference\_profile) | Whether or not to create an application inference profile. | `bool` | `false` | no |
| <a name="input_create_bda"></a> [create\_bda](#input\_create\_bda) | Whether or not to create a Bedrock data automatio project. | `bool` | `false` | no |
| <a name="input_create_bedrock_data_automation_config"></a> [create\_bedrock\_data\_automation\_config](#input\_create\_bedrock\_data\_automation\_config) | Whether or not to create Bedrock Data Automation configuration for the data source. | `bool` | `false` | no |
| <a name="input_create_blueprint"></a> [create\_blueprint](#input\_create\_blueprint) | Whether or not to create a BDA blueprint. | `bool` | `false` | no |
| <a name="input_create_collaborator"></a> [create\_collaborator](#input\_create\_collaborator) | Whether or not to create an agent collaborator. | `bool` | `false` | no |
| <a name="input_create_confluence"></a> [create\_confluence](#input\_create\_confluence) | Whether or not create a Confluence data source. | `bool` | `false` | no |
| <a name="input_create_context_enrichment_config"></a> [create\_context\_enrichment\_config](#input\_create\_context\_enrichment\_config) | Whether or not to create context enrichment configuration for the data source. | `bool` | `false` | no |
| <a name="input_create_custom_model"></a> [create\_custom\_model](#input\_create\_custom\_model) | Whether or not to create a custom model. | `bool` | `false` | no |
| <a name="input_create_custom_tranformation_config"></a> [create\_custom\_tranformation\_config](#input\_create\_custom\_tranformation\_config) | Whether or not to create a custom transformation configuration. | `bool` | `false` | no |
| <a name="input_create_default_kb"></a> [create\_default\_kb](#input\_create\_default\_kb) | Whether or not to create the default knowledge base. | `bool` | `false` | no |
| <a name="input_create_flow_alias"></a> [create\_flow\_alias](#input\_create\_flow\_alias) | Whether or not to create a flow alias resource. | `bool` | `false` | no |
| <a name="input_create_guardrail"></a> [create\_guardrail](#input\_create\_guardrail) | Whether or not to create a guardrail. | `bool` | `false` | no |
| <a name="input_create_kb"></a> [create\_kb](#input\_create\_kb) | Whether or not to attach a knowledge base. | `bool` | `false` | no |
| <a name="input_create_kb_log_group"></a> [create\_kb\_log\_group](#input\_create\_kb\_log\_group) | Whether or not to create a log group for the knowledge base. | `bool` | `false` | no |
| <a name="input_create_kendra_config"></a> [create\_kendra\_config](#input\_create\_kendra\_config) | Whether or not to create a Kendra GenAI knowledge base. | `bool` | `false` | no |
| <a name="input_create_kendra_s3_data_source"></a> [create\_kendra\_s3\_data\_source](#input\_create\_kendra\_s3\_data\_source) | Whether or not to create a Kendra S3 data source. | `bool` | `false` | no |
| <a name="input_create_mongo_config"></a> [create\_mongo\_config](#input\_create\_mongo\_config) | Whether or not to use MongoDB Atlas configuration | `bool` | `false` | no |
| <a name="input_create_neptune_analytics_config"></a> [create\_neptune\_analytics\_config](#input\_create\_neptune\_analytics\_config) | Whether or not to use Neptune Analytics configuration | `bool` | `false` | no |
| <a name="input_create_opensearch_config"></a> [create\_opensearch\_config](#input\_create\_opensearch\_config) | Whether or not to use Opensearch Serverless configuration | `bool` | `false` | no |
| <a name="input_create_opensearch_managed_config"></a> [create\_opensearch\_managed\_config](#input\_create\_opensearch\_managed\_config) | Whether or not to use OpenSearch Managed Cluster configuration | `bool` | `false` | no |
| <a name="input_create_parsing_configuration"></a> [create\_parsing\_configuration](#input\_create\_parsing\_configuration) | Whether or not to create a parsing configuration. | `bool` | `false` | no |
| <a name="input_create_pinecone_config"></a> [create\_pinecone\_config](#input\_create\_pinecone\_config) | Whether or not to use Pinecone configuration | `bool` | `false` | no |
| <a name="input_create_prompt"></a> [create\_prompt](#input\_create\_prompt) | Whether or not to create a prompt resource. | `bool` | `false` | no |
| <a name="input_create_prompt_version"></a> [create\_prompt\_version](#input\_create\_prompt\_version) | Whether or not to create a prompt version. | `bool` | `false` | no |
| <a name="input_create_rds_config"></a> [create\_rds\_config](#input\_create\_rds\_config) | Whether or not to use RDS configuration | `bool` | `false` | no |
| <a name="input_create_s3_data_source"></a> [create\_s3\_data\_source](#input\_create\_s3\_data\_source) | Whether or not to create the S3 data source. | `bool` | `false` | no |
| <a name="input_create_salesforce"></a> [create\_salesforce](#input\_create\_salesforce) | Whether or not create a Salesforce data source. | `bool` | `false` | no |
| <a name="input_create_server_side_encryption_config"></a> [create\_server\_side\_encryption\_config](#input\_create\_server\_side\_encryption\_config) | Whether or not to create server-side encryption configuration for the data source. | `bool` | `false` | no |
| <a name="input_create_sharepoint"></a> [create\_sharepoint](#input\_create\_sharepoint) | Whether or not create a Share Point data source. | `bool` | `false` | no |
| <a name="input_create_sql_config"></a> [create\_sql\_config](#input\_create\_sql\_config) | Whether or not to create a SQL knowledge base. | `bool` | `false` | no |
| <a name="input_create_supervisor"></a> [create\_supervisor](#input\_create\_supervisor) | Whether or not to create an agent supervisor. | `bool` | `false` | no |
| <a name="input_create_supervisor_guardrail"></a> [create\_supervisor\_guardrail](#input\_create\_supervisor\_guardrail) | Whether or not to create a guardrail for the supervisor agent. | `bool` | `false` | no |
| <a name="input_create_supplemental_data_storage"></a> [create\_supplemental\_data\_storage](#input\_create\_supplemental\_data\_storage) | Whether or not to create supplemental data storage configuration. | `bool` | `false` | no |
| <a name="input_create_vector_ingestion_configuration"></a> [create\_vector\_ingestion\_configuration](#input\_create\_vector\_ingestion\_configuration) | Whether or not to create a vector ingestion configuration. | `bool` | `false` | no |
| <a name="input_create_web_crawler"></a> [create\_web\_crawler](#input\_create\_web\_crawler) | Whether or not create a web crawler data source. | `bool` | `false` | no |
| <a name="input_credentials_secret_arn"></a> [credentials\_secret\_arn](#input\_credentials\_secret\_arn) | The ARN of the secret in Secrets Manager that is linked to your database | `string` | `null` | no |
| <a name="input_custom_control"></a> [custom\_control](#input\_custom\_control) | Custom control of action execution. | `string` | `null` | no |
| <a name="input_custom_metadata_field"></a> [custom\_metadata\_field](#input\_custom\_metadata\_field) | The name of the field in which Amazon Bedrock stores custom metadata about the vector store. | `string` | `null` | no |
| <a name="input_custom_model_hyperparameters"></a> [custom\_model\_hyperparameters](#input\_custom\_model\_hyperparameters) | Parameters related to tuning the custom model. | `map(string)` | <pre>{<br/>  "batchSize": "1",<br/>  "epochCount": "2",<br/>  "learningRate": "0.00001",<br/>  "learningRateWarmupSteps": "10"<br/>}</pre> | no |
| <a name="input_custom_model_id"></a> [custom\_model\_id](#input\_custom\_model\_id) | The base model id for a custom model. | `string` | `"amazon.titan-text-express-v1"` | no |
| <a name="input_custom_model_job_name"></a> [custom\_model\_job\_name](#input\_custom\_model\_job\_name) | A name for the model customization job. | `string` | `"custom-model-job"` | no |
| <a name="input_custom_model_kms_key_id"></a> [custom\_model\_kms\_key\_id](#input\_custom\_model\_kms\_key\_id) | The custom model is encrypted at rest using this key. Specify the key ARN. | `string` | `null` | no |
| <a name="input_custom_model_name"></a> [custom\_model\_name](#input\_custom\_model\_name) | Name for the custom model. | `string` | `"custom-model"` | no |
| <a name="input_custom_model_output_uri"></a> [custom\_model\_output\_uri](#input\_custom\_model\_output\_uri) | The S3 URI where the output data is stored for custom model. | `string` | `null` | no |
| <a name="input_custom_model_tags"></a> [custom\_model\_tags](#input\_custom\_model\_tags) | A map of tag keys and values for the custom model. | `map(string)` | `null` | no |
| <a name="input_custom_model_training_uri"></a> [custom\_model\_training\_uri](#input\_custom\_model\_training\_uri) | The S3 URI where the training data is stored for custom model. | `string` | `null` | no |
| <a name="input_custom_orchestration_lambda_arn"></a> [custom\_orchestration\_lambda\_arn](#input\_custom\_orchestration\_lambda\_arn) | ARN of the Lambda function to use for custom orchestration. Required when orchestration\_type is set to CUSTOM. | `string` | `null` | no |
| <a name="input_customer_encryption_key_arn"></a> [customer\_encryption\_key\_arn](#input\_customer\_encryption\_key\_arn) | A KMS key ARN. | `string` | `null` | no |
| <a name="input_customization_type"></a> [customization\_type](#input\_customization\_type) | The customization type. Valid values: FINE\_TUNING, CONTINUED\_PRE\_TRAINING. | `string` | `"FINE_TUNING"` | no |
| <a name="input_data_deletion_policy"></a> [data\_deletion\_policy](#input\_data\_deletion\_policy) | Policy for deleting data from the data source. Can be either DELETE or RETAIN. | `string` | `"DELETE"` | no |
| <a name="input_data_source_description"></a> [data\_source\_description](#input\_data\_source\_description) | Description of the data source. | `string` | `null` | no |
| <a name="input_data_source_kms_key_arn"></a> [data\_source\_kms\_key\_arn](#input\_data\_source\_kms\_key\_arn) | The ARN of the AWS KMS key used to encrypt the data source. | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name of the database. | `string` | `null` | no |
| <a name="input_default_variant"></a> [default\_variant](#input\_default\_variant) | Name for a variant. | `string` | `null` | no |
| <a name="input_document_metadata_configurations"></a> [document\_metadata\_configurations](#input\_document\_metadata\_configurations) | List of document metadata configurations for Kendra. | <pre>list(object({<br/>    name = optional(string)<br/>    type = optional(string)<br/>    search = optional(object({<br/>      facetable   = optional(bool)<br/>      searchable  = optional(bool)<br/>      displayable = optional(bool)<br/>      sortable    = optional(bool)<br/>    }))<br/>    relevance = optional(object({<br/>      duration   = optional(string)<br/>      freshness  = optional(bool)<br/>      importance = optional(number)<br/>      rank_order = optional(string)<br/>      value_importance_items = optional(list(object({<br/>        key   = optional(string)<br/>        value = optional(number)<br/>      })))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_domain_arn"></a> [domain\_arn](#input\_domain\_arn) | The Amazon Resource Name (ARN) of the OpenSearch domain. | `string` | `null` | no |
| <a name="input_domain_endpoint"></a> [domain\_endpoint](#input\_domain\_endpoint) | The endpoint URL the OpenSearch domain. | `string` | `null` | no |
| <a name="input_embedding_data_type"></a> [embedding\_data\_type](#input\_embedding\_data\_type) | The data type for the vectors when using a model to convert text into vector embeddings. | `string` | `null` | no |
| <a name="input_embedding_model_dimensions"></a> [embedding\_model\_dimensions](#input\_embedding\_model\_dimensions) | The dimensions details for the vector configuration used on the Bedrock embeddings model. | `number` | `null` | no |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Database endpoint | `string` | `null` | no |
| <a name="input_endpoint_service_name"></a> [endpoint\_service\_name](#input\_endpoint\_service\_name) | MongoDB Atlas endpoint service name. | `string` | `null` | no |
| <a name="input_enrichment_strategy_method"></a> [enrichment\_strategy\_method](#input\_enrichment\_strategy\_method) | Enrichment Strategy method. | `string` | `null` | no |
| <a name="input_exclusion_filters"></a> [exclusion\_filters](#input\_exclusion\_filters) | A set of regular expression filter patterns for a type of object. | `list(string)` | `[]` | no |
| <a name="input_existing_kb"></a> [existing\_kb](#input\_existing\_kb) | The ID of the existing knowledge base. | `string` | `null` | no |
| <a name="input_filters_config"></a> [filters\_config](#input\_filters\_config) | List of content filter configs in content policy. | <pre>list(object({<br/>    type              = string<br/>    input_strength    = string<br/>    output_strength   = string<br/>    input_action      = optional(string)<br/>    output_action     = optional(string)<br/>    input_modalities  = optional(list(string))<br/>    output_modalities = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_flow_alias_description"></a> [flow\_alias\_description](#input\_flow\_alias\_description) | A description of the flow alias. | `string` | `null` | no |
| <a name="input_flow_alias_name"></a> [flow\_alias\_name](#input\_flow\_alias\_name) | The name of your flow alias. | `string` | `"BedrockFlowAlias"` | no |
| <a name="input_flow_arn"></a> [flow\_arn](#input\_flow\_arn) | ARN representation of the flow. | `string` | `null` | no |
| <a name="input_flow_version"></a> [flow\_version](#input\_flow\_version) | Version of the flow. | `string` | `null` | no |
| <a name="input_flow_version_description"></a> [flow\_version\_description](#input\_flow\_version\_description) | A description of flow version. | `string` | `null` | no |
| <a name="input_foundation_model"></a> [foundation\_model](#input\_foundation\_model) | The foundation model for the Bedrock agent. | `string` | `null` | no |
| <a name="input_graph_arn"></a> [graph\_arn](#input\_graph\_arn) | ARN for Neptune Analytics graph database. | `string` | `null` | no |
| <a name="input_guardrail_cross_region_config"></a> [guardrail\_cross\_region\_config](#input\_guardrail\_cross\_region\_config) | The system-defined guardrail profile to use with your guardrail. | <pre>object({<br/>    guardrail_profile_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_guardrail_description"></a> [guardrail\_description](#input\_guardrail\_description) | Description of the guardrail. | `string` | `null` | no |
| <a name="input_guardrail_kms_key_arn"></a> [guardrail\_kms\_key\_arn](#input\_guardrail\_kms\_key\_arn) | KMS encryption key to use for the guardrail. | `string` | `null` | no |
| <a name="input_guardrail_name"></a> [guardrail\_name](#input\_guardrail\_name) | The name of the guardrail. | `string` | `"TerraformBedrockGuardrail"` | no |
| <a name="input_guardrail_tags"></a> [guardrail\_tags](#input\_guardrail\_tags) | A map of tags keys and values for the knowledge base. | `list(map(string))` | `null` | no |
| <a name="input_heirarchical_overlap_tokens"></a> [heirarchical\_overlap\_tokens](#input\_heirarchical\_overlap\_tokens) | The number of tokens to repeat across chunks in the same layer. | `number` | `null` | no |
| <a name="input_host_type"></a> [host\_type](#input\_host\_type) | The supported host type, whether online/cloud or server/on-premises. | `string` | `null` | no |
| <a name="input_host_url"></a> [host\_url](#input\_host\_url) | The host URL or instance URL. | `string` | `null` | no |
| <a name="input_idle_session_ttl"></a> [idle\_session\_ttl](#input\_idle\_session\_ttl) | How long sessions should be kept open for the agent. | `number` | `600` | no |
| <a name="input_inclusion_filters"></a> [inclusion\_filters](#input\_inclusion\_filters) | A set of regular expression filter patterns for a type of object. | `list(string)` | `[]` | no |
| <a name="input_instruction"></a> [instruction](#input\_instruction) | A narrative instruction to provide the agent as context. | `string` | `""` | no |
| <a name="input_kb_description"></a> [kb\_description](#input\_kb\_description) | Description of knowledge base. | `string` | `"Terraform deployed Knowledge Base"` | no |
| <a name="input_kb_embedding_model_arn"></a> [kb\_embedding\_model\_arn](#input\_kb\_embedding\_model\_arn) | The ARN of the model used to create vector embeddings for the knowledge base. | `string` | `"arn:aws:bedrock:us-east-1::foundation-model/amazon.titan-embed-text-v2:0"` | no |
| <a name="input_kb_log_group_retention_in_days"></a> [kb\_log\_group\_retention\_in\_days](#input\_kb\_log\_group\_retention\_in\_days) | The retention period of the knowledge base log group. | `number` | `0` | no |
| <a name="input_kb_monitoring_arn"></a> [kb\_monitoring\_arn](#input\_kb\_monitoring\_arn) | The ARN of the target for delivery of knowledge base application logs | `string` | `null` | no |
| <a name="input_kb_name"></a> [kb\_name](#input\_kb\_name) | Name of the knowledge base. | `string` | `"knowledge-base"` | no |
| <a name="input_kb_role_arn"></a> [kb\_role\_arn](#input\_kb\_role\_arn) | The ARN of the IAM role with permission to invoke API operations on the knowledge base. | `string` | `null` | no |
| <a name="input_kb_s3_data_source"></a> [kb\_s3\_data\_source](#input\_kb\_s3\_data\_source) | The S3 data source ARN for the knowledge base. | `string` | `null` | no |
| <a name="input_kb_s3_data_source_kms_arn"></a> [kb\_s3\_data\_source\_kms\_arn](#input\_kb\_s3\_data\_source\_kms\_arn) | The ARN of the KMS key used to encrypt S3 content | `string` | `null` | no |
| <a name="input_kb_state"></a> [kb\_state](#input\_kb\_state) | State of knowledge base; whether it is enabled or disabled | `string` | `"ENABLED"` | no |
| <a name="input_kb_storage_type"></a> [kb\_storage\_type](#input\_kb\_storage\_type) | The storage type of a knowledge base. | `string` | `null` | no |
| <a name="input_kb_tags"></a> [kb\_tags](#input\_kb\_tags) | A map of tags keys and values for the knowledge base. | `map(string)` | `null` | no |
| <a name="input_kb_type"></a> [kb\_type](#input\_kb\_type) | The type of a knowledge base. | `string` | `"VECTOR"` | no |
| <a name="input_kendra_data_source_description"></a> [kendra\_data\_source\_description](#input\_kendra\_data\_source\_description) | A description for the Kendra data source. | `string` | `null` | no |
| <a name="input_kendra_data_source_language_code"></a> [kendra\_data\_source\_language\_code](#input\_kendra\_data\_source\_language\_code) | The code for the language of the Kendra data source content. | `string` | `"en"` | no |
| <a name="input_kendra_data_source_name"></a> [kendra\_data\_source\_name](#input\_kendra\_data\_source\_name) | The name of the Kendra data source. | `string` | `"kendra-data-source"` | no |
| <a name="input_kendra_data_source_schedule"></a> [kendra\_data\_source\_schedule](#input\_kendra\_data\_source\_schedule) | The schedule for Amazon Kendra to update the index. | `string` | `null` | no |
| <a name="input_kendra_data_source_tags"></a> [kendra\_data\_source\_tags](#input\_kendra\_data\_source\_tags) | A map of tag keys and values for Kendra data source. | `list(map(string))` | `null` | no |
| <a name="input_kendra_index_arn"></a> [kendra\_index\_arn](#input\_kendra\_index\_arn) | The ARN of the existing Kendra index. | `string` | `null` | no |
| <a name="input_kendra_index_description"></a> [kendra\_index\_description](#input\_kendra\_index\_description) | A description for the Kendra index. | `string` | `null` | no |
| <a name="input_kendra_index_edition"></a> [kendra\_index\_edition](#input\_kendra\_index\_edition) | The Amazon Kendra Edition to use for the index. | `string` | `"GEN_AI_ENTERPRISE_EDITION"` | no |
| <a name="input_kendra_index_id"></a> [kendra\_index\_id](#input\_kendra\_index\_id) | The ID of the existing Kendra index. | `string` | `null` | no |
| <a name="input_kendra_index_name"></a> [kendra\_index\_name](#input\_kendra\_index\_name) | The name of the Kendra index. | `string` | `"kendra-genai-index"` | no |
| <a name="input_kendra_index_query_capacity"></a> [kendra\_index\_query\_capacity](#input\_kendra\_index\_query\_capacity) | The number of queries per second allowed for the Kendra index. | `number` | `1` | no |
| <a name="input_kendra_index_storage_capacity"></a> [kendra\_index\_storage\_capacity](#input\_kendra\_index\_storage\_capacity) | The storage capacity of the Kendra index. | `number` | `1` | no |
| <a name="input_kendra_index_tags"></a> [kendra\_index\_tags](#input\_kendra\_index\_tags) | A map of tag keys and values for Kendra index. | `list(map(string))` | `null` | no |
| <a name="input_kendra_index_user_context_policy"></a> [kendra\_index\_user\_context\_policy](#input\_kendra\_index\_user\_context\_policy) | The Kendra index user context policy. | `string` | `null` | no |
| <a name="input_kendra_kms_key_id"></a> [kendra\_kms\_key\_id](#input\_kendra\_kms\_key\_id) | The Kendra index is encrypted at rest using this key. Specify the key ARN. | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS encryption key to use for the agent. | `string` | `null` | no |
| <a name="input_lambda_action_group_executor"></a> [lambda\_action\_group\_executor](#input\_lambda\_action\_group\_executor) | ARN of Lambda. | `string` | `null` | no |
| <a name="input_level_configurations_list"></a> [level\_configurations\_list](#input\_level\_configurations\_list) | Token settings for each layer. | `list(object({ max_tokens = number }))` | `null` | no |
| <a name="input_managed_word_lists_config"></a> [managed\_word\_lists\_config](#input\_managed\_word\_lists\_config) | A config for the list of managed words. | `list(map(string))` | `null` | no |
| <a name="input_max_length"></a> [max\_length](#input\_max\_length) | The maximum number of tokens to generate in the response. | `number` | `0` | no |
| <a name="input_max_pages"></a> [max\_pages](#input\_max\_pages) | Maximum number of pages the crawler can crawl. | `number` | `null` | no |
| <a name="input_memory_configuration"></a> [memory\_configuration](#input\_memory\_configuration) | Configuration for agent memory storage | <pre>object({<br/>    enabled_memory_types = optional(list(string))<br/>    session_summary_configuration = optional(object({<br/>      max_recent_sessions = optional(number)<br/>    }))<br/>    storage_days = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_metadata_field"></a> [metadata\_field](#input\_metadata\_field) | The name of the field in which Amazon Bedrock stores metadata about the vector store. | `string` | `"AMAZON_BEDROCK_METADATA"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | This value is appended at the beginning of resource names. | `string` | `"BedrockAgents"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | The namespace to be used to write new data to your pinecone database | `string` | `null` | no |
| <a name="input_number_of_replicas"></a> [number\_of\_replicas](#input\_number\_of\_replicas) | The number of replica shards for the OpenSearch index. | `string` | `"1"` | no |
| <a name="input_number_of_shards"></a> [number\_of\_shards](#input\_number\_of\_shards) | The number of shards for the OpenSearch index. This setting cannot be changed after index creation. | `string` | `"1"` | no |
| <a name="input_orchestration_type"></a> [orchestration\_type](#input\_orchestration\_type) | The type of orchestration strategy for the agent. Valid values: DEFAULT, CUSTOM\_ORCHESTRATION | `string` | `"DEFAULT"` | no |
| <a name="input_override_lambda_arn"></a> [override\_lambda\_arn](#input\_override\_lambda\_arn) | The ARN of the Lambda function to use when parsing the raw foundation model output in parts of the agent sequence. | `string` | `null` | no |
| <a name="input_parent_action_group_signature"></a> [parent\_action\_group\_signature](#input\_parent\_action\_group\_signature) | Action group signature for a builtin action. | `string` | `null` | no |
| <a name="input_parser_mode"></a> [parser\_mode](#input\_parser\_mode) | Specifies whether to override the default parser Lambda function. | `string` | `null` | no |
| <a name="input_parsing_config_model_arn"></a> [parsing\_config\_model\_arn](#input\_parsing\_config\_model\_arn) | The model's ARN. | `string` | `null` | no |
| <a name="input_parsing_modality"></a> [parsing\_modality](#input\_parsing\_modality) | Determine how parsed content will be stored. | `string` | `null` | no |
| <a name="input_parsing_prompt_text"></a> [parsing\_prompt\_text](#input\_parsing\_prompt\_text) | Instructions for interpreting the contents of a document. | `string` | `null` | no |
| <a name="input_parsing_strategy"></a> [parsing\_strategy](#input\_parsing\_strategy) | The parsing strategy for the data source. | `string` | `null` | no |
| <a name="input_pattern_object_filter_list"></a> [pattern\_object\_filter\_list](#input\_pattern\_object\_filter\_list) | List of pattern object information. | <pre>list(object({<br/>    exclusion_filters = optional(list(string))<br/>    inclusion_filters = optional(list(string))<br/>    object_type       = optional(string)<br/><br/>  }))</pre> | `[]` | no |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | The ARN of the IAM permission boundary for the role. | `string` | `null` | no |
| <a name="input_pii_entities_config"></a> [pii\_entities\_config](#input\_pii\_entities\_config) | List of entities. | `list(map(string))` | `null` | no |
| <a name="input_primary_key_field"></a> [primary\_key\_field](#input\_primary\_key\_field) | The name of the field in which Bedrock stores the ID for each entry. | `string` | `null` | no |
| <a name="input_prompt_creation_mode"></a> [prompt\_creation\_mode](#input\_prompt\_creation\_mode) | Specifies whether to override the default prompt template. | `string` | `null` | no |
| <a name="input_prompt_description"></a> [prompt\_description](#input\_prompt\_description) | Description for a prompt resource. | `string` | `null` | no |
| <a name="input_prompt_name"></a> [prompt\_name](#input\_prompt\_name) | Name for a prompt resource. | `string` | `null` | no |
| <a name="input_prompt_override"></a> [prompt\_override](#input\_prompt\_override) | Whether to provide prompt override configuration. | `bool` | `false` | no |
| <a name="input_prompt_state"></a> [prompt\_state](#input\_prompt\_state) | Specifies whether to allow the agent to carry out the step specified in the promptType. | `string` | `null` | no |
| <a name="input_prompt_tags"></a> [prompt\_tags](#input\_prompt\_tags) | A map of tag keys and values for prompt resource. | `map(string)` | `null` | no |
| <a name="input_prompt_type"></a> [prompt\_type](#input\_prompt\_type) | The step in the agent sequence that this prompt configuration applies to. | `string` | `null` | no |
| <a name="input_prompt_version_description"></a> [prompt\_version\_description](#input\_prompt\_version\_description) | Description for a prompt version resource. | `string` | `null` | no |
| <a name="input_prompt_version_tags"></a> [prompt\_version\_tags](#input\_prompt\_version\_tags) | A map of tag keys and values for a prompt version resource. | `map(string)` | `null` | no |
| <a name="input_provisioned_auth_configuration"></a> [provisioned\_auth\_configuration](#input\_provisioned\_auth\_configuration) | Configurations for provisioned Redshift query engine | <pre>object({<br/>    database_user                = optional(string)<br/>    type                         = optional(string) # Auth type explicitly defined<br/>    username_password_secret_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_provisioned_config_cluster_identifier"></a> [provisioned\_config\_cluster\_identifier](#input\_provisioned\_config\_cluster\_identifier) | The cluster identifier for the provisioned Redshift query engine. | `string` | `null` | no |
| <a name="input_query_generation_configuration"></a> [query\_generation\_configuration](#input\_query\_generation\_configuration) | Configurations for generating Redshift engine queries. | <pre>object({<br/>    generation_context = optional(object({<br/>      curated_queries = optional(list(object({<br/>        natural_language = optional(string) # Question for the query<br/>        sql              = optional(string) # SQL answer for the query<br/>      })))<br/>      tables = optional(list(object({<br/>        columns = optional(list(object({<br/>          description = optional(string) # Column description<br/>          inclusion   = optional(string) # Include or exclude status<br/>          name        = optional(string) # Column name<br/>        })))<br/>        description = optional(string) # Table description<br/>        inclusion   = optional(string) # Include or exclude status<br/>        name        = optional(string) # Table name (three-part notation)<br/>      })))<br/>    }))<br/>    execution_timeout_seconds = optional(number) # Max query execution timeout<br/>  })</pre> | `null` | no |
| <a name="input_rate_limit"></a> [rate\_limit](#input\_rate\_limit) | Rate of web URLs retrieved per minute. | `number` | `null` | no |
| <a name="input_redshift_query_engine_type"></a> [redshift\_query\_engine\_type](#input\_redshift\_query\_engine\_type) | Redshift query engine type for the knowledge base. Defaults to SERVERLESS | `string` | `"SERVERLESS"` | no |
| <a name="input_redshift_storage_configuration"></a> [redshift\_storage\_configuration](#input\_redshift\_storage\_configuration) | List of configurations for available Redshift query engine storage types. | <pre>list(object({<br/>    aws_data_catalog_configuration = optional(object({<br/>      table_names = optional(list(string)) # List of table names in AWS Data Catalog<br/>    }))<br/>    redshift_configuration = optional(object({<br/>      database_name = optional(string)<br/>    }))<br/>    type = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_regexes_config"></a> [regexes\_config](#input\_regexes\_config) | List of regex. | `list(map(string))` | `null` | no |
| <a name="input_relay_conversation_history"></a> [relay\_conversation\_history](#input\_relay\_conversation\_history) | Relay conversation history setting will share conversation history to collaborator if enabled. | `string` | `"TO_COLLABORATOR"` | no |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | The ARN of the vector store. | `string` | `null` | no |
| <a name="input_s3_data_source_bucket_name"></a> [s3\_data\_source\_bucket\_name](#input\_s3\_data\_source\_bucket\_name) | The name of the S3 bucket where the data source is stored. | `string` | `null` | no |
| <a name="input_s3_data_source_document_metadata_prefix"></a> [s3\_data\_source\_document\_metadata\_prefix](#input\_s3\_data\_source\_document\_metadata\_prefix) | The prefix for the S3 data source. | `string` | `null` | no |
| <a name="input_s3_data_source_exclusion_patterns"></a> [s3\_data\_source\_exclusion\_patterns](#input\_s3\_data\_source\_exclusion\_patterns) | A list of glob patterns to exclude from the data source. | `list(string)` | `null` | no |
| <a name="input_s3_data_source_inclusion_patterns"></a> [s3\_data\_source\_inclusion\_patterns](#input\_s3\_data\_source\_inclusion\_patterns) | A list of glob patterns to include in the data source. | `list(string)` | `null` | no |
| <a name="input_s3_data_source_key_path"></a> [s3\_data\_source\_key\_path](#input\_s3\_data\_source\_key\_path) | The S3 key path where for the data source. | `string` | `null` | no |
| <a name="input_s3_inclusion_prefixes"></a> [s3\_inclusion\_prefixes](#input\_s3\_inclusion\_prefixes) | List of S3 prefixes that define the object containing the data sources. | `list(string)` | `null` | no |
| <a name="input_s3_location_uri"></a> [s3\_location\_uri](#input\_s3\_location\_uri) | A location for storing content from data sources temporarily as it is processed by custom components in the ingestion pipeline. | `string` | `null` | no |
| <a name="input_salesforce_credentials_secret_arn"></a> [salesforce\_credentials\_secret\_arn](#input\_salesforce\_credentials\_secret\_arn) | The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your Salesforce instance URL. | `string` | `null` | no |
| <a name="input_seed_urls"></a> [seed\_urls](#input\_seed\_urls) | A list of web urls. | `list(object({ url = string }))` | `[]` | no |
| <a name="input_semantic_buffer_size"></a> [semantic\_buffer\_size](#input\_semantic\_buffer\_size) | The buffer size. | `number` | `null` | no |
| <a name="input_semantic_max_tokens"></a> [semantic\_max\_tokens](#input\_semantic\_max\_tokens) | The maximum number of tokens that a chunk can contain. | `number` | `null` | no |
| <a name="input_serverless_auth_configuration"></a> [serverless\_auth\_configuration](#input\_serverless\_auth\_configuration) | Configuration for the Redshift serverless query engine. | <pre>object({<br/>    type                         = optional(string) # Auth type explicitly defined<br/>    username_password_secret_arn = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_share_point_credentials_secret_arn"></a> [share\_point\_credentials\_secret\_arn](#input\_share\_point\_credentials\_secret\_arn) | The ARN of an AWS Secrets Manager secret that stores your authentication credentials for your SharePoint site/sites. | `string` | `null` | no |
| <a name="input_share_point_domain"></a> [share\_point\_domain](#input\_share\_point\_domain) | The domain of your SharePoint instance or site URL/URLs. | `string` | `null` | no |
| <a name="input_share_point_site_urls"></a> [share\_point\_site\_urls](#input\_share\_point\_site\_urls) | A list of one or more SharePoint site URLs. | `list(string)` | `[]` | no |
| <a name="input_skip_resource_in_use"></a> [skip\_resource\_in\_use](#input\_skip\_resource\_in\_use) | Specifies whether to allow deleting action group while it is in use. | `bool` | `null` | no |
| <a name="input_sql_kb_workgroup_arn"></a> [sql\_kb\_workgroup\_arn](#input\_sql\_kb\_workgroup\_arn) | The ARN of the existing workgroup. | `string` | `null` | no |
| <a name="input_stop_sequences"></a> [stop\_sequences](#input\_stop\_sequences) | A list of stop sequences. | `list(string)` | `[]` | no |
| <a name="input_supervisor_guardrail_id"></a> [supervisor\_guardrail\_id](#input\_supervisor\_guardrail\_id) | The ID of the guardrail for the supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_guardrail_version"></a> [supervisor\_guardrail\_version](#input\_supervisor\_guardrail\_version) | The version of the guardrail for the supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_id"></a> [supervisor\_id](#input\_supervisor\_id) | The ID of the supervisor. | `string` | `null` | no |
| <a name="input_supervisor_idle_session_ttl"></a> [supervisor\_idle\_session\_ttl](#input\_supervisor\_idle\_session\_ttl) | How long sessions should be kept open for the supervisor agent. | `number` | `600` | no |
| <a name="input_supervisor_instruction"></a> [supervisor\_instruction](#input\_supervisor\_instruction) | A narrative instruction to provide the agent as context. | `string` | `""` | no |
| <a name="input_supervisor_kms_key_arn"></a> [supervisor\_kms\_key\_arn](#input\_supervisor\_kms\_key\_arn) | KMS encryption key to use for the supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_model"></a> [supervisor\_model](#input\_supervisor\_model) | The foundation model for the Bedrock supervisor agent. | `string` | `null` | no |
| <a name="input_supervisor_name"></a> [supervisor\_name](#input\_supervisor\_name) | The name of the supervisor. | `string` | `"TerraformBedrockAgentSupervisor"` | no |
| <a name="input_supplemental_data_s3_uri"></a> [supplemental\_data\_s3\_uri](#input\_supplemental\_data\_s3\_uri) | The S3 URI for supplemental data storage. | `string` | `null` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | The name of the table in the database. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tag bedrock agent resource. | `map(string)` | `null` | no |
| <a name="input_temperature"></a> [temperature](#input\_temperature) | The likelihood of the model selecting higher-probability options while generating a response. | `number` | `0` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The identifier of your Microsoft 365 tenant. | `string` | `null` | no |
| <a name="input_text_field"></a> [text\_field](#input\_text\_field) | The name of the field in which Amazon Bedrock stores the raw text from your data. | `string` | `"AMAZON_BEDROCK_TEXT_CHUNK"` | no |
| <a name="input_text_index_name"></a> [text\_index\_name](#input\_text\_index\_name) | Name of a MongoDB Atlas text index. | `string` | `null` | no |
| <a name="input_top_k"></a> [top\_k](#input\_top\_k) | Sample from the k most likely next tokens. | `number` | `50` | no |
| <a name="input_top_p"></a> [top\_p](#input\_top\_p) | Cumulative probability cutoff for token selection. | `number` | `0.5` | no |
| <a name="input_topics_config"></a> [topics\_config](#input\_topics\_config) | List of topic configs in topic policy | <pre>list(object({<br/>    name       = string<br/>    examples   = list(string)<br/>    type       = string<br/>    definition = string<br/>  }))</pre> | `null` | no |
| <a name="input_topics_tier_config"></a> [topics\_tier\_config](#input\_topics\_tier\_config) | Guardrail tier config for topic policy. | <pre>object({<br/>    tier_name = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_transformations_list"></a> [transformations\_list](#input\_transformations\_list) | A list of Lambda functions that process documents. | <pre>list(object({<br/>    step_to_apply = optional(string)<br/>    transformation_function = optional(object({<br/>      transformation_lambda_configuration = optional(object({<br/>        lambda_arn = optional(string)<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_use_app_inference_profile"></a> [use\_app\_inference\_profile](#input\_use\_app\_inference\_profile) | Whether or not to attach to the app\_inference\_profile\_model\_source. | `bool` | `false` | no |
| <a name="input_use_aws_provider_alias"></a> [use\_aws\_provider\_alias](#input\_use\_aws\_provider\_alias) | Whether or not to use the aws or awscc provider for the agent alias. Defaults to using the awscc provider. | `bool` | `false` | no |
| <a name="input_use_existing_s3_data_source"></a> [use\_existing\_s3\_data\_source](#input\_use\_existing\_s3\_data\_source) | Whether or not to use an existing S3 data source. | `bool` | `false` | no |
| <a name="input_user_agent"></a> [user\_agent](#input\_user\_agent) | The suffix that will be included in the user agent header for web crawling. | `string` | `null` | no |
| <a name="input_user_token_configurations"></a> [user\_token\_configurations](#input\_user\_token\_configurations) | List of user token configurations for Kendra. | <pre>list(object({<br/><br/>    json_token_type_configurations = optional(object({<br/>      group_attribute_field     = string<br/>      user_name_attribute_field = string<br/>    }))<br/><br/>    jwt_token_type_configuration = optional(object({<br/>      claim_regex               = optional(string)<br/>      key_location              = optional(string)<br/>      group_attribute_field     = optional(string)<br/>      user_name_attribute_field = optional(string)<br/>      issuer                    = optional(string)<br/>      secret_manager_arn        = optional(string)<br/>      url                       = optional(string)<br/>    }))<br/><br/>  }))</pre> | `null` | no |
| <a name="input_variants_list"></a> [variants\_list](#input\_variants\_list) | List of prompt variants. | <pre>list(object({<br/>    name                            = optional(string)<br/>    template_type                   = optional(string)<br/>    model_id                        = optional(string)<br/>    additional_model_request_fields = optional(string)<br/>    metadata = optional(list(object({<br/>      key   = optional(string)<br/>      value = optional(string)<br/>    })))<br/>    gen_ai_resource = optional(object({<br/>      agent = optional(object({<br/>        agent_identifier = optional(string)<br/>      }))<br/>    }))<br/><br/>    inference_configuration = optional(object({<br/>      text = optional(object({<br/>        max_tokens     = optional(number)<br/>        stop_sequences = optional(list(string))<br/>        temperature    = optional(number)<br/>        top_p          = optional(number)<br/>        top_k          = optional(number)<br/>      }))<br/>    }))<br/><br/>    template_configuration = optional(object({<br/>      chat = optional(object({<br/>        input_variables = optional(list(object({<br/>          name = optional(string)<br/>        })))<br/>        messages = optional(list(object({<br/>          content = optional(list(object({<br/>            cache_point = optional(object({<br/>              type = optional(string)<br/>            }))<br/>            text = optional(string)<br/>          })))<br/>          role = optional(string)<br/>        })))<br/>        system = optional(list(object({<br/>          cache_point = optional(object({<br/>            type = optional(string)<br/>          }))<br/>          text = optional(string)<br/>        })))<br/>        tool_configuration = optional(object({<br/>          tool_choice = optional(object({<br/>            any  = optional(string)<br/>            auto = optional(string)<br/>            tool = optional(object({<br/>              name = optional(string)<br/>            }))<br/>          }))<br/>          tools = optional(list(object({<br/>            cache_point = optional(object({<br/>              type = optional(string)<br/>            }))<br/>            tool_spec = optional(object({<br/>              description = optional(string)<br/>              input_schema = optional(object({<br/>                json = optional(string)<br/>              }))<br/>              name = optional(string)<br/>            }))<br/>          })))<br/>        }))<br/>      })),<br/><br/>      text = optional(object({<br/>        input_variables = optional(list(object({ name = optional(string) })))<br/>        text            = optional(string)<br/>        cache_point = optional(object({<br/>          type = optional(string)<br/>        }))<br/>        text_s3_location = optional(object({<br/>          bucket  = optional(string)<br/>          key     = optional(string)<br/>          version = optional(string)<br/>        }))<br/>      }))<br/>    }))<br/>  }))</pre> | `null` | no |
| <a name="input_vector_dimension"></a> [vector\_dimension](#input\_vector\_dimension) | The dimension of vectors in the OpenSearch index. Use 1024 for Titan Text Embeddings V2, 1536 for V1 | `number` | `1024` | no |
| <a name="input_vector_field"></a> [vector\_field](#input\_vector\_field) | The name of the field where the vector embeddings are stored | `string` | `"bedrock-knowledge-base-default-vector"` | no |
| <a name="input_vector_index_name"></a> [vector\_index\_name](#input\_vector\_index\_name) | The name of the vector index. | `string` | `"bedrock-knowledge-base-default-index"` | no |
| <a name="input_words_config"></a> [words\_config](#input\_words\_config) | List of custom word configs. | `list(map(string))` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_agent_resource_role_arn"></a> [agent\_resource\_role\_arn](#output\_agent\_resource\_role\_arn) | The ARN of the Bedrock agent resource role. |
| <a name="output_agent_resource_role_name"></a> [agent\_resource\_role\_name](#output\_agent\_resource\_role\_name) | The name of the Bedrock agent resource role. |
| <a name="output_application_inference_profile_arn"></a> [application\_inference\_profile\_arn](#output\_application\_inference\_profile\_arn) | The ARN of the application inference profile. |
| <a name="output_bda_blueprint"></a> [bda\_blueprint](#output\_bda\_blueprint) | The BDA blueprint. |
| <a name="output_bedrock_agent"></a> [bedrock\_agent](#output\_bedrock\_agent) | The Amazon Bedrock Agent if it is created. |
| <a name="output_bedrock_agent_alias"></a> [bedrock\_agent\_alias](#output\_bedrock\_agent\_alias) | The Amazon Bedrock Agent Alias if it is created. |
| <a name="output_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#output\_cloudwatch\_log\_group) | The name of the CloudWatch log group for the knowledge base.  If no log group was requested, value will be null |
| <a name="output_custom_model"></a> [custom\_model](#output\_custom\_model) | The custom model. If no custom model was requested, value will be null. |
| <a name="output_datasource_identifier"></a> [datasource\_identifier](#output\_datasource\_identifier) | The unique identifier of the data source. |
| <a name="output_default_collection"></a> [default\_collection](#output\_default\_collection) | Opensearch default collection value. |
| <a name="output_default_kb_identifier"></a> [default\_kb\_identifier](#output\_default\_kb\_identifier) | The unique identifier of the default knowledge base that was created.  If no default KB was requested, value will be null |
| <a name="output_knowledge_base_role_name"></a> [knowledge\_base\_role\_name](#output\_knowledge\_base\_role\_name) | The name of the IAM role used by the knowledge base. |
| <a name="output_mongo_kb_identifier"></a> [mongo\_kb\_identifier](#output\_mongo\_kb\_identifier) | The unique identifier of the MongoDB knowledge base that was created.  If no MongoDB KB was requested, value will be null |
| <a name="output_opensearch_kb_identifier"></a> [opensearch\_kb\_identifier](#output\_opensearch\_kb\_identifier) | The unique identifier of the OpenSearch knowledge base that was created.  If no OpenSearch KB was requested, value will be null |
| <a name="output_pinecone_kb_identifier"></a> [pinecone\_kb\_identifier](#output\_pinecone\_kb\_identifier) | The unique identifier of the Pinecone knowledge base that was created.  If no Pinecone KB was requested, value will be null |
| <a name="output_rds_kb_identifier"></a> [rds\_kb\_identifier](#output\_rds\_kb\_identifier) | The unique identifier of the RDS knowledge base that was created.  If no RDS KB was requested, value will be null |
| <a name="output_s3_data_source_arn"></a> [s3\_data\_source\_arn](#output\_s3\_data\_source\_arn) | The Amazon Bedrock Data Source for S3. |
| <a name="output_s3_data_source_name"></a> [s3\_data\_source\_name](#output\_s3\_data\_source\_name) | The name of the Amazon Bedrock Data Source for S3. |
| <a name="output_supervisor_id"></a> [supervisor\_id](#output\_supervisor\_id) | The identifier of the supervisor agent. |
| <a name="output_supervisor_role_arn"></a> [supervisor\_role\_arn](#output\_supervisor\_role\_arn) | The ARN of the Bedrock supervisor agent resource role. |
<!-- END_TF_DOCS -->