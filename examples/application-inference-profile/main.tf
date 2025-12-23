#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

module "bedrock" {
  source       = "../.." # local example
  create_agent = false

  # Application Inference Profile
  create_app_inference_profile       = true
  app_inference_profile_model_source = "arn:aws:bedrock:${data.aws_region.current.region}::foundation-model/anthropic.claude-3-sonnet-20240229-v1:0"
}