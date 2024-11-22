variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
  default     = "us-west-2"
}

variable "kb_metrics_namespace" {
  description = "Namespace under which Bedrock knowledge base sync metrics are published"
  type        = string
  default     = "KnowledgeBaseSync"
}

variable "crawlable_event_threshold" {
  description = "Number of crawlable events (create/update/delete) required to trigger a sync job"
  type        = number
  default     = 1
}

variable "crawlable_event_period" {
  description = "Time period (in seconds) over which to evaluate 'crawlable_event_threshold' before triggering a sync job"
  type        = number
  default     = 60
}

variable "sync_job_schedule" {
  description = "Schedule for sync which caps the maximum ingestion latency"
  type        = string
  // https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html
  default = "rate(1 hours)"
}