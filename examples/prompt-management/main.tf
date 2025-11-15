#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "bedrock" {
  source       = "../.." # local example
  create_agent = false

  # Prompt Management
  prompt_name                = "prompt"
  default_variant            = "variant-example"
  create_prompt              = true
  create_prompt_version      = true
  prompt_version_description = "Example prompt version"
  variants_list = [
    {
      name          = "variant-example"
      template_type = "TEXT"
      model_id      = "amazon.titan-text-express-v1"
      inference_configuration = {
        text = {
          temperature    = 1
          top_p          = 0.9900000095367432
          max_tokens     = 300
          stop_sequences = ["User:"]
          top_k          = 250
        }
      }
      template_configuration = {
        text = {
          input_variables = [
            {
              name = "topic"
            }
          ]
          text = "Make me a {{genre}} playlist consisting of the following number of songs: {{number}}."
        }
      }
    }

  ]

}