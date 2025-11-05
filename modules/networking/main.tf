/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

data "aws_vpc" "selected" {
  id = var.vpc_id
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${var.resource_name_prefix}-vpc-endpoints-"
  description = "Security group for VPC endpoints used by Vault cluster"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    { Name = "${var.resource_name_prefix}-vpc-endpoints-sg" },
    var.common_tags,
  )

  lifecycle {
    create_before_destroy = true
  }
}

# VPC Endpoint for AWS Secrets Manager
resource "aws_vpc_endpoint" "secrets_manager" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vault_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    { Name = "${var.resource_name_prefix}-secretsmanager-endpoint" },
    var.common_tags,
  )
}

# VPC Endpoint for AWS KMS
resource "aws_vpc_endpoint" "kms" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.kms"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vault_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    { Name = "${var.resource_name_prefix}-kms-endpoint" },
    var.common_tags,
  )
}

# VPC Endpoint for AWS Certificate Manager (ACM)
# This creates an endpoint for ACM Private CA
resource "aws_vpc_endpoint" "acm_pca" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.acm-pca"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.vault_subnets
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    { Name = "${var.resource_name_prefix}-acm-pca-endpoint" },
    var.common_tags,
  )
}

# Optional: VPC Endpoint for S3 (Gateway endpoint - no cost)
# Useful if Vault needs to access S3 for backups or other purposes
# resource "aws_vpc_endpoint" "s3" {
#   count = var.enable_s3_endpoint ? 1 : 0

#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.${var.aws_region}.s3"
#   vpc_endpoint_type = "Gateway"
#   route_table_ids   = data.aws_route_tables.private.ids

#   tags = merge(
#     { Name = "${var.resource_name_prefix}-s3-endpoint" },
#     var.common_tags,
#   )
# }

# Optional: VPC Endpoint for EC2 (useful for metadata and EC2 API calls)
# resource "aws_vpc_endpoint" "ec2" {
#   count = var.enable_ec2_endpoint ? 1 : 0

#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ec2"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = var.vault_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true

#   tags = merge(
#     { Name = "${var.resource_name_prefix}-ec2-endpoint" },
#     var.common_tags,
#   )
# }

# Optional: VPC Endpoint for SSM (Systems Manager)
# Useful for Session Manager access to instances
# resource "aws_vpc_endpoint" "ssm" {
#   count = var.enable_ssm_endpoints ? 1 : 0

#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ssm"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = var.vault_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true

#   tags = merge(
#     { Name = "${var.resource_name_prefix}-ssm-endpoint" },
#     var.common_tags,
#   )
# }

# resource "aws_vpc_endpoint" "ssmmessages" {
#   count = var.enable_ssm_endpoints ? 1 : 0

#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ssmmessages"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = var.vault_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true

#   tags = merge(
#     { Name = "${var.resource_name_prefix}-ssmmessages-endpoint" },
#     var.common_tags,
#   )
# }

# resource "aws_vpc_endpoint" "ec2messages" {
#   count = var.enable_ssm_endpoints ? 1 : 0

#   vpc_id              = var.vpc_id
#   service_name        = "com.amazonaws.${var.aws_region}.ec2messages"
#   vpc_endpoint_type   = "Interface"
#   subnet_ids          = var.vault_subnets
#   security_group_ids  = [aws_security_group.vpc_endpoints.id]
#   private_dns_enabled = true

#   tags = merge(
#     { Name = "${var.resource_name_prefix}-ec2messages-endpoint" },
#     var.common_tags,
#   )
# }