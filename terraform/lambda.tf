data "archive_file" "booking_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/booking-lambda"
  output_path = "${path.module}/.build/booking-lambda.zip"
}

data "archive_file" "events_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/events-lambda"
  output_path = "${path.module}/.build/events-lambda.zip"
}

data "archive_file" "history_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/history-lambda"
  output_path = "${path.module}/.build/history-lambda.zip"
}

data "archive_file" "ticket_generator_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/../backend/ticket-generator-lambda"
  output_path = "${path.module}/.build/ticket-generator-lambda.zip"
}

resource "aws_lambda_function" "booking" {
  filename         = data.archive_file.booking_lambda.output_path
  function_name    = "${local.project_name}-book"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.booking_lambda.output_base64sha256

  environment {
    variables = {
      BOOKINGS_TABLE     = aws_dynamodb_table.bookings.name
      EVENTS_TABLE       = aws_dynamodb_table.events.name
      BOOKING_QUEUE_URL  = aws_sqs_queue.booking_queue.url
      AWS_ENDPOINT_URL   = var.floci_endpoint
      IS_LOCAL           = "true"
    }
  }

  depends_on = [
    aws_iam_role_policy.dynamodb_access,
    aws_iam_role_policy.sqs_access
  ]

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_lambda_function" "events" {
  filename         = data.archive_file.events_lambda.output_path
  function_name    = "${local.project_name}-events"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.events_lambda.output_base64sha256

  environment {
    variables = {
      EVENTS_TABLE     = aws_dynamodb_table.events.name
      AWS_ENDPOINT_URL = var.floci_endpoint
      IS_LOCAL         = "true"
    }
  }

  depends_on = [
    aws_iam_role_policy.dynamodb_access
  ]

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_lambda_function" "history" {
  filename         = data.archive_file.history_lambda.output_path
  function_name    = "${local.project_name}-history"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  source_code_hash = data.archive_file.history_lambda.output_base64sha256

  environment {
    variables = {
      BOOKINGS_TABLE   = aws_dynamodb_table.bookings.name
      AWS_ENDPOINT_URL = var.floci_endpoint
      IS_LOCAL         = "true"
    }
  }

  depends_on = [
    aws_iam_role_policy.dynamodb_access
  ]

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_lambda_function" "ticket_generator" {
  filename         = data.archive_file.ticket_generator_lambda.output_path
  function_name    = "${local.project_name}-ticket-generator"
  role             = aws_iam_role.lambda_execution.arn
  handler          = "index.handler"
  runtime          = "nodejs22.x"
  timeout          = 60
  memory_size      = 512
  source_code_hash = data.archive_file.ticket_generator_lambda.output_base64sha256

  environment {
    variables = {
      BOOKINGS_TABLE   = aws_dynamodb_table.bookings.name
      TICKETS_BUCKET   = aws_s3_bucket.tickets.id
      AWS_ENDPOINT_URL = var.floci_endpoint
      IS_LOCAL         = "true"
    }
  }

  depends_on = [
    aws_iam_role_policy.dynamodb_access,
    aws_iam_role_policy.s3_access
  ]

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_lambda_event_source_mapping" "ticket_generator_sqs" {
  event_source_arn = aws_sqs_queue.booking_queue.arn
  function_name    = aws_lambda_function.ticket_generator.arn
  enabled          = true
  batch_size       = 1
}
