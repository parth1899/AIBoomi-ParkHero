from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from apps.orbit.models import Booking
from . import services


@api_view(['POST'])
@permission_classes([AllowAny])
def validate_access(request):
    """
    Validate an access code for entry/exit.
    Public endpoint - used by scanners.
    """
    code = request.data.get('access_code')
    if not code:
        return Response(
            {'error': 'access_code is required'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
        
    result = services.validate_access_code(code)
    
    if result.get('valid'):
        return Response(result)
    else:
        return Response(
            result, 
            status=status.HTTP_400_BAD_REQUEST
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_qr_code(request, booking_id):
    """
    Get QR code for a specific booking.
    User must own the booking.
    """
    booking = get_object_or_404(Booking, id=booking_id)
    
    # Check if user owns the booking or is admin
    if booking.user != request.user and not request.user.is_staff:
        return Response(
            {'error': 'Not authorized to view this booking'}, 
            status=status.HTTP_403_FORBIDDEN
        )
        
    result = services.get_access_payload(booking)
    return Response(result)


@api_view(['POST'])
@permission_classes([AllowAny])
def validate_barrier(request):
    """
    Validate entry at a barrier device.
    """
    qr_payload = request.data.get('qr_code')
    device_code = request.data.get('device_code')
    
    if not qr_payload or not device_code:
        return Response(
            {'error': 'qr_code and device_code are required'}, 
            status=status.HTTP_400_BAD_REQUEST
        )
        
    result = services.validate_barrier_access(qr_payload, device_code)
    
    status_code = status.HTTP_200_OK if result.get('valid') else status.HTTP_400_BAD_REQUEST
    return Response(result, status=status_code)
