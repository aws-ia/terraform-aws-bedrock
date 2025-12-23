#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "bedrock" {
  source           = "../.." # local example
  create_guardrail = true
  filters_config = [
    {
      input_strength    = "MEDIUM"
      output_strength   = "MEDIUM"
      type              = "HATE"
      input_modalities  = ["TEXT"]
      output_modalities = ["TEXT"]
    },
    {
      input_strength    = "HIGH"
      output_strength   = "HIGH"
      type              = "VIOLENCE"
      input_modalities  = ["TEXT", "IMAGE"]
      output_modalities = ["TEXT", "IMAGE"]
    },
    {
      input_strength    = "HIGH"
      output_strength   = "HIGH"
      type              = "MISCONDUCT"
      input_modalities  = ["IMAGE"]
      output_modalities = ["IMAGE"]
    },
    {
      input_strength    = "MEDIUM"
      output_strength   = "MEDIUM"
      type              = "SEXUAL"
      input_modalities  = ["IMAGE"]
      output_modalities = ["IMAGE"]
    }
  ]
  pii_entities_config = [
    {
      action = "BLOCK"
      type   = "NAME"
    },
    {
      action = "BLOCK"
      type   = "DRIVER_ID"
    },
    {
      action = "ANONYMIZE"
      type   = "USERNAME"
    },
  ]
  regexes_config = [{
    action      = "BLOCK"
    description = "example regex"
    name        = "regex_example"
    pattern     = "^\\d{3}-\\d{2}-\\d{4}$"
  }]
  managed_word_lists_config = [{
    type = "PROFANITY"
  }]
  words_config = [{
    text = "HATE"
  }]
  topics_config = [{
    name       = "investment_topic"
    examples   = ["Where should I invest my money ?"]
    type       = "DENY"
    definition = "Investment advice refers to inquiries, guidance, or recommendations regarding the management or allocation of funds or assets with the goal of generating returns ."
  }]
  foundation_model = "anthropic.claude-v2"
  instruction      = "You are an automotive assisant who can provide detailed information about cars to a customer."
}