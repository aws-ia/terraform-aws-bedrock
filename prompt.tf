# – Prompt Management –

resource "awscc_bedrock_prompt_version" "prompt_version" {
  count       = var.create_prompt_version ? 1 : 0
  prompt_arn  = awscc_bedrock_prompt.prompt[0].arn
  description = var.prompt_version_description
  tags        = var.prompt_version_tags
}

resource "awscc_bedrock_prompt" "prompt" {
  count                       = var.create_prompt ? 1 : 0
  name                        = "${random_string.solution_prefix.result}-${var.prompt_name}"
  description                 = var.prompt_description
  customer_encryption_key_arn = var.customer_encryption_key_arn
  default_variant             = var.default_variant
  tags                        = var.prompt_tags
  variants                    = var.variants_list
}
