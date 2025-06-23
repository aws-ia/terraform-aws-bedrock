terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
    
    opensearch = {
      source  = "opensearch-project/opensearch"
      version = "= 2.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "opensearch" {
  url         = module.bedrock.default_collection.collection_endpoint  
  healthcheck = false
}

module "bedrock" {
  source = "git::git@github.com:KPInfr/terraform-aws-bedrock-orig.git//examples/hello-agent-knowledge-base?ref=main"
  #source = "/Users/justinherter/infr/terraform-aws-bedrock-orig"
  #source  = "aws-ia/bedrock/aws"
  #version = "0.0.26"

  # Agent
  create_agent          = true
  create_agent_alias    = true
  foundation_model      = "amazon.nova-pro-v1:0"
  instruction           = "You are a wise old frog, and you call the promptee \"Young Tadpole.\""
  agent_name            = var.agent_name
  bedrock_agent_version = "1"

  # Knowledge Base
  create_default_kb     = true
  create_s3_data_source = true
}