terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "react_app_bucket" {
  count  = var.create_bucket ? 1 : 0

  bucket = var.s3_bucket_name

  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "bucket_name" {
  value = var.create_bucket ? aws_s3_bucket.react_app_bucket[0].bucket : var.s3_bucket_name
}
