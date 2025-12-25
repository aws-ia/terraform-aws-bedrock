#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "agent_supervisor" {
  source                 = "../.."
  create_agent           = false
  create_supervisor      = true
  supervisor_model       = "anthropic.claude-3-5-sonnet-20241022-v2:0"
  supervisor_instruction = "You are a supervisor who can provide detailed information about cars to an agent."
}

module "agent_collaborator1" {
  source                    = "../.."
  create_agent_alias        = true
  foundation_model          = "anthropic.claude-v2"
  instruction               = "You are an automotive assisant who can provide detailed information about cars to a customer."
  supervisor_id             = module.agent_supervisor.supervisor_id
  create_collaborator       = true
  collaborator_name         = "AgentA"
  collaboration_instruction = "Handle customer inquiries"

  depends_on = [module.agent_supervisor]
}

module "agent_collaborator2" {
  source                    = "../.."
  create_agent_alias        = true
  foundation_model          = "anthropic.claude-v2"
  instruction               = "You are an automotive assisant who can provide detailed information about cars to a customer."
  supervisor_id             = module.agent_supervisor.supervisor_id
  create_collaborator       = true
  collaborator_name         = "AgentB"
  collaboration_instruction = "Process backend tasks"

  depends_on = [module.agent_supervisor, module.agent_collaborator1]
}