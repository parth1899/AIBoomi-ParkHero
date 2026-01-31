from rest_framework import serializers
from apps.atlas.models import Facility, Floor, ParkingSpot
from apps.orbit.models import Booking


class MobileFacilityListSerializer(serializers.ModelSerializer):
    """Lightweight facility list for mobile app."""
    available_spots = serializers.SerializerMethodField()
    confidence = serializers.IntegerField(source='confidence_score')
    price = serializers.SerializerMethodField()
    badges = serializers.SerializerMethodField()
    
    class Meta:
        model = Facility
        fields = ['id', 'name', 'type', 'confidence', 'available_spots', 'price', 'badges']
    
    def get_available_spots(self, obj):
        return ParkingSpot.objects.filter(
            floor__facility=obj,
            status='available'
        ).count()
    
    def get_price(self, obj):
        # Static pricing for MVP
        price_map = {
            'mall': 50,
            'office': 40,
            'lot': 30
        }
        return price_map.get(obj.type, 40)
    
    def get_badges(self, obj):
        from apps.confidence import services as confidence_services
        return confidence_services.get_status_badges(obj)


class MobileFacilityDetailSerializer(serializers.ModelSerializer):
    """Detailed facility view for mobile app."""
    available_spots = serializers.SerializerMethodField()
    confidence = serializers.IntegerField(source='confidence_score')
    price = serializers.SerializerMethodField()
    floors = serializers.SerializerMethodField()
    badges = serializers.SerializerMethodField()
    
    class Meta:
        model = Facility
        fields = [
            'id', 'name', 'type', 'address', 'confidence',
            'available_spots', 'price', 'floors', 'badges'
        ]
    
    def get_available_spots(self, obj):
        return ParkingSpot.objects.filter(
            floor__facility=obj,
            status='available'
        ).count()
    
    def get_price(self, obj):
        price_map = {
            'mall': 50,
            'office': 40,
            'lot': 30
        }
        return price_map.get(obj.type, 40)
    
    def get_floors(self, obj):
        floors = obj.floors.all()
        return [{
            'id': floor.id,
            'label': floor.label,
            'spots_count': floor.spots.count(),
            'available_count': floor.spots.filter(status='available').count()
        } for floor in floors]
    
    def get_badges(self, obj):
        from apps.confidence import services as confidence_services
        return confidence_services.get_status_badges(obj)


class MobileSpotSerializer(serializers.ModelSerializer):
    """Spot data for floor map overlay."""
    class Meta:
        model = ParkingSpot
        fields = ['id', 'code', 'x', 'y', 'status']


class MobileFloorMapSerializer(serializers.ModelSerializer):
    """Floor map with spot overlay data."""
    spots = MobileSpotSerializer(many=True, read_only=True)
    facility_name = serializers.CharField(source='facility.name', read_only=True)
    
    class Meta:
        model = Floor
        fields = ['id', 'label', 'facility_name', 'floorplan_image', 'spots']


class MobileBookingSerializer(serializers.ModelSerializer):
    """Booking confirmation response for mobile."""
    spot_code = serializers.CharField(source='spot.code', read_only=True)
    floor = serializers.CharField(source='spot.floor.label', read_only=True)
    facility = serializers.CharField(source='spot.floor.facility.name', read_only=True)
    qr_payload = serializers.SerializerMethodField()
    
    class Meta:
        model = Booking
        fields = [
            'id', 'spot_code', 'floor', 'facility',
            'start_time', 'end_time', 'access_code',
            'qr_payload', 'status'
        ]
    
    def get_qr_payload(self, obj):
        from apps.lockbox import services as lockbox_services
        return lockbox_services.get_access_payload(obj)


class AccessValidationSerializer(serializers.Serializer):
    """Access validation response."""
    valid = serializers.BooleanField()
    spot_code = serializers.CharField(required=False)
    floor = serializers.CharField(required=False)
    facility = serializers.CharField(required=False)
    time_remaining = serializers.FloatField(required=False)
    error = serializers.CharField(required=False)
