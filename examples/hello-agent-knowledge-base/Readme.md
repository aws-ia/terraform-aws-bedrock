# hello-agent-knowledge-base
This Terraform code uses the [AWS Bedrock Terraform module](https://registry.terraform.io/modules/aws-ia/bedrock/aws/latest) on a custom internal fork for GovCloud [here](https://github.com/KPInfr/terraform-aws-bedrock-orig).  Essentially, we establish
* An LLM agent and aliast to interact with
* A knowledge base for the LLM to search
* An S3 bucket to host data for the knowledge base to ingest

Although the IaC is simplified by use of the module, a lot of complexity is buried, given the 200+ inputs available.
> While this note is here, please do not deploy this in dev.  State is saved to local machine.

## Naming
Acronym is KALYPSO for Kairos-Aware Language Yielding & Parsing System Operator.