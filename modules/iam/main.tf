/**
 * Copyright © 2014-2022 HashiCorp, Inc.
 *
 * This Source Code is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this project, you can obtain one at http://mozilla.org/MPL/2.0/.
 *
 */


resource "aws_iam_instance_profile" "vault" {
  name_prefix = "${var.resource_name_prefix}-vault"
  role        = var.user_supplied_iam_role_name != null ? var.user_supplied_iam_role_name : aws_iam_role.instance_role[0].name
}

resource "aws_iam_role" "instance_role" {
  count                = var.user_supplied_iam_role_name != null ? 0 : 1
  name_prefix          = "${var.resource_name_prefix}-vault"
  permissions_boundary = var.permissions_boundary
  assume_role_policy   = data.aws_iam_policy_document.instance_role.json
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


resource "aws_iam_role_policy" "cloud_auto_join" {
  count  = var.user_supplied_iam_role_name != null ? 0 : 1
  name   = "${var.resource_name_prefix}-vault-auto-join"
  role   = aws_iam_role.instance_role[0].id
  policy = data.aws_iam_policy_document.cloud_auto_join.json
}

data "aws_iam_policy_document" "cloud_auto_join" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "auto_unseal" {
  count  = var.user_supplied_iam_role_name != null ? 0 : 1
  name   = "${var.resource_name_prefix}-vault-auto-unseal"
  role   = aws_iam_role.instance_role[0].id
  policy = data.aws_iam_policy_document.auto_unseal.json
}

data "aws_iam_policy_document" "auto_unseal" {
  statement {
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
    ]

    resources = [
      var.kms_key_arn,
    ]
  }
}

resource "aws_iam_role_policy" "session_manager" {
  count  = var.user_supplied_iam_role_name != null ? 0 : 1
  name   = "${var.resource_name_prefix}-vault-ssm"
  role   = aws_iam_role.instance_role[0].id
  policy = data.aws_iam_policy_document.session_manager.json
}

data "aws_iam_policy_document" "session_manager" {
  statement {
    effect = "Allow"

    actions = [
      "ssm:UpdateInstanceInformation",
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "secrets_manager" {
  count  = var.user_supplied_iam_role_name != null ? 0 : 1
  name   = "${var.resource_name_prefix}-vault-secrets-manager"
  role   = aws_iam_role.instance_role[0].id
  policy = data.aws_iam_policy_document.secrets_manager.json
}

data "aws_iam_policy_document" "secrets_manager" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      var.secrets_manager_arn,
    ]
  }
}


###### IAM policy for Vault to access S3 - START ######
# resource "aws_iam_role_policy" "vault_snapshot_policy" {
#   name = "${var.resource_name_prefix}-vault-snapshot-s3-policy"
#   role   = aws_iam_role.instance_role[0].id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:DeleteObject"
#         ]
#         Resource = [
#           var.vault_snapshot_s3_arn,
#           "${var.vault_snapshot_s3_arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey",
#           "kms:DescribeKey"
#         ]
#         Resource = [
#           var.vault_snapshot_kms_key_arn
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "vault_snapshot_policy" {
#   name        = "${var.resource_name_prefix}-vault-snapshot-s3-policy"
#   description = "Policy for Vault to write snapshots to S3"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "s3:PutObject",
#           "s3:GetObject",
#           "s3:ListBucket",
#           "s3:DeleteObject"
#         ]
#         Resource = [
#           var.vault_snapshot_s3_arn,
#           "${var.vault_snapshot_s3_arn}/*"
#         ]
#       },
#       {
#         Effect = "Allow"
#         Action = [
#           "kms:Decrypt",
#           "kms:Encrypt",
#           "kms:GenerateDataKey",
#           "kms:DescribeKey"
#         ]
#         Resource = [
#           var.vault_snapshot_kms_key_arn
#         ]
#       }
#     ]
#   })
# }

# # Attach policy to role
# resource "aws_iam_role_policy_attachment" "vault_snapshot_attach" {
#   role       = aws_iam_role.instance_role.name
#   policy_arn = aws_iam_policy.vault_snapshot_policy.arn
# }

###### IAM policy for Vault to access S3 - END. ######


###### IAM policy for Vault to CloudWatch - START ######

# # IAM Role for EC2 Instance (CloudWatch Agent)
# resource "aws_iam_role" "vault_cloudwatch" {
#   name = "${var.resource_name_prefix}-vault-cloudwatch-logs-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })

#   tags = {
#     Name = "Vault CloudWatch Logs Role"
#   }
# }

# IAM Policy for CloudWatch Logs
resource "aws_iam_role_policy" "vault_cloudwatch_logs" {
  name = "${var.resource_name_prefix}-vault-cloudwatch-logs-policy"
  role   = aws_iam_role.instance_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${var.vault_cloudwatch_log_group_arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups"
        ]
        Resource = "*"
      }
    ]
  })
}


###### IAM policy for Vault to CloudWatch - END ######