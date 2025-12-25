# - Knowledge Base Default OpenSearch -
resource "awscc_bedrock_knowledge_base" "knowledge_base_default" {
  count       = var.create_default_kb ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = "OPENSEARCH_SERVERLESS"
    opensearch_serverless_configuration = {
      collection_arn    = module.oss_knowledgebase[0].opensearch_serverless_collection.arn
      vector_index_name = module.oss_knowledgebase[0].vector_index.name
      field_mapping = {
        metadata_field = var.metadata_field
        text_field     = var.text_field
        vector_field   = var.vector_field
      }
    }
  }
  knowledge_base_configuration = {
    type = "VECTOR"
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
  depends_on = [time_sleep.wait_after_index_creation]
}

# – Existing Vector KBs –

# - Mongo –
resource "awscc_bedrock_knowledge_base" "knowledge_base_mongo" {
  count       = var.create_mongo_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = var.kb_storage_type

    mongo_db_atlas_configuration = {
      collection_name        = var.collection_name
      credentials_secret_arn = var.credentials_secret_arn
      database_name          = var.database_name
      endpoint               = var.endpoint
      vector_index_name      = var.vector_index_name
      text_index_name        = var.text_index_name
      field_mapping = {
        metadata_field = var.metadata_field
        text_field     = var.text_field
        vector_field   = var.vector_field
      }
      endpoint_service_name = var.endpoint_service_name
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – OpenSearch Managed Cluster –
resource "awscc_bedrock_knowledge_base" "knowledge_base_opensearch_managed" {
  count       = var.create_opensearch_managed_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = "OPENSEARCH_MANAGED_CLUSTER"
    opensearch_managed_cluster_configuration = {
      domain_arn        = var.domain_arn
      domain_endpoint   = var.domain_endpoint
      vector_index_name = var.vector_index_name
      field_mapping = {
        metadata_field = var.metadata_field
        text_field     = var.text_field
        vector_field   = var.vector_field
      }
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – OpenSearch Serverless –
resource "awscc_bedrock_knowledge_base" "knowledge_base_opensearch" {
  count       = var.create_opensearch_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = var.kb_storage_type
    opensearch_serverless_configuration = {
      collection_arn    = var.collection_arn
      vector_index_name = var.vector_index_name
      field_mapping = {
        metadata_field = var.metadata_field
        text_field     = var.text_field
        vector_field   = var.vector_field
      }
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – Neptune Analytics –
resource "awscc_bedrock_knowledge_base" "knowledge_base_neptune_analytics" {
  count       = var.create_neptune_analytics_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = "NEPTUNE_ANALYTICS"
    neptune_analytics_configuration = {
      graph_arn = var.graph_arn
      field_mapping = {
        metadata_field = var.metadata_field
        text_field     = var.text_field
      }
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – S3 Vectors –
resource "awscc_bedrock_knowledge_base" "knowledge_base_s3_vectors" {
  count       = var.create_s3_vectors_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = "S3_VECTORS"
    s3_vectors_configuration = var.s3_vectors_index_arn != null ? {
      index_arn = var.s3_vectors_index_arn
    } : {
      index_name        = var.s3_vectors_index_name
      vector_bucket_arn = var.s3_vectors_bucket_arn
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – Pinecone –
resource "awscc_bedrock_knowledge_base" "knowledge_base_pinecone" {
  count       = var.create_pinecone_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = var.kb_storage_type
    pinecone_configuration = {
      connection_string      = var.connection_string
      credentials_secret_arn = var.credentials_secret_arn
      field_mapping = {
        metadata_field = var.metadata_field
        text_field     = var.text_field
      }
      namespace = var.namespace
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – RDS –
resource "awscc_bedrock_knowledge_base" "knowledge_base_rds" {
  count       = var.create_rds_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  storage_configuration = {
    type = var.kb_storage_type
    rds_configuration = {
      credentials_secret_arn = var.credentials_secret_arn
      database_name          = var.database_name
      resource_arn           = var.resource_arn
      table_name             = var.table_name
      field_mapping = {
        metadata_field        = var.metadata_field
        primary_key_field     = var.primary_key_field
        text_field            = var.text_field
        vector_field          = var.vector_field
        custom_metadata_field = var.custom_metadata_field
      }
    }
  }
  knowledge_base_configuration = {
    type = var.kb_type
    vector_knowledge_base_configuration = {
      embedding_model_arn = local.kb_embedding_model_arn
      embedding_model_configuration = var.embedding_model_dimensions != null ? {
        bedrock_embedding_model_configuration = {
          dimensions          = var.embedding_model_dimensions
          embedding_data_type = var.embedding_data_type
        }
      } : null
      supplemental_data_storage_configuration = var.create_supplemental_data_storage ? {
        supplemental_data_storage_locations = [
          {
            supplemental_data_storage_location_type = "S3"
            s3_location = {
              uri = var.supplemental_data_s3_uri
            }
          }
        ]
      } : null
    }
  }
}

# – Kendra Knowledge Base – 

resource "awscc_bedrock_knowledge_base" "knowledge_base_kendra" {
  count       = var.create_kendra_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  knowledge_base_configuration = {
    type = "KENDRA"
    kendra_knowledge_base_configuration = {
      kendra_index_arn = var.kendra_index_arn != null ? var.kendra_index_arn : awscc_kendra_index.genai_kendra_index[0].arn
    }
  }

  depends_on = [time_sleep.wait_after_kendra_index_creation, time_sleep.wait_after_kendra_s3_data_source_creation]
}

# – SQL Knowledge Base –

resource "awscc_bedrock_knowledge_base" "knowledge_base_sql" {
  count       = var.create_sql_config ? 1 : 0
  name        = "${random_string.solution_prefix.result}-${var.kb_name}"
  description = var.kb_description
  role_arn    = var.kb_role_arn != null ? var.kb_role_arn : aws_iam_role.bedrock_knowledge_base_role[0].arn
  tags        = var.kb_tags

  knowledge_base_configuration = {
    type = "SQL"
    sql_knowledge_base_configuration = {
      type = "REDSHIFT"
      redshift_configuration = {
        query_engine_configuration = {
          serverless_configuration = var.sql_kb_workgroup_arn == null ? null : {
            workgroup_arn = var.sql_kb_workgroup_arn
            auth_configuration = var.serverless_auth_configuration != null ? {
              type                         = var.serverless_auth_configuration.type
              username_password_secret_arn = var.serverless_auth_configuration.username_password_secret_arn
            } : null
          }
          provisioned_configuration = var.provisioned_config_cluster_identifier == null ? null : {
            cluster_identifier = var.provisioned_config_cluster_identifier
            auth_configuration = var.provisioned_auth_configuration != null ? {
              type                         = var.provisioned_auth_configuration.type
              database_user                = var.provisioned_auth_configuration.database_user
              username_password_secret_arn = var.provisioned_auth_configuration.username_password_secret_arn
            } : null
          }
          type = var.redshift_query_engine_type
        }
        query_generation_configuration = var.query_generation_configuration
        storage_configurations         = var.redshift_storage_configuration
      }
    }
  }
}
