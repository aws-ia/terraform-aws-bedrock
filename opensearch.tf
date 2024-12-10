# – OpenSearch Serverless Default –

# Create a Collection
resource "awscc_opensearchserverless_collection" "default_collection" {
  count       = var.create_default_kb ? 1 : 0
  name        = "default-collection-${random_string.solution_prefix.result}"
  type        = "VECTORSEARCH"
  description = "Default collection created by Amazon Bedrock Knowledge base."
  depends_on = [
    aws_opensearchserverless_security_policy.security_policy[0],
    aws_opensearchserverless_security_policy.nw_policy[0]
  ]
}

# Encryption Security Policy
resource "aws_opensearchserverless_security_policy" "security_policy" {
  count = var.create_default_kb ? 1 : 0
  name  = "awscc-security-policy-${random_string.solution_prefix.result}"
  type  = "encryption"
  policy = jsonencode({
    Rules = [
      {
        Resource     = ["collection/default-collection-${random_string.solution_prefix.result}"]
        ResourceType = "collection"
      }
    ],
    AWSOwnedKey = true
  })
}

# Network policy
resource "aws_opensearchserverless_security_policy" "nw_policy" {
  count = var.create_default_kb ? 1 : 0
  name  = "nw-policy-${random_string.solution_prefix.result}"
  type  = "network"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "collection"
          Resource     = ["collection/default-collection-${random_string.solution_prefix.result}"]
        },
      ]
      AllowFromPublic = true,
    },
    {
      Description = "Public access for dashboards",
      Rules = [
        {
          ResourceType = "dashboard"
          Resource = [
            "collection/default-collection-${random_string.solution_prefix.result}"
          ]
        }
      ],
      AllowFromPublic = true
    }

  ])
}


# Data policy
resource "aws_opensearchserverless_access_policy" "data_policy" {
  count = var.create_default_kb ? 1 : 0
  name  = "os-access-policy-${random_string.solution_prefix.result}"
  type  = "data"
  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            "index/${awscc_opensearchserverless_collection.default_collection[0].name}/*"
          ]
          Permission = [
            "aoss:UpdateIndex",
            "aoss:DeleteIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument",
            "aoss:CreateIndex"
          ]
        },
        {
          ResourceType = "collection"
          Resource = [
            "collection/${awscc_opensearchserverless_collection.default_collection[0].name}"
          ]
          Permission = [
            "aoss:DescribeCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:CreateCollectionItems",
            "aoss:UpdateCollectionItems"
          ]
        }
      ],
      Principal = [
        var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn,
        data.aws_caller_identity.current.arn
      ]
    }
  ])
}

# OpenSearch index

resource "time_sleep" "wait_before_index_creation" {
  count           = var.create_default_kb ? 1 : 0
  depends_on      = [aws_opensearchserverless_access_policy.data_policy[0]]
  create_duration = "60s" # Wait for 60 seconds before creating the index
}

resource "opensearch_index" "default_oss_index" {
  count                          = var.create_default_kb ? 1 : 0
  name                           = "bedrock-knowledge-base-default-index-${random_string.solution_prefix.result}"
  number_of_shards               = "2"
  number_of_replicas             = "0"
  index_knn                      = true
  index_knn_algo_param_ef_search = "512"
  mappings                       = <<-EOF
    {
      "properties": {
        "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": 1536,
          "method": {
            "name": "hnsw",
            "engine": "faiss",
            "parameters": {
              "m": 16,
              "ef_construction": 512
            },
            "space_type": "l2"
          }
        },
        "AMAZON_BEDROCK_METADATA": {
          "type": "text",
          "index": "false"
        },
        "AMAZON_BEDROCK_TEXT_CHUNK": {
          "type": "text",
          "index": "true"
        }
      }
    }
  EOF
  force_destroy                  = true
  depends_on                     = [time_sleep.wait_before_index_creation, aws_opensearchserverless_access_policy.data_policy[0]]
}

resource "time_sleep" "wait_after_index_creation" {
  count           = var.create_default_kb ? 1 : 0
  depends_on      = [ opensearch_index.default_oss_index[0] ]
  create_duration = "60s" # Wait for 60 seconds before creating the index
}