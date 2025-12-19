terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

############################
# AWS Providers (two regions)
############################
provider "aws" {
  region = var.primary_region
}

provider "aws" {
  alias  = "replica"
  region = var.replica_region
}

############################
# Call the S3 storage module
############################
module "s3_storage" {
  source = "./modules/s3_storage"

  photo_bucket_name       = var.photo_bucket_name
  replication_bucket_name = var.replication_bucket_name
}
