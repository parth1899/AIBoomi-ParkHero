from django.db import models
from django.contrib.auth.models import User
from common.models import TimeStampedModel


class Facility(TimeStampedModel):
    """
    Parking facility/location - source of truth for parking inventory.
    """
    TYPE_CHOICES = [
        ('mall', 'Shopping Mall'),
        ('office', 'Office Building'),
        ('lot', 'Parking Lot'),
    ]
    
    ONBOARDING_TYPE_CHOICES = [
        ('enterprise', 'Enterprise'),
        ('small', 'Small Business'),
        ('p2p', 'Peer-to-Peer'),
    ]
    
    name = models.CharField(max_length=255)
    type = models.CharField(max_length=20, choices=TYPE_CHOICES)
    address = models.TextField()
    onboarding_type = models.CharField(
        max_length=20, 
        choices=ONBOARDING_TYPE_CHOICES,
        default='small'
    )
    confidence_score = models.IntegerField(default=80)
    
    # P2P Marketplace fields
    owner = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='owned_facilities',
        null=True,
        blank=True,
        help_text="Facility owner for P2P marketplace"
    )
    hourly_rate = models.DecimalField(
        max_digits=8,
        decimal_places=2,
        null=True,
        blank=True,
        help_text="Hourly parking rate in INR"
    )
    daily_rate = models.DecimalField(
        max_digits=8,
        decimal_places=2,
        null=True,
        blank=True,
        help_text="Daily parking rate in INR"
    )
    latitute = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Latitude of the facility"
    )
    longitude = models.DecimalField(
        max_digits=9,
        decimal_places=6,
        null=True,
        blank=True,
        help_text="Longitude of the facility"
    )
    
    class Meta:
        verbose_name_plural = "Facilities"
        ordering = ['-created_at']
    
    def __str__(self):
        return f"{self.name} ({self.get_type_display()})"


class Floor(TimeStampedModel):
    """
    Floor within a parking facility with floorplan image.
    """
    facility = models.ForeignKey(
        Facility, 
        on_delete=models.CASCADE,
        related_name='floors'
    )
    label = models.CharField(max_length=10, help_text="e.g., B1, P2, Ground")
    floorplan_image = models.ImageField(
        upload_to='floorplans/',
        null=True,
        blank=True
    )
    
    class Meta:
        ordering = ['label']
        unique_together = ['facility', 'label']
    
    def __str__(self):
        return f"{self.facility.name} - Floor {self.label}"


class ParkingSpot(TimeStampedModel):
    """
    Individual parking spot with coordinates and status.
    """
    STATUS_CHOICES = [
        ('available', 'Available'),
        ('occupied', 'Occupied'),
        ('reserved', 'Reserved'),
        ('blocked', 'Blocked'),
    ]
    
    floor = models.ForeignKey(
        Floor,
        on_delete=models.CASCADE,
        related_name='spots'
    )
    code = models.CharField(max_length=20, help_text="Spot identifier, e.g., A-101")
    x = models.FloatField(help_text="X coordinate on floorplan")
    y = models.FloatField(help_text="Y coordinate on floorplan")
    status = models.CharField(
        max_length=20,
        choices=STATUS_CHOICES,
        default='available'
    )
    verified = models.BooleanField(
        default=False,
        help_text="Whether spot has been verified by installer"
    )
    distance_from_entry = models.IntegerField(
        default=0,
        help_text="Distance from entry in meters (for closest spot logic)"
    )
    
    class Meta:
        ordering = ['distance_from_entry', 'code']
        unique_together = ['floor', 'code']
    
    def __str__(self):
        return f"{self.floor.facility.name} - {self.floor.label} - {self.code}"


class Device(TimeStampedModel):
    """
    IoT devices (Simulated).
    Can be:
    1. Sensors: Bound to a specific spot (Mall scenario)
    2. Barriers: Bound to a facility entrance (Small lot/Homeowner scenario)
    """
    DEVICE_TYPES = [
        ('sensor', 'Parking Spot Sensor'),
        ('barrier', 'QR Boom Barrier'),
    ]

    device_code = models.CharField(max_length=50, unique=True)
    device_type = models.CharField(max_length=20, choices=DEVICE_TYPES, default='sensor')
    
    # For sensors: bound to specific spot
    bound_spot = models.OneToOneField(
        ParkingSpot, 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True,
        related_name='device'
    )
    
    # For barriers: bound to facility entrance
    bound_facility = models.ForeignKey(
        Facility,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='barriers'
    )

    def __str__(self):
        type_icon = "📡" if self.device_type == 'sensor' else "🚧"
        if self.bound_spot:
            return f"{type_icon} {self.device_code} ({self.bound_spot.code})"
        elif self.bound_facility:
            return f"{type_icon} {self.device_code} ({self.bound_facility.name})"
        return f"{type_icon} {self.device_code}"
