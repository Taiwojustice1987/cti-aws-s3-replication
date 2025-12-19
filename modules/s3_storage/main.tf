############################
# 0. Terraform required providers
############################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

############################
# 0a. AWS Providers (two regions)
############################
provider "aws" {
  region = "us-west-1"
}

provider "aws" {
  alias  = "replica"
  region = "us-west-2"
}

############################
# 0b. Random suffix for uniqueness
############################
resource "random_id" "suffix" {
  byte_length = 4
}

############################
# 1. Photo bucket (us-west-1)
############################
resource "aws_s3_bucket" "photo_bucket" {
  provider      = aws
  bucket        = "${var.photo_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "photo_versioning" {
  provider = aws
  bucket   = aws_s3_bucket.photo_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

################################
# 2. Replication bucket (us-west-2)
################################
resource "aws_s3_bucket" "replication_bucket" {
  provider      = aws.replica
  bucket        = "${var.replication_bucket_name}-${random_id.suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "replication_versioning" {
  provider = aws.replica
  bucket   = aws_s3_bucket.replication_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

############################
# 3. IAM Role for Replication
############################
resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    } ]
  })
}

##################################
# 3a. IAM Policy for Replication
##################################
resource "aws_iam_role_policy" "s3_replication_policy" {
  name = "s3-replication-policy-${random_id.suffix.hex}"
  role = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetReplicationConfiguration",
          "s3:ListBucket",
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication"
        ]
        Resource = [
          aws_s3_bucket.photo_bucket.arn,
          "${aws_s3_bucket.photo_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.replication_bucket.arn}/*"
      }
    ]
  })
}

##################################
# 4. Cross-Region Replication Rule
##################################
resource "aws_s3_bucket_replication_configuration" "replication" {
  provider = aws
  bucket   = aws_s3_bucket.photo_bucket.id
  role     = aws_iam_role.s3_replication_role.arn

  depends_on = [
    aws_s3_bucket_versioning.photo_versioning,
    aws_s3_bucket_versioning.replication_versioning,
    aws_iam_role_policy.s3_replication_policy
  ]

  rule {
    id     = "replicate-to-us-west-2"
    status = "Enabled"

    filter {
      prefix = ""
    }

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn
      storage_class = "STANDARD"
    }

    delete_marker_replication {
      status = "Disabled"
    }
  }
}

############################
# 5. Photo Bucket Policy
############################
resource "aws_s3_bucket_policy" "photo_bucket_policy" {
  provider = aws
  bucket   = aws_s3_bucket.photo_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [ {
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::626635400294:root"
      }
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.photo_bucket.arn,
        "${aws_s3_bucket.photo_bucket.arn}/*"
      ]
    } ]
  })
}
