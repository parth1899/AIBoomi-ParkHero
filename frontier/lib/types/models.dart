import 'package:flutter/material.dart';

enum SpotStatus { available, occupied, reserved }

enum BookingStatus { active, completed, cancelled }

class ParkingAmenity {
  final String id;
  final String name;
  final IconData icon;

  const ParkingAmenity({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class ParkingSpot {
  final String id;
  final String label;
  final double x;
  final double y;
  final SpotStatus status;
  final double pricePerHour;
  final List<ParkingAmenity> amenities;

  const ParkingSpot({
    required this.id,
    required this.label,
    required this.x,
    required this.y,
    required this.status,
    required this.pricePerHour,
    this.amenities = const [],
  });
}

class ParkingFloor {
  final String id;
  final String name;
  final String imageAsset;
  final List<ParkingSpot> spots;

  const ParkingFloor({
    required this.id,
    required this.name,
    required this.imageAsset,
    required this.spots,
  });
}

class ParkingLot {
  final String id;
  final String name;
  final String address;
  final List<String> areaTags;
  final double latitude;
  final double longitude;
  final double pricePerHour;
  final double rating;
  final int reviewCount;
  final String distance;
  final String availabilityLabel;
  final bool isOpen;
  final String imageAsset;
  final List<ParkingAmenity> amenities;
  final List<ParkingFloor> floors;

  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.areaTags,
    required this.latitude,
    required this.longitude,
    required this.pricePerHour,
    required this.rating,
    required this.reviewCount,
    required this.distance,
    required this.availabilityLabel,
    required this.isOpen,
    required this.imageAsset,
    required this.amenities,
    required this.floors,
  });
}

class Booking {
  final String id;
  final String lotName;
  final String spotLabel;
  final String floor;
  final String dateLabel;
  final String timeLabel;
  final BookingStatus status;
  final String imageAsset;

  const Booking({
    required this.id,
    required this.lotName,
    required this.spotLabel,
    required this.floor,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.imageAsset,
  });
}
