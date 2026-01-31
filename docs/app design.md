Perfect — now we’re in **build mode**. I’ll give you a **production-clean, hackathon-fast structure** with proper separation of concerns, designed specifically for:

- ✅ Django + Django REST Framework backend
    
- ✅ React Native frontend (FRONTIER only)
    
- ✅ Django Admin as TOWER + Installer console
    
- ✅ No hardware integration
    
- ✅ Debuggable in 24 hours
    
- ✅ Parallel backend + frontend development
    

This will be **prompt-ready** so your frontend teammate can start immediately.

No fluff — just structure.

---

# 🧱 BACKEND — Django + DRF Architecture

We map your codenames into Django apps with clean responsibility boundaries.

```
parkhero/
├── manage.py
├── parkhero/
│   ├── settings.py
│   ├── urls.py
│   └── asgi.py
│
├── apps/
│   ├── atlas/        → inventory source of truth
│   ├── orbit/        → booking engine
│   ├── lockbox/      → access verification
│   ├── signal/       → confidence + status logic
│   ├── frontier_api/ → user-facing APIs (aggregation layer)
│
├── common/
│   ├── models.py
│   ├── utils.py
│   └── permissions.py
```

Key idea:

- **atlas/orbit/lockbox/signal = domain logic**
    
- **frontier_api = mobile-facing API surface**
    
- Keeps separation clean.
    

---

# 🗺️ ATLAS App — Inventory Domain

```
apps/atlas/
├── models.py
├── admin.py
├── serializers.py
├── services.py
├── views.py
├── urls.py
```

## Models

### Facility

- name
    
- type
    
- address
    
- onboarding_type
    
- confidence_score
    

### Floor

- facility (FK)
    
- label
    
- floorplan_image
    

### ParkingSpot

- floor (FK)
    
- code
    
- x
    
- y
    
- status
    
- verified
    
- distance_from_entry
    

### Device (simulated)

- device_code
    
- bound_spot (FK nullable)
    

---

## Services (important separation)

```
atlas/services.py
```

Functions:

- create_facility()
    
- create_floor()
    
- create_spot()
    
- get_available_spots(facility_id)
    

No HTTP logic here — pure domain.

---

# 🛰️ ORBIT App — Booking Engine

```
apps/orbit/
├── models.py
├── serializers.py
├── services.py
├── views.py
├── urls.py
```

## Models

### Booking

- user
    
- spot
    
- start_time
    
- end_time
    
- status
    
- access_code
    

---

## Services

```
orbit/services.py
```

Functions:

- find_best_available_spot(facility_id)
    
- create_booking(user, facility_id, duration)
    
- release_spot(spot_id)
    
- validate_booking_window()
    

This keeps booking logic isolated.

---

# 🔐 LOCKBOX App — Access Validation

```
apps/lockbox/
├── services.py
├── views.py
├── urls.py
```

No models needed — uses Booking.

## Services

- validate_access_code(code)
    
- get_access_payload(booking)
    

---

# 📡 SIGNAL App — Confidence + Status

```
apps/signal/
├── services.py
```

## Services

- compute_facility_confidence()
    
- compute_spot_confidence()
    
- get_status_badges()
    

No DB required — pure logic layer.

---

# 🌐 FRONTIER_API — Mobile Aggregation Layer

This is what your React Native app hits.

```
apps/frontier_api/
├── views.py
├── serializers.py
├── urls.py
```

This layer:

- calls atlas/orbit/signal services
    
- returns mobile-shaped responses
    
- hides internal structure
    

---

## Endpoints to Implement (Front-End Contract)

### GET /api/mobile/facilities/

Returns:

- id
    
- name
    
- type
    
- confidence
    
- available_spots
    
- price
    

---

### GET /api/mobile/facilities/{id}/

Returns:

- facility info
    
- floors list
    

---

### GET /api/mobile/floors/{id}/map/

Returns:

- floorplan_image
    
- spots:
    
    - id
        
    - code
        
    - x,y
        
    - status
        

---

### POST /api/mobile/bookings/

Input:

- facility_id
    
- duration
    

Returns:

- booking_id
    
- spot_code
    
- floor
    
- access_code
    
- qr_payload
    

---

### GET /api/mobile/bookings/me/

Returns user bookings.

---

### POST /api/mobile/access/validate/

Input:

- access_code  
    Returns:
    
- valid/invalid
    
- spot
    
- time
    

---

# 🛠 Django Admin (TOWER + INSTALLER)

Register in admin:

- Facility
    
- Floor
    
- ParkingSpot
    
- Device
    
- Booking
    

Add:

- inline Spots under Floor
    
- inline Floors under Facility
    

This becomes:  
✅ Admin panel  
✅ Installer onboarding  
✅ Spot mapping  
✅ Status control

No extra frontend needed.

---

# 📱 FRONTEND — React Native (FRONTIER)

Use:

- Expo
    
- React Navigation
    
- Axios
    

---

## Folder Structure

```
frontend/
├── src/
│   ├── api/
│   │   ├── client.js
│   │   ├── facilities.js
│   │   ├── bookings.js
│
│   ├── screens/
│   │   ├── FacilityListScreen.js
│   │   ├── FacilityDetailScreen.js
│   │   ├── FloorMapScreen.js
│   │   ├── BookingConfirmScreen.js
│   │   ├── MyBookingsScreen.js
│
│   ├── components/
│   │   ├── FacilityCard.js
│   │   ├── SpotMarker.js
│   │   ├── FloorSelector.js
│   │   ├── ConfidenceBadge.js
│
│   ├── navigation/
│   │   └── AppNavigator.js
│
│   ├── store/
│   │   └── useBookingStore.js
│
│   └── utils/
│       └── spotColors.js
```

---

## Screens to Build

### FacilityListScreen

- fetch facilities
    
- list cards
    

---

### FacilityDetailScreen

- show facility info
    
- list floors
    
- reserve button
    

---

### FloorMapScreen

- show floorplan image
    
- overlay spot markers using absolute positioning
    

---

### BookingConfirmScreen

- show booking
    
- show QR code
    

---

### MyBookingsScreen

- list bookings
    

---

# 🔌 API Client Setup

```
api/client.js
```

- axios instance
    
- baseURL
    
- auth header support
    

---

# 🎯 FRONTEND START PROMPT (Give This to Frontend Dev / AI)

Copy-paste ready:

---

**PROMPT — START FRONTIER APP**

Build a React Native (Expo) mobile app called ParkHero FRONTIER.

Requirements:

Stack:

- Expo
    
- React Navigation
    
- Axios
    
- Functional components
    
- Clean modular structure
    

Screens required:

1. FacilityListScreen  
    Fetch from GET /api/mobile/facilities/  
    Display facility cards with name, type, confidence, available spots.
    
2. FacilityDetailScreen  
    Fetch GET /api/mobile/facilities/{id}/  
    Show details + floors list + Reserve button.
    
3. FloorMapScreen  
    Fetch GET /api/mobile/floors/{id}/map/  
    Render floorplan image and overlay spot markers using x,y coordinates.  
    Color spots by status (green/yellow/red).
    
4. BookingConfirmScreen  
    POST /api/mobile/bookings/  
    Show booking id, spot code, floor, access code, QR code.
    
5. MyBookingsScreen  
    GET /api/mobile/bookings/me/
    

Components:

- FacilityCard
    
- SpotMarker
    
- ConfidenceBadge
    
- FloorSelector
    

Use a centralized api client file with axios.

No payments. No auth UI required — assume demo user token exists.

Design for fast demo, not production polish.

---

If you want, next I can give you:

✅ exact Django model code  
✅ serializer code  
✅ DRF viewsets  
✅ admin inline config  
✅ booking service logic  
✅ frontend spot overlay math

Say **“generate backend skeleton”** and we start coding.