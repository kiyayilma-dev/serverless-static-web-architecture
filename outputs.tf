output "cloudfront_domain_name" {
  description = "The fully qualified domain name of the CloudFront distribution."
  value       = aws_cloudfront_distribution.static_assets.domain_name
}

output "s3_bucket_name" {
  description = "The name of the provisioned S3 bucket."
  value       = aws_s3_bucket.static_assets.id
}