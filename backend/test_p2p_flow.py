"""
Test script for P2P Marketplace functionality.
Demonstrates the complete P2P booking approval workflow.
"""

import requests
import json
from pprint import pprint

BASE_URL = "http://localhost:8001"

def login(username, password):
    """Login and get auth token."""
    response = requests.post(
        f"{BASE_URL}/api/auth/login/",
        json={"username": username, "password": password}
    )
    if response.status_code == 200:
        token = response.json()['token']
        print(f"✅ Logged in as {username}")
        return token
    else:
        print(f"❌ Login failed: {response.text}")
        return None


def get_p2p_facilities(token=None):
    """Get all P2P facilities."""
    headers = {}
    if token:
        headers['Authorization'] = f'Token {token}'
    
    response = requests.get(
        f"{BASE_URL}/api/mobile/facilities/?type=p2p",
        headers=headers
    )
    
    if response.status_code == 200:
        facilities = response.json()
        print(f"\n🏠 Found {len(facilities)} P2P facilities:")
        for fac in facilities:
            print(f"  - {fac['name']} (₹{fac.get('price', 'N/A')}/hr) - Owner: {fac.get('owner_name', 'Unknown')}")
        return facilities
    else:
        print(f"❌ Failed to get facilities: {response.text}")
        return []


def create_p2p_booking(token, facility_id):
    """Create a P2P booking (will be pending approval)."""
    headers = {'Authorization': f'Token {token}'}
    
    response = requests.post(
        f"{BASE_URL}/api/mobile/bookings/",
        headers=headers,
        json={
            "facility_id": facility_id,
            "duration": 2.0
        }
    )
    
    if response.status_code == 201:
        booking = response.json()
        print(f"\n✅ Booking created!")
        print(f"   Status: {booking['status']}")
        print(f"   Facility: {booking['facility_name']}")
        print(f"   Spot: {booking['spot_code']}")
        if booking.get('requires_approval'):
            print(f"   ⏳ Waiting for approval from: {booking.get('host_name', 'host')}")
        return booking
    else:
        print(f"❌ Booking failed: {response.text}")
        return None


def get_incoming_bookings(token):
    """Get pending bookings for host."""
    headers = {'Authorization': f'Token {token}'}
    
    response = requests.get(
        f"{BASE_URL}/api/atlas/facilities/incoming-bookings/",
        headers=headers
    )
    
    if response.status_code == 200:
        bookings = response.json()
        print(f"\n📥 Found {len(bookings)} pending bookings:")
        for booking in bookings:
            print(f"  - Booking #{booking['id']}")
            print(f"    User: {booking.get('user_name', 'Unknown')}")
            print(f"    Email: {booking.get('user_email', 'N/A')}")
            print(f"    Facility: {booking['facility_name']}")
            print(f"    Spot: {booking['spot_code']}")
            print(f"    Status: {booking['status']}")
        return bookings
    else:
        print(f"❌ Failed to get bookings: {response.text}")
        return []


def approve_booking(token, booking_id):
    """Approve a pending booking."""
    headers = {'Authorization': f'Token {token}'}
    
    response = requests.post(
        f"{BASE_URL}/api/orbit/bookings/{booking_id}/approve/",
        headers=headers
    )
    
    if response.status_code == 200:
        booking = response.json()
        print(f"\n✅ Booking approved!")
        print(f"   Status: {booking['status']}")
        print(f"   Access Code: {booking['access_code']}")
        return booking
    else:
        print(f"❌ Approval failed: {response.text}")
        return None


def reject_booking(token, booking_id, reason):
    """Reject a pending booking."""
    headers = {'Authorization': f'Token {token}'}
    
    response = requests.post(
        f"{BASE_URL}/api/orbit/bookings/{booking_id}/reject/",
        headers=headers,
        json={"reason": reason}
    )
    
    if response.status_code == 200:
        booking = response.json()
        print(f"\n✅ Booking rejected!")
        print(f"   Status: {booking['status']}")
        print(f"   Reason: {booking['rejection_reason']}")
        return booking
    else:
        print(f"❌ Rejection failed: {response.text}")
        return None


def get_my_bookings(token):
    """Get user's bookings."""
    headers = {'Authorization': f'Token {token}'}
    
    response = requests.get(
        f"{BASE_URL}/api/mobile/bookings/me/",
        headers=headers
    )
    
    if response.status_code == 200:
        bookings = response.json()
        print(f"\n📋 My bookings ({len(bookings)}):")
        for booking in bookings:
            print(f"  - {booking['facility_name']} - {booking['spot_code']}")
            print(f"    Status: {booking['status']}")
        return bookings
    else:
        print(f"❌ Failed to get bookings: {response.text}")
        return []


def main():
    print("="*60)
    print("🚀 ParkHero P2P Marketplace Test")
    print("="*60)
    
    # Step 1: Login as driver
    print("\n--- STEP 1: Driver discovers P2P facilities ---")
    driver_token = login("demo", "demo123")
    if not driver_token:
        return
    
    # Step 2: Get P2P facilities
    p2p_facilities = get_p2p_facilities(driver_token)
    if not p2p_facilities:
        print("❌ No P2P facilities found!")
        return
    
    # Step 3: Create booking
    print("\n--- STEP 2: Driver creates booking ---")
    first_facility = p2p_facilities[0]
    booking = create_p2p_booking(driver_token, first_facility['id'])
    if not booking:
        return
    
    booking_id = booking['id']
    
    # Step 4: Login as homeowner
    print("\n--- STEP 3: Homeowner checks pending requests ---")
    homeowner_token = login("homeowner_demo", "demo123")
    if not homeowner_token:
        return
    
    # Step 5: Check incoming bookings
    incoming = get_incoming_bookings(homeowner_token)
    
    # Step 6: Approve the booking
    if incoming:
        print("\n--- STEP 4: Homeowner approves booking ---")
        approved = approve_booking(homeowner_token, booking_id)
        
        # Step 7: Driver checks updated booking
        if approved:
            print("\n--- STEP 5: Driver checks approved booking ---")
            get_my_bookings(driver_token)
    
    print("\n" + "="*60)
    print("✅ P2P Marketplace workflow test completed!")
    print("="*60)
    
    # Additional demo: Show rejection flow
    print("\n\n💡 BONUS: Testing rejection flow...")
    print("\n--- Creating another booking ---")
    if len(p2p_facilities) > 1:
        booking2 = create_p2p_booking(driver_token, p2p_facilities[1]['id'])
        if booking2:
            print("\n--- Homeowner rejects booking ---")
            reject_booking(homeowner_token, booking2['id'], "Driveway occupied by family vehicle")


if __name__ == '__main__':
    main()
