#!/bin/bash

# Empty Parking Lot Workflow Test
# Tests the complete flow: Book → QR → Barrier Entry

set -e  # Exit on error

BASE_URL="http://localhost:8001"

echo "============================================================"
echo "🅿️  Empty Parking Lot Workflow Test"
echo "============================================================"

# Check if server is running
if ! curl -s "$BASE_URL/api/mobile/facilities/" > /dev/null 2>&1; then
    echo "❌ Error: Server not running at $BASE_URL"
    echo "Please start the server first:"
    echo "  cd backend && uv run python manage.py runserver 8001"
    exit 1
fi

# Step 1: Login
echo -e "\n--- STEP 1: Login as driver ---"
TOKEN=$(curl -s -X POST $BASE_URL/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')

if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
    echo "❌ Login failed"
    exit 1
fi

echo "✅ Logged in successfully"
echo "Token: ${TOKEN:0:30}..."

# Step 2: Discover empty parking lots
echo -e "\n--- STEP 2: Discover empty parking lots ---"
LOTS=$(curl -s "$BASE_URL/api/mobile/facilities/?type=small")
LOT_COUNT=$(echo "$LOTS" | jq 'length')

echo "Found $LOT_COUNT empty parking lots:"
echo "$LOTS" | jq -r '.[] | "  • \(.name) - ₹\(.price)/hr - \(.available_spots) spots available"'

# Get first lot ID
FACILITY_ID=$(echo "$LOTS" | jq -r '.[0].id')
FACILITY_NAME=$(echo "$LOTS" | jq -r '.[0].name')

echo -e "\nSelected: $FACILITY_NAME (ID: $FACILITY_ID)"

# Step 3: Create booking (instant - no approval)
echo -e "\n--- STEP 3: Create booking (instant) ---"
BOOKING=$(curl -s -X POST $BASE_URL/api/mobile/bookings/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"facility_id\": $FACILITY_ID, \"duration\": 2.0}")

echo "$BOOKING" | jq .

BOOKING_ID=$(echo "$BOOKING" | jq -r '.id')
ACCESS_CODE=$(echo "$BOOKING" | jq -r '.access_code')
SPOT_CODE=$(echo "$BOOKING" | jq -r '.spot_code')
STATUS=$(echo "$BOOKING" | jq -r '.status')

if [[ "$STATUS" == "reserved" ]]; then
    echo "✅ Booking created instantly (no approval needed)"
    echo "   Booking ID: $BOOKING_ID"
    echo "   Spot: $SPOT_CODE"
    echo "   Access Code: $ACCESS_CODE"
    echo "   Status: $STATUS"
elif [[ "$STATUS" == "pending_approval" ]]; then
    echo "❌ ERROR: Status is pending_approval (should be instant for empty lots)"
    exit 1
else
    echo "❌ Booking failed"
    echo "$BOOKING"
    exit 1
fi

# Step 4: Get QR code
echo -e "\n--- STEP 4: Get QR code for entry ---"
QR_DATA=$(curl -s -H "Authorization: Token $TOKEN" \
  $BASE_URL/api/lockbox/qr/$BOOKING_ID/)

echo "$QR_DATA" | jq '{booking_id, access_code, payload}'

QR_PAYLOAD=$(echo "$QR_DATA" | jq -r '.payload')
QR_IMAGE_LENGTH=$(echo "$QR_DATA" | jq -r '.qr_code' | wc -c)

echo "✅ QR code generated"
echo "   Payload: $QR_PAYLOAD"
echo "   Image: Base64 string (${QR_IMAGE_LENGTH} chars)"

# Step 5: Simulate barrier entry scan
echo -e "\n--- STEP 5: Simulate barrier entry scan ---"
BARRIER_CODE="BARRIER-$FACILITY_ID-ENTRY"
echo "Driver arrives at barrier: $BARRIER_CODE"
echo "Driver shows QR code: $QR_PAYLOAD"

BARRIER_RESULT=$(curl -s -X POST $BASE_URL/api/lockbox/barrier/validate/ \
  -H "Content-Type: application/json" \
  -d "{\"qr_code\": \"$QR_PAYLOAD\", \"device_code\": \"$BARRIER_CODE\"}")

echo -e "\nBarrier Response:"
echo "$BARRIER_RESULT" | jq .

IS_VALID=$(echo "$BARRIER_RESULT" | jq -r '.valid')
ACTION=$(echo "$BARRIER_RESULT" | jq -r '.action // "none"')

if [[ "$IS_VALID" == "true" && "$ACTION" == "open_barrier" ]]; then
    echo -e "\n✅ SUCCESS: Barrier OPENED!"
    echo "   Facility: $(echo "$BARRIER_RESULT" | jq -r '.facility')"
    echo "   Duration: $(echo "$BARRIER_RESULT" | jq -r '.duration')"
    echo "   Spots Available: $(echo "$BARRIER_RESULT" | jq -r '.spots_available')"
else
    echo -e "\n❌ FAILED: Barrier DENIED access"
    echo "   Error: $(echo "$BARRIER_RESULT" | jq -r '.error // "Unknown error"')"
    exit 1
fi

# Step 6: Check booking status
echo -e "\n--- STEP 6: Verify booking status ---"
MY_BOOKINGS=$(curl -s -H "Authorization: Token $TOKEN" \
  $BASE_URL/api/mobile/bookings/me/)

echo "Current bookings:"
echo "$MY_BOOKINGS" | jq -r '.[] | "  • \(.facility_name) - Spot \(.spot_code) - Status: \(.status)"'

echo -e "\n============================================================"
echo "✅ EMPTY PARKING LOT WORKFLOW COMPLETE!"
echo "============================================================"
echo ""
echo "📝 Summary:"
echo "  1. ✅ Found empty parking lots"
echo "  2. ✅ Booked instantly (no approval)"
echo "  3. ✅ Generated QR code"
echo "  4. ✅ Validated at barrier"
echo "  5. ✅ Barrier opened automatically"
echo ""
echo "🎯 Result: Empty lot workflow is FULLY FUNCTIONAL!"
echo ""
