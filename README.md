# ParkHero

**ParkHero** is a consumer-facing parking discovery and booking app designed for fast, confident parking decisions. It connects drivers to available spots in malls, lots, and garages while giving hosts a predictable booking flow.

**This repo contains the Flutter mobile app (Frontier).**

---

## Why it matters (business view)

**The problem**
- Drivers waste time and fuel searching for parking.
- Hosts have unused capacity and no easy way to monetize it.

**The solution**
- Real-time availability surfaced at the facility and spot level.
- Transparent pricing and quick selection.
- A reservation flow that removes uncertainty.

**Value**
- **Drivers:** faster parking, clearer prices, less friction.
- **Hosts:** higher utilization and structured demand.

**MVP scope (today)**
- Consumer app for discovery + booking.
- Mock floor-plan experience for malls (no backend images required).
- Integration-ready services for facilities, floors, spots, and bookings.

---

## Product walkthrough (end-to-end)

1. **Browse facilities** by type and availability.
2. **Open a facility** to see details and floor options.
3. **Choose a floor** and find a spot.
4. **Reserve a spot** (API flow for non-malls, mock flow for malls).

---

## Technical overview

**Stack:** Flutter (Dart)

**Architecture highlights**
- **Services layer** for API requests and clean data mapping.
- **Typed models** for facilities, floors, spots, and bookings.
- **UI states** for loading, selection, and booking confirmation.

**Core modules**
- **Facilities:** list, detail view, availability & badges.
- **Floors & spots:** per-floor spot layouts with status (available/occupied/reserved).
- **Bookings:** creation + confirmation flow.
- **Access (prepared):** QR/validation endpoints are integrated and ready for backend.

---

## Backend (ParkHero API)

The backend is a Django REST Framework service powering inventory, bookings, and access control. It includes facilities, floors, spots, devices, and booking workflows.

- Backend README: [backend/README.md](backend/README.md)
- API docs: [backend/API_DOCUMENTATION.md](backend/API_DOCUMENTATION.md)

**Backend highlights**
- Inventory management (facilities, floors, spots, devices)
- Booking engine with approval workflows
- QR access + access validation endpoints
- Token auth + CORS for frontend integration

### Backend setup (detailed)

**Prerequisites**
- Python 3.12+
- `uv` package manager

**Install & run**

```bash
cd backend
uv sync
uv run python manage.py migrate
uv run python manage.py createsuperuser
uv run python manage.py runserver
```

Backend will be available at:

http://localhost:8000

**Admin panel**
- http://localhost:8000/admin/

**Core data model**
- **Facility** → building/site with a type (mall/lot/garage)
- **Floor** → level within a facility
- **ParkingSpot** → individual space (status: available/occupied/reserved/blocked)
- **Booking** → reservation with access code and status
- **Device** → simulated sensors/barriers bound to spots

**MVP data flow**
1. Create facilities → add floors → add spots
2. Mobile app fetches facilities and floor/spot data
3. User reserves a spot (booking created)
4. Access code/QR generated for entry/exit validation

**Useful commands**

```bash
uv run python manage.py migrate
uv run python manage.py createsuperuser
uv run python manage.py runserver
```

---

## Mall demo mode (frontend-only)

For **shopping malls**, the app generates **mock floor plans locally** so the demo works even without backend floor images:

- Multiple levels (Ground, Level 1, Level 2)
- Random occupied vs available spots
- Selecting a green spot opens a “temporary reservation” dialog
- The selected spot turns red (occupied) locally

This ensures the end-to-end flow is demo-ready with no dependency on floorplan assets.

---

## Setup guide

### Prerequisites
- Flutter SDK (stable channel)
- Android SDK + emulator or connected device

### Install dependencies

```bash
cd frontier
flutter pub get
```

### Run the app

```bash
flutter run
```

### Build a release APK

```bash
flutter build apk --release
```

APK output:

build/app/outputs/flutter-apk/app-release.apk

---

## API configuration

Set the API base URL in the app config before running against a backend. The services layer reads this base URL to reach facility, floor, spot, and booking endpoints.

---

## GitHub Actions APK artifact

This repository includes a CI workflow that builds and uploads a **release APK** on every push to `main`.

**How to download:**
1. Open the repository on GitHub.
2. Go to **Actions** → latest workflow run.
3. Download **app-release-apk** from the **Artifacts** section.

---

## Project structure (frontend)

- App entry: [frontier/lib/main.dart](frontier/lib/main.dart)
- Screens: [frontier/lib/screens](frontier/lib/screens)
- Services: [frontier/lib/services](frontier/lib/services)
- Models: [frontier/lib/types/models.dart](frontier/lib/types/models.dart)

## Project structure (backend)

- App entry: [backend/manage.py](backend/manage.py)
- Project config: [backend/parkhero](backend/parkhero)
- Django apps: [backend/apps](backend/apps)
	- atlas (inventory)
	- orbit (bookings)
	- lockbox (access)
	- confidence (scoring)
	- frontier_api (mobile API)
- Shared utilities: [backend/common](backend/common)
- Docs: [backend/README.md](backend/README.md)

---

## Notes

- Mall floor plans are currently mocked in the app (frontend only).
- Backend floorplan images can be enabled later without UI changes.
