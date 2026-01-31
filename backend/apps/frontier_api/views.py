from rest_framework import viewsets, status
from rest_framework.decorators import api_view, permission_classes, action
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from apps.atlas.models import Facility, Floor
from apps.orbit import services as orbit_services
from apps.lockbox import services as lockbox_services
from .serializers import (
    MobileFacilityListSerializer,
    MobileFacilityDetailSerializer,
    MobileFloorMapSerializer,
    MobileBookingSerializer,
    AccessValidationSerializer
)


class MobileFacilityViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Mobile API for facilities.
    
    GET /api/mobile/facilities/ - List all facilities
    GET /api/mobile/facilities/{id}/ - Get facility details
    
    Query params:
    - type: Filter by onboarding type (p2p, small, enterprise)
    - facility_type: Filter by facility type (mall, lot, office)
    """
    queryset = Facility.objects.all()
    permission_classes = [AllowAny]
    
    def get_serializer_class(self):
        if self.action == 'list':
            return MobileFacilityListSerializer
        return MobileFacilityDetailSerializer
    
    def get_queryset(self):
        queryset = super().get_queryset()
        
        # Filter by onboarding type (p2p, small, enterprise)
        onboarding_type = self.request.query_params.get('type')
        if onboarding_type:
            queryset = queryset.filter(onboarding_type=onboarding_type)
        
        # Filter by facility type (mall, lot, office)
        facility_type = self.request.query_params.get('facility_type')
        if facility_type:
            queryset = queryset.filter(type=facility_type)
        
        return queryset


class MobileFloorViewSet(viewsets.ReadOnlyModelViewSet):
    """
    Mobile API for floor maps.
    
    GET /api/mobile/floors/{id}/map/ - Get floor map with spots
    """
    queryset = Floor.objects.select_related('facility').prefetch_related('spots').all()
    serializer_class = MobileFloorMapSerializer
    permission_classes = [AllowAny]
    
    @action(detail=True, methods=['get'])
    def map(self, request, pk=None):
        """Get floor map with spot overlay data."""
        floor = self.get_object()
        serializer = self.get_serializer(floor)
        return Response(serializer.data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_mobile_booking(request):
    """
    Create a new booking from mobile app.
    
    POST /api/mobile/bookings/
    Body: {
        "facility_id": 1,
        "duration_hours": 2.0
    }
    """
    facility_id = request.data.get('facility_id')
    duration_hours = request.data.get('duration_hours', 1.0)
    
    if not facility_id:
        return Response(
            {'error': 'facility_id is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    try:
        booking = orbit_services.create_booking(
            user=request.user,
            facility_id=facility_id,
            duration_hours=float(duration_hours)
        )
        
        serializer = MobileBookingSerializer(booking)
        return Response(serializer.data, status=status.HTTP_201_CREATED)
        
    except ValueError as e:
        return Response(
            {'error': str(e)},
            status=status.HTTP_400_BAD_REQUEST
        )
    except Exception as e:
        return Response(
            {'error': 'Failed to create booking'},
            status=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def my_mobile_bookings(request):
    """
    Get current user's bookings.
    
    GET /api/mobile/bookings/me/
    """
    bookings = orbit_services.get_user_bookings(request.user)
    serializer = MobileBookingSerializer(bookings, many=True)
    return Response(serializer.data)


@api_view(['POST'])
@permission_classes([AllowAny])
def validate_mobile_access(request):
    """
    Validate access code from mobile app.
    
    POST /api/mobile/access/validate/
    Body: {"access_code": "ABC123"}
    """
    access_code = request.data.get('access_code')
    
    if not access_code:
        return Response(
            {'error': 'access_code is required'},
            status=status.HTTP_400_BAD_REQUEST
        )
    
    result = lockbox_services.validate_access_code(access_code)
    serializer = AccessValidationSerializer(result)
    
    if result.get('valid'):
        return Response(serializer.data, status=status.HTTP_200_OK)
    else:
        return Response(serializer.data, status=status.HTTP_404_NOT_FOUND)
