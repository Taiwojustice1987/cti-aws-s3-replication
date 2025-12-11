output "photo_bucket" {
  description = "The name of the photo S3 bucket"
  value       = module.s3_storage.photo_bucket
}

output "replication_bucket" {
  description = "The name of the replication S3 bucket"
  value       = module.s3_storage.replication_bucket
}
