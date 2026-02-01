"""
Access verification and validation services for LOCKBOX app.
"""
from django.utils import timezone
from django.db import models
from apps.orbit.models import Booking
from common.utils import generate_qr_code


def validate_access_code(code):
    """
    Validate an access code and return booking details.
    
    Args:
        code: Access code string
        
    Returns:
        Dictionary with validation result and booking details
    """
    try:
        booking = Booking.objects.select_related(
            'spot', 'spot__floor', 'spot__floor__facility', 'user'
        ).get(access_code=code)
        
        now = timezone.now()
        is_valid = (
            booking.status in ['reserved', 'active'] and
            booking.start_time <= now <= booking.end_time
        )
        
        return {
            'valid': is_valid,
            'booking_id': booking.id,
            'spot_code': booking.spot.code,
            'floor': booking.spot.floor.label,
            'facility': booking.spot.floor.facility.name,
            'start_time': booking.start_time,
            'end_time': booking.end_time,
            'status': booking.status,
            'user': booking.user.username,
            'time_remaining': (booking.end_time - now).total_seconds() if is_valid else 0
        }
    except Booking.DoesNotExist:
        return {
            'valid': False,
            'error': 'Invalid access code'
        }


def get_access_payload(booking):
    """
    Generate QR code payload for a booking.
    
    Args:
        booking: Booking instance
        
    Returns:
        Dictionary with QR code data
    """
    payload_data = f"PARKHERO-{booking.access_code}-{booking.id}"
    qr_code_base64 = generate_qr_code(payload_data)
    
    return {
        'qr_code': qr_code_base64,
        'access_code': booking.access_code,
        'booking_id': booking.id,
        'payload': payload_data
    }





def validate_barrier_access(qr_payload, device_code):
    """
    Validate access at a barrier (QR scan).
    
    Args:
        qr_payload: QR string scanned (format: PARKHERO:CODE:ID)
        device_code: ID of the barrier device
        
    Returns:
        Dict with validation result and action
    """
    from apps.atlas.models import Device
    
    # 1. Validate Barrier Device
    try:
        barrier = Device.objects.select_related('bound_facility').get(
            device_code=device_code, 
            device_type='barrier'
        )
    except Device.DoesNotExist:
        return {'valid': False, 'error': 'Invalid barrier device'}
        
    # 2. Parse QR Code
    try:
        # Expected format: PARKHERO-ACCESS_CODE-BOOKING_ID
        parts = qr_payload.split('-')
        if len(parts) != 3 or parts[0] != 'PARKHERO':
            return {'valid': False, 'error': 'Invalid QR format'}
            
        access_code = parts[1]
        booking_id = parts[2]
    except Exception:
        return {'valid': False, 'error': 'Malformed QR data'}
        
    # 3. Validate Booking
    try:
        booking = Booking.objects.select_related(
            'spot', 'spot__floor', 'spot__floor__facility'
        ).get(id=booking_id, access_code=access_code)
        
        # Check facility match
        booking_facility = booking.spot.floor.facility
        if booking_facility != barrier.bound_facility:
            return {
                'valid': False, 
                'error': f'Ticket not valid for this facility (Go to {booking_facility.name})'
            }
            
        # Check time window
        now = timezone.now()
        if not (booking.start_time <= now <= booking.end_time):
             return {
                'valid': False, 
                'error': 'Booking not active (Check time)'
            }
            
        return {
            'valid': True,
            'action': 'open_barrier',
            'booking_id': booking.id,
            'facility': booking_facility.name,
            'duration': f"{(booking.end_time - booking.start_time).total_seconds() / 3600:.1f} hours",
            'spots_available': booking_facility.floors.aggregate(
                avail=models.Count('spots', filter=models.Q(spots__status='available'))
            )['avail']
        }
        
    except Booking.DoesNotExist:
        return {'valid': False, 'error': 'Booking not found'}
