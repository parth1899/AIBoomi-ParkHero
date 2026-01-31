from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from common.permissions import IsOwnerOrAdmin
from .models import Booking
from .serializers import (
    BookingSerializer, BookingCreateSerializer, BookingListSerializer
)
from . import services


class BookingViewSet(viewsets.ModelViewSet):
    """ViewSet for Booking CRUD operations."""
    queryset = Booking.objects.select_related(
        'user', 'spot', 'spot__floor', 'spot__floor__facility'
    ).all()
    permission_classes = [IsAuthenticated]
    
    def get_serializer_class(self):
        if self.action == 'create':
            return BookingCreateSerializer
        elif self.action == 'list':
            return BookingListSerializer
        return BookingSerializer
    
    def get_queryset(self):
        """Filter bookings based on user permissions."""
        queryset = super().get_queryset()
        
        # Non-admin users only see their own bookings
        if not self.request.user.is_staff:
            queryset = queryset.filter(user=self.request.user)
        
        # Filter by status if provided
        status_filter = self.request.query_params.get('status')
        if status_filter:
            queryset = queryset.filter(status=status_filter)
        
        return queryset
    
    def create(self, request, *args, **kwargs):
        """Create a new booking."""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        
        try:
            booking = services.create_booking(
                user=request.user,
                facility_id=serializer.validated_data['facility_id'],
                duration_hours=serializer.validated_data['duration_hours'],
                start_time=serializer.validated_data.get('start_time')
            )
            
            response_serializer = BookingSerializer(booking)
            return Response(
                response_serializer.data,
                status=status.HTTP_201_CREATED
            )
        except ValueError as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'])
    def cancel(self, request, pk=None):
        """Cancel a booking."""
        booking = self.get_object()
        
        # Check permissions
        if not request.user.is_staff and booking.user != request.user:
            return Response(
                {'error': 'You do not have permission to cancel this booking'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        try:
            updated_booking = services.cancel_booking(booking.id)
            serializer = self.get_serializer(updated_booking)
            return Response(serializer.data)
        except ValueError as e:
            return Response(
                {'error': str(e)},
                status=status.HTTP_400_BAD_REQUEST
            )
    
    @action(detail=True, methods=['post'])
    def complete(self, request, pk=None):
        """Complete a booking and release the spot."""
        booking = self.get_object()
        
        # Only staff can manually complete bookings
        if not request.user.is_staff:
            return Response(
                {'error': 'Only staff can complete bookings'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        updated_booking = services.release_spot(booking.id)
        serializer = self.get_serializer(updated_booking)
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def my_bookings(self, request):
        """Get current user's bookings."""
        active_only = request.query_params.get('active_only', 'false').lower() == 'true'
        bookings = services.get_user_bookings(request.user, active_only=active_only)
        
        page = self.paginate_queryset(bookings)
        if page is not None:
            serializer = BookingListSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)
        
        serializer = BookingListSerializer(bookings, many=True)
        return Response(serializer.data)
