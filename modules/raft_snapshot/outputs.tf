# Outputs
output "s3_bucket_vault_snapshots" {
  description = "Name of the S3 bucket for Vault snapshots"
  value       = aws_s3_bucket.vault_snapshots.bucket
}

output "s3_bucket_vault_snapshots_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.vault_snapshots.arn
}
