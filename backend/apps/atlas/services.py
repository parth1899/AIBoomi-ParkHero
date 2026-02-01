"""
Business logic services for ATLAS app.
Keeps domain logic separate from HTTP layer.
"""
from django.db import transaction
from django.db.models import Q
from .models import Facility, Floor, ParkingSpot, Device


def create_facility(data):
    """
    Create a new parking facility.
    
    Args:
        data: Dictionary with facility fields
        
    Returns:
        Facility instance
    """
    facility = Facility.objects.create(**data)
    return facility


def create_floor(facility_id, data):
    """
    Create a new floor for a facility.
    
    Args:
        facility_id: ID of the parent facility
        data: Dictionary with floor fields
        
    Returns:
        Floor instance
    """
    facility = Facility.objects.get(id=facility_id)
    floor = Floor.objects.create(facility=facility, **data)
    return floor


def create_spot(floor_id, data):
    """
    Create a new parking spot.
    
    Args:
        floor_id: ID of the parent floor
        data: Dictionary with spot fields
        
    Returns:
        ParkingSpot instance
    """
    floor = Floor.objects.get(id=floor_id)
    spot = ParkingSpot.objects.create(floor=floor, **data)
    return spot


def get_available_spots(facility_id, floor_id=None):
    """
    Get all available spots for a facility, optionally filtered by floor.
    
    Args:
        facility_id: ID of the facility
        floor_id: Optional floor ID to filter by
        
    Returns:
        QuerySet of available ParkingSpot instances
    """
    query = ParkingSpot.objects.filter(
        floor__facility_id=facility_id,
        status='available'
    ).select_related('floor', 'floor__facility')
    
    if floor_id:
        query = query.filter(floor_id=floor_id)
    
    return query.order_by('distance_from_entry')


def update_spot_status(spot_id, status):
    """
    Update the status of a parking spot.
    
    Args:
        spot_id: ID of the spot
        status: New status value
        
    Returns:
        Updated ParkingSpot instance
    """
    spot = ParkingSpot.objects.get(id=spot_id)
    spot.status = status
    spot.save(update_fields=['status', 'updated_at'])
    return spot


@transaction.atomic
def bind_device_to_spot(device_code, spot_id):
    """
    Bind a device to a parking spot.
    
    Args:
        device_code: Device code string
        spot_id: ID of the spot to bind to (None to unbind)
        
    Returns:
        Device instance
    """
    device, created = Device.objects.get_or_create(device_code=device_code)
    
    if spot_id:
        spot = ParkingSpot.objects.get(id=spot_id)
        device.bound_spot = spot
    else:
        device.bound_spot = None
    
    device.save(update_fields=['bound_spot', 'updated_at'])
    return device


def get_facility_stats(facility_id):
    """
    Get statistics for a facility.
    
    Args:
        facility_id: ID of the facility
        
    Returns:
        Dictionary with stats
    """
    facility = Facility.objects.get(id=facility_id)
    total_spots = ParkingSpot.objects.filter(floor__facility=facility).count()
    available = ParkingSpot.objects.filter(
        floor__facility=facility, 
        status='available'
    ).count()
    occupied = ParkingSpot.objects.filter(
        floor__facility=facility, 
        status='occupied'
    ).count()
    reserved = ParkingSpot.objects.filter(
        floor__facility=facility, 
        status='reserved'
    ).count()
    verified = ParkingSpot.objects.filter(
        floor__facility=facility, 
        verified=True
    ).count()
    
    return {
        'total_spots': total_spots,
        'available': available,
        'occupied': occupied,
        'reserved': reserved,
        'verified': verified,
        'verification_rate': (verified / total_spots * 100) if total_spots > 0 else 0
    }
