# AWS CloudWatch Module

## Required variables

* `lb_certificate_arn` - ARN of TLS certificate imported into ACM for use with LB listener
* `lb_health_check_path` - The endpoint to check for Vault's health status
* `lb_subnets` - Subnets where load balancer will be deployed
* `lb_type` - The type of load balancer to provision: network or application
* `resource_name_prefix` - Resource name prefix used for tagging and naming AWS resources
* `ssl_policy` - SSL policy to use on LB listener
* `vault_sg_id` - Security group ID of Vault cluster
* `vpc_id` - VPC ID where Vault will be deployed

## Example usage

```hcl
module "cloudwatch" {
  source = "./modules/cloudwatch"

  common_tags               = var.common_tags
  aws_region                = var.aws_s3_region
  resource_name_prefix      = var.resource_name_prefix
  log_group_name            = var.log_group_name
  log_retention_days        = var.log_retention_days
}
```