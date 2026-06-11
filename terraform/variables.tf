variable "aws_region" {
  description = "AWS region for Floci"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "floci_endpoint" {
  description = "Floci endpoint URL"
  type        = string
  default     = "http://localhost:4566"
}
