from rest_framework import serializers
from .models import Facility, Floor, ParkingSpot, Device


class FacilitySerializer(serializers.ModelSerializer):
    """Full facility details serializer."""
    available_spots_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Facility
        fields = [
            'id', 'name', 'type', 'address', 'onboarding_type',
            'confidence_score', 'available_spots_count', 
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
    
    def get_available_spots_count(self, obj):
        """Count available spots across all floors."""
        return ParkingSpot.objects.filter(
            floor__facility=obj,
            status='available'
        ).count()


class FacilityListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for facility list view."""
    available_spots = serializers.SerializerMethodField()
    
    class Meta:
        model = Facility
        fields = [
            'id', 'name', 'type', 'confidence_score', 'available_spots'
        ]
    
    def get_available_spots(self, obj):
        return ParkingSpot.objects.filter(
            floor__facility=obj,
            status='available'
        ).count()


class ParkingSpotSerializer(serializers.ModelSerializer):
    """Parking spot details serializer."""
    floor_label = serializers.CharField(source='floor.label', read_only=True)
    facility_name = serializers.CharField(source='floor.facility.name', read_only=True)
    
    class Meta:
        model = ParkingSpot
        fields = [
            'id', 'floor', 'floor_label', 'facility_name', 'code',
            'x', 'y', 'status', 'verified', 'distance_from_entry',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']


class FloorSerializer(serializers.ModelSerializer):
    """Floor serializer with spot count."""
    spots_count = serializers.SerializerMethodField()
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    spots = ParkingSpotSerializer(many=True, read_only=True)
    
    class Meta:
        model = Floor
        fields = [
            'id', 'facility', 'facility_name', 'label', 
            'floorplan_image', 'spots_count', 'spots',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
    
    def get_spots_count(self, obj):
        return obj.spots.count()


class DeviceSerializer(serializers.ModelSerializer):
    """Device serializer for binding management."""
    spot_code = serializers.CharField(source='bound_spot.code', read_only=True)
    facility_name = serializers.CharField(source='bound_facility.name', read_only=True)
    
    class Meta:
        model = Device
        fields = [
            'id', 'device_code', 'device_type', 
            'bound_spot', 'spot_code',
            'bound_facility', 'facility_name',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['created_at', 'updated_at']
