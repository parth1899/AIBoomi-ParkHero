# ParkHero P2P Marketplace - Implementation Complete ✅

## Overview

The P2P (peer-to-peer) marketplace functionality has been fully implemented, allowing homeowners to list their parking spaces and requiring host approval for bookings.

## What's Been Implemented

### 1. Data Model Updates

#### Facility Model (`apps/atlas/models.py`)
- **New Fields**:
  - `owner` (ForeignKey to User) - Links facility to the owner
  - `hourly_rate` (DecimalField) - Hourly parking rate in INR
  - `daily_rate` (DecimalField) - Daily parking rate in INR
  - `onboarding_type` - Added `'p2p'` choice for peer-to-peer facilities

#### Booking Model (`apps/orbit/models.py`)
- **New Fields**:
  - `host_user` (ForeignKey to User) - The facility owner who needs to approve
  - `rejection_reason` (TextField) - Reason if booking is rejected
- **New Statuses**:
  - `'pending_approval'` - Waiting for host approval
  - `'rejected'` - Booking rejected by host

### 2. Booking Workflow (`apps/orbit/services.py`)

#### Automatic Status Detection
- **P2P facilities** (`onboarding_type='p2p'`):
  - Initial status: `'pending_approval'`
  - `host_user` automatically set to facility owner
  - Spot reserved but not confirmed until approved

- **Other facilities** (`enterprise`, `small`):
  - Initial status: `'reserved'` (instant booking)
  - No approval required

#### New Services
- **`approve_booking(booking_id, approver_user)`**
  - Validates approver is facility owner
  - Changes status from `pending_approval` → `reserved`
  - Returns updated booking

- **`reject_booking(booking_id, approver_user, reason)`**
  - Validates approver is facility owner
  - Changes status to `rejected`
  - Releases the spot
  - Records rejection reason

### 3. Host Management Endpoints (`apps/atlas/views.py`)

#### `GET /api/atlas/facilities/my-listings/`
- Returns facilities owned by current user
- For hosts to see their P2P listings

#### `GET /api/atlas/facilities/incoming-bookings/`
- Returns pending approval requests
- Filtered to facilities owned by current user
- Query params: `?facility_id=X` to filter by specific facility
- Shows full booking details including user info (name, email)

### 4. Approval Endpoints (`apps/orbit/views.py`)

#### `POST /api/orbit/bookings/{id}/approve/`
- Approves a pending booking
- Only facility owner can approve
- Returns updated booking with `reserved` status

#### `POST /api/orbit/bookings/{id}/reject/`
- Rejects a pending booking
- Body: `{"reason": "explanation"}`
- Only facility owner can reject
- Returns updated booking with `rejected` status and reason

### 5. Mobile API Updates (`apps/frontier_api/`)

#### Facility List/Detail
- **New Fields**:
  - `requires_approval` - Boolean indicating if P2P
  - `owner_name` - Name of facility owner
  - `hourly_rate` / `daily_rate` - Actual pricing

#### Filtering
- **`GET /api/mobile/facilities/?type=p2p`** - Get only P2P facilities
- **`GET /api/mobile/facilities/?type=small`** - Get small business lots
- **`GET /api/mobile/facilities/?type=enterprise`** - Get enterprise facilities
- **`GET /api/mobile/facilities/?facility_type=mall`** - Filter by facility type

#### Booking Response
- **New Fields**:
  - `requires_approval` - If waiting for host
  - `host_name` - Host who needs to approve
  - `rejection_reason` - If rejected

### 6. Test Data (`setup_initial_data.py`)

#### Demo Users Created
1. **`homeowner_demo`** / `demo123`
   - Owns 6 P2P homeowner facilities
   - First name: Rajesh, Last name: Sharma

2. **`lotowner_demo`** / `demo123`
   - Owns 5 independent parking lots
   - First name: Amit, Last name: Patel

3. **`demo`** / `demo123` (already existed)
   - Regular driver user for testing bookings

#### P2P Facilities (6 total)
All with `onboarding_type='p2p'`:
- Aundh Residential Parking - Sharma (2 spots, ₹50/hr)
- Koregaon Park Home Parking - Patel (1 spot, ₹60/hr)
- Baner Society Parking - Deshmukh (2 spots, ₹45/hr)
- Kalyani Nagar Private Parking - Joshi (3 spots, ₹55/hr)
- Wakad Home Parking - Kulkarni (1 spot, ₹40/hr)
- Hinjewadi Residential - Mehta (2 spots, ₹50/hr)

#### Small Business Lots (5 total)
All with `onboarding_type='small'`:
- Koregaon Park Quick Park (25 spots, ₹30/hr)
- FC Road Parking Zone (30 spots, ₹40/hr)
- Deccan Gymkhana Lot (40 spots, ₹35/hr)
- Viman Nagar Plaza Parking (35 spots, ₹45/hr)
- Kothrud Market Parking (28 spots, ₹30/hr)

## API Workflow Examples

### Driver Perspective

#### 1. Discover P2P Facilities
```bash
GET /api/mobile/facilities/?type=p2p
Authorization: Token <driver_token>
```

Response includes:
- `requires_approval: true`
- `owner_name: "Rajesh Sharma"`
- `hourly_rate: 50.00`

#### 2. Create Booking
```bash
POST /api/mobile/bookings/
Authorization: Token <driver_token>
Body: {
  "facility_id": 42,
  "duration": 2.0
}
```

Response:
```json
{
  "id": 123,
  "status": "pending_approval",
  "requires_approval": true,
  "host_name": "Rajesh Sharma",
  "facility_name": "Aundh Residential Parking - Sharma",
  "spot_code": "H-1",
  "access_code": "ABC123"
}
```

#### 3. Check Booking Status
```bash
GET /api/mobile/bookings/me/
Authorization: Token <driver_token>
```

### Homeowner Perspective

#### 1. View Your Listings
```bash
GET /api/atlas/facilities/my-listings/
Authorization: Token <homeowner_token>
```

#### 2. Check Pending Requests
```bash
GET /api/atlas/facilities/incoming-bookings/
Authorization: Token <homeowner_token>
```

Response includes driver details:
```json
[
  {
    "id": 123,
    "status": "pending_approval",
    "user_name": "demo",
    "user_first_name": "Demo",
    "user_last_name": "User",
    "user_email": "demo@parkhero.com",
    "facility_name": "Aundh Residential Parking - Sharma",
    "spot_code": "H-1",
    "start_time": "2026-01-31T18:00:00Z",
    "end_time": "2026-01-31T20:00:00Z"
  }
]
```

#### 3. Approve Booking
```bash
POST /api/orbit/bookings/123/approve/
Authorization: Token <homeowner_token>
```

Response:
```json
{
  "id": 123,
  "status": "reserved",
  "access_code": "ABC123",
  "user_name": "demo"
}
```

#### 4. Reject Booking
```bash
POST /api/orbit/bookings/123/reject/
Authorization: Token <homeowner_token>
Body: {
  "reason": "Driveway occupied by family vehicle"
}
```

Response:
```json
{
  "id": 123,
  "status": "rejected",
  "rejection_reason": "Driveway occupied by family vehicle"
}
```

## Database Schema Changes

### Migrations Created
1. **`atlas/migrations/0005_*`**
   - Added `owner`, `hourly_rate`, `daily_rate` to Facility
   - Updated `onboarding_type` choices to include `'p2p'`

2. **`orbit/migrations/0002_*`**
   - Added `host_user`, `rejection_reason` to Booking
   - Updated `status` choices to include `'pending_approval'` and `'rejected'`

## Testing

### Manual Testing Steps

1. **Start Server**
```bash
cd backend
uv run python manage.py runserver 8001
```

2. **Get Authentication Token (Driver)**
```bash
curl -X POST http://localhost:8001/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}'
```

3. **List P2P Facilities**
```bash
curl http://localhost:8001/api/mobile/facilities/?type=p2p \
  -H "Authorization: Token <your_token>"
```

4. **Create P2P Booking**
```bash
curl -X POST http://localhost:8001/api/mobile/bookings/ \
  -H "Authorization: Token <driver_token>" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 42, "duration": 2.0}'
```

5. **Login as Homeowner**
```bash
curl -X POST http://localhost:8001/api/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username": "homeowner_demo", "password": "demo123"}'
```

6. **Check Incoming Requests**
```bash
curl http://localhost:8001/api/atlas/facilities/incoming-bookings/ \
  -H "Authorization: Token <homeowner_token>"
```

7. **Approve Booking**
```bash
curl -X POST http://localhost:8001/api/orbit/bookings/123/approve/ \
  -H "Authorization: Token <homeowner_token>"
```

### Automated Test Script

Run `test_p2p_flow.py` to see complete workflow:
```bash
cd backend
python3 test_p2p_flow.py
```

This demonstrates:
- Driver discovering P2P facilities
- Creating booking with pending status
- Homeowner viewing incoming requests
- Approving booking
- Rejecting another booking

## Key Features

### ✅ Implemented
- [x] P2P onboarding type for homeowner facilities
- [x] Owner assignment to facilities
- [x] Pricing (hourly/daily rates) per facility
- [x] Pending approval workflow for P2P bookings
- [x] Instant booking for non-P2P facilities
- [x] Host approval endpoint with owner validation
- [x] Host rejection endpoint with reason
- [x] Host dashboard endpoints (my listings, incoming requests)
- [x] Mobile API filtering by onboarding type
- [x] Driver sees approval requirements and host name
- [x] Spot reservation during pending approval
- [x] Automatic spot release on rejection
- [x] Test data with realistic P2P homeowner scenarios

### 🎯 Business Logic
- **Shared Responsibility**: Both driver and homeowner must confirm
- **No Automatic Approval**: Homeowner control over their property
- **Transparent Pricing**: Rates visible before booking
- **User Information Sharing**: Homeowner sees driver details for trust

## Future Enhancements (Not in Scope)
- Payment processing integration
- Automated reminders for pending approvals
- Rating/review system for P2P hosts
- Host calendar/availability management
- Multi-spot selection for P2P
- Messaging between driver and host

## Summary

The P2P marketplace is **fully functional** and ready for testing. The implementation correctly separates:
- **P2P facilities** → Require host approval
- **Small business lots** → Instant booking
- **Enterprise malls** → Instant booking with sensors

All existing functionality remains intact while adding the approval workflow only where needed.
