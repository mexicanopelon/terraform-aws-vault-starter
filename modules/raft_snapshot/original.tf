# S3 Bucket for Vault snapshots
resource "aws_s3_bucket" "vault_snapshots" {
  bucket = "vault-raft-snapshots-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "Vault Raft Snapshots"
    Environment = var.environment
  }
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "vault_snapshots" {
  bucket = aws_s3_bucket.vault_snapshots.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_snapshots" {
  bucket = aws_s3_bucket.vault_snapshots.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "vault_snapshots" {
  bucket = aws_s3_bucket.vault_snapshots.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM policy for Vault to access S3
resource "aws_iam_policy" "vault_snapshot_policy" {
  name        = "vault-snapshot-s3-policy"
  description = "Policy for Vault to write snapshots to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.vault_snapshots.arn,
          "${aws_s3_bucket.vault_snapshots.arn}/*"
        ]
      }
    ]
  })
}

# IAM role for Vault (if using EC2 instance profile)
resource "aws_iam_role" "vault_snapshot_role" {
  name = "vault-snapshot-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "vault_snapshot_attach" {
  role       = aws_iam_role.vault_snapshot_role.name
  policy_arn = aws_iam_policy.vault_snapshot_policy.arn
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "vault_snapshot_profile" {
  name = "vault-snapshot-profile"
  role = aws_iam_role.vault_snapshot_role.name
}

# Vault Raft Snapshot Agent Configuration
resource "vault_raft_snapshot_agent_config" "s3_snapshots" {
  name              = "s3-snapshot-agent"
  interval_seconds  = 3600  # Take snapshot every hour
  retain            = 168   # Retain 168 snapshots (1 week if hourly)
  path_prefix       = "vault-raft/"
  
  storage_type = "aws-s3"
  
  aws_s3_bucket                = aws_s3_bucket.vault_snapshots.bucket
  aws_s3_region                = var.aws_region
  aws_s3_enable_kms            = false
  aws_s3_server_side_encryption = true
  
  # If using IAM instance profile, these can be omitted
  # aws_access_key_id     = var.aws_access_key_id
  # aws_secret_access_key = var.aws_secret_access_key
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Variables
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "aws_region" {
  description = "AWS region for S3 bucket"
  type        = string
  default     = "us-east-1"
}

# Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket for Vault snapshots"
  value       = aws_s3_bucket.vault_snapshots.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.vault_snapshots.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role for Vault snapshots"
  value       = aws_iam_role.vault_snapshot_role.arn
}