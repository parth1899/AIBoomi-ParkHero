from django.db import models
from django.contrib.auth.models import User
from common.models import TimeStampedModel
from apps.atlas.models import ParkingSpot


class Booking(TimeStampedModel):
    """
    Parking spot booking with time window and access control.
    """
    STATUS_CHOICES = [
        ('pending_approval', 'Pending Approval'),
        ('reserved', 'Reserved'),
        ('active', 'Active'),
        ('completed', 'Completed'),
        ('cancelled', 'Cancelled'),
        ('rejected', 'Rejected'),
    ]
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='bookings'
    )
    spot = models.ForeignKey(
        ParkingSpot,
        on_delete=models.CASCADE,
        related_name='bookings'
    )
    start_time = models.DateTimeField()
    end_time = models.DateTimeField()
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='reserved'
    )
    access_code = models.CharField(
        max_length=8,
        unique=True,
        help_text="Unique access code for entry verification"
    )
    
    # P2P Approval fields
    host_user = models.ForeignKey(
        User,
        on_delete=models.SET_NULL,
        related_name='hosted_bookings',
        null=True,
        blank=True,
        help_text="Facility owner who needs to approve (for P2P)"
    )
    rejection_reason = models.TextField(
        null=True,
        blank=True,
        help_text="Reason for rejection (if rejected)"
    )
    
    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['spot', 'start_time', 'end_time']),
            models.Index(fields=['user', 'status']),
            models.Index(fields=['access_code']),
        ]
    
    def __str__(self):
        return f"Booking {self.id} - {self.user.username} - {self.spot.code}"
    
    @property
    def is_active(self):
        """Check if booking is currently active."""
        from django.utils import timezone
        now = timezone.now()
        return (
            self.status in ['reserved', 'active'] and
            self.start_time <= now <= self.end_time
        )
