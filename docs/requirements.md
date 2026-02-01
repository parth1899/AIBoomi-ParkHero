Perfect — now we lock this down into a **24-hour build contract**.

No hardware.  
No sensors.  
No ML.  
No complex routing engines.  
No overengineering.

This is the **complete, realistic feature set per app** that:

- supports your ParkHero story
    
- supports commercial mall onboarding
    
- shows installer control
    
- shows floor visibility
    
- shows guaranteed booking
    
- can be built + debugged fast
    

Think of this as your **feature freeze doc**.

---

# 🧭 Overall System — What You Are Actually Building in 24 Hours

You are building:

> **A controlled-inventory parking reservation platform with commercial floor maps and installer onboarding tools — powered by admin-managed occupancy (not hardware).**

Everything below aligns with that.

---

# 🚗 APP 1 — Driver App (FRONTIER)

**Audience:** Drivers  
**Goal:** Reserve guaranteed parking + view floor layout + see spot status

Build as:

- Web app (React / Next.js)
    
- Mobile responsive
    

---

## ✅ Core Features — Must Build

### 1️⃣ Location Search / Browse

User can:

- View list of parking locations
    
- See:
    
    - name
        
    - type (Mall / Office / Lot)
        
    - distance (static or computed)
        
    - price
        
    - confidence badge
        

No advanced search filters.

---

### 2️⃣ Location Details Page

Show:

- Location name
    
- Address
    
- Type
    
- Pricing
    
- Confidence level
    
- Floors available
    
- Available spot count (computed)
    

Button:

> **View Parking Map**

---

### 3️⃣ Floorplan Viewer (Commercial Mode)

User can:

- Select floor (B1 / B2 / P1 etc.)
    
- View uploaded floorplan image
    
- See spots as colored dots
    

Spot colors:

- 🟢 Available
    
- 🔴 Occupied
    
- 🟡 Reserved
    

Implementation:

- Static image + coordinate overlays
    

No zoom engine required (basic zoom optional).

---

### 4️⃣ Spot Selection OR Auto Assign

Two options (pick one for speed):

**Option A (fastest):**

- User clicks “Reserve Spot”
    
- System auto-assigns nearest available spot
    

**Option B (nicer UX):**

- User clicks green spot dot → reserve
    

Either is fine.

---

### 5️⃣ Reserve Parking

Inputs:

- Start time (default now)
    
- Duration (1–3 hr dropdown)
    

System:

- locks one available spot
    
- creates booking
    

---

### 6️⃣ Booking Confirmation Screen (Critical)

Show:

- Booking ID
    
- Facility
    
- Floor
    
- Spot code
    
- Time window
    
- QR code or access code
    
- “Guaranteed Reserved Spot” banner
    

This is your demo highlight.

---

### 7️⃣ My Bookings Page

User can:

- See active booking
    
- See past bookings
    

Status:

- Reserved
    
- Active
    
- Completed
    

---

## ❌ Do NOT Build

- Payments
    
- Navigation routing
    
- Reviews
    
- User profiles
    
- Notifications
    
- Live sensor feeds
    

---

# 🏢 APP 2 — Admin / Operator App (TOWER)

**Audience:** Operators + your team  
**Goal:** Control inventory + onboarding + occupancy

This proves **operational realism**.

Can be:

- Same web app with admin role
    
- Simple dashboard UI
    

---

## ✅ Core Features — Must Build

### 1️⃣ Facility Management

Admin can:

- Create facility
    
- Set:
    
    - name
        
    - type (mall / office / small lot)
        
    - address
        
    - confidence level (auto or dropdown)
        

---

### 2️⃣ Floor Management

Admin can:

- Add floor
    
- Set floor label
    
- Upload floorplan image
    

Store:

- image URL
    
- floor id
    

---

### 3️⃣ Spot Management

Admin can:

- Add spots
    
- Set:
    
    - spot code
        
    - floor
        
    - coordinates (x,y on map)
        
    - distance from entry (number)
        

Methods:

- Table entry (fastest)  
    OR
    
- Click-on-map placement (better demo)
    

---

### 4️⃣ Spot Status Control (Sensor Simulation)

Admin can toggle:

- Available
    
- Occupied
    
- Blocked
    

This simulates hardware.

This powers live UI.

---

### 5️⃣ View Bookings

Admin sees:

- Active bookings
    
- Spot assigned
    
- Time window
    
- User
    

---

### 6️⃣ Manual Override

Admin can:

- Cancel booking
    
- Free spot
    
- Mark occupied manually
    

Supports:

> “What if something goes wrong?”

---

## ❌ Do NOT Build

- Operator billing
    
- Analytics charts
    
- Staff roles
    
- SLA dashboards
    
- Reports export
    

---

# 🛠️ APP 3 — Installer Mode (Inside Admin)

**Audience:** Your onboarding technician  
**Goal:** Prove controlled onboarding model

Do NOT make separate app — just a mode switch.

---

## ✅ Core Features — Must Build

### 1️⃣ Spot Placement Mode

Installer can:

- Open floorplan
    
- Click → place spot marker
    
- Enter spot code
    

Stores x,y coordinates.

---

### 2️⃣ Device Binding (Simulated)

Installer can:

- Enter fake device ID
    
- Bind to spot
    

Field exists → hardware story validated.

---

### 3️⃣ Spot Verification Toggle

Installer marks:

- Verified
    
- Not verified
    

This feeds:

- confidence score display
    

---

### 4️⃣ Distance Tagging

Installer sets:

- distance from entry (number)
    

Used for:

- “closest spot” logic
    

---

## ❌ Do NOT Build

- QR scanner
    
- BLE pairing
    
- Sensor testing flows
    
- Calibration math
    

Manual input only.

---

# ⚙️ Backend — Required Features

Use:

- Django / Node + Express
    
- SQLite / Postgres
    
- REST APIs
    

---

## ✅ Core Models

### Facility

- id
    
- name
    
- type
    
- confidence_score
    

---

### Floor

- id
    
- facility_id
    
- label
    
- floorplan_image
    

---

### Spot

- id
    
- floor_id
    
- code
    
- x
    
- y
    
- status
    
- verified
    
- distance_from_entry
    

---

### Device (fake)

- id
    
- device_code
    

---

### Booking

- id
    
- user
    
- spot_id
    
- start
    
- end
    
- status
    

---

## ✅ Core Logic

### Booking Engine

- find available spot
    
- lock it
    
- prevent double booking
    

---

### Availability Engine

Status priority:

```
occupied > reserved > available
```

---

### Closest Spot Logic

Simple:

```
ORDER BY distance_from_entry
```

No routing graph needed.

---

# 🎯 Demo Flow You Are Supporting

Driver:  
Search → open mall → view floor → see green spots → reserve → get guaranteed spot

Admin:  
Open facility → show map → toggle spot → driver UI updates

Installer:  
Place spots → verify → bind device → show onboarding workflow

That’s a **complete commercial story**.

---

# ⏱️ Reality Check — This Fits 24 Hours

If you stick to this:

- 2 devs frontend
    
- 1 dev backend
    
- 1 dev admin tools
    

This is absolutely buildable.

---

If you want, next I’ll give you:

✅ exact API endpoint list  
✅ DB migration file  
✅ frontend component tree  
✅ 24-hour sprint task board  
✅ judge demo script

Say the word and we go into build mode.