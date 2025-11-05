# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "vault_audit" {
  name              = var.log_group_name != null ? var.log_group_name : "/vault/${var.resource_name_prefix}-audit-logs"
  retention_in_days = var.log_retention_days

  tags = merge(
    { Name = "${var.resource_name_prefix}-vault-audit-logs" },
    var.common_tags,
  )
}

# SSM Parameter for CloudWatch Agent Configuration
resource "aws_ssm_parameter" "cloudwatch_config" {
  name        = "/vault/${var.resource_name_prefix}-cloudwatch-agent-config"
  description = "CloudWatch Agent configuration for Vault audit logs"
  type        = "String"
  
  value = jsonencode({
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path        = "/var/log/vault/audit.log"
              log_group_name   = var.log_group_name
              log_stream_name  = "{instance_id}-audit"
              timezone         = "UTC"
              timestamp_format = "%Y-%m-%dT%H:%M:%S"
            }
          ]
        }
      }
    }
  })

  tags = merge(
    { Name = "${var.resource_name_prefix}-vault-cloudwatch-agent-config" },
    var.common_tags,
  )
}

# CloudWatch Log Metric Filter for SSO Logins
resource "aws_cloudwatch_log_metric_filter" "sso_logins" {
  name           = "${var.resource_name_prefix}-vault-sso-login-attempts"
  log_group_name = aws_cloudwatch_log_group.vault_audit.name
  pattern        = "{ ($.request.path = \"auth/oidc/*\" || $.request.path = \"auth/jwt/*\" || $.request.path = \"auth/ldap/*\") && $.type = \"request\" }"

  metric_transformation {
    name      = "VaultSSOLoginAttempts"
    namespace = "Vault/SSO"
    value     = "1"
    unit      = "Count"
  }
}

# CloudWatch Log Metric Filter for Failed SSO Logins
resource "aws_cloudwatch_log_metric_filter" "sso_login_failures" {
  name           = "${var.resource_name_prefix}-vault-sso-login-failures"
  log_group_name = aws_cloudwatch_log_group.vault_audit.name
  pattern        = "{ ($.request.path = \"auth/oidc/*\" || $.request.path = \"auth/jwt/*\" || $.request.path = \"auth/ldap/*\") && $.error != \"\" }"

  metric_transformation {
    name      = "VaultSSOLoginFailures"
    namespace = "Vault/SSO"
    value     = "1"
    unit      = "Count"
  }
}

# CloudWatch Alarm for Failed SSO Logins
resource "aws_cloudwatch_metric_alarm" "sso_login_failures" {
  alarm_name          = "${var.resource_name_prefix}-vault-sso-login-failures-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "VaultSSOLoginFailures"
  namespace           = "Vault/SSO"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This metric monitors Vault SSO login failures"
  treat_missing_data  = "notBreaching"

  alarm_actions = []  # Add SNS topic ARN here for notifications
}

# CloudWatch Log Insights Query - SSO Authentication Events
resource "aws_cloudwatch_query_definition" "sso_auth_events" {
  name = "${var.resource_name_prefix}-vault-sso-authentication-events"

  log_group_names = [
    aws_cloudwatch_log_group.vault_audit.name
  ]

  query_string = <<-QUERY
fields @timestamp, @message
| filter @message like /auth\/oidc/ or @message like /auth\/jwt/ or @message like /auth\/ldap/
| filter @message like /login/ or @message like /callback/
| sort @timestamp desc
| limit 100
QUERY
}

# CloudWatch Log Insights Query - Failed SSO Attempts
resource "aws_cloudwatch_query_definition" "failed_sso_attempts" {
  name = "${var.resource_name_prefix}-vault-failed-sso-attempts"

  log_group_names = [
    aws_cloudwatch_log_group.vault_audit.name
  ]

  query_string = <<-QUERY
fields @timestamp, @message
| filter @message like /auth\/oidc/ or @message like /auth\/jwt/ or @message like /auth\/ldap/
| filter @message like /error/
| parse @message /"error":"*"/ as error_msg
| display @timestamp, error_msg
| sort @timestamp desc
| limit 50
QUERY
}


