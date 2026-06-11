#!/bin/bash

# Watch S3 Buckets
# Shows uploaded tickets and frontend files

while true; do
  clear
  echo "=========================================="
  echo "S3: Buckets Monitor"
  echo "=========================================="
  echo "Last updated: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""

  # Tickets Bucket
  echo "--- Tickets Bucket (event-tickets-000000000000) ---"
  TICKETS=$(aws s3 ls s3://event-tickets-000000000000/ --recursive \
    --endpoint-url http://localhost:4566 2>/dev/null | wc -l)

  if [ "$TICKETS" -eq 0 ]; then
    echo "No tickets uploaded yet"
  else
    echo "Total ticket files: $((TICKETS - 1))"
    echo ""
    echo "Uploaded tickets:"
    aws s3 ls s3://event-tickets-000000000000/ --recursive \
      --endpoint-url http://localhost:4566 2>/dev/null | \
      awk '{print "  " $4 " (" $3 " bytes, " $1 " " $2 ")"}' | tail -20
  fi

  echo ""
  echo "--- Frontend Bucket (event-booking-frontend-000000000000) ---"
  FRONTEND=$(aws s3 ls s3://event-booking-frontend-000000000000/ --recursive \
    --endpoint-url http://localhost:4566 2>/dev/null | wc -l)

  if [ "$FRONTEND" -eq 0 ]; then
    echo "No frontend files uploaded"
  else
    echo "Total frontend files: $((FRONTEND - 1))"
    echo ""
    echo "Latest frontend files:"
    aws s3 ls s3://event-booking-frontend-000000000000/ --recursive \
      --endpoint-url http://localhost:4566 2>/dev/null | \
      awk '{print "  " $4 " (" $3 " bytes, " $1 " " $2 ")"}' | tail -10
  fi

  echo ""
  echo "Statistics:"
  TOTAL_TICKETS=$(aws s3 ls s3://event-tickets-000000000000/ --recursive \
    --endpoint-url http://localhost:4566 2>/dev/null | awk '{sum+=$3} END {print sum}')
  TOTAL_FRONTEND=$(aws s3 ls s3://event-booking-frontend-000000000000/ --recursive \
    --endpoint-url http://localhost:4566 2>/dev/null | awk '{sum+=$3} END {print sum}')

  echo "  Tickets bucket size: ${TOTAL_TICKETS:-0} bytes"
  echo "  Frontend bucket size: ${TOTAL_FRONTEND:-0} bytes"

  echo ""
  echo "Refreshing in 2 seconds... (Press Ctrl+C to stop)"
  sleep 2
done
