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

# --- S3 Bucket y CloudFront (tu configuración actual) ---

resource "aws_s3_bucket" "react_app_bucket" {
  count  = var.create_bucket ? 1 : 0

  bucket = var.s3_bucket_name
  acl    = "private"

  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "react_app_bucket_versioning" {
  count  = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.react_app_bucket[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  count = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.react_app_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  count   = var.create_bucket ? 1 : 0
  comment = "Origin Access Identity for React App S3 Bucket"
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  count = var.create_bucket ? 1 : 0

  bucket = aws_s3_bucket.react_app_bucket[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = aws_cloudfront_origin_access_identity.origin_access_identity[0].iam_arn
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.react_app_bucket[0].arn}/*"
    }]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  count = var.create_bucket ? 1 : 0

  enabled             = true
  comment             = "CloudFront Distribution for React App"
  price_class         = "PriceClass_100"
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.react_app_bucket[0].bucket_regional_domain_name
    origin_id   = "S3-react-app"

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.origin_access_identity[0].id}"
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

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_cloudfront_distribution" "cdn_external" {
  count = var.create_bucket || length(var.s3_static_domain) == 0 ? 0 : 1

  enabled             = true
  comment             = "CloudFront Distribution for External S3 Bucket"
  price_class         = "PriceClass_100"
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  origin {
    domain_name = var.s3_static_domain
    origin_id   = "S3-external-bucket"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-external-bucket"

    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1"
  }

  tags = {
    Environment = var.environment
  }
}

output "bucket_name" {
  value = var.create_bucket ? aws_s3_bucket.react_app_bucket[0].bucket : var.s3_bucket_name
}

output "cloudfront_domain_name" {
  value = var.create_bucket ? aws_cloudfront_distribution.cdn[0].domain_name : (length(aws_cloudfront_distribution.cdn_external) > 0 ? aws_cloudfront_distribution.cdn_external[0].domain_name : "")
}

output "cloudfront_distribution_id" {
  value = var.create_bucket && length(aws_cloudfront_distribution.cdn) > 0 ? aws_cloudfront_distribution.cdn[0].id : ( length(aws_cloudfront_distribution.cdn_external) > 0 ? aws_cloudfront_distribution.cdn_external[0].id : "")
}

# --- Datos de VPC ---

data "aws_vpc" "default" {
  default = true
}

# --- Security Group para EC2 ---

resource "aws_security_group" "ec2_sg" {
  name        = "allow_http_ssh1"
  description = "Permite acceso HTTP y SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "allow_http_ssh"
    Environment = var.environment
  }
}

# --- Instancia EC2 ---

resource "aws_instance" "app_server" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]

  tags = {
    Name        = "app-server"
    Environment = var.environment
  }
}

# --- Outputs para EC2 ---

output "ec2_instance_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "ec2_instance_id" {
  value = aws_instance.app_server.id
}
