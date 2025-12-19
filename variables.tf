variable "primary_region" {
  description = "Primary AWS region for photo bucket"
  type        = string
  default     = "us-west-1"
}

variable "replica_region" {
  description = "Secondary AWS region for replication bucket"
  type        = string
  default     = "us-west-2"
}

variable "photo_bucket_name" {
  description = "Photo S3 bucket name"
  type        = string
  default     = "cti-photo-bucket"
}

variable "replication_bucket_name" {
  description = "Replication S3 bucket name"
  type        = string
  default     = "cti-replication-bucket"
}
