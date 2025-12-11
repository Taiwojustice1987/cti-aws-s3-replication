# 1. Photo bucket
resource "aws_s3_bucket" "photo_bucket" {
  bucket        = var.photo_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "photo_versioning" {
  bucket = aws_s3_bucket.photo_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. Replication bucket
resource "aws_s3_bucket" "replication_bucket" {
  bucket        = var.replication_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "replication_versioning" {
  bucket = aws_s3_bucket.replication_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. IAM Role for S3 Replication
resource "aws_iam_role" "s3_replication_role" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# 3a. IAM Role Policy for replication
resource "aws_iam_role_policy" "s3_replication_policy" {
  name = "s3-replication-policy"
  role = aws_iam_role.s3_replication_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersion",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionForReplication",
          "s3:ListBucket"
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

# 4. S3 Replication configuration
resource "aws_s3_bucket_replication_configuration" "replication" {
  bucket = aws_s3_bucket.photo_bucket.id
  role   = aws_iam_role.s3_replication_role.arn

  depends_on = [
    aws_s3_bucket_versioning.photo_versioning,
    aws_s3_bucket_versioning.replication_versioning,
    aws_iam_role_policy.s3_replication_policy
  ]

  rule {
    id     = "replicate-to-replication-bucket"
    status = "Enabled"

    destination {
      bucket        = aws_s3_bucket.replication_bucket.arn
      storage_class = "STANDARD"
    }

    filter {
      prefix = ""  # replicate all objects
    }

    delete_marker_replication {
      status = "Disabled"
    }
  }
}

# 5. Photo bucket policy
resource "aws_s3_bucket_policy" "photo_bucket_policy" {
  bucket = aws_s3_bucket.photo_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::626635400294:root"  # valid principal for testing
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
      }
    ]
  })
}
