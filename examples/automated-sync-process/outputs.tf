output "dashboard" {
  value       = "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards/dashboard/${aws_cloudwatch_dashboard.ingestion_monitoring.dashboard_name}"
  description = "Link to the monitoring dashboard"
}