variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "The globally unique name for the S3 bucket."
  type        = string
  # Note: S3 bucket names must be globally unique across all AWS accounts.
  default = "kiya-serverless-assets-prod-2026" 
}