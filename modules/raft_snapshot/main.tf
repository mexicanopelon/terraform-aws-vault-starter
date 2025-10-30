# S3 Bucket for Vault snapshots
resource "aws_s3_bucket" "vault_snapshots" {
  bucket = "${var.resource_name_prefix}-vault-raft-snapshots" # MODIFY name if needed
  
  tags = merge(
    { Name = "${var.resource_name_prefix}-vault-raft-snapshots" },
    var.common_tags,
  )
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "vault_snapshots" {
  bucket = aws_s3_bucket.vault_snapshots.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption for the S3 bucket with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "vault_snapshots" {
  bucket = aws_s3_bucket.vault_snapshots.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.vault_snapshot_kms_key_arn
    }
    bucket_key_enabled = true
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


# Vault Raft Snapshot Agent Configuration
resource "vault_raft_snapshot_agent_config" "s3_snapshots" {
  name              = "${var.resource_name_prefix}-s3-snapshot-agent"
  interval_seconds  = 3600  # Take snapshot every hour
  retain            = 168   # Retain 168 snapshots (1 week if hourly)
  path_prefix       = "vault-raft/"
  
  storage_type = "aws-s3"
  
  aws_s3_bucket                = aws_s3_bucket.vault_snapshots.bucket
  aws_s3_region                = var.aws_region
  aws_s3_enable_kms            = true
  aws_s3_kms_key               = var.vault_snapshot_kms_key_arn
  aws_s3_server_side_encryption = true
  
  # If using IAM instance profile, these can be omitted
  # aws_access_key_id     = var.aws_access_key_id
  # aws_secret_access_key = var.aws_secret_access_key
}
