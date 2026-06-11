#!/bin/bash

# Watch SQS Queue
# Shows messages in BookingQueue waiting for processing

get_queue_url() {
  aws sqs list-queues \
    --endpoint-url http://localhost:4566 2>/dev/null | \
    jq -r '.QueueUrls[] | select(contains("BookingQueue"))' | \
    grep -v DLQ | head -1
}

get_queue_attributes() {
  local QUEUE_URL=$1
  aws sqs get-queue-attributes \
    --queue-url "$QUEUE_URL" \
    --attribute-names All \
    --endpoint-url http://localhost:4566 2>/dev/null
}

while true; do
  clear
  echo "=========================================="
  echo "SQS: BookingQueue Monitor"
  echo "=========================================="
  echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  QUEUE_URL=$(get_queue_url)

  if [ -z "$QUEUE_URL" ]; then
    echo "Error: BookingQueue not found"
    echo "Retrying in 2 seconds..."
    sleep 2
    continue
  fi

  echo "Queue URL: $QUEUE_URL"
  echo ""

  # Get queue attributes (message count)
  ATTRS=$(get_queue_attributes "$QUEUE_URL")
  MESSAGES=$(echo "$ATTRS" | jq -r '.Attributes.ApproximateNumberOfMessages // "0"')
  VISIBLE=$(echo "$ATTRS" | jq -r '.Attributes.ApproximateNumberOfMessagesVisible // "0"')
  NOT_VISIBLE=$(echo "$ATTRS" | jq -r '.Attributes.ApproximateNumberOfMessagesNotVisible // "0"')

  echo "Message Count Summary:"
  echo "  Total messages: $MESSAGES"
  echo "  Visible (waiting): $VISIBLE"
  echo "  Not visible (being processed): $NOT_VISIBLE"
  echo ""

  # Try to receive messages (without deleting them)
  MESSAGES=$(aws sqs receive-message \
    --queue-url "$QUEUE_URL" \
    --max-number-of-messages 10 \
    --endpoint-url http://localhost:4566 2>/dev/null)

  MESSAGE_COUNT=$(echo "$MESSAGES" | jq '.Messages | length // 0')

  if [ "$MESSAGE_COUNT" -eq 0 ]; then
    echo "Status: Queue is empty ✓"
    echo ""
    echo "Waiting for new bookings..."
  else
    echo "Messages in queue: $MESSAGE_COUNT"
    echo ""
    echo "Message Details:"
    echo "$MESSAGES" | jq -r '.Messages[] |
      "---\nMessageId: \(.MessageId)\nReceiptHandle: \(.ReceiptHandle)\nBody:\n\(.Body | @json | fromjson | .)"' | \
      jq -r 'if type == "object" then
        "  bookingId: \(.bookingId)\n  userId: \(.userId)\n  eventId: \(.eventId)\n  quantity: \(.quantity)\n  totalPrice: \(.totalPrice)\n  userEmail: \(.userEmail)\n  createdAt: \(.createdAt)"
      else . end' 2>/dev/null
  fi

  echo ""
  echo "DLQ Status:"
  DLQ_URL=$(aws sqs list-queues --endpoint-url http://localhost:4566 2>/dev/null | jq -r '.QueueUrls[] | select(contains("BookingQueueDLQ"))' | head -1)
  if [ -n "$DLQ_URL" ]; then
    DLQ_ATTRS=$(aws sqs get-queue-attributes --queue-url "$DLQ_URL" --attribute-names All --endpoint-url http://localhost:4566 2>/dev/null)
    DLQ_MESSAGES=$(echo "$DLQ_ATTRS" | jq -r '.Attributes.ApproximateNumberOfMessages // "0"')
    echo "  Dead Letter Queue messages: $DLQ_MESSAGES"
    if [ "$DLQ_MESSAGES" -gt 0 ]; then
      echo "  ⚠️  Failed messages detected!"
    fi
  fi

  echo ""
  echo "Refreshing in 2 seconds... (Press Ctrl+C to stop)"
  sleep 2
done
