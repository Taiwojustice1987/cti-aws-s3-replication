# Variables
variable "region" {
  description = "AWS region"
  default     = "us-west-2"
}

variable "photo_bucket_name" {
  description = "Name of the photo bucket"
  default     = "cti-photo-service-bucket"
}

variable "replication_bucket_name" {
  description = "Name of the replication bucket"
  default     = "cti-photo-service-replication"
}
