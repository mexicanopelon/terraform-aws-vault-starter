/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

variable "aws_region" {
  type        = string
  description = "AWS region where Vault is being deployed"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Vault will be deployed"
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

variable "vault_subnets" {
  type        = list(string)
  description = "Subnet IDs to deploy Vault into"
}