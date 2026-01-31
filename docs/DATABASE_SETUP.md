# ParkHero Database Setup - Complete

## Overview

The ParkHero ATLAS database has been successfully populated with realistic parking data for the Pune area, ready for product demonstration.

## Database Statistics

### Facilities: 46 Total

- **🏬 Malls**: 5 commercial facilities with multi-floor parking
- **🏛️ Government Lots**: 30 official parking facilities (from PMC data)
- **🅿️ Independent Lots**: 5 small commercial parking lots
- **🏠 Homeowner Spaces**: 6 residential parking spaces

### Infrastructure

- **Floors**: 56 parking levels across all facilities
- **Parking Spots**: 3,581 total spaces
  - Available: 1,983 (55%)
  - Occupied: 1,470 (41%)
  - Reserved: 128 (4%)
  - Verified: 3,498 (98%)
- **Sensors**: 966 simulated IoT devices (70% coverage in malls)

---

## Facility Types Breakdown

### 1. Commercial Malls (5 facilities)

Premium parking facilities with real-time availability tracking and floor plans.

#### Phoenix Market City
- **Location**: Viman Nagar, Pune
- **Floors**: B2, B1, Ground, P1 (4 levels)
- **Total Spots**: 450
- **Features**: Full sensor coverage, verified spots, floorplan images

#### Seasons Mall
- **Location**: Magarpatta City, Hadapsar
- **Floors**: B1, Ground, P1 (3 levels)
- **Total Spots**: 240
- **Features**: Real-time availability, floorplan navigation

#### Amanora Town Centre
- **Location**: Amanora Park Town, Hadapsar
- **Floors**: B2, B1, Ground (3 levels)
- **Total Spots**: 340
- **Features**: Multi-level parking, sensor integration

#### Pavilion Mall
- **Location**: Senapati Bapat Road, Shivajinagar
- **Floors**: B1, Ground (2 levels)
- **Total Spots**: 140
- **Features**: Central location, verified parking

#### Westend Mall
- **Location**: Aundh, Pune
- **Floors**: B1, Ground, P1 (3 levels)
- **Total Spots**: 210
- **Features**: Residential area mall, good availability

---

### 2. Government Parking Lots (30 facilities)

Official PMC (Pune Municipal Corporation) parking facilities from government database.

**Sample Facilities**:
- Minarva, Misal (Mandai) - 446 spots
- Shinde Tukaram (Pune Station) - 1,200+ spots (2W + 4W)
- Aryan, Babu Genu (Mandai) - 400 spots
- P.L. Desh. Udyan (Sinhagad Road) - 273 spots
- Kharadi Amenity Space - 278 spots

**Coverage Areas**:
- Kasba-Vishrambaugwada
- Dhole Patil
- Bhawani Peth
- Singhgad Road
- Bibwewadi
- Dhankwadi
- Shivajinagar
- Kharadi

---

### 3. Independent Parking Lots (5 facilities)

Small commercial parking operations in popular areas.

1. **Koregaon Park Quick Park** - 25 spots
   - Lane 5, Koregaon Park
   - Popular nightlife area

2. **FC Road Parking Zone** - 30 spots
   - Near Goodluck Cafe, FC Road
   - Student hub area

3. **Deccan Gymkhana Lot** - 40 spots
   - Opposite Fergusson College
   - Educational district

4. **Viman Nagar Plaza Parking** - 35 spots
   - Near Phoenix Market City
   - IT hub area

5. **Kothrud Market Parking** - 28 spots
   - Kothrud Market
   - Residential shopping area

---

### 4. Homeowner Parking Spaces (6 facilities)

Private residential parking spaces available for rent.

1. **Aundh Residential - Sharma** (2 spots)
2. **Koregaon Park Home - Patel** (1 spot)
3. **Baner Society - Deshmukh** (2 spots)
4. **Kalyani Nagar Private - Joshi** (3 spots)
5. **Wakad Home - Kulkarni** (1 spot)
6. **Hinjewadi Residential - Mehta** (2 spots)

---

## Mall Parking Features

### Real-Time Availability Simulation

All mall parking spots are configured with realistic occupancy patterns:
- **60-70% occupied** during peak hours (simulated)
- **10% reserved** for upcoming bookings
- **20-30% available** for immediate booking

### Floorplan Integration

Each mall floor has professional architectural floorplan images:

- **B2 Level**: Deep basement parking with entry/exit ramps
- **B1 Level**: Basement parking with elevator access
- **Ground Level**: Outdoor parking with landscaping
- **P1 Level**: Elevated parking deck with safety barriers

### Sensor Coverage

- **966 IoT sensors** deployed across mall parking
- **70% coverage rate** (realistic for enterprise deployment)
- Sensors bound to specific parking spots
- Real-time status updates (simulated)

---

## Demo User Account

**Username**: `demo`  
**Password**: `demo123`  
**Email**: demo@parkhero.com

Use this account to test booking flows and mobile API endpoints.

---

## API Testing

### View All Facilities
```bash
GET http://localhost:8000/api/mobile/facilities/
```

Response includes:
- Facility name and type
- Available spots count
- Confidence score
- Status badges

### Get Mall Details
```bash
GET http://localhost:8000/api/mobile/facilities/42/
```

Response includes:
- Facility information
- List of floors with spot counts
- Real-time availability

### View Floor Map
```bash
GET http://localhost:8000/api/mobile/floors/45/map/
```

Response includes:
- Floorplan image URL
- Array of spots with coordinates (x, y)
- Status for each spot (available/occupied/reserved)

### Create Booking
```bash
POST http://localhost:8000/api/mobile/bookings/
Authorization: Token <your-token>

{
  "facility_id": 42,
  "duration": 2.0
}
```

Response includes:
- Booking ID and access code
- Assigned spot details
- QR code (base64)
- Floor information

---

## Data Characteristics

### Geographic Coverage

All facilities are located in and around Pune:
- **Central Pune**: Shivajinagar, FC Road, Deccan
- **East Pune**: Viman Nagar, Kalyani Nagar, Kharadi
- **South Pune**: Hadapsar, Katraj, Bibwewadi
- **West Pune**: Aundh, Baner, Kothrud, Hinjewadi
- **North Pune**: Wakad

### Confidence Scores

- **Malls**: 95 (Enterprise verified)
- **Government Lots**: 85 (Official facilities)
- **Independent Lots**: 75 (Small business)
- **Homeowner Spaces**: 70 (Individual owners)

### Verification Status

- **98% verified** spots (3,498 out of 3,581)
- All mall spots are verified
- All government lot spots are verified
- Mixed verification for independent and homeowner spaces

---

## Scripts Available

### Initial Setup
```bash
uv run python setup_initial_data.py
```
Creates all facilities, floors, spots, and demo user.

### Attach Floorplans
```bash
uv run python attach_floorplans.py
```
Links floorplan images to mall floors.

### Re-run Setup
To reset and recreate all data:
```bash
uv run python setup_initial_data.py
uv run python attach_floorplans.py
```

---

## Demo Scenarios

### Scenario 1: Mall Parking Discovery
1. User opens app
2. Views list of facilities
3. Sees "Phoenix Market City" with 120 available spots
4. Clicks to view details
5. Sees 4 floors (B2, B1, Ground, P1)
6. Selects B1 floor to view map
7. Sees floorplan with color-coded spots
8. Books an available spot

### Scenario 2: Government Lot Booking
1. User searches near Pune Station
2. Finds "Shinde Tukaram" parking
3. Sees 400+ available spots
4. Books a spot for 3 hours
5. Receives access code and QR

### Scenario 3: Homeowner Space
1. User searches in Koregaon Park
2. Finds "Koregaon Park Home Parking - Patel"
3. Sees 1 spot available
4. Books for overnight parking
5. Gets homeowner contact info

---

## Product Demo Highlights

✅ **Real-world data**: 30 actual government parking lots from PMC  
✅ **Diverse facility types**: Malls, lots, homeowners  
✅ **Professional floorplans**: Architectural-quality images  
✅ **Real-time simulation**: Realistic occupancy patterns  
✅ **Sensor integration**: 966 IoT devices (simulated)  
✅ **Geographic spread**: Covers all major Pune areas  
✅ **Confidence scoring**: Differentiated by facility type  
✅ **3,500+ parking spots**: Substantial inventory

---

## Next Steps for Demo

1. **Test Mobile APIs**: Use Postman or curl to test endpoints
2. **Create Sample Bookings**: Book spots in different facilities
3. **View Admin Panel**: See all data in Django admin
4. **Test Floor Maps**: View floorplans with spot overlays
5. **Validate Access Codes**: Test booking verification flow

---

## Maintenance

### Update Spot Availability
Use Django admin to toggle spot statuses:
- Navigate to Parking Spots
- Select spots
- Use bulk actions to mark as Available/Occupied

### Add More Facilities
Use the admin interface or create additional setup scripts.

### Refresh Demo Data
Re-run `setup_initial_data.py` to reset to initial state.

---

**Database is production-ready for demo! 🎉**
