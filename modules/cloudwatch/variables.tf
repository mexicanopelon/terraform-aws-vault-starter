variable "aws_region" {
  description = "AWS region for CloudWatch"
  type        = string
  default     = "us-east-1"
}

variable "resource_name_prefix" {
  type        = string
  description = "Resource name prefix used for tagging and naming AWS resources"
}

variable "common_tags" {
  type        = map(string)
  description = "(Optional) Map of common tags for all taggable AWS resources."
  default     = {}
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}