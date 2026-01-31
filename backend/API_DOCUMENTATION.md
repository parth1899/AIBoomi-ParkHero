# 📘 ParkHero API Documentation

Comprehensive guide to ParkHero backend endpoints for testing and integration.

## 🔐 Authentication

All protected endpoints require a Token Authorization header.

**Header:** `Authorization: Token <your_token>`

### 1. Get Auth Token (Login)
*   **Endpoint:** `POST /api/auth/token/`
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
    { "token": "9f8a7..." }
    ```
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8000/api/auth/token/ \
         -H "Content-Type: application/json" \
         -d '{"username": "demo", "password": "demo123"}'
    ```

---

## 🗺️ Mobile API (Frontier)
*Aggregated endpoints for the mobile application context.*

### 2. List Facilities
*   **Endpoint:** `GET /api/mobile/facilities/`
*   **Access:** Public
*   **Response:** List of facilities with availability count.
*   **Curl:**
    ```bash
    curl http://localhost:8000/api/mobile/facilities/
    ```

### 3. Get Facility Details
*   **Endpoint:** `GET /api/mobile/facilities/{id}/`
*   **Access:** Public
*   **Curl:**
    ```bash
    curl http://localhost:8000/api/mobile/facilities/88/
    ```

### 4. Get Floor Map (with Spots)
*   **Endpoint:** `GET /api/mobile/floors/{id}/map/`
*   **Access:** Public
*   **Response:** Floor details + Floorplan image URL + List of spots with X,Y coords and status.
*   **Curl:**
    ```bash
    curl http://localhost:8000/api/mobile/floors/99/map/
    ```

### 5. Create Booking (Mobile)
*   **Endpoint:** `POST /api/mobile/bookings/`
*   **Access:** Authenticated
*   **Body:**
    ```json
    {
        "facility_id": 88,
        "duration": 2.0
    }
    ```
*   **Response:** Booking details including `access_code`.
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8000/api/mobile/bookings/ \
         -H "Authorization: Token <YOUR_TOKEN>" \
         -H "Content-Type: application/json" \
         -d '{"facility_id": 88, "duration": 2.0}'
    ```

### 6. Get My Bookings (Mobile)
*   **Endpoint:** `GET /api/mobile/bookings/me/`
*   **Access:** Authenticated
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" http://localhost:8000/api/mobile/bookings/me/
    ```

---

## 🔐 LOCKBOX (Access Control)
*Endpoints for physical access control hardware (Barriers/Sensors).*

### 7. Get QR Code for Booking
*   **Endpoint:** `GET /api/lockbox/qr/{booking_id}/`
*   **Access:** Authenticated (Owner only)
*   **Response:** Base64 QR code image + payload data.
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" http://localhost:8000/api/lockbox/qr/1/
    ```

### 8. Validate Barrier Entry (Small Lots/Homeowners)
*   **Endpoint:** `POST /api/lockbox/barrier/validate/`
*   **Access:** Public (Used by Barrier Hardware)
*   **Body:**
    ```json
    {
        "qr_code": "PARKHERO-ACCESS_CODE-BOOKING_ID",
        "device_code": "BARRIER-XXX-ENTRY"
    }
    ```
*   **Response:**
    ```json
    {
        "valid": true,
        "action": "open_barrier",
        "facility": "Koregaon Park Quick Park"
    }
    ```
*   **Curl:**
    ```bash
    curl -X POST http://localhost:8000/api/lockbox/barrier/validate/ \
         -H "Content-Type: application/json" \
         -d '{"qr_code": "PARKHERO-ABC12345-1", "device_code": "BARRIER-77-ENTRY"}'
    ```

---

## 📡 ATLAS (Inventory Management)
*Admin/Management endpoints.*

### 9. List All Devices
*   **Endpoint:** `GET /api/atlas/devices/`
*   **Access:** Admin/Staff
*   **Curl:**
    ```bash
    curl -H "Authorization: Token <YOUR_TOKEN>" http://localhost:8000/api/atlas/devices/
    ```

## 🧪 Testing Workflow

1.  **Login** as demo user locally to get Token.
    *   Command: `curl -X POST http://localhost:8000/api/auth/token/ -d '{"username": "demo", "password": "demo123"}' -H "Content-Type: application/json"`
2.  **List Facilities** to find a Small Lot ID.
    *   Command: `curl http://localhost:8000/api/mobile/facilities/`
3.  **Book** a spot at that facility.
    *   Command: `curl -X POST http://localhost:8000/api/mobile/bookings/ -H "Authorization: Token <TOKEN>" -d '{"facility_id": <ID>, "duration": 1}' -H "Content-Type: application/json"`
4.  **Simulate Barrier Scan**.
    *   Use the `booking_id` and `access_code` from step 3.
    *   Command: `curl -X POST http://localhost:8000/api/lockbox/barrier/validate/ -d '{"qr_code": "PARKHERO-<CODE>-<ID>", "device_code": "BARRIER-<ID>-ENTRY"}' -H "Content-Type: application/json"`
