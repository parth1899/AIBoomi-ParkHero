from rest_framework import serializers
from django.contrib.auth.models import User
from .models import Booking
from apps.atlas.serializers import ParkingSpotSerializer


class BookingSerializer(serializers.ModelSerializer):
    """Full booking details serializer."""
    spot_details = ParkingSpotSerializer(source='spot', read_only=True)
    user_name = serializers.CharField(source='user.username', read_only=True)
    user_first_name = serializers.CharField(source='user.first_name', read_only=True)
    user_last_name = serializers.CharField(source='user.last_name', read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    facility_name = serializers.CharField(source='spot.floor.facility.name', read_only=True)
    floor_label = serializers.CharField(source='spot.floor.label', read_only=True)
    spot_code = serializers.CharField(source='spot.code', read_only=True)
    is_active = serializers.BooleanField(read_only=True)
    host_username = serializers.CharField(source='host_user.username', read_only=True, allow_null=True)
    
    class Meta:
        model = Booking
        fields = [
            'id', 'user', 'user_name', 'user_first_name', 'user_last_name', 'user_email',
            'spot', 'spot_details',
            'spot_code', 'floor_label', 'facility_name',
            'start_time', 'end_time', 'status', 'access_code',
            'host_user', 'host_username', 'rejection_reason',
            'is_active', 'created_at', 'updated_at'
        ]
        read_only_fields = ['access_code', 'host_user', 'rejection_reason', 'created_at', 'updated_at']


class BookingCreateSerializer(serializers.Serializer):
    """Serializer for creating a new booking."""
    facility_id = serializers.IntegerField()
    duration_hours = serializers.FloatField(min_value=0.5, max_value=24)
    start_time = serializers.DateTimeField(required=False, allow_null=True)
    
    def validate_duration_hours(self, value):
        """Validate duration is reasonable."""
        if value < 0.5:
            raise serializers.ValidationError("Minimum duration is 30 minutes")
        if value > 24:
            raise serializers.ValidationError("Maximum duration is 24 hours")
        return value


class BookingListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for booking list."""
    facility_name = serializers.CharField(source='spot.floor.facility.name', read_only=True)
    floor_label = serializers.CharField(source='spot.floor.label', read_only=True)
    spot_code = serializers.CharField(source='spot.code', read_only=True)
    
    class Meta:
        model = Booking
        fields = [
            'id', 'facility_name', 'floor_label', 'spot_code',
            'start_time', 'end_time', 'status', 'access_code'
        ]
