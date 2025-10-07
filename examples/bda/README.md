<!-- BEGIN_TF_DOCS -->
This example shows how to deploy a Bedrock data automation (BDA) project and blueprint.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.0.0 |
| <a name="requirement_opensearch"></a> [opensearch](#requirement\_opensearch) | = 2.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.6.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.6 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bda"></a> [bda](#module\_bda) | ../.. | n/a |
| <a name="module_blueprint"></a> [blueprint](#module\_blueprint) | ../.. | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy the resources | `string` | `"us-east-1"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->