resource "aws_dynamodb_table" "events" {
  name           = "Events"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "eventId"

  attribute {
    name = "eventId"
    type = "S"
  }

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}

resource "aws_dynamodb_table" "bookings" {
  name           = "Bookings"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "userId"
  range_key      = "bookingId"

  attribute {
    name = "userId"
    type = "S"
  }

  attribute {
    name = "bookingId"
    type = "S"
  }

  tags = {
    Environment = local.environment
    Project     = local.project_name
  }
}
