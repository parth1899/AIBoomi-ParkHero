# ParkHero

**ParkHero** is a consumer-facing parking discovery and booking app designed for fast, confident parking decisions. It connects drivers to available spots in malls, lots, and garages while giving hosts a predictable booking flow.

This repository contains the Flutter mobile app (Frontier) and a Django REST Framework backend.

---

## Problem statement (2–3 lines)
Drivers waste time and fuel searching for parking, while hosts have unused capacity they cannot monetize easily. ParkHero reduces parking search friction by surfacing availability and enabling quick reservations.

## Users & context
- **Drivers/consumers:** need fast, reliable parking near destinations.
- **Hosts/facility owners:** want higher utilization and structured bookings.
- **Context:** urban malls, lots, and garages with variable demand.

## Solution overview (diagram optional)
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
- **Facility, Floor, ParkingSpot, Booking, Device** modeled in Django.
- **Data sources:** internal seed data/scripts + admin-created records.
- **Licenses:** list any third‑party datasets and their licenses here. (TODO)

## Evaluation & guardrails (hallucination/bias mitigations)
- No generative content is shown to end users in the MVP.
- Inputs are validated at API boundaries; status changes are deterministic.
- User-facing decisions are based on availability/state, not subjective AI scoring.

## Known limitations & risks
- Mall floor plans are mocked locally; real floor images and coordinates pending.
- Availability accuracy depends on backend data freshness.
- Pricing rules and payments are simplified for MVP.

## Team (names, roles, contacts)
- TODO: Add team members, roles, and contact links.

## Product demo link
- TODO: Add demo video / hosted app / presentation link.

## GitHub repo URL
- TODO: Add repository URL.
