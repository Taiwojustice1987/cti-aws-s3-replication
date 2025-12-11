output "photo_bucket" {
  description = "The name of the photo S3 bucket"
  value       = aws_s3_bucket.photo_bucket.id
}

output "replication_bucket" {
  description = "The name of the replication S3 bucket"
  value       = aws_s3_bucket.replication_bucket.id
}
