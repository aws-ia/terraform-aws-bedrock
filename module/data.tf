data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition
  create_kb  = var.create_default_kb || var.create_rds_config || var.create_mongo_config || var.create_pinecone_config || var.create_opensearch_config || var.create_kb || var.create_kendra_config
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
  count = var.create_agent ? 1 : 0
  statement {
    actions = [
      "bedrock:InvokeModel",
      "bedrock:InvokeModelWithResponseStream"
    ]
    resources = [
      "arn:${local.partition}:bedrock:${local.region}::foundation-model/${var.foundation_model}",
      "arn:${local.partition}:bedrock:*::foundation-model/${var.foundation_model}",
      "arn:${local.partition}:bedrock:${local.region}:${local.account_id}:inference-profile/*.${var.foundation_model}",
    ]
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

data "aws_bedrock_foundation_model" "model_identifier" {
  count = var.create_custom_model ? 1 : 0
  model_id = var.custom_model_id
}
