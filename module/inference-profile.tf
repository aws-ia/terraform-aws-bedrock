resource "awscc_bedrock_application_inference_profile" "application_inference_profile" {
  count                  = var.create_app_inference_profile ? 1 : 0
  inference_profile_name = "${random_string.solution_prefix.result}-${var.app_inference_profile_name}"
  description            = var.app_inference_profile_description
  model_source = {
    copy_from = var.app_inference_profile_model_source
  }
  tags = var.app_inference_profile_tags
}
