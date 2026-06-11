# Deployment Guide - Floci Event Booking Platform

## ✅ Pipeline Status: All Systems Ready

All 8 pipeline connectivity checks have passed. The application is ready for deployment.

---

## Quick Deploy (Recommended)

```bash
bash scripts/full-pipeline.sh
```

This automatically:
1. Starts Floci (LocalStack)
2. Deploys infrastructure with Terraform
3. Seeds sample events
4. Builds frontend
5. Deploys to S3
6. Outputs access information

**Time:** ~3-5 minutes

---

## Manual Deployment (Step-by-Step)

### 1. Start Floci
```bash
bash scripts/setup-floci.sh
```

### 2. Deploy Infrastructure
```bash
bash scripts/deploy-terraform.sh
```
Creates:
- API Gateway (3 endpoints with CORS)
- 4 Lambda functions
- DynamoDB tables (Events, Bookings)
- SQS queue with DLQ
- S3 buckets (frontend, tickets)
- Cognito user pool

### 3. Load Configuration
```bash
source .env.terraform
```

### 4. Seed Data
```bash
bash scripts/seed-data.sh
```

### 5. Build Frontend
```bash
bash scripts/build-frontend.sh
```

### 6. Deploy Frontend
```bash
bash scripts/deploy-frontend.sh
```

### 7. Start Dev Server
```bash
cd frontend && npm start
```

Access at: **http://localhost:3000**

---

## Architecture

```
Frontend (React)
    ↓
API Gateway
    ├→ GET  /events  → Events Lambda → DynamoDB
    ├→ POST /book    → Booking Lambda → DynamoDB → SQS → Ticket Generator
    └→ GET  /history → History Lambda → DynamoDB

Ticket Generator
    ├→ Generate PDF
    ├→ Upload to S3
    └→ Update booking status

DynamoDB Tables:
  • Events (eventId as key)
  • Bookings (userId, bookingId as composite key)
```

---

## What's Connected

✅ **Frontend → API Gateway**
- Uses `REACT_APP_API_ENDPOINT` env var
- CORS enabled on all endpoints

✅ **API Gateway → Lambda**
- AWS_PROXY integration
- Lambda permissions configured
- All Lambda functions have proper IAM roles

✅ **Lambda → DynamoDB**
- All functions use DocumentClient
- Environment variables for table names
- Proper AWS SDK configuration for Floci

✅ **Lambda → SQS**
- Booking Lambda sends to queue
- Event source mapping connects SQS to Ticket Generator
- DLQ configured with 3 retries

✅ **Ticket Generator → S3**
- Generates PDF tickets
- Stores in S3 bucket
- Updates booking status

✅ **Environment Variables**
- All passed from Terraform to Lambda
- Frontend loads from `.env.terraform`
- No hardcoded values

✅ **Security**
- No AWS credentials in code
- All `.env` files in `.gitignore`
- Test credentials for local development

---

## Verify Before Deploying

```bash
bash scripts/verify-pipeline.sh
```

Checks:
- Floci running
- All Lambda functions configured
- Terraform infrastructure complete
- API Gateway CORS enabled
- Environment variables set
- Deployment scripts executable
- Credentials secured

---

## Testing

### Test Events Endpoint
```bash
curl $REACT_APP_API_ENDPOINT/events
```

### Test Booking
```bash
curl -X POST $REACT_APP_API_ENDPOINT/book \
  -H "Content-Type: application/json" \
  -d '{
    "eventId": "event-001",
    "quantity": 2,
    "userEmail": "test@example.com"
  }'
```

### Test History
```bash
curl $REACT_APP_API_ENDPOINT/history
```

---

## Troubleshooting

**Floci Not Running**
```bash
bash scripts/setup-floci.sh
podman-compose logs -f floci
```

**API Errors**
```bash
source .env.terraform
echo $REACT_APP_API_ENDPOINT
aws logs tail /aws/lambda/event-booking-book --follow --endpoint-url http://localhost:4566
```

**Frontend Build Issues**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm start
```

**DynamoDB Issues**
```bash
aws dynamodb scan --table-name Events --endpoint-url http://localhost:4566
aws dynamodb scan --table-name Bookings --endpoint-url http://localhost:4566
```

---

## Environment Variables

### Auto-generated (`.env.terraform`)
- `REACT_APP_API_ENDPOINT` - API URL
- `REACT_APP_COGNITO_USER_POOL_ID` - User pool ID
- `REACT_APP_COGNITO_CLIENT_ID` - App client ID
- `REACT_APP_COGNITO_REGION` - AWS region

### Lambda Runtime
- `BOOKINGS_TABLE` - Table name
- `EVENTS_TABLE` - Table name
- `TICKETS_BUCKET` - S3 bucket
- `BOOKING_QUEUE_URL` - SQS queue
- `AWS_ENDPOINT_URL` - Floci endpoint
- `IS_LOCAL` - Local flag

---

## Demo Credentials

After deployment, login with:
- **Email:** demo@example.com
- **Password:** Demo@123456

---

## Cleanup

```bash
bash scripts/cleanup.sh
```

Removes Floci container and local state.

---

## Next Steps

1. Run: `bash scripts/full-pipeline.sh`
2. Open: http://localhost:3000
3. Test: Create a booking
4. Verify: Check ticket generation

All systems are connected and ready! 🚀
