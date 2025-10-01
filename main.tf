resource "random_string" "solution_prefix" {
  length  = 4
  special = false
  upper   = false
}

# – Bedrock Agent –

locals {
  bedrock_agent_alias = var.create_agent_alias && var.use_aws_provider_alias ? aws_bedrockagent_agent_alias.bedrock_agent_alias : awscc_bedrock_agent_alias.bedrock_agent_alias

  counter_kb        = local.create_kb || var.existing_kb != null ? [1] : []
  knowledge_base_id = local.create_kb ? (var.create_default_kb ? awscc_bedrock_knowledge_base.knowledge_base_default[0].id : (var.create_mongo_config ? awscc_bedrock_knowledge_base.knowledge_base_mongo[0].id : (var.create_opensearch_config ? awscc_bedrock_knowledge_base.knowledge_base_opensearch[0].id : (var.create_opensearch_managed_config ? awscc_bedrock_knowledge_base.knowledge_base_opensearch_managed[0].id : (var.create_pinecone_config ? awscc_bedrock_knowledge_base.knowledge_base_pinecone[0].id : (var.create_rds_config ? awscc_bedrock_knowledge_base.knowledge_base_rds[0].id : (var.create_kendra_config ? awscc_bedrock_knowledge_base.knowledge_base_kendra[0].id : (var.create_sql_config ? awscc_bedrock_knowledge_base.knowledge_base_sql[0].id : null)))))))) : null
  knowledge_bases_value = {
    description          = var.kb_description
    knowledge_base_id    = local.create_kb ? local.knowledge_base_id : var.existing_kb
    knowledge_base_state = var.kb_state
  }
  kb_result = [for count in local.counter_kb : local.knowledge_bases_value]


  counter_action_group = var.create_ag ? [1] : []
  action_group_value = {
    action_group_name                    = var.action_group_name
    description                          = var.parent_action_group_signature != null ? null : var.action_group_description
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
  }
  action_group_result = [for count in local.counter_action_group : local.action_group_value]

  # Create a map with action_group_name as keys for stable sorting
  action_group_map = var.action_group_list != null ? {
    for idx, ag in var.action_group_list :
    # Use action_group_name as key, or index if name is null
    coalesce(try(ag.action_group_name, ""), format("%04d", idx)) => ag
  } : {}

  # Extract values from the sorted map (Terraform maps are sorted by keys)
  # Also handle the description/parent_action_group_signature conflict
  sorted_action_groups = [for k, v in local.action_group_map : merge(v, {
    description = try(v.parent_action_group_signature, null) != null ? null : try(v.description, null)
  })]

  # Combine action groups with consistent ordering
  action_group_list = concat(local.action_group_result, local.sorted_action_groups)

  counter_collaborator = var.create_agent && var.create_agent_alias && var.create_collaborator ? 1 : 0

  supervisor_guardrail = var.create_supervisor_guardrail == false || local.counter_collaborator == 0 ? null : [{
    guardrail_identifier = var.supervisor_guardrail_id
    guardrail_version    = var.supervisor_guardrail_version
  }]
}

# Add a sleep after creating the inference profile to ensure it's fully available
resource "time_sleep" "wait_for_inference_profile" {
  count           = var.create_app_inference_profile ? 1 : 0
  depends_on      = [awscc_bedrock_application_inference_profile.application_inference_profile[0]]
  create_duration = "5s"
}

resource "time_sleep" "wait_for_use_inference_profile_role_policy" {
  count           = var.use_app_inference_profile ? 1 : 0
  depends_on      = [aws_iam_role_policy.app_inference_profile_role_policy]
  create_duration = "10s"
}

resource "awscc_bedrock_agent" "bedrock_agent" {
  count                       = var.create_agent ? 1 : 0
  agent_name                  = "${random_string.solution_prefix.result}-${var.agent_name}"
  foundation_model            = var.use_app_inference_profile ? var.app_inference_profile_model_source : (var.create_app_inference_profile ? awscc_bedrock_application_inference_profile.application_inference_profile[0].inference_profile_arn : var.foundation_model)
  instruction                 = var.instruction
  description                 = var.agent_description
  idle_session_ttl_in_seconds = var.idle_session_ttl
  agent_resource_role_arn     = var.agent_resource_role_arn != null ? var.agent_resource_role_arn : aws_iam_role.agent_role[0].arn
  orchestration_type          = var.orchestration_type
  custom_orchestration = var.orchestration_type == "CUSTOM" ? {
    executor = {
      lambda = var.custom_orchestration_lambda_arn
    }
  } : null

  depends_on = [time_sleep.wait_for_inference_profile, time_sleep.wait_for_use_inference_profile_role_policy]

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
      base_prompt_template            = var.base_prompt_template
      parser_mode                     = var.parser_mode
      prompt_creation_mode            = var.prompt_creation_mode
      prompt_state                    = var.prompt_state
      additional_model_request_fields = var.additional_model_request_fields
    }]
    override_lambda = var.override_lambda_arn
  }
  # open issue: https://github.com/hashicorp/terraform-provider-awscc/issues/2004
  # auto_prepare needs to be set to true
  auto_prepare    = true
  knowledge_bases = length(local.kb_result) > 0 ? local.kb_result : null
  action_groups   = length(local.action_group_list) > 0 ? local.action_group_list : null
  guardrail_configuration = var.create_guardrail == false ? null : {
    guardrail_identifier = awscc_bedrock_guardrail.guardrail[0].id
    guardrail_version    = awscc_bedrock_guardrail_version.guardrail[0].version
  }
  memory_configuration = var.memory_configuration
}

# Agent Alias

resource "awscc_bedrock_agent_alias" "bedrock_agent_alias" {
  count            = var.create_agent_alias && var.use_aws_provider_alias == false ? 1 : 0
  agent_alias_name = var.agent_alias_name
  agent_id         = var.create_agent ? awscc_bedrock_agent.bedrock_agent[0].id : var.agent_id
  description      = var.agent_alias_description
  routing_configuration = var.bedrock_agent_version == null ? null : [
    {
      agent_version = var.bedrock_agent_version
    }
  ]
  tags = var.agent_alias_tags
}

resource "aws_bedrockagent_agent_alias" "bedrock_agent_alias" {
  count            = var.create_agent_alias && var.use_aws_provider_alias ? 1 : 0
  agent_alias_name = var.agent_alias_name
  agent_id         = var.create_agent ? awscc_bedrock_agent.bedrock_agent[0].id : var.agent_id
  description      = var.agent_alias_description
  routing_configuration = var.bedrock_agent_version == null ? null : [
    {
      agent_version          = var.bedrock_agent_version
      provisioned_throughput = var.bedrock_agent_alias_provisioned_throughput
    }
  ]
  tags = var.agent_alias_tags
}

# Agent Collaborator 

resource "aws_bedrockagent_agent_collaborator" "agent_collaborator" {
  count                      = local.counter_collaborator
  agent_id                   = var.create_supervisor ? aws_bedrockagent_agent.agent_supervisor[0].agent_id : var.supervisor_id
  collaboration_instruction  = var.collaboration_instruction
  collaborator_name          = "${random_string.solution_prefix.result}-${var.collaborator_name}"
  relay_conversation_history = var.relay_conversation_history

  agent_descriptor {
    alias_arn = local.bedrock_agent_alias[0].agent_alias_arn
  }

  depends_on = [awscc_bedrock_agent.bedrock_agent[0], local.bedrock_agent_alias]
}

resource "aws_bedrockagent_agent" "agent_supervisor" {
  count                   = var.create_supervisor ? 1 : 0
  agent_name              = "${random_string.solution_prefix.result}-${var.supervisor_name}"
  agent_resource_role_arn = var.agent_resource_role_arn != null ? var.agent_resource_role_arn : aws_iam_role.agent_role[0].arn

  agent_collaboration         = var.agent_collaboration
  idle_session_ttl_in_seconds = var.supervisor_idle_session_ttl
  foundation_model            = var.use_app_inference_profile ? var.app_inference_profile_model_source : (var.create_app_inference_profile ? awscc_bedrock_application_inference_profile.application_inference_profile[0].inference_profile_arn : var.supervisor_model)
  instruction                 = var.supervisor_instruction
  customer_encryption_key_arn = var.supervisor_kms_key_arn
  #checkov:skip=CKV_AWS_383:The user can optionally associate agent with Bedrock guardrails
  guardrail_configuration = local.supervisor_guardrail
  prepare_agent           = false

  depends_on = [time_sleep.wait_for_inference_profile, time_sleep.wait_for_use_inference_profile_role_policy]
}

# – Guardrail –

resource "awscc_bedrock_guardrail" "guardrail" {
  count                     = var.create_guardrail ? 1 : 0
  name                      = "${random_string.solution_prefix.result}-${var.guardrail_name}"
  blocked_input_messaging   = var.blocked_input_messaging
  blocked_outputs_messaging = var.blocked_outputs_messaging
  description               = var.guardrail_description

  # Cross region configuration
  cross_region_config = var.guardrail_cross_region_config

  # Content policy configuration
  content_policy_config = {
    filters_config              = var.filters_config
    content_filters_tier_config = var.content_filters_tier_config
  }

  # Contextual grounding policy configuration
  contextual_grounding_policy_config = var.contextual_grounding_policy_filters != null ? {
    filters_config = var.contextual_grounding_policy_filters
  } : null

  # Sensitive information policy configuration
  sensitive_information_policy_config = {
    pii_entities_config = var.pii_entities_config
    regexes_config      = var.regexes_config
  }

  # Word policy configuration
  word_policy_config = {
    managed_word_lists_config = var.managed_word_lists_config
    words_config              = var.words_config
  }

  # Topic policy configuration
  topic_policy_config = var.topics_config == null ? null : {
    topics_config      = var.topics_config
    topics_tier_config = var.topics_tier_config
  }

  tags        = var.guardrail_tags
  kms_key_arn = var.guardrail_kms_key_arn
}

resource "awscc_bedrock_guardrail_version" "guardrail" {
  count                = var.create_guardrail ? 1 : 0
  guardrail_identifier = awscc_bedrock_guardrail.guardrail[0].guardrail_id
  description          = "Guardrail version"
}

# – Bedrock Flow –

resource "awscc_bedrock_flow_alias" "flow_alias" {
  count       = var.create_flow_alias ? 1 : 0
  name        = var.flow_alias_name
  flow_arn    = var.flow_arn
  description = var.flow_alias_description
  routing_configuration = [
    {
      flow_version = var.flow_version != null ? var.flow_version : awscc_bedrock_flow_version.flow_version[0].version
    }
  ]
}

resource "awscc_bedrock_flow_version" "flow_version" {
  count       = var.flow_version == null && var.create_flow_alias ? 1 : 0
  flow_arn    = var.flow_arn
  description = var.flow_version_description
}

# – Custom Model – 

resource "aws_bedrock_custom_model" "custom_model" {
  count                   = var.create_custom_model ? 1 : 0
  custom_model_name       = "${random_string.solution_prefix.result}-${var.custom_model_name}"
  job_name                = "${random_string.solution_prefix.result}-${var.custom_model_job_name}"
  base_model_identifier   = data.aws_bedrock_foundation_model.model_identifier[0].model_arn
  role_arn                = aws_iam_role.custom_model_role[0].arn
  custom_model_kms_key_id = var.custom_model_kms_key_id
  customization_type      = var.customization_type
  hyperparameters         = var.custom_model_hyperparameters
  output_data_config {
    s3_uri = var.custom_model_output_uri == null ? "s3://${awscc_s3_bucket.custom_model_output[0].id}/" : "s3://${var.custom_model_output_uri}"
  }
  training_data_config {
    s3_uri = "s3://${var.custom_model_training_uri}"
  }
  tags = var.custom_model_tags
}

resource "awscc_s3_bucket" "custom_model_output" {
  count       = var.custom_model_output_uri == null && var.create_custom_model == true ? 1 : 0
  bucket_name = "${random_string.solution_prefix.result}-${var.custom_model_name}-output-bucket"
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
  tags = var.custom_model_tags != null ? [for k, v in var.custom_model_tags : { key = k, value = v }] : [{
    key   = "Name"
    value = "${random_string.solution_prefix.result}-${var.custom_model_name}-output-bucket"
  }]
}
