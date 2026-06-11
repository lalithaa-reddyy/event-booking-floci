output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.main.id
}

output "events_table_name" {
  description = "DynamoDB Events Table Name"
  value       = aws_dynamodb_table.events.name
}

output "bookings_table_name" {
  description = "DynamoDB Bookings Table Name"
  value       = aws_dynamodb_table.bookings.name
}

output "tickets_bucket_name" {
  description = "S3 Tickets Bucket Name"
  value       = aws_s3_bucket.tickets.id
}

output "frontend_bucket_name" {
  description = "S3 Frontend Bucket Name"
  value       = aws_s3_bucket.frontend.id
}

output "booking_queue_url" {
  description = "SQS Booking Queue URL"
  value       = aws_sqs_queue.booking_queue.url
}

output "booking_topic_arn" {
  description = "SNS Booking Notifications Topic ARN"
  value       = aws_sns_topic.booking_notifications.arn
}

output "api_endpoint" {
  description = "API Gateway Endpoint"
  value       = "http://localhost:4566/restapis/${aws_api_gateway_rest_api.main.id}/prod/_user_request_"
}

output "booking_lambda_arn" {
  description = "Booking Lambda ARN"
  value       = aws_lambda_function.booking.arn
}

output "events_lambda_arn" {
  description = "Events Lambda ARN"
  value       = aws_lambda_function.events.arn
}

output "history_lambda_arn" {
  description = "History Lambda ARN"
  value       = aws_lambda_function.history.arn
}

output "ticket_generator_lambda_arn" {
  description = "Ticket Generator Lambda ARN"
  value       = aws_lambda_function.ticket_generator.arn
}
