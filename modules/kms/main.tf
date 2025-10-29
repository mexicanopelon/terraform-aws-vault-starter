/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */

resource "aws_kms_key" "vault" {
  count                   = var.user_supplied_kms_key_arn != null ? 0 : 1
  deletion_window_in_days = var.kms_key_deletion_window
  description             = "AWS KMS Customer-managed key used for Vault auto-unseal and encryption"
  enable_key_rotation     = false
  is_enabled              = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = merge(
    { Name = "${var.resource_name_prefix}-vault-key" },
    var.common_tags,
  )
}


# KMS key for S3 bucket encryption
resource "aws_kms_key" "vault_snapshots" {
  description             = "KMS key for Vault snapshot encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = merge(
    { Name = "${var.resource_name_prefix}-vault-snapshots-key" },
    var.common_tags,
  )
}

# KMS key alias
resource "aws_kms_alias" "vault_snapshots" {
  name          = "alias/vault-snapshots"
  target_key_id = aws_kms_key.vault_snapshots.key_id
}