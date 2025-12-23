#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

locals {
  region     = data.aws_region.current.name
  account_id = data.aws_caller_identity.current.account_id
}

module "agent_supervisor" {
  source = "../.."

  create_agent      = false
  create_supervisor = true
  supervisor_name   = "SupervisorTF"

  create_app_inference_profile       = true
  app_inference_profile_name         = "Claude37SonnetProfile"
  app_inference_profile_description  = "Inference profile for Claude 3.7 Sonnet"
  app_inference_profile_model_source = "arn:aws:bedrock:${local.region}:${local.account_id}:inference-profile/us.anthropic.claude-3-7-sonnet-20250219-v1:0"

  supervisor_instruction = "You are a supervisor who can provide detailed information about cars and trucks to an agent. You can also provide feedback to the agent."

}
