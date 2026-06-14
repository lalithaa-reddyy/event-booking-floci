#!/bin/bash
set -e

echo "Seeding DynamoDB with sample events..."

# Add Event 1
aws dynamodb put-item \
  --table-name Events \
  --item '{"eventId":{"S":"event-001"},"name":{"S":"Summer Music Festival 2026"},"category":{"S":"Music"},"ticketPrice":{"N":"99.99"},"capacity":{"N":"5000"}}' \
  --endpoint-url $AWS_ENDPOINT_URL 2>/dev/null || echo "Event 1 already exists"

# Add Event 2
aws dynamodb put-item \
  --table-name Events \
  --item '{"eventId":{"S":"event-002"},"name":{"S":"Tech Conference 2026"},"category":{"S":"Technology"},"ticketPrice":{"N":"299.99"},"capacity":{"N":"3000"}}' \
  --endpoint-url $AWS_ENDPOINT_URL 2>/dev/null || echo "Event 2 already exists"

# Add Event 3
aws dynamodb put-item \
  --table-name Events \
  --item '{"eventId":{"S":"event-003"},"name":{"S":"Food Carnival 2026"},"category":{"S":"Food"},"ticketPrice":{"N":"49.99"},"capacity":{"N":"2000"}}' \
  --endpoint-url $AWS_ENDPOINT_URL 2>/dev/null || echo "Event 3 already exists"

# Add Event 4
aws dynamodb put-item \
  --table-name Events \
  --item '{"eventId":{"S":"event-004"},"name":{"S":"Basketball Championship 2026"},"category":{"S":"Sports"},"ticketPrice":{"N":"150.00"},"capacity":{"N":"20000"}}' \
  --endpoint-url $AWS_ENDPOINT_URL 2>/dev/null || echo "Event 4 already exists"

echo "✓ Events seeded successfully"
