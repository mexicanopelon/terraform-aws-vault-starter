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

output "kms_key_id" {
  description = "ID of the KMS key for snapshot encryption"
  value       = aws_kms_key.vault_snapshots.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for snapshot encryption"
  value       = aws_kms_key.vault_snapshots.arn
}