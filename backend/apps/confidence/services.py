"""
Confidence and status calculation services for CONFIDENCE app.
"""
from apps.atlas.models import Facility, ParkingSpot


def compute_facility_confidence(facility):
    """
    Calculate confidence score for a facility.
    
    Base scores:
    - Enterprise: 95
    - Small: 80
    
    Bonuses:
    - +5 for high verification rate (>80%)
    
    Args:
        facility: Facility instance
        
    Returns:
        Integer confidence score (0-100)
    """
    # Base score by onboarding type
    if facility.onboarding_type == 'enterprise':
        base_score = 95
    else:
        base_score = 80
    
    # Calculate verification rate
    total_spots = ParkingSpot.objects.filter(floor__facility=facility).count()
    
    if total_spots == 0:
        return base_score
    
    verified_spots = ParkingSpot.objects.filter(
        floor__facility=facility,
        verified=True
    ).count()
    
    verification_rate = (verified_spots / total_spots) * 100
    
    # Bonus for high verification
    if verification_rate > 80:
        base_score = min(100, base_score + 5)
    
    return base_score


def compute_spot_confidence(spot):
    """
    Calculate confidence level for a parking spot.
    
    Returns:
    - 'high': Verified spot with device
    - 'medium': Verified spot or has device
    - 'low': Unverified, no device
    
    Args:
        spot: ParkingSpot instance
        
    Returns:
        String confidence level
    """
    has_device = spot.devices.exists()
    
    if spot.verified and has_device:
        return 'high'
    elif spot.verified or has_device:
        return 'medium'
    else:
        return 'low'


def get_status_badges(facility):
    """
    Get status badges for a facility.
    
    Args:
        facility: Facility instance
        
    Returns:
        List of badge strings
    """
    badges = []
    
    # Confidence-based badges
    if facility.confidence_score >= 95:
        badges.append('High Confidence')
    
    # Onboarding type badges
    if facility.onboarding_type == 'enterprise':
        badges.append('Enterprise Verified')
    
    # Verification badges
    total_spots = ParkingSpot.objects.filter(floor__facility=facility).count()
    if total_spots > 0:
        verified_spots = ParkingSpot.objects.filter(
            floor__facility=facility,
            verified=True
        ).count()
        verification_rate = (verified_spots / total_spots) * 100
        
        if verification_rate >= 90:
            badges.append('Fully Verified')
        elif verification_rate >= 50:
            badges.append('Partially Verified')
    
    # Availability badge
    available_spots = ParkingSpot.objects.filter(
        floor__facility=facility,
        status='available'
    ).count()
    
    if available_spots > 0:
        badges.append('Available Now')
    
    return badges


def update_facility_confidence(facility_id):
    """
    Recalculate and update facility confidence score.
    
    Args:
        facility_id: ID of the facility
        
    Returns:
        Updated Facility instance
    """
    facility = Facility.objects.get(id=facility_id)
    new_score = compute_facility_confidence(facility)
    
    facility.confidence_score = new_score
    facility.save(update_fields=['confidence_score', 'updated_at'])
    
    return facility
