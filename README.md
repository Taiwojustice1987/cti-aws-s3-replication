# Terraform AWS S3 Replication Module

## Overview
This project provisions an **AWS S3 replication setup** using Terraform. It creates two S3 buckets:

1. **Photo Bucket** – Main bucket for photo caching.
2. **Replication Bucket** – Destination bucket for cross-region replication.

The project also sets up:

- Bucket versioning for both buckets.
- An IAM role and policy to allow replication.
- S3 replication configuration between the source and destination buckets.

This setup can be used by a photo service to store and replicate photos automatically.

---

## Architecture

Photo Service
│
▼
Photo Bucket (S3) --> Replication Bucket (S3)
│
└─ Versioning Enabled

yaml
Copy code

---

## Prerequisites

- Terraform >= 1.5.0
- AWS CLI configured with access to your AWS account
- Git

---

## Getting Started

1. **Clone the repository**

```bash
git clone https://github.com/Taiwojustice1987/cti-aws-s3-replication.git
cd cti-aws-s3-replication
Initialize Terraform

bash
Copy code
terraform init
Plan the deployment

bash
Copy code
terraform plan
Apply the configuration

bash
Copy code
terraform apply
Confirm by typing yes when prompted.

Outputs
After successful deployment, Terraform outputs:

photo_bucket – Name of the photo bucket.

replication_bucket – Name of the replication bucket.

Validation / Testing
Go to the AWS S3 console and verify both buckets exist.

Check that versioning is enabled on both buckets.

Confirm the replication configuration on the photo bucket.

Optional: Upload a file to the photo bucket and verify it replicates to the replication bucket.

The photo_bucket_policy allows your photo service to access the bucket.

Notes
The .terraform folder and provider binaries are not included in the repository.

Make sure to never commit provider binaries as they exceed GitHub's size limits.

License
This project is open-source and available under the MIT License.

yaml
Copy code

---

If you want, I can also **add a `.gitignore`** specifically for Terraform so you never push `.terraform` or `.tfstate` files again. This is important to keep your GitHub repo clean.  

Do you want me to do that next?
