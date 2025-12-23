#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "bedrock" {
  source                = "../.." # local example
  create_default_kb     = true
  create_agent          = false
  create_s3_data_source = true
}