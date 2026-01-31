from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from common.permissions import IsAdminOrReadOnly
from .models import Facility, Floor, ParkingSpot, Device
from .serializers import (
    FacilitySerializer, FacilityListSerializer,
    FloorSerializer, ParkingSpotSerializer, DeviceSerializer
)
from . import services


class FacilityViewSet(viewsets.ModelViewSet):
    """ViewSet for Facility CRUD operations."""
    queryset = Facility.objects.all()
    permission_classes = [IsAdminOrReadOnly]
    
    def get_serializer_class(self):
        if self.action == 'list':
            return FacilityListSerializer
        return FacilitySerializer
    
    @action(detail=True, methods=['get'])
    def stats(self, request, pk=None):
        """Get statistics for a facility."""
        facility = self.get_object()
        stats = services.get_facility_stats(facility.id)
        return Response(stats)


class FloorViewSet(viewsets.ModelViewSet):
    """ViewSet for Floor CRUD operations."""
    queryset = Floor.objects.select_related('facility').all()
    serializer_class = FloorSerializer
    permission_classes = [IsAdminOrReadOnly]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        facility_id = self.request.query_params.get('facility')
        if facility_id:
            queryset = queryset.filter(facility_id=facility_id)
        return queryset


class ParkingSpotViewSet(viewsets.ModelViewSet):
    """ViewSet for ParkingSpot CRUD operations."""
    queryset = ParkingSpot.objects.select_related('floor', 'floor__facility').all()
    serializer_class = ParkingSpotSerializer
    permission_classes = [IsAdminOrReadOnly]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        floor_id = self.request.query_params.get('floor')
        facility_id = self.request.query_params.get('facility')
        status_filter = self.request.query_params.get('status')
        
        if floor_id:
            queryset = queryset.filter(floor_id=floor_id)
        if facility_id:
            queryset = queryset.filter(floor__facility_id=facility_id)
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def update_status(self, request, pk=None):
        """Update spot status."""
        spot = self.get_object()
        new_status = request.data.get('status')
        
        if new_status not in dict(ParkingSpot.STATUS_CHOICES):
            return Response(
                {'error': 'Invalid status'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        updated_spot = services.update_spot_status(spot.id, new_status)
        serializer = self.get_serializer(updated_spot)
        return Response(serializer.data)


class DeviceViewSet(viewsets.ModelViewSet):
    """ViewSet for Device management."""
    queryset = Device.objects.select_related('bound_spot').all()
    serializer_class = DeviceSerializer
    permission_classes = [IsAdminOrReadOnly]
    
    @action(detail=True, methods=['post'])
    def bind(self, request, pk=None):
        """Bind device to a spot."""
        device = self.get_object()
        spot_id = request.data.get('spot_id')
        
        updated_device = services.bind_device_to_spot(device.device_code, spot_id)
        serializer = self.get_serializer(updated_device)
        return Response(serializer.data)
