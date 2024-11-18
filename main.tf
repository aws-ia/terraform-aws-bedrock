resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
}

# – Bedrock Agent –

locals {
  counter_kb        = var.create_kb ? [1] : []
  knowledge_base_id = var.create_kb ? (var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : (var.create_mongo_config ? awscc_bedrock_knowledge_base.knowledge_base_mongo[0].id : (var.create_opensearch_config ? awscc_bedrock_knowledge_base.knowledge_base_opensearch[0].id : (var.create_pinecone_config ? awscc_bedrock_knowledge_base.knowledge_base_pinecone[0].id : (var.create_rds_config ? awscc_bedrock_knowledge_base.knowledge_base_rds[0].id : null))))) : null
  knowledge_bases_value = {
    description          = var.kb_description
    knowledge_base_id    = var.create_kb ? local.knowledge_base_id : var.existing_kb
    knowledge_base_state = var.kb_state
  }
  kb_result = [for count in local.counter_kb : local.knowledge_bases_value]


  counter_action_group = var.create_ag ? [1] : []
  action_group_value = {
    action_group_name                    = var.action_group_name
    description                          = var.action_group_description
    action_group_state                   = var.action_group_state
    parent_action_group_signature        = var.parent_action_group_signature
    skip_resource_in_use_check_on_delete = var.skip_resource_in_use
    api_schema = {
      payload = var.api_schema_payload
      s3 = {
        s3_bucket_name = var.api_schema_s3_bucket_name
        s3_object_key  = var.api_schema_s3_object_key
      }
    }
    action_group_executor = {
      custom_control = var.custom_control
      lambda         = var.lambda_action_group_executor
    }
    function_schema = {
      functions = [{
        name        = var.function_name
        description = var.function_description
        parameters = {
          description = var.function_parameters_description
          required    = var.function_parameters_required
          type        = var.function_parameters_type
        }
      }]
    }
  }
  action_group_result = [for count in local.counter_action_group : local.action_group_value]

}

resource "awscc_bedrock_agent" "bedrock_agent" {
  count                       = var.create_agent ? 1 : 0
  agent_name                  = "${random_string.solution_prefix.result}-${var.agent_name}"
  foundation_model            = var.foundation_model
  instruction                 = var.instruction
  description                 = var.agent_description
  idle_session_ttl_in_seconds = var.idle_session_ttl
  agent_resource_role_arn     = aws_iam_role.agent_role[0].arn
  customer_encryption_key_arn = var.kms_key_arn
  tags                        = var.tags
  prompt_override_configuration = var.prompt_override == false ? null : {
    prompt_configurations = [{
      prompt_type = var.prompt_type
      inference_configuration = {
        temperature    = var.temperature
        top_p          = var.top_p
        top_k          = var.top_k
        stop_sequences = var.stop_sequences
        maximum_length = var.max_length
      }
      base_prompt_template = var.base_prompt_template
      parser_mode          = var.parser_mode
      prompt_creation_mode = var.prompt_creation_mode
      prompt_state         = var.prompt_state

    }]
    override_lambda = var.override_lambda_arn

  }
  # open issue: https://github.com/hashicorp/terraform-provider-awscc/issues/2004
  # auto_prepare needs to be set to true
  auto_prepare    = true
  knowledge_bases = length(local.kb_result) > 0 ? local.kb_result : null
  action_groups   = length(local.action_group_result) > 0 ? local.action_group_result : null
  guardrail_configuration = var.create_guardrail == false ? null : {
    guardrail_identifier = awscc_bedrock_guardrail.guardrail[0].id
    guardrail_version    = awscc_bedrock_guardrail_version.guardrail[0].version
  }
}

# – Guardrail –

resource "awscc_bedrock_guardrail" "guardrail" {
  count                     = var.create_guardrail ? 1 : 0
  name                      = "${random_string.solution_prefix.result}-${var.guardrail_name}"
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  description               = var.guardrail_description
  content_policy_config = {
    filters_config = var.filters_config
  }
  sensitive_information_policy_config = {
    pii_entities_config = var.pii_entities_config
    regexes_config = var.regexes_config
  }
  word_policy_config = {
    managed_word_lists_config = var.managed_word_lists_config
    words_config = var.words_config
  }
  topic_policy_config = var.topics_config == null ? null : {
    topics_config = var.topics_config
  }
  tags = var.guardrail_tags
  kms_key_arn = var.guardrail_kms_key_arn

}

resource "awscc_bedrock_guardrail_version" "guardrail" {
  count                = var.create_guardrail ? 1 : 0
  guardrail_identifier = awscc_bedrock_guardrail.guardrail[0].guardrail_id
  description          = "Guardrail version"
}
