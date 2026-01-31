# ParkHero Backend

Django REST Framework backend for the ParkHero parking reservation platform.

## Architecture

The backend consists of 5 Django apps with clear separation of concerns:

- **atlas** - Parking inventory management (facilities, floors, spots, devices)
- **orbit** - Booking & availability engine with double-booking prevention
- **lockbox** - Access code generation and verification
- **confidence** - Confidence score calculation and status badges
- **frontier_api** - Mobile-facing API aggregation layer

## Tech Stack

- Django 6.0.1
- Django REST Framework 3.16.1
- SQLite (for MVP)
- Token-based authentication
- CORS enabled for frontend integration

## Setup Instructions

### Prerequisites

- Python 3.12+
- uv package manager

### Installation

```bash
# Navigate to backend directory
cd backend

# Dependencies are already installed via uv
# If you need to reinstall:
uv sync

# Run migrations
uv run python manage.py migrate

# Create superuser for admin access
uv run python manage.py createsuperuser

# Run development server
uv run python manage.py runserver
```

The server will start at `http://localhost:8000`

## API Endpoints

### Admin Panel
- `http://localhost:8000/admin/` - Django admin interface

### Authentication
- `POST /api/auth/token/` - Get authentication token
  ```json
  {
    "username": "your_username",
    "password": "your_password"
  }
  ```

### Mobile API (Frontend Integration)

#### Facilities
- `GET /api/mobile/facilities/` - List all facilities
- `GET /api/mobile/facilities/{id}/` - Get facility details

#### Floor Maps
- `GET /api/mobile/floors/{id}/` - Get floor details
- `GET /api/mobile/floors/{id}/map/` - Get floor map with spot overlay

#### Bookings
- `POST /api/mobile/bookings/` - Create new booking
  ```json
  {
    "facility_id": 1,
    "duration": 2.0
  }
  ```
- `GET /api/mobile/bookings/me/` - Get user's bookings

#### Access Validation
- `POST /api/mobile/access/validate/` - Validate access code
  ```json
  {
    "access_code": "ABC123"
  }
  ```

### Internal APIs (Admin/Management)

#### Atlas (Inventory)
- `GET /api/atlas/facilities/` - List facilities
- `GET /api/atlas/floors/` - List floors
- `GET /api/atlas/spots/` - List parking spots
- `GET /api/atlas/devices/` - List devices

#### Orbit (Bookings)
- `GET /api/orbit/bookings/` - List all bookings (admin)
- `POST /api/orbit/bookings/{id}/cancel/` - Cancel booking
- `POST /api/orbit/bookings/{id}/complete/` - Complete booking

#### Lockbox (Access)
- `POST /api/lockbox/validate/` - Validate access code
- `GET /api/lockbox/qr/{booking_id}/` - Get QR code for booking

## Database Models

### ATLAS App

**Facility**
- name, type (mall/office/lot), address
- onboarding_type (enterprise/small)
- confidence_score

**Floor**
- facility (FK), label, floorplan_image

**ParkingSpot**
- floor (FK), code, x, y coordinates
- status (available/occupied/reserved/blocked)
- verified, distance_from_entry

**Device**
- device_code, bound_spot (FK)

### ORBIT App

**Booking**
- user (FK), spot (FK)
- start_time, end_time, status
- access_code (unique)

## Admin Interface Features

The Django admin provides:
- Facility management with inline floors
- Floor management with inline spots
- Spot status toggles and bulk actions
- Booking management and cancellation
- Device binding interface
- Search and filtering across all models

## Development Workflow

1. **Add Sample Data via Admin**
   - Create facilities
   - Add floors with floorplan images
   - Place parking spots with coordinates
   - Optionally bind devices

2. **Test Mobile APIs**
   - Use DRF browsable API at `/api/mobile/`
   - Test booking creation flow
   - Verify access code validation

3. **Frontend Integration**
   - CORS is configured for localhost:3000 and localhost:8081
   - Use token authentication
   - All mobile endpoints return JSON

## Project Structure

```
backend/
├── manage.py
├── pyproject.toml
├── parkhero/              # Main project config
│   ├── settings.py
│   ├── urls.py
│   └── wsgi.py
├── apps/
│   ├── atlas/             # Inventory management
│   ├── orbit/             # Booking engine
│   ├── lockbox/           # Access verification
│   ├── confidence/        # Confidence scoring
│   └── frontier_api/      # Mobile API layer
├── common/                # Shared utilities
│   ├── models.py          # Base models
│   ├── utils.py           # Helper functions
│   └── permissions.py     # Custom permissions
└── media/                 # Uploaded files
    └── floorplans/
```

## Key Features

✅ Double-booking prevention  
✅ Automatic access code generation  
✅ QR code generation for bookings  
✅ Confidence score calculation  
✅ Spot status management  
✅ Device binding (simulated)  
✅ Time-based booking validation  
✅ User-specific booking queries  
✅ Admin bulk actions  
✅ CORS-enabled for frontend

## Next Steps

1. Create superuser and log into admin
2. Add sample facilities and floors
3. Upload floorplan images
4. Create parking spots with coordinates
5. Test booking creation via API
6. Integrate with React Native frontend

## Notes

- SQLite database is used for MVP (file: `db.sqlite3`)
- Media files are stored in `media/floorplans/`
- All business logic is in `services.py` files (separated from views)
- Token authentication is required for most endpoints
- Access validation endpoint is public (no auth required)
