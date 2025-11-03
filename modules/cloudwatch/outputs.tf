# Outputs
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.vault_audit.name
}

output "vault_cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.vault_audit.arn
}

output "cloudwatch_console_url" {
  description = "CloudWatch Logs console URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(var.log_group_name, "/", "$252F")}"
}

output "cloudwatch_config" {
  description = "CloudWatch SSM parameter config"
  value       = aws_ssm_parameter.cloudwatch_config
}