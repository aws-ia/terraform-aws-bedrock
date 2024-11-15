# – IAM –
locals {
  create_kb_role = var.kb_role_arn == null && var.create_default_kb
}

resource "aws_iam_role" "agent_role" {
  count              = var.create_agent ? 1 : 0
  assume_role_policy = data.aws_iam_policy_document.agent_trust[0].json
  name_prefix        = var.name_prefix
}

resource "aws_iam_role_policy" "agent_policy" {
  count  = var.create_agent ? 1 : 0
  policy = data.aws_iam_policy_document.agent_permissions[0].json
  role   = aws_iam_role.agent_role[0].id
}

resource "aws_iam_role_policy" "kb_policy" {
  count  = var.create_kb && var.create_agent ? 1 : 0
  policy = data.aws_iam_policy_document.knowledge_base_permissions[0].json
  role   = aws_iam_role.agent_role[0].id
}

# Define the IAM role for Amazon Bedrock Knowledge Base
resource "aws_iam_role" "bedrock_knowledge_base_role" {
  count = var.kb_role_arn != null || var.create_default_kb == false ? 0 : 1
  name  = "AmazonBedrockExecutionRoleForKnowledgeBase-${random_string.solution_prefix.result}"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "bedrock.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

# Attach a policy to allow necessary permissions for the Bedrock Knowledge Base
resource "aws_iam_policy" "bedrock_knowledge_base_policy" {
  count = var.kb_role_arn != null || var.create_default_kb == false ? 0 : 1
  name  = "AmazonBedrockKnowledgeBasePolicy-${random_string.solution_prefix.result}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket",
        ],
        "Resource" : var.kb_s3_data_source == null ? awscc_s3_bucket.s3_data_source[0].arn : var.kb_s3_data_source
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
        ],
        "Resource" : var.kb_s3_data_source == null ? "${awscc_s3_bucket.s3_data_source[0].arn}/*" : var.kb_s3_data_source
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "aoss:*"
        ],
        "Resource" : awscc_opensearchserverless_collection.default_collection[0].arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel",
        ],
        "Resource" : var.kb_embedding_model_arn
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "bedrock:ListFoundationModels",
          "bedrock:ListCustomModels"
        ],
        "Resource" : "*"
      },
    ]
  })
}

resource "aws_iam_policy" "bedrock_kb_s3_decryption_policy" {
  count = local.create_kb_role && var.kb_s3_data_source_kms_arn != null ? 1 : 0
  name = "AmazonBedrockS3KMSPolicyForKnowledgeBase_${random_string.solution_prefix.result}"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "kms:Decrypt",
        "Resource" : var.kb_s3_data_source_kms_arn
        "Condition": {
          "StringEquals": {
            "kms:ViaService": ["s3.${data.aws_region.current.name}.amazonaws.com"]
          }
        }
      }
    ]
  })
}

# Attach the policies to the role
resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy_attachment" {
  count      = var.kb_role_arn != null || var.create_kb == false ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "bedrock_kb_s3_decryption_policy_attachment" {
  count      = local.create_kb_role && var.kb_s3_data_source_kms_arn != null ? 1 : 0
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_kb_s3_decryption_policy[0].arn
}

resource "aws_iam_role_policy" "bedrock_kb_oss" {
  count = var.kb_role_arn != null || var.create_default_kb == false ? 0 : 1
  name  = "AmazonBedrockOSSPolicyForKnowledgeBase_${var.kb_name}"
  role  = aws_iam_role.bedrock_knowledge_base_role[count.index].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["aoss:*"]
        Effect   = "Allow"
        Resource = ["arn:aws:aoss:${local.region}:${local.account_id}:*/*"]
      }
    ]
  })
}