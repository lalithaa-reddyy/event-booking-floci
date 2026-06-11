terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Configure for Floci
  skip_credentials_validation = true
  skip_metadata_api_check     = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cognitoidp     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    s3             = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    iam            = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
  }

  s3_use_path_style = true
}

locals {
  project_name = "event-booking"
  environment  = var.environment
  account_id   = "000000000000"
}
