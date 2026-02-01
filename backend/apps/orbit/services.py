"""
Booking engine services for ORBIT app.
Handles spot finding, booking creation, and conflict prevention.
"""
import random
import string
from datetime import datetime, timedelta
from django.db import transaction
from django.db.models import Q
from django.utils import timezone
from apps.atlas.models import ParkingSpot
from .models import Booking


def generate_access_code(length=6):
    """
    Generate a unique random access code.
    
    Args:
        length: Length of the code (default 6)
        
    Returns:
        Unique access code string
    """
    while True:
        code = ''.join(random.choices(string.ascii_uppercase + string.digits, k=length))
        if not Booking.objects.filter(access_code=code).exists():
            return code


def validate_booking_window(spot_id, start_time, end_time, exclude_booking_id=None):
    """
    Check if a spot is available during the requested time window.
    
    Args:
        spot_id: ID of the parking spot
        start_time: Booking start time
        end_time: Booking end time
        exclude_booking_id: Optional booking ID to exclude (for updates)
        
    Returns:
        Boolean indicating if the window is available
    """
    # Check for overlapping bookings
    overlapping = Booking.objects.filter(
        spot_id=spot_id,
        status__in=['reserved', 'active']
    ).filter(
        Q(start_time__lt=end_time) & Q(end_time__gt=start_time)
    )
    
    if exclude_booking_id:
        overlapping = overlapping.exclude(id=exclude_booking_id)
    
    return not overlapping.exists()


def find_best_available_spot(facility_id, start_time, end_time):
    """
    Find the best available spot for booking.
    Prioritizes spots by distance from entry.
    
    Args:
        facility_id: ID of the facility
        start_time: Booking start time
        end_time: Booking end time
        
    Returns:
        ParkingSpot instance or None if no spots available
    """
    # Get all available spots in the facility
    available_spots = ParkingSpot.objects.filter(
        floor__facility_id=facility_id,
        status='available'
    ).select_related('floor').order_by('distance_from_entry')
    
    # Check each spot for time conflicts
    for spot in available_spots:
        if validate_booking_window(spot.id, start_time, end_time):
            return spot
    
    return None


@transaction.atomic
def create_booking(user, facility_id, duration_hours, start_time=None):
    """
    Create a new parking booking.
    
    Args:
        user: User instance
        facility_id: ID of the facility
        duration_hours: Duration in hours
        start_time: Optional start time (defaults to now)
        
    Returns:
        Booking instance
        
    Raises:
        ValueError: If no spots available
    """
    from apps.atlas.models import Facility
    
    if start_time is None:
        start_time = timezone.now()
    
    end_time = start_time + timedelta(hours=duration_hours)
    
    # Get facility to check onboarding type
    facility = Facility.objects.get(id=facility_id)
    
    # Find best available spot
    spot = find_best_available_spot(facility_id, start_time, end_time)
    
    if not spot:
        raise ValueError("No available spots for the requested time window")
    
    # Generate access code
    access_code = generate_access_code()
    
    # Determine initial status based on facility type
    # P2P facilities require host approval
    if facility.onboarding_type == 'p2p':
        initial_status = 'pending_approval'
        host_user = facility.owner
    else:
        initial_status = 'reserved'
        host_user = None
    
    # Create booking
    booking = Booking.objects.create(
        user=user,
        spot=spot,
        start_time=start_time,
        end_time=end_time,
        access_code=access_code,
        status=initial_status,
        host_user=host_user
    )
    
    # Update spot status (reserve spot even if pending approval)
    spot.status = 'reserved'
    spot.save(update_fields=['status', 'updated_at'])
    
    return booking


@transaction.atomic
def release_spot(booking_id):
    """
    Release a spot by completing a booking.
    
    Args:
        booking_id: ID of the booking
        
    Returns:
        Updated Booking instance
    """
    booking = Booking.objects.select_related('spot').get(id=booking_id)
    
    # Update booking status
    booking.status = 'completed'
    booking.save(update_fields=['status', 'updated_at'])
    
    # Update spot status to available
    booking.spot.status = 'available'
    booking.spot.save(update_fields=['status', 'updated_at'])
    
    return booking


@transaction.atomic
def cancel_booking(booking_id):
    """
    Cancel a booking and release the spot.
    
    Args:
        booking_id: ID of the booking
        
    Returns:
        Updated Booking instance
    """
    booking = Booking.objects.select_related('spot').get(id=booking_id)
    
    if booking.status not in ['reserved', 'active']:
        raise ValueError("Cannot cancel a completed or already cancelled booking")
    
    # Update booking status
    booking.status = 'cancelled'
    booking.save(update_fields=['status', 'updated_at'])
    
    # Update spot status to available
    booking.spot.status = 'available'
    booking.spot.save(update_fields=['status', 'updated_at'])
    
    return booking


@transaction.atomic
def approve_booking(booking_id, approver_user):
    """
    Approve a P2P booking request.
    
    Args:
        booking_id: ID of the booking
        approver_user: User approving the booking (must be facility owner)
        
    Returns:
        Updated Booking instance
        
    Raises:
        ValueError: If booking cannot be approved
    """
    booking = Booking.objects.select_related('spot', 'spot__floor__facility').get(id=booking_id)
    
    # Verify the approver is the facility owner
    if booking.host_user != approver_user:
        raise ValueError("Only the facility owner can approve this booking")
    
    if booking.status != 'pending_approval':
        raise ValueError(f"Cannot approve booking with status: {booking.status}")
    
    # Update booking status to reserved
    booking.status = 'reserved'
    booking.save(update_fields=['status', 'updated_at'])
    
    return booking


@transaction.atomic
def reject_booking(booking_id, approver_user, reason=None):
    """
    Reject a P2P booking request.
    
    Args:
        booking_id: ID of the booking
        approver_user: User rejecting the booking (must be facility owner)
        reason: Optional rejection reason
        
    Returns:
        Updated Booking instance
        
    Raises:
        ValueError: If booking cannot be rejected
    """
    booking = Booking.objects.select_related('spot', 'spot__floor__facility').get(id=booking_id)
    
    # Verify the approver is the facility owner
    if booking.host_user != approver_user:
        raise ValueError("Only the facility owner can reject this booking")
    
    if booking.status != 'pending_approval':
        raise ValueError(f"Cannot reject booking with status: {booking.status}")
    
    # Update booking status to rejected
    booking.status = 'rejected'
    booking.rejection_reason = reason or "No reason provided"
    booking.save(update_fields=['status', 'rejection_reason', 'updated_at'])
    
    # Release the spot
    booking.spot.status = 'available'
    booking.spot.save(update_fields=['status', 'updated_at'])
    
    return booking


def get_user_bookings(user, active_only=False):
    """
    Get bookings for a user.
    
    Args:
        user: User instance
        active_only: If True, only return active/reserved bookings
        
    Returns:
        QuerySet of Booking instances
    """
    queryset = Booking.objects.filter(user=user).select_related(
        'spot', 'spot__floor', 'spot__floor__facility'
    )
    
    if active_only:
        queryset = queryset.filter(status__in=['reserved', 'active'])
    
    return queryset.order_by('-created_at')
