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

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count  = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.react_app_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for React App S3 Bucket"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.react_app_bucket[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.react_app_bucket[0].arn}/*"
    }]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "CloudFront Distribution for React App"

  origin {
    domain_name = var.create_bucket ? aws_s3_bucket.react_app_bucket[0].bucket_regional_domain_name : var.s3_static_domain
    origin_id   = "S3-react-app"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-react-app"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100"

  tags = {
    Environment = var.environment
  }
}

output "bucket_name" {
  value = var.create_bucket ? aws_s3_bucket.react_app_bucket[0].bucket : var.s3_bucket_name
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.cdn.domain_name
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}
