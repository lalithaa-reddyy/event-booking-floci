resource "aws_s3_bucket" "tickets" {
  bucket         = "event-tickets-${local.account_id}"
  force_destroy  = true

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket         = "event-booking-frontend-${local.account_id}"
  force_destroy  = true

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.frontend.arn}/*"
      }
    ]
  })
}
