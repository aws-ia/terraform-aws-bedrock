# – OpenSearch Serverless Default –

module "oss_knowledgebase" {
  count = var.create_default_kb ? 1 : 0
  source  = "aws-ia/opensearch-serverless/aws"
  version = "0.0.2"
  allow_public_access_network_policy = var.allow_opensearch_public_access
  create_vector_index = true
  vector_index_mappings = <<-EOF
      {
      "properties": {
          "bedrock-knowledge-base-default-vector": {
          "type": "knn_vector",
          "dimension": ${var.vector_dimension},
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
}

resource "aws_opensearchserverless_access_policy" "updated_data_policy" {
  count = var.create_default_kb ? 1 : 0

  name = "os-access-policy-${random_string.solution_prefix.result}"
  type = "data"

  policy = jsonencode([
    {
      Rules = [
        {
          ResourceType = "index"
          Resource = [
            "index/${module.oss_knowledgebase[0].opensearch_serverless_collection.name}/*"
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
            "collection/${module.oss_knowledgebase[0].opensearch_serverless_collection.name}"
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
        var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
      ]
    }
  ])
}

resource "time_sleep" "wait_after_index_creation" {
  count           = var.create_default_kb ? 1 : 0
  depends_on      = [ module.oss_knowledgebase[0].vector_index ]
  create_duration = "60s" # Wait for 60 seconds before creating the index
}
