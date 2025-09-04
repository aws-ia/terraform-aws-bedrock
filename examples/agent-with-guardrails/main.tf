#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "bedrock" {
  source = "../.." # local example
  create_guardrail = true
  
  # Basic guardrail configuration
  blocked_input_messaging   = "I'm sorry, but I cannot process that input due to content policy restrictions."
  blocked_outputs_messaging = "I apologize, but I cannot provide that information due to content policy restrictions."
  guardrail_description     = "Enhanced guardrail with advanced configuration"
  
  # Cross region configuration
  # guardrail_cross_region_config = {
  #   guardrail_profile_arn = "arn:aws:bedrock:us-east-1:123456789012:guardrail-profile/example-profile"
  # }
  
  # Content filters with tier configuration
  content_filters_tier_config = {
    tier_name = "STANDARD"
  }
  
  # Content filters configuration
  filters_config = [
    {
      "type"            = "HATE"
      "input_strength"  = "MEDIUM"
      "output_strength" = "MEDIUM"
    },
    {
      "type"            = "VIOLENCE"
      "input_strength"  = "HIGH"
      "output_strength" = "HIGH"
    }
  ]
  
  # PII entities configuration
  pii_entities_config = [
    {
      "type"   = "NAME"
      "action" = "BLOCK"
    },
    {
      "type"   = "DRIVER_ID"
      "action" = "BLOCK"
    },
    {
      "type"   = "USERNAME"
      "action" = "ANONYMIZE"
    }
  ]
  
  # Regex configuration
  regexes_config = [{
    "name"        = "regex_example"
    "pattern"     = "^\\d{3}-\\d{2}-\\d{4}$"
    "description" = "Social Security Number pattern"
    "action"      = "BLOCK"
  }]
  
  # Managed word lists configuration
  managed_word_lists_config = [{
    "type" = "PROFANITY"
  }]
  
  # Custom words configuration
  words_config = [{
    "text" = "HATE"
  }]
  
  # Topics with tier configuration
  topics_tier_config = {
    tier_name = "STANDARD"
  }
  
  # Topics configuration
  topics_config = [{
    name       = "investment_topic"
    examples   = ["Where should I invest my money?"]
    type       = "DENY"
    definition = "Investment advice refers to inquiries, guidance, or recommendations regarding the management or allocation of funds or assets with the goal of generating returns."
  }]
  
  # Agent configuration
  foundation_model = "anthropic.claude-v2"
  instruction = "You are an automotive assistant who can provide detailed information about cars to a customer."
}
