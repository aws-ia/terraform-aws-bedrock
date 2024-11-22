#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################
variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}

provider "awscc" {
  region = var.region
}

provider "opensearch" {
  url         = "n/a"
  healthcheck = false
}

module "bedrock" {
  source = "../.." # local example
  create_kb = false
  create_default_kb = false
  create_s3_data_source = false
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assisant who can provide detailed information about cars to a customer."
}