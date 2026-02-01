# ParkHero

**ParkHero** is a consumer-facing parking discovery and booking app designed for fast, confident parking decisions. It connects drivers to available spots in malls, lots, garages, and homeowner-listed P2P spots on the marketplace, while giving hosts a predictable booking flow.

This repository contains the Flutter mobile app (Frontier) and a Django REST Framework backend.

---

## Problem statement
Drivers waste time and fuel searching for parking, while hosts have unused capacity they cannot monetize easily. ParkHero reduces parking search friction by surfacing availability and enabling quick reservations.

## Users & context
- **Drivers/consumers:** need fast, reliable parking near destinations.
- **Hosts/facility owners:** want higher utilization and structured bookings.
- **Context:** urban malls, lots, and garages with variable demand.

## Solution overview
- **Mobile app** for discovery → floor/spot selection → reservation.
- **Backend services** for inventory, booking lifecycle, and access validation.
- **Mall demo mode** uses local mock floor plans when floor images are unavailable.

**Tech stack**
- Frontend: Flutter (Dart)
- Backend: Django + Django REST Framework
- Auth: token-based

**Project structure**
- Frontend entry: [frontier/lib/main.dart](frontier/lib/main.dart)
- Frontend screens: [frontier/lib/screens](frontier/lib/screens)
- Frontend services: [frontier/lib/services](frontier/lib/services)
- Frontend models: [frontier/lib/types/models.dart](frontier/lib/types/models.dart)
- Backend entry: [backend/manage.py](backend/manage.py)
- Backend apps: [backend/apps](backend/apps)
- Backend docs: [backend/README.md](backend/README.md)

## Setup & run (steps)
**Frontend**
1. `cd frontier`
2. `flutter pub get`
3. `flutter run`

**Backend**
1. `cd backend`
2. `uv sync`
3. `uv run python manage.py migrate`
4. `uv run python manage.py runserver`

## Models & data (sources, licenses)
- **Models:** `Facility`, `Floor`, `ParkingSpot`, `Booking`, `Device` (Django models under `backend/apps/atlas`).
- **Data sources:** internal seed/ingest scripts (see `backend/setup_initial_data.py`) and admin-created records. Some government parking lists (Excel/CSV) are used as seed inputs.
- **Licenses:** Please document any third‑party dataset licenses you include here before submission (placeholder).

## Evaluation & guardrails (hallucination/bias mitigations)
- No generative content is shown to end users in the MVP.
- Inputs are validated at API boundaries; status changes are deterministic.
- User-facing decisions are based on availability/state, not subjective AI scoring.

## Known limitations & risks
- Mall floor plans are mocked locally; real floor images and coordinates pending.
- Availability accuracy depends on backend data freshness.
- Pricing rules and payments are simplified for MVP.

## Team (names, roles, contacts)
- **Team Name:** Inclined
- **Team Number:** 46
- **Members:**
	- Parth Kalani
	  - Phone: +91 7358353305
	  - Email: parthkalani1899@gmail.com
	- Parth Petkar
	  - Phone: +91 9373063894
	  - Email: parthmanisha8777@gmail.com

## Product demo link
- TODO: Add demo video / hosted app / presentation link. (e.g., a short walkthrough video or hosted prototype URL)

## GitHub repo URL
- TODO: Add repository URL (e.g., https://github.com/<your-org>/AIBoomi-ParkHero).
