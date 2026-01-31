from rest_framework import serializers
from apps.atlas.models import Facility, Floor, ParkingSpot
from apps.orbit.models import Booking


class MobileFacilityListSerializer(serializers.ModelSerializer):
    """Lightweight facility list for mobile app."""
    available_spots = serializers.SerializerMethodField()
    confidence = serializers.IntegerField(source='confidence_score')
    price = serializers.SerializerMethodField()
    badges = serializers.SerializerMethodField()
    owner_name = serializers.SerializerMethodField()
    requires_approval = serializers.SerializerMethodField()
    
    class Meta:
        model = Facility
        fields = [
            'id', 'name', 'type', 'onboarding_type', 'confidence', 
            'available_spots', 'price', 'badges', 'owner_name', 'requires_approval'
        ]
    
    def get_available_spots(self, obj):
        return ParkingSpot.objects.filter(
            floor__facility=obj,
            status='available'
        ).count()
    
    def get_price(self, obj):
        """Return actual hourly rate if set, otherwise default."""
        if obj.hourly_rate:
            return float(obj.hourly_rate)
        # Default pricing for MVP
        price_map = {
            'mall': 50,
            'office': 40,
            'lot': 30
        }
        return price_map.get(obj.type, 40)
    
    def get_badges(self, obj):
        from apps.confidence import services as confidence_services
        return confidence_services.get_status_badges(obj)
    
    def get_owner_name(self, obj):
        """Get owner name for P2P facilities."""
        if obj.owner:
            return f"{obj.owner.first_name} {obj.owner.last_name}".strip() or obj.owner.username
        return None
    
    def get_requires_approval(self, obj):
        """Check if facility requires host approval."""
        return obj.onboarding_type == 'p2p'


class MobileFacilityDetailSerializer(serializers.ModelSerializer):
    """Detailed facility view for mobile app."""
    available_spots = serializers.SerializerMethodField()
    confidence = serializers.IntegerField(source='confidence_score')
    price = serializers.SerializerMethodField()
    floors = serializers.SerializerMethodField()
    badges = serializers.SerializerMethodField()
    owner_name = serializers.SerializerMethodField()
    requires_approval = serializers.SerializerMethodField()
    hourly_rate = serializers.DecimalField(max_digits=8, decimal_places=2, read_only=True)
    daily_rate = serializers.DecimalField(max_digits=8, decimal_places=2, read_only=True)
    
    class Meta:
        model = Facility
        fields = [
            'id', 'name', 'type', 'address', 'onboarding_type', 'confidence',
            'available_spots', 'price', 'hourly_rate', 'daily_rate',
            'floors', 'badges', 'owner_name', 'requires_approval'
        ]
    
    def get_available_spots(self, obj):
        return ParkingSpot.objects.filter(
            floor__facility=obj,
            status='available'
        ).count()
    
    def get_price(self, obj):
        """Return actual hourly rate if set, otherwise default."""
        if obj.hourly_rate:
            return float(obj.hourly_rate)
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
    
    def get_owner_name(self, obj):
        """Get owner name for P2P facilities."""
        if obj.owner:
            return f"{obj.owner.first_name} {obj.owner.last_name}".strip() or obj.owner.username
        return None
    
    def get_requires_approval(self, obj):
        """Check if facility requires host approval."""
        return obj.onboarding_type == 'p2p'


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
    facility_name = serializers.CharField(source='spot.floor.facility.name', read_only=True)
    requires_approval = serializers.SerializerMethodField()
    host_name = serializers.SerializerMethodField()
    
    class Meta:
        model = Booking
        fields = [
            'id', 'spot_code', 'floor', 'facility_name', 
            'start_time', 'end_time', 'status', 'access_code',
            'requires_approval', 'host_name', 'rejection_reason'
        ]
    
    def get_requires_approval(self, obj):
        return obj.status == 'pending_approval'
    
    def get_host_name(self, obj):
        if obj.host_user:
            return f"{obj.host_user.first_name} {obj.host_user.last_name}".strip() or obj.host_user.username
        return None


class AccessValidationSerializer(serializers.Serializer):
    """Access validation response."""
    valid = serializers.BooleanField()
    spot_code = serializers.CharField(required=False)
    floor = serializers.CharField(required=False)
    facility = serializers.CharField(required=False)
    time_remaining = serializers.FloatField(required=False)
    error = serializers.CharField(required=False)
