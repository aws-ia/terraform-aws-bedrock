# – IAM –

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
          "aoss:APIAccessAll"
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

# Attach the policy to the role
resource "aws_iam_role_policy_attachment" "bedrock_knowledge_base_policy_attachment" {
  count      = var.kb_role_arn != null || var.create_kb == false ? 0 : 1
  role       = aws_iam_role.bedrock_knowledge_base_role[0].name
  policy_arn = aws_iam_policy.bedrock_knowledge_base_policy[0].arn
}
