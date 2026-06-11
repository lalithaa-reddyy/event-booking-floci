resource "aws_api_gateway_rest_api" "main" {
  name        = "${local.project_name}-api"
  description = "Event Booking Platform API"

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

# /events resource
resource "aws_api_gateway_resource" "events" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_method" "events_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.events.id
  http_method      = "GET"
  authorization    = "NONE"
  request_parameters = {
    "method.request.header.Content-Type" = false
  }
}

resource "aws_api_gateway_integration" "events_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.events.id
  http_method             = aws_api_gateway_method.events_get.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.events.invoke_arn
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "events_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.events.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# /book resource
resource "aws_api_gateway_resource" "book" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "book"
}

resource "aws_api_gateway_method" "book_post" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.book.id
  http_method      = "POST"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "book_post" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.book.id
  http_method             = aws_api_gateway_method.book_post.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.booking.invoke_arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_method" "book_options" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.book.id
  http_method      = "OPTIONS"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "book_options" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.book.id
  http_method             = aws_api_gateway_method.book_options.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.booking.invoke_arn
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "booking_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.booking.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# /history resource
resource "aws_api_gateway_resource" "history" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  parent_id   = aws_api_gateway_rest_api.main.root_resource_id
  path_part   = "history"
}

resource "aws_api_gateway_method" "history_get" {
  rest_api_id      = aws_api_gateway_rest_api.main.id
  resource_id      = aws_api_gateway_resource.history.id
  http_method      = "GET"
  authorization    = "NONE"
}

resource "aws_api_gateway_integration" "history_get" {
  rest_api_id             = aws_api_gateway_rest_api.main.id
  resource_id             = aws_api_gateway_resource.history.id
  http_method             = aws_api_gateway_method.history_get.http_method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.history.invoke_arn
  integration_http_method = "POST"
}

resource "aws_lambda_permission" "history_api" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.history.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
}

# Deployment
resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.main.id

  depends_on = [
    aws_api_gateway_integration.events_get,
    aws_api_gateway_integration.book_post,
    aws_api_gateway_integration.book_options,
    aws_api_gateway_integration.history_get,
  ]
}

# Stage
resource "aws_api_gateway_stage" "main" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.main.id
  stage_name    = var.environment
}
