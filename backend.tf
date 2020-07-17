# Create an S3 bucket and a dynamodb table for use as a terraform backend.

terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version                 = "~> 2.0"
  shared_credentials_file = var.credentials
  region                  = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  # Globally unique S3 bucket name for tf state for all projects
  bucket = "all-projects-tf-states-${data.aws_caller_identity.current.account_id}"

  # Enable versioning so we can see the full revision history of our tf state

  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# create dynamodb table for tf lock
# https://github.com/hashicorp/terraform/issues/15303

resource "aws_dynamodb_table" "terraform_locks" {
  # Dyanmodb table for all tf projects
  name         = "all-project-tf-locks-${data.aws_caller_identity.current.account_id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
