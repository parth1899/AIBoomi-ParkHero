Perfect. Now we lock this into a **complete 24-hour build requirements document** — covering **every module/app in your codename architecture** — with strict scope control so you don’t overbuild.

No hardware.  
No sensors.  
No CV.  
No LiDAR.  
No real-time device telemetry.

Everything is **software-simulated but architecturally correct** so your pitch stays credible.

Think of this as your **feature freeze + build contract**.

---

# 🧭 PARKHERO — Complete 24-Hour Build Scope

```
PARKHERO/
├── ATLAS      → Source of Truth (parking inventory)
├── LOCKBOX    → Access & verification layer
├── ORBIT      → Booking & availability engine
├── SIGNAL     → Confidence + status indicator
├── FRONTIER   → User-facing app
├── TOWER      → Admin / onboarding panel

ENTERPRISE LAYER
├── FLOORPLAN VIEW
├── SPOT MAP + STATUS
├── INSTALLER ONBOARDING FLOW
```

Below = **exact requirements per module**.

---

# 🗺️ ATLAS — Source of Truth (Inventory Service)

**Purpose:** Central data authority for all parking entities.

This is your DB + CRUD APIs.

---

## ✅ Must Support

### Facilities

- Create facility
    
- Fields:
    
    - id
        
    - name
        
    - type (mall / office / small lot)
        
    - address
        
    - confidence_score
        
    - onboarding_type (enterprise / small)
        

---

### Floors

- Create floor under facility
    
- Fields:
    
    - id
        
    - facility_id
        
    - label (B1, P2, etc.)
        
    - floorplan_image_url
        

---

### Parking Spots

- Create spot
    
- Fields:
    
    - id
        
    - floor_id
        
    - code
        
    - x, y (map coordinates)
        
    - status (available / occupied / reserved / blocked)
        
    - verified (bool)
        
    - distance_from_entry (number)
        

---

### Devices (Simulated)

- Create device
    
- Fields:
    
    - id
        
    - device_code
        
    - bound_spot_id
        

(No hardware calls — just stored data.)

---

## ❌ Do NOT Build

- Versioning
    
- Audit logs
    
- Bulk import tools
    

---

# 🔐 LOCKBOX — Access & Verification Layer

**Purpose:** Validate that a booking is legitimate and active.

Purely logical — no hardware integration.

---

## ✅ Must Support

### Booking Validation API

Input:

- booking_id OR access_code
    

Returns:

- valid / invalid
    
- spot
    
- time window
    
- status
    

---

### Access Code Generation

When booking created:

- generate short code (6–8 chars)
    
- store with booking
    

---

### QR Code Generation (UI-level)

- Generate QR from booking_id
    
- Display in driver app
    

(No scanners needed.)

---

## ❌ Do NOT Build

- Gate controllers
    
- Barrier APIs
    
- NFC / BLE
    

---

# 🛰️ ORBIT — Booking & Availability Engine

**Purpose:** Deterministic booking + spot locking.

Most important backend logic.

---

## ✅ Must Support

### Create Booking

Input:

- facility_id
    
- duration
    

Logic:

- find available spot
    
- order by distance_from_entry
    
- assign first free
    
- mark spot = reserved
    
- create booking
    

---

### Prevent Double Booking

- Spot cannot be reserved twice in overlapping window
    

Simple rule:

```
if spot.status != available → skip
```

Time conflict logic can be basic.

---

### Booking Status Updates

Statuses:

- reserved
    
- active
    
- completed
    
- cancelled
    

Manual transition allowed via admin.

---

### Release Spot

When:

- booking completed  
    → spot → available
    

Manual trigger acceptable.

---

## ❌ Do NOT Build

- Waitlists
    
- Optimization engines
    
- Dynamic pricing
    

---

# 📡 SIGNAL — Confidence + Status Layer

**Purpose:** Trust indicators for users + judges.

This is psychological + visual.

---

## ✅ Must Support

### Confidence Score Rules (Static)

What you implement:

```
enterprise facility → 95
small lot → 80
verified spot → +5
```

Computed once — stored or calculated.

---

### Status Badges (API + UI)

Return:

- Verified Location
    
- High Confidence
    
- Installer Verified Spot
    

Displayed in:

- Driver app
    
- Admin app
    

---

## ❌ Do NOT Build

- ML confidence models
    
- Sensor reliability scoring
    

---

# 🚗 FRONTIER — Driver App

**Purpose:** User books guaranteed parking + views commercial floor maps.

Web app is enough.

---

## ✅ Must Support

### Location List

- Show facilities
    
- Show confidence
    
- Show price
    
- Show available spots count
    

---

### Location Detail

- Facility info
    
- Floors list
    
- Button → View Floor Map
    
- Button → Reserve Spot
    

---

### FLOORPLAN VIEW (Enterprise Layer Feature)

- Floor selector
    
- Show floorplan image
    
- Overlay spots
    

---

### SPOT MAP + STATUS

Spot markers show:

- green = available
    
- red = occupied
    
- yellow = reserved
    

Clickable optional.

---

### Booking Flow

- Reserve
    
- Auto-assign spot
    
- Create booking
    

---

### Booking Confirmation

Show:

- spot code
    
- floor
    
- time
    
- QR code
    
- access code
    
- “Guaranteed” label
    

---

### My Bookings

- Active
    
- Past
    

---

## ❌ Do NOT Build

- Payments
    
- Turn-by-turn navigation
    
- Push notifications
    

---

# 🏢 TOWER — Admin / Onboarding Panel

**Purpose:** Operational control + onboarding proof.

Same web app with admin role.

---

## ✅ Must Support

### Facility Creation

- Create facility
    
- Set type + confidence
    

---

### Floor Creation

- Add floor
    
- Upload floorplan image
    

---

### Spot Management

- Add spot
    
- Edit spot
    
- Delete spot
    
- Set coordinates
    
- Set distance_from_entry
    

---

### Spot Status Toggle

- available
    
- occupied
    
- blocked
    

Simulates sensors.

---

### Booking Monitor

- View bookings list
    
- Cancel booking
    
- Release spot
    

---

## ❌ Do NOT Build

- Analytics
    
- Billing
    
- Staff permissions
    

---

# 🏗️ ENTERPRISE LAYER — Installer Onboarding Flow

**Purpose:** Show controlled onboarding model.

Inside Admin as “Installer Mode”.

---

## ✅ Must Support

### INSTALLER ONBOARDING FLOW

Stepper UI:

**Step 1 — Create Facility**  
**Step 2 — Add Floor**  
**Step 3 — Upload Floorplan**  
**Step 4 — Place Spots on Map**  
**Step 5 — Verify Spots**

---

### Spot Placement Tool

- Click map → create marker
    
- Enter spot code
    

---

### Device Binding (Simulated)

- Enter fake device ID
    
- Bind to spot
    

---

### Spot Verification

- Toggle verified = true
    

---

## ❌ Do NOT Build

- Sensor pairing
    
- Calibration math
    
- Field diagnostics
    

---

# 🧠 Final Scope Reality Check

If you build ONLY this:

✅ Driver booking + guarantee  
✅ Commercial floor map UX  
✅ Spot-level visibility  
✅ Installer onboarding workflow  
✅ Admin control panel  
✅ Deterministic booking engine  
✅ Access validation layer  
✅ Confidence system

You will look like a **deployable enterprise parking platform**, not a student demo.

---

If you want next, I can give you:

- exact API route list
    
- DB schema file
    
- React component tree
    
- 24-hour sprint assignment per teammate
    
- demo script that hits every module cleanly
    

Say **“build plan”** and we go straight into execution mode.