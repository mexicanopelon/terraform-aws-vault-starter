# Outputs
output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.vault_audit.name
}

output "cloudwatch_log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.vault_audit.arn
}

output "iam_role_arn" {
  description = "IAM role ARN for EC2 instance"
  value       = aws_iam_role.vault_cloudwatch.arn
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name"
  value       = aws_iam_instance_profile.vault_cloudwatch.name
}

output "cloudwatch_console_url" {
  description = "CloudWatch Logs console URL"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#logsV2:log-groups/log-group/${replace(var.log_group_name, "/", "$252F")}"
}