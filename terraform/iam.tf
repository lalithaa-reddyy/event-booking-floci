resource "aws_iam_role" "lambda_execution" {
  name = "${local.project_name}-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_iam_role_policy" "dynamodb_access" {
  name = "${local.project_name}-dynamodb-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.bookings.arn,
          aws_dynamodb_table.events.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "sqs_access" {
  name = "${local.project_name}-sqs-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = [
          aws_sqs_queue.booking_queue.arn,
          aws_sqs_queue.booking_dlq.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "sns_access" {
  name = "${local.project_name}-sns-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.booking_notifications.arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "s3_access" {
  name = "${local.project_name}-s3-policy"
  role = aws_iam_role.lambda_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.tickets.arn}/*"
      }
    ]
  })
}
