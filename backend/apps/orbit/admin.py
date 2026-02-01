from django.contrib import admin
from .models import Booking


@admin.register(Booking)
class BookingAdmin(admin.ModelAdmin):
    """Admin interface for Booking model."""
    list_display = [
        'id', 'user', 'spot', 'start_time', 
        'end_time', 'status', 'access_code', 'created_at'
    ]
    list_filter = ['status', 'spot__floor__facility', 'created_at']
    search_fields = [
        'user__username', 'spot__code', 
        'access_code', 'spot__floor__facility__name'
    ]
    readonly_fields = ['access_code', 'created_at', 'updated_at']
    date_hierarchy = 'start_time'
    
    fieldsets = (
        ('Booking Information', {
            'fields': ('user', 'spot', 'status')
        }),
        ('Time Window', {
            'fields': ('start_time', 'end_time')
        }),
        ('Access Control', {
            'fields': ('access_code',)
        }),
        ('Timestamps', {
            'fields': ('created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    actions = ['cancel_bookings', 'complete_bookings']
    
    def cancel_bookings(self, request, queryset):
        """Cancel selected bookings."""
        from . import services
        count = 0
        for booking in queryset.filter(status__in=['reserved', 'active']):
            try:
                services.cancel_booking(booking.id)
                count += 1
            except ValueError:
                pass
        self.message_user(request, f"{count} booking(s) cancelled successfully.")
    cancel_bookings.short_description = "Cancel selected bookings"
    
    def complete_bookings(self, request, queryset):
        """Complete selected bookings."""
        from . import services
        count = 0
        for booking in queryset.filter(status__in=['reserved', 'active']):
            services.release_spot(booking.id)
            count += 1
        self.message_user(request, f"{count} booking(s) completed successfully.")
    complete_bookings.short_description = "Complete selected bookings"
