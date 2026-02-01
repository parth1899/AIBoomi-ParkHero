from django.contrib import admin
from .models import Facility, Floor, ParkingSpot, Device


class FloorInline(admin.TabularInline):
    """Inline admin for floors within facility."""
    model = Floor
    extra = 1
    fields = ['label', 'floorplan_image']


class ParkingSpotInline(admin.TabularInline):
    """Inline admin for spots within floor."""
    model = ParkingSpot
    extra = 0
    fields = ['code', 'x', 'y', 'status', 'verified', 'distance_from_entry']
    list_select_related = ['floor']


@admin.register(Facility)
class FacilityAdmin(admin.ModelAdmin):
    """Admin interface for Facility model."""
    list_display = [
        'name', 'type', 'onboarding_type', 
        'confidence_score', 'latitute', 'longitude', 'created_at'
    ]
    list_filter = ['type', 'onboarding_type']
    search_fields = ['name', 'address']
    inlines = [FloorInline]
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Basic Information', {
            'fields': ('name', 'type', 'address', 'latitute', 'longitude')
        }),
        ('Configuration', {
            'fields': ('onboarding_type', 'confidence_score')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(Floor)
class FloorAdmin(admin.ModelAdmin):
    """Admin interface for Floor model."""
    list_display = ['facility', 'label', 'spots_count', 'created_at']
    list_filter = ['facility']
    search_fields = ['facility__name', 'label']
    inlines = [ParkingSpotInline]
    readonly_fields = ['created_at', 'updated_at']
    
    def spots_count(self, obj):
        return obj.spots.count()
    spots_count.short_description = 'Total Spots'


@admin.register(ParkingSpot)
class ParkingSpotAdmin(admin.ModelAdmin):
    """Admin interface for ParkingSpot model."""
    list_display = [
        'code', 'floor', 'status', 'verified', 
        'distance_from_entry', 'created_at'
    ]
    list_filter = ['status', 'verified', 'floor__facility']
    search_fields = ['code', 'floor__label', 'floor__facility__name']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Location', {
            'fields': ('floor', 'code')
        }),
        ('Map Coordinates', {
            'fields': ('x', 'y', 'distance_from_entry')
        }),
        ('Status', {
            'fields': ('status', 'verified')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    actions = ['mark_available', 'mark_occupied', 'mark_verified']
    
    def mark_available(self, request, queryset):
        queryset.update(status='available')
    mark_available.short_description = "Mark selected spots as Available"
    
    def mark_occupied(self, request, queryset):
        queryset.update(status='occupied')
    mark_occupied.short_description = "Mark selected spots as Occupied"
    
    def mark_verified(self, request, queryset):
        queryset.update(verified=True)
    mark_verified.short_description = "Mark selected spots as Verified"


@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    """Admin interface for Device model."""
    list_display = ['device_code', 'bound_spot', 'created_at']
    list_filter = ['bound_spot__floor__facility']
    search_fields = ['device_code', 'bound_spot__code']
    readonly_fields = ['created_at', 'updated_at']
    
    fieldsets = (
        ('Device Information', {
            'fields': ('device_code', 'bound_spot')
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
