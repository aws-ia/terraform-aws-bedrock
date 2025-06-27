data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  create_kb  = var.create_default_kb || var.create_rds_config || var.create_mongo_config || var.create_pinecone_config || var.create_opensearch_config || var.create_kb || var.create_kendra_config
  foundation_model = var.create_agent ? var.foundation_model : (var.create_supervisor ? var.supervisor_model : null)
}

data "aws_iam_policy_document" "agent_trust" {
  count = var.create_agent || var.create_supervisor ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [local.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "agent_permissions" {
  count = var.create_agent || var.create_supervisor ? 1 : 0
  statement {
    actions = [
      "bedrock:InvokeModel*", // For "bedrock:InvokeModel" & "bedrock:InvokeModelWithResponseStream"
      "bedrock:UseInferenceProfile",
      "bedrock:GetInferenceProfile",
    ]
    resources = distinct(concat(
      var.use_app_inference_profile ? [
        var.app_inference_profile_model_source,
        "arn:aws:bedrock:*:*:inference-profile/*",
        "arn:aws:bedrock:*::foundation-model/*", // Too broad
        "arn:aws:bedrock:*:*:application-inference-profile/*",
      ] : [],
      var.create_app_inference_profile ? [
       var.app_inference_profile_model_source,
       awscc_bedrock_application_inference_profile.application_inference_profile[0].inference_profile_arn,
       "arn:${local.partition}:bedrock:*:*:application-inference-profile/*",
      ] : [],
      var.create_app_inference_profile ? 
        awscc_bedrock_application_inference_profile.application_inference_profile[0].models[*].model_arn : [],
      !var.create_app_inference_profile && !var.use_app_inference_profile ? 
      [
       "arn:${local.partition}:bedrock:${local.region}::foundation-model/${local.foundation_model}",
       "arn:${local.partition}:bedrock:*::foundation-model/${local.foundation_model}",
       "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:inference-profile/*.${local.foundation_model}",
      ]: []
    ))
  }
}

data "aws_iam_policy_document" "agent_alias_permissions" {
  count = var.create_agent_alias || var.create_supervisor ? 1 : 0
  statement {
    actions = [
      "bedrock:GetAgentAlias", 
      "bedrock:InvokeAgent"
    ]
    resources = [
      "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent/*",
      "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:agent-alias/*"     
    ]
  }
}


data "aws_iam_policy_document" "knowledge_base_permissions" {
  count = local.create_kb ? 1 : 0

  statement {
    actions   = ["bedrock:Retrieve"]
    resources = ["arn:${local.partition}:bedrock:${local.region}:${local.account_id}:knowledge-base/*"]
  }
}

data "aws_iam_policy_document" "custom_model_trust" {
  count = var.create_custom_model ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["bedrock.amazonaws.com"]
      type        = "Service"
    }
    condition {
      test     = "StringEquals"
      values   = [local.account_id]
      variable = "aws:SourceAccount"
    }
    condition {
      test     = "ArnLike"
      values   = ["arn:${local.partition}:bedrock:${local.region}:${local.account_id}:model-customization-job/*"]
      variable = "AWS:SourceArn"
    }
  }
}

data "aws_iam_policy_document" "app_inference_profile_permission" {
  count = var.create_app_inference_profile || var.use_app_inference_profile ? 1 : 0
  statement {
    actions = [
      "bedrock:GetInferenceProfile",
      "bedrock:ListInferenceProfiles",
      "bedrock:UseInferenceProfile",
    ]
    resources = [
      "arn:${local.partition}:bedrock:*:*:inference-profile/*",
      "arn:${local.partition}:bedrock:*:*:application-inference-profile/*"
    ]
  }
}

data "aws_bedrock_foundation_model" "model_identifier" {
  count = var.create_custom_model ? 1 : 0
  model_id = var.custom_model_id
}
