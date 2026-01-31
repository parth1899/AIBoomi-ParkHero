# 📘 ParkHero API Documentation

Comprehensive guide to ParkHero backend endpoints for testing and integration.

**Base URL:** `http://localhost:8001` (Development)

**Demo Credentials:**
- Driver: `demo` / `demo123`
- Homeowner: `homeowner_demo` / `demo123`
- Lot Owner: `lotowner_demo` / `demo123`

---

## 🔐 Authentication

All protected endpoints require a Token Authorization header.

**Header:** `Authorization: Token <your_token>`

### 1. Get Auth Token (Login)
*   **Endpoints:** 
    - `POST /api/auth/token/` (primary)
    - `POST /api/auth/login/` (alias)
*   **Access:** Public
*   **Body:**
    ```json
    {
        "username": "demo",
        "password": "demo123"
    }
    ```
*   **Response:**
    ```json
    { "token": "9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4c" }
    ```
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8001/api/auth/token/ \
         -H "Content-Type: application/json" \
         -d '{"username": "demo", "password": "demo123"}'
    ```
*   **Note:** Both endpoints are identical; `/api/auth/login/` is provided as an alias for convenience.

---

## 🗺️ MOBILE API (Frontier) - Consumer Facing

*Aggregated endpoints for the mobile application.*

### 2. List All Facilities
*   **Endpoint:** `GET /api/mobile/facilities/`
*   **Access:** Public
*   **Query Params:**
    - `type` - Filter by onboarding type (`p2p`, `small`, `enterprise`)
    - `facility_type` - Filter by facility type (`mall`, `lot`, `office`)
*   **Response Fields:**
    - `id` - Facility ID
    - `name` - Facility name
    - `type` - Facility type (mall/lot/office)
    - `onboarding_type` - Business model (p2p/small/enterprise)
    - `confidence` - Trust score (0-100)
    - `available_spots` - Current availability count
    - `price` - Hourly rate (₹)
    - `owner_name` - Owner's name (for P2P)
    - `requires_approval` - Boolean (true for P2P)
    - `badges` - Status badges array
*   **Curl - All Facilities:**
    ```bash
    curl http://localhost:8001/api/mobile/facilities/
    ```
*   **Curl - P2P Only:**
    ```bash
    curl "http://localhost:8001/api/mobile/facilities/?type=p2p"
    ```
*   **Curl - Small Business Lots:**
    ```bash
    curl "http://localhost:8001/api/mobile/facilities/?type=small"
    ```
*   **Curl - Malls Only:**
    ```bash
    curl "http://localhost:8001/api/mobile/facilities/?facility_type=mall"
    ```

### 3. Get Facility Details
*   **Endpoint:** `GET /api/mobile/facilities/{id}/`
*   **Access:** Public
*   **Response Fields:** (All from list + additional)
    - `address` - Full address
    - `hourly_rate` - Exact hourly rate (₹)
    - `daily_rate` - Exact daily rate (₹)
    - `floors` - Array of floor objects with spot counts
*   **Curl:**
    ```bash
    curl http://localhost:8001/api/mobile/facilities/42/
    ```

### 4. Get Floor Map with Spot Overlay
*   **Endpoint:** `GET /api/mobile/floors/{id}/map/`
*   **Access:** Public
*   **Response:**
    ```json
    {
        "id": 99,
        "label": "B2",
        "facility_name": "Phoenix Market City",
        "floorplan_image": "/media/floorplans/phoenix_b2.png",
        "spots": [
            {
                "id": 1,
                "code": "B2-A01",
                "x": 25.5,
                "y": 30.2,
                "status": "available"
            }
        ]
    }
    ```
*   **Curl:**
    ```bash
    curl http://localhost:8001/api/mobile/floors/99/map/
    ```

### 5. Create Booking
*   **Endpoint:** `POST /api/mobile/bookings/`
*   **Access:** Authenticated (Driver)
*   **Body:**
    ```json
    {
        "facility_id": 42,
        "duration_hours": 2.0
    }
    ```
*   **Response:**
    ```json
    {
        "id": 123,
        "spot_code": "H-1",
        "floor": "Driveway",
        "facility_name": "Aundh Residential - Sharma",
        "start_time": "2026-02-01T14:30:00Z",
        "end_time": "2026-02-01T16:30:00Z",
        "status": "pending_approval",
        "access_code": "ABC123",
        "requires_approval": true,
        "host_name": "Rajesh Sharma",
        "rejection_reason": null
    }
    ```
*   **Curl - Instant Booking (Enterprise/Small):**
    ```bash
    curl -X POST http://localhost:8001/api/mobile/bookings/ \
         -H "Authorization: Token <YOUR_TOKEN>" \
         -H "Content-Type: application/json" \
         -d '{"facility_id": 88, "duration_hours": 2.0}'
    ```
*   **Curl - P2P Booking (Requires Approval):**
    ```bash
    curl -X POST http://localhost:8001/api/mobile/bookings/ \
         -H "Authorization: Token <DRIVER_TOKEN>" \
         -H "Content-Type: application/json" \
         -d '{"facility_id": 42, "duration_hours": 2.0}'
    ```

### 6. Get My Bookings
*   **Endpoint:** `GET /api/mobile/bookings/me/`
*   **Access:** Authenticated
*   **Response:** Array of booking objects (same format as create)
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" \
         http://localhost:8001/api/mobile/bookings/me/
    ```

### 7. Validate Access Code (Mobile)
*   **Endpoint:** `POST /api/mobile/access/validate/`
*   **Access:** Public
*   **Body:**
    ```json
    {
        "access_code": "ABC123"
    }
    ```
*   **Response:**
    ```json
    {
        "valid": true,
        "booking_id": 123,
        "facility": "Aundh Residential - Sharma",
        "spot": "H-1"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8001/api/mobile/access/validate/ \
         -H "Content-Type: application/json" \
         -d '{"access_code": "ABC123"}'
    ```

---

## 🏠 HOST MANAGEMENT API (P2P Owners)

*Endpoints for facility owners to manage their P2P listings and approve/reject bookings.*

### 8. Get My Listings
*   **Endpoint:** `GET /api/atlas/facilities/my-listings/`
*   **Access:** Authenticated (Facility Owner)
*   **Response:** Array of facilities owned by current user
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <HOMEOWNER_TOKEN>" \
         http://localhost:8001/api/atlas/facilities/my-listings/
    ```

### 9. Get Incoming Booking Requests
*   **Endpoint:** `GET /api/atlas/facilities/incoming-bookings/`
*   **Access:** Authenticated (Facility Owner)
*   **Query Params:**
    - `facility_id` - Filter by specific facility
*   **Response:**
    ```json
    [
        {
            "id": 123,
            "status": "pending_approval",
            "user_name": "demo",
            "user_first_name": "Demo",
            "user_last_name": "User",
            "user_email": "demo@parkhero.com",
            "facility_name": "Aundh Residential - Sharma",
            "spot_code": "H-1",
            "floor_label": "Driveway",
            "start_time": "2026-02-01T14:30:00Z",
            "end_time": "2026-02-01T16:30:00Z",
            "access_code": "ABC123",
            "created_at": "2026-02-01T14:25:00Z"
        }
    ]
    ```
*   **Curl - All Incoming:**
    ```bash
    curl -H "Authorization: Token <HOMEOWNER_TOKEN>" \
         http://localhost:8001/api/atlas/facilities/incoming-bookings/
    ```
*   **Curl - Specific Facility:**
    ```bash
    curl -H "Authorization: Token <HOMEOWNER_TOKEN>" \
         "http://localhost:8001/api/atlas/facilities/incoming-bookings/?facility_id=42"
    ```

---

## 🎫 BOOKING MANAGEMENT API (ORBIT)

*Endpoints for managing bookings - drivers and hosts.*

### 10. List All Bookings (Admin/Staff)
*   **Endpoint:** `GET /api/orbit/bookings/`
*   **Access:** Authenticated (Own bookings only, or Staff for all)
*   **Query Params:**
    - `status` - Filter by status (pending_approval, reserved, active, completed, cancelled, rejected)
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" \
         http://localhost:8000/api/orbit/bookings/
    ```

### 11. Get Booking Details
*   **Endpoint:** `GET /api/orbit/bookings/{id}/`
*   **Access:** Authenticated (Owner or Staff)
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" \
         http://localhost:8001/api/orbit/bookings/123/
    ```

### 12. Approve Booking (Host Only)
*   **Endpoint:** `POST /api/orbit/bookings/{id}/approve/`
*   **Access:** Authenticated (Facility Owner)
*   **Body:** None required
*   **Response:**
    ```json
    {
        "id": 123,
        "status": "reserved",
        "access_code": "ABC123",
        "facility_name": "Aundh Residential - Sharma",
        "spot_code": "H-1"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST \
         -H "Authorization: Token <HOMEOWNER_TOKEN>" \
         http://localhost:8001/api/orbit/bookings/123/approve/
    ```

### 13. Reject Booking (Host Only)
*   **Endpoint:** `POST /api/orbit/bookings/{id}/reject/`
*   **Access:** Authenticated (Facility Owner)
*   **Body:**
    ```json
    {
        "reason": "Driveway occupied by family vehicle"
    }
    ```
*   **Response:**
    ```json
    {
        "id": 123,
        "status": "rejected",
        "rejection_reason": "Driveway occupied by family vehicle",
        "facility_name": "Aundh Residential - Sharma"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST \
         -H "Authorization: Token <HOMEOWNER_TOKEN>" \
         -H "Content-Type: application/json" \
         -d '{"reason": "Driveway occupied by family vehicle"}' \
         http://localhost:8001/api/orbit/bookings/123/reject/
    ```

### 14. Cancel Booking (Driver)
*   **Endpoint:** `POST /api/orbit/bookings/{id}/cancel/`
*   **Access:** Authenticated (Booking Owner or Staff)
*   **Curl:**
    ```bash
    curl -X POST \
         -H "Authorization: Token <DRIVER_TOKEN>" \
         http://localhost:8001/api/orbit/bookings/123/cancel/
    ```

### 15. Complete Booking (Staff Only)
*   **Endpoint:** `POST /api/orbit/bookings/{id}/complete/`
*   **Access:** Staff Only
*   **Curl:**
    ```bash
    curl -X POST \
         -H "Authorization: Token <STAFF_TOKEN>" \
         http://localhost:8001/api/orbit/bookings/123/complete/
    ```

### 16. Get User's Bookings
*   **Endpoint:** `GET /api/orbit/bookings/my-bookings/`
*   **Access:** Authenticated
*   **Query Params:**
    - `active_only` - Boolean (true/false)
*   **Curl - All Bookings:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" \
         http://localhost:8000/api/orbit/bookings/my-bookings/
    ```
*   **Curl - Active Only:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" \
         "http://localhost:8000/api/orbit/bookings/my-bookings/?active_only=true"
    ```

---

## 🗺️ ATLAS API - Inventory & Facility Management

*Internal APIs for facility, floor, spot, and device management.*

### 17. List Facilities
*   **Endpoint:** `GET /api/atlas/facilities/`
*   **Access:** Public (Read) / Admin (Write)
*   **Note:** Admins can also POST (create), PUT/PATCH (update), DELETE facilities. Only GET endpoints documented here for MVP.
*   **Curl:**
    ```bash
    curl http://localhost:8000/api/atlas/facilities/
    ```

### 18. Get Facility Stats
*   **Endpoint:** `GET /api/atlas/facilities/{id}/stats/`
*   **Access:** Public
*   **Response:**
    ```json
    {
        "total_spots": 120,
        "available": 87,
        "occupied": 28,
        "reserved": 5,
        "occupancy_rate": 27.5
    }
    ```
*   **Curl:**
    ```bash
    curl http://localhost:8000/api/atlas/facilities/88/stats/
    ```

### 19. List Floors
*   **Endpoint:** `GET /api/atlas/floors/`
*   **Access:** Public
*   **Query Params:**
    - `facility` - Filter by facility ID
*   **Curl:**
    ```bash
    curl "http://localhost:8000/api/atlas/floors/?facility=88"
    ```

### 20. List Parking Spots
*   **Endpoint:** `GET /api/atlas/spots/`
*   **Access:** Public
*   **Query Params:**
    - `floor` - Filter by floor ID
    - `facility` - Filter by facility ID
    - `status` - Filter by status (available, occupied, reserved, blocked)
*   **Curl - All Spots:**
    ```bash
    curl http://localhost:8000/api/atlas/spots/
    ```
*   **Curl - Available Spots in Facility:**
    ```bash
    curl "http://localhost:8000/api/atlas/spots/?facility=88&status=available"
    ```

### 21. Update Spot Status (Admin)
*   **Endpoint:** `POST /api/atlas/spots/{id}/update-status/`
*   **Access:** Admin
*   **Body:**
    ```json
    {
        "status": "occupied"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST \
         -H "Authorization: Token <ADMIN_TOKEN>" \
         -H "Content-Type: application/json" \
         -d '{"status": "occupied"}' \
         http://localhost:8000/api/atlas/spots/123/update-status/
    ```

### 22. List Devices
*   **Endpoint:** `GET /api/atlas/devices/`
*   **Access:** Admin
*   **Response:** List of sensors and barriers
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <ADMIN_TOKEN>" \
         http://localhost:8000/api/atlas/devices/
    ```
---

## 🔐 LOCKBOX API - Access Control & Verification

*Endpoints for physical access control hardware (Barriers/Sensors) and QR code generation.*

### 23. Get QR Code for Booking
*   **Endpoint:** `GET /api/lockbox/qr/{booking_id}/`
*   **Access:** Authenticated (Booking Owner or Staff)
*   **Response:**
    ```json
    {
        "booking_id": 123,
        "qr_payload": "PARKHERO-ABC123-123",
        "qr_image_base64": "iVBORw0KGgoAAAANSUhEUg...",
        "access_code": "ABC123",
        "facility": "Aundh Residential - Sharma",
        "spot": "H-1"
    }
    ```
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" \
         http://localhost:8000/api/lockbox/qr/123/
    ```

### 24. Validate Access Code
*   **Endpoint:** `POST /api/lockbox/validate/`
*   **Access:** Public (Used by IoT devices)
*   **Body:**
    ```json
    {
        "access_code": "ABC123"
    }
    ```
*   **Response:**
    ```json
    {
        "valid": true,
        "booking_id": 123,
        "facility": "Aundh Residential - Sharma",
        "spot": "H-1",
        "status": "reserved"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8000/api/lockbox/validate/ \
         -H "Content-Type: application/json" \
         -d '{"access_code": "ABC123"}'
    ```

### 25. Barrier Entry Validation (QR Scan)
*   **Endpoint:** `POST /api/lockbox/barrier/validate/`
*   **Access:** Public (Used by Barrier Hardware)
*   **Body:**
    ```json
    {
        "qr_code": "PARKHERO-ABC123-123",
        "device_code": "BARRIER-42-ENTRY"
    }
    ```
*   **Response - Valid:**
    ```json
    {
        "valid": true,
        "action": "open_barrier",
        "facility": "Aundh Residential - Sharma",
        "spot": "H-1",
        "booking_id": 123,
        "spots_available": 1
    }
    ```
*   **Response - Invalid:**
    ```json
    {
        "valid": false,
        "error": "Invalid access code"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8000/api/lockbox/barrier/validate/ \
         -H "Content-Type: application/json" \
         -d '{"qr_code": "PARKHERO-ABC123-123", "device_code": "BARRIER-42-ENTRY"}'
    ```

---

## 🧪 COMPLETE TESTING WORKFLOWS

### Workflow 1: Instant Booking (Small Business Lot)

```bash
# Step 1: Login as driver
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')

# Step 2: Find small business lots
curl -s "http://localhost:8000/api/mobile/facilities/?type=small" | jq .

# Step 3: Book a spot (instant - no approval needed)
curl -X POST http://localhost:8000/api/mobile/bookings/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 36, "duration_hours": 2.0}' | jq .

# Step 4: Get booking QR code
curl -H "Authorization: Token $TOKEN" \
  http://localhost:8000/api/lockbox/qr/1/ | jq .

# Step 5: Simulate barrier scan
curl -X POST http://localhost:8000/api/lockbox/barrier/validate/ \
  -H "Content-Type: application/json" \
  -d '{"qr_code": "PARKHERO-ABC123-1", "device_code": "BARRIER-36-ENTRY"}' | jq .
```

### Workflow 2: P2P Booking with Approval

```bash
# Step 1: Login as driver
DRIVER_TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')

# Step 2: Discover P2P facilities
curl -s "http://localhost:8000/api/mobile/facilities/?type=p2p" | jq .

# Step 3: Create P2P booking (status: pending_approval)
BOOKING=$(curl -s -X POST http://localhost:8000/api/mobile/bookings/ \
  -H "Authorization: Token $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 42, "duration_hours": 2.0}')

echo $BOOKING | jq .
BOOKING_ID=$(echo $BOOKING | jq -r '.id')

# Step 4: Login as homeowner
HOMEOWNER_TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "homeowner_demo", "password": "demo123"}' | jq -r '.token')

# Step 5: Check incoming booking requests
curl -H "Authorization: Token $HOMEOWNER_TOKEN" \
  http://localhost:8000/api/atlas/facilities/incoming-bookings/ | jq .

# Step 6: Approve the booking
curl -X POST \
  -H "Authorization: Token $HOMEOWNER_TOKEN" \
  http://localhost:8000/api/orbit/bookings/$BOOKING_ID/approve/ | jq .

# Step 7: Driver checks updated booking
curl -H "Authorization: Token $DRIVER_TOKEN" \
  http://localhost:8000/api/mobile/bookings/me/ | jq .

# Step 8: Get QR code for entry
curl -H "Authorization: Token $DRIVER_TOKEN" \
  http://localhost:8000/api/lockbox/qr/$BOOKING_ID/ | jq .
```

### Workflow 3: Rejection Flow

```bash
# Step 1: Login as driver
DRIVER_TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')

# Step 2: Create another P2P booking
BOOKING=$(curl -s -X POST http://localhost:8000/api/mobile/bookings/ \
  -H "Authorization: Token $DRIVER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 42, "duration_hours": 3.0}')

BOOKING_ID=$(echo $BOOKING | jq -r '.id')

# Step 3: Login as homeowner
HOMEOWNER_TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "homeowner_demo", "password": "demo123"}' | jq -r '.token')

# Step 4: Reject the booking with reason
curl -X POST \
  -H "Authorization: Token $HOMEOWNER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reason": "Driveway occupied by family vehicle"}' \
  http://localhost:8000/api/orbit/bookings/$BOOKING_ID/reject/ | jq .

# Step 5: Driver sees rejection
curl -H "Authorization: Token $DRIVER_TOKEN" \
  http://localhost:8000/api/orbit/bookings/$BOOKING_ID/ | jq .
```

### Workflow 4: Mall Parking with Floor Maps

```bash
# Step 1: Get auth token
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username": "demo", "password": "demo123"}' | jq -r '.token')

# Step 2: Find malls
curl -s "http://localhost:8000/api/mobile/facilities/?facility_type=mall" | jq .

# Step 3: Get facility details with floors
curl -s http://localhost:8000/api/mobile/facilities/88/ | jq .

# Step 4: View floor map with spot overlay
curl -s http://localhost:8000/api/mobile/floors/99/map/ | jq .

# Step 5: Book a spot
curl -X POST http://localhost:8000/api/mobile/bookings/ \
  -H "Authorization: Token $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"facility_id": 88, "duration_hours": 2.0}' | jq .
```

---

## 📊 API Summary by Category

### Authentication (1)
- `POST /api/auth/token/` - Login

### Mobile/Consumer (6)
- `GET /api/mobile/facilities/` - List facilities (with filters)
- `GET /api/mobile/facilities/{id}/` - Facility details
- `GET /api/mobile/floors/{id}/map/` - Floor map with spots
- `POST /api/mobile/bookings/` - Create booking
- `GET /api/mobile/bookings/me/` - My bookings
- `POST /api/mobile/access/validate/` - Validate access code

### Host Management (2)
- `GET /api/atlas/facilities/my-listings/` - My P2P listings
- `GET /api/atlas/facilities/incoming-bookings/` - Pending requests

### Booking Operations (7)
- `GET /api/orbit/bookings/` - List bookings
- `GET /api/orbit/bookings/{id}/` - Booking details
- `POST /api/orbit/bookings/{id}/approve/` - Approve (host)
- `POST /api/orbit/bookings/{id}/reject/` - Reject (host)
- `POST /api/orbit/bookings/{id}/cancel/` - Cancel (driver)
- `POST /api/orbit/bookings/{id}/complete/` - Complete (staff)
- `GET /api/orbit/bookings/my-bookings/` - User's bookings

### Inventory Management (6)
- `GET /api/atlas/facilities/` - List facilities
- `GET /api/atlas/facilities/{id}/stats/` - Facility stats
- `GET /api/atlas/floors/` - List floors
- `GET /api/atlas/spots/` - List spots (with filters)
- `POST /api/atlas/spots/{id}/update-status/` - Update spot status
- `GET /api/atlas/devices/` - List IoT devices

### Access Control (3)
- `GET /api/lockbox/qr/{id}/` - Get QR code
- `POST /api/lockbox/validate/` - Validate access code
- `POST /api/lockbox/barrier/validate/` - Barrier QR scan

**Total Endpoints: 25**

---

## 🎯 Quick Reference by User Role

### Driver/Consumer
- Login → Discover facilities → Book → Get QR → Enter
- Filter P2P vs instant booking
- View booking status (pending/approved/rejected)
- View floor maps for malls

### Homeowner/Host (P2P)
- Login → View listings → Check incoming requests → Approve/Reject
- See driver details before approval
- Provide rejection reason

### Lot Owner (Small Business)
- Instant bookings (no approval needed)
- Monitor via admin panel

### Admin/Staff
- Full access to all endpoints
- Manage facilities, spots, devices
- Override booking operations

---

## 🔒 Security Notes

1. **Authentication Required:**
   - All booking operations
   - Host management
   - Admin operations

2. **Public Access:**
   - Facility browsing
   - Floor maps
   - IoT validation endpoints (for hardware)

3. **Role-Based Access:**
   - Homeowners: Only their facilities' bookings
   - Drivers: Only their own bookings
   - Staff: All data

---

## 💡 Testing Tips

1. **Use `jq` for JSON formatting:**
   ```bash
   curl ... | jq .
   ```

2. **Save tokens as variables:**
   ```bash
   TOKEN=$(curl ... | jq -r '.token')
   ```

3. **Check response status:**
   ```bash
   curl -w "\nHTTP Status: %{http_code}\n" ...
   ```

4. **Test error cases:**
   - Invalid token
   - Wrong user (e.g., driver trying to approve)
   - Invalid facility/booking ID
   - Duplicate bookings

5. **Database Reset:**
   ```bash
   cd backend
   uv run python setup_initial_data.py
   ```
