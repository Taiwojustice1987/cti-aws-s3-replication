terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "s3_storage" {
  source                  = "./modules/s3_storage"
  photo_bucket_name       = var.photo_bucket_name
  replication_bucket_name = var.replication_bucket_name
}
