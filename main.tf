# ==============================================================================
# Provider Configuration
# ==============================================================================
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ==============================================================================
# S3 Bucket Configuration
# ==============================================================================
resource "aws_s3_bucket" "static_assets" {
  bucket = var.bucket_name

  tags = {
    Name        = "serverless-static-assets"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_website_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  index_document {
    suffix = "index.html"
  }
}

# Security: Block all public access. CloudFront will access it privately via OAC.
resource "aws_s3_bucket_public_access_block" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ==============================================================================
# CloudFront Origin Access Control (OAC)
# ==============================================================================
resource "aws_cloudfront_origin_access_control" "static_assets" {
  name                              = "oac-serverless-website"
  description                       = "OAC for secure S3 to CloudFront communication"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ==============================================================================
# S3 Bucket Policy (Allows CloudFront to read objects)
# ==============================================================================
resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipal"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_assets.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.static_assets.arn
          }
        }
      }
    ]
  })
}

# ==============================================================================
# CloudFront Distribution
# ==============================================================================
resource "aws_cloudfront_distribution" "static_assets" {
  origin {
    domain_name              = aws_s3_bucket.static_assets.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.static_assets.bucket}"
    origin_access_control_id = aws_cloudfront_origin_access_control.static_assets.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.static_assets.bucket}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "serverless-cdn-distribution"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# ==============================================================================
# Asset Deployment (Uploads local files to S3)
# ==============================================================================
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "index.html"
  source       = "${path.module}/website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/website/index.html")
}

resource "aws_s3_object" "style_css" {
  bucket       = aws_s3_bucket.static_assets.id
  key          = "style.css"
  source       = "${path.module}/website/style.css"
  content_type = "text/css"
  etag         = filemd5("${path.module}/website/style.css")
}