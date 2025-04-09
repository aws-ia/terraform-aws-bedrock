resource "awscc_bedrock_data_automation_project" "bda_project" {
    count                         = var.create_bda ? 1 : 0
    project_name                  = "${random_string.solution_prefix.result}-${var.bda_project_name}"
    project_description           = var.bda_project_description
    kms_encryption_context        = var.bda_kms_encryption_context
    kms_key_id                    = var.bda_kms_key_id
    tags                          = var.bda_tags
    standard_output_configuration = var.bda_standard_output_configuration
    custom_output_configuration   = {
        blueprints = var.bda_custom_output_config
    }
    override_configuration = {
        document = {
            splitter = {
                state = var.bda_override_config_state
            }
        }
    }
}

resource "awscc_bedrock_blueprint" "bda_blueprint" {
    count                  = var.create_blueprint ? 1 : 0 
    blueprint_name         = "${random_string.solution_prefix.result}-${var.blueprint_name}"
    schema                 = var.blueprint_schema
    type                   = var.blueprint_type
    kms_encryption_context = var.blueprint_kms_encryption_context
    kms_key_id             = var.blueprint_kms_key_id
    tags                   = var.blueprint_tags
}