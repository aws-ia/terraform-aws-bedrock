#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "bda" {
  source       = "../.." # local example
  create_agent = false

  # BDA project config
  create_bda = true
  bda_standard_output_configuration = {
    image = {
      extraction = {
        bounding_box = {
          state = "ENABLED"
        }
        category = {
          state = "ENABLED"
          types = ["TEXT_DETECTION", "LOGOS"]
        }
      }
      generative_field = {
        state = "ENABLED"
        types = ["IMAGE_SUMMARY"]
      }
    }
  }
  bda_custom_output_config = [{
    blueprint_arn   = module.blueprint.bda_blueprint.blueprint_arn
    blueprint_stage = module.blueprint.bda_blueprint.blueprint_stage
  }]
}

module "blueprint" {
  source       = "../.."
  create_agent = false

  # Blueprint config
  create_blueprint = true
  blueprint_schema = jsonencode({
    "$schema"   = "http://json-schema.org/draft-07/schema#"
    description = "This blueprint is to extract key information from advertisement images."
    class       = "advertisement image"
    type        = "object"
    definitions = {
      ProductDetails = {
        type = "object"
        properties = {
          product_category = {
            type          = "string"
            inferenceType = "explicit"
            instruction   = "The broad category or type of product being advertised, e.g., appliances, electronics, clothing, etc."
          }
          product_name = {
            type          = "string"
            inferenceType = "explicit"
            instruction   = "The specific name or model of the product being advertised, if visible in the image."
          }
          product_placement = {
            type          = "string"
            inferenceType = "explicit"
            instruction   = "How the product is positioned or placed within the advertisement image. Limit the field values to enum['Front and center', 'In the background', 'Held/used by a person', 'Others']"
          }
        }
      }
    }
    properties = {
      product_details = {
        "$ref" = "#/definitions/ProductDetails"
      }
      image_sentiment = {
        type          = "string"
        inferenceType = "explicit"
        instruction   = "What is the overall sentiment of the image? Limit the field values to enum['Positive', 'Negative', 'Neutral']"
      }
      image_background = {
        type          = "string"
        inferenceType = "explicit"
        instruction   = "What is the background of the ad image? For example, 'Solid color', 'Natural landscape', 'Indoor', 'Urban', 'Abstract'"
      }
      image_style = {
        type          = "string"
        inferenceType = "explicit"
        instruction   = "Classify the image style of the ad. For example, 'Product image', 'Lifestyle', 'Portrait', 'Retro', 'Infographic', 'None of the above'"
      }
      image_humor = {
        type          = "boolean"
        inferenceType = "explicit"
        instruction   = "Does the advertisement use any humor or wit in its messaging?"
      }
      key_visuals = {
        type          = "array"
        inferenceType = "explicit"
        instruction   = "A list of key visual elements or objects present in the advertisement image, apart from the main product."
        items = {
          type = "string"
        }
      }
      ad_copy = {
        type          = "string"
        inferenceType = "explicit"
        instruction   = "Any text or copy present in the advertisement image, excluding the brand name and promotional offer."
      }
    }
  })
}