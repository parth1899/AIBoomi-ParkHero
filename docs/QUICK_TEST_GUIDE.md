# 🚀 Quick Test Guide - ParkHero API

## Prerequisites

```bash
cd backend
uv run python manage.py runserver 8001
```

Server should be running at: `http://localhost:8001`

---

## 🎯 Essential Test Commands

### 1. Login & Get Token

```bash
# Driver
curl -X POST http://localhost:8001/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'

# Homeowner
curl -X POST http://localhost:8001/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "homeowner_demo", "password": "demo123"}'

# Lot Owner
curl -X POST http://localhost:8001/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "lotowner_demo", "password": "demo123"}'
```

**Save the token:** Replace `<TOKEN>` in commands below with actual token value.

---

## 🏠 Test P2P Marketplace (5 Steps)

### Step 1: Discover P2P Facilities
```bash
curl "http://localhost:8001/api/mobile/facilities/?type=p2p"
```

**Expected:** 6 homeowner facilities with `"requires_approval": true`

### Step 2: Create Booking (Driver)
```bash
curl -X POST http://localhost:8001/api/mobile/bookings/ \
  -H "Authorization: Token <DRIVER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 42, "duration": 2.0}'
```

**Expected:** Status `"pending_approval"`, has `host_name`

### Step 3: Check Incoming Requests (Homeowner)
```bash
curl -H "Authorization: Token <HOMEOWNER_TOKEN>" \
  http://localhost:8001/api/atlas/facilities/incoming-bookings/
```

**Expected:** Shows booking with driver's name and email

### Step 4: Approve Booking (Homeowner)
```bash
curl -X POST \
  -H "Authorization: Token <HOMEOWNER_TOKEN>" \
  http://localhost:8001/api/orbit/bookings/1/approve/
```

**Expected:** Status changes to `"reserved"`, access code available

### Step 5: Verify Approval (Driver)
```bash
curl -H "Authorization: Token <DRIVER_TOKEN>" \
  http://localhost:8001/api/mobile/bookings/me/
```

**Expected:** Booking now shows `"status": "reserved"`

---

## 🅿️ Test Instant Booking (Small Lots / Empty Lots)

**Note:** Empty parking lots use the same workflow as small business lots - instant booking with barrier access control.

### Step 1: Find Small Business Lots / Empty Lots
```bash
curl "http://localhost:8001/api/mobile/facilities/?type=small"
```

**Expected:** 5 parking lots with `"requires_approval": false`

### Step 2: Book Instantly
```bash
curl -X POST http://localhost:8001/api/mobile/bookings/ \
  -H "Authorization: Token <DRIVER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 36, "duration": 2.0}'
```

**Expected:** Status immediately `"reserved"` (no approval needed)

### Step 3: Get QR Code
```bash
curl -H "Authorization: Token <DRIVER_TOKEN>" \
  http://localhost:8001/api/lockbox/qr/2/
```

**Expected:** QR code payload and base64 image

### Step 4: Simulate Barrier Scan
```bash
curl -X POST http://localhost:8001/api/lockbox/barrier/validate/ \
  -H "Content-Type: application/json" \
  -d '{"qr_code": "PARKHERO-ABC123-2", "device_code": "BARRIER-36-ENTRY"}'
```

**Expected:** `"valid": true`, `"action": "open_barrier"`

---

## 🏬 Test Mall Parking

### Step 1: Find Malls
```bash
curl "http://localhost:8001/api/mobile/facilities/?facility_type=mall"
```

**Expected:** 5 commercial malls

### Step 2: Get Facility Details
```bash
curl http://localhost:8001/api/mobile/facilities/88/
```

**Expected:** Multiple floors with spot counts

### Step 3: View Floor Map
```bash
curl http://localhost:8001/api/mobile/floors/99/map/
```

**Expected:** Floor plan image URL + array of spots with coordinates

### Step 4: Book Mall Spot
```bash
curl -X POST http://localhost:8001/api/mobile/bookings/ \
  -H "Authorization: Token <DRIVER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 88, "duration": 2.0}'
```

**Expected:** Instant reservation, specific spot code (e.g., B2-A05)

---

## ❌ Test Rejection Flow

### Step 1: Create Booking
```bash
curl -X POST http://localhost:8001/api/mobile/bookings/ \
  -H "Authorization: Token <DRIVER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 42, "duration": 3.0}'
```

### Step 2: Reject with Reason (Homeowner)
```bash
curl -X POST \
  -H "Authorization: Token <HOMEOWNER_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Driveway already occupied"}' \
  http://localhost:8001/api/orbit/bookings/3/reject/
```

**Expected:** Status `"rejected"`, rejection reason saved

### Step 3: Driver Views Rejection
```bash
curl -H "Authorization: Token <DRIVER_TOKEN>" \
  http://localhost:8001/api/orbit/bookings/3/
```

**Expected:** Shows rejection reason

---

## 📊 Quick Verification Commands

### Check All Facilities
```bash
curl http://localhost:8001/api/mobile/facilities/ | jq 'length'
```
**Expected:** 46 facilities

### Check P2P Count
```bash
curl "http://localhost:8001/api/mobile/facilities/?type=p2p" | jq 'length'
```
**Expected:** 6

### Check Available Spots
```bash
curl http://localhost:8001/api/atlas/facilities/88/stats/
```
**Expected:** Breakdown of available/occupied/reserved

### My Active Bookings
```bash
curl -H "Authorization: Token <TOKEN>" \
  "http://localhost:8001/api/orbit/bookings/my_bookings/?active_only=true"
```

---

## 🐛 Common Issues & Solutions

### "Connection refused"
- **Cause:** Server not running
- **Fix:** `cd backend && uv run python manage.py runserver 8001`

### "Invalid token"
- **Cause:** Wrong or expired token
- **Fix:** Login again to get fresh token

### "You do not have permission"
- **Cause:** Using wrong user (e.g., driver trying to approve)
- **Fix:** Use homeowner token for approvals

### "No available spots"
- **Cause:** All spots booked
- **Fix:** Reset database `uv run python setup_initial_data.py`

### 404 Not Found
- **Cause:** Wrong endpoint or ID
- **Fix:** Check API_DOCUMENTATION.md for correct URLs

---

## 🔄 Reset Database

If you need fresh data:

```bash
cd backend
uv run python setup_initial_data.py
```

This recreates:
- 46 facilities
- 3,581 parking spots
- 3 demo users
- All devices and barriers

---

## 📝 Sample Test Sequence

```bash
# 1. Login
DRIVER=$(curl -s -X POST http://localhost:8001/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')

HOST=$(curl -s -X POST http://localhost:8001/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "homeowner_demo", "password": "demo123"}' | jq -r '.token')

# 2. Browse P2P
curl -s "http://localhost:8001/api/mobile/facilities/?type=p2p" | jq '.[0]'

# 3. Book
BOOKING=$(curl -s -X POST http://localhost:8001/api/mobile/bookings/ \
  -H "Authorization: Token $DRIVER" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 42, "duration": 2.0}' | jq -r '.id')

# 4. Check pending
curl -s -H "Authorization: Token $HOST" \
  http://localhost:8001/api/atlas/facilities/incoming-bookings/ | jq .

# 5. Approve
curl -s -X POST -H "Authorization: Token $HOST" \
  http://localhost:8001/api/orbit/bookings/$BOOKING/approve/ | jq .

# 6. Verify
curl -s -H "Authorization: Token $DRIVER" \
  http://localhost:8001/api/mobile/bookings/me/ | jq .

echo "✅ Complete P2P workflow tested successfully!"
```

---

## 📚 Full Documentation

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for complete endpoint reference.

## 🎯 Next: Empty Parking Lots

P2P marketplace is complete. Ready to implement empty parking lots with barrier access control.
