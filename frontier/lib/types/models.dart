import 'package:flutter/material.dart';

enum SpotStatus { available, occupied, reserved }

enum BookingStatus { pending, reserved, active, completed, cancelled, rejected }

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
  final String? apiId;
  final String name;
  final String imageAsset;
  final String? imageUrl;
  final int? totalSpots;
  final int? availableSpots;
  final List<ParkingSpot> spots;

  const ParkingFloor({
    required this.id,
    this.apiId,
    required this.name,
    required this.imageAsset,
    this.imageUrl,
    this.totalSpots,
    this.availableSpots,
    required this.spots,
  });
}

class ParkingLot {
  final String id;
  final String name;
  final String address;
  final String? facilityType;
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
  final bool requiresApproval;
  final String? ownerName;

  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    this.facilityType,
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
    this.requiresApproval = false,
    this.ownerName,
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
  final String? accessCode;
  final String? qrPayload;
  final bool? requiresApproval;
  final String? hostName;
  final String? rejectionReason;
  final double? latitude;
  final double? longitude;

  const Booking({
    required this.id,
    required this.lotName,
    required this.spotLabel,
    required this.floor,
    required this.dateLabel,
    required this.timeLabel,
    required this.status,
    required this.imageAsset,
    this.accessCode,
    this.qrPayload,
    this.requiresApproval,
    this.hostName,
    this.rejectionReason,
    this.latitude,
    this.longitude,
  });

  Booking copyWith({
    String? id,
    String? lotName,
    String? spotLabel,
    String? floor,
    String? dateLabel,
    String? timeLabel,
    BookingStatus? status,
    String? imageAsset,
    String? accessCode,
    String? qrPayload,
    bool? requiresApproval,
    String? hostName,
    String? rejectionReason,
    double? latitude,
    double? longitude,
  }) {
    return Booking(
      id: id ?? this.id,
      lotName: lotName ?? this.lotName,
      spotLabel: spotLabel ?? this.spotLabel,
      floor: floor ?? this.floor,
      dateLabel: dateLabel ?? this.dateLabel,
      timeLabel: timeLabel ?? this.timeLabel,
      status: status ?? this.status,
      imageAsset: imageAsset ?? this.imageAsset,
      accessCode: accessCode ?? this.accessCode,
      qrPayload: qrPayload ?? this.qrPayload,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      hostName: hostName ?? this.hostName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class AccessValidationResult {
  final bool valid;
  final String? bookingId;
  final String? facility;
  final String? spot;
  final String? status;

  const AccessValidationResult({
    required this.valid,
    this.bookingId,
    this.facility,
    this.spot,
    this.status,
  });
}

class LockboxQrResult {
  final String bookingId;
  final String? qrPayload;
  final String? qrImageBase64;
  final String? accessCode;
  final String? facility;
  final String? spot;

  const LockboxQrResult({
    required this.bookingId,
    this.qrPayload,
    this.qrImageBase64,
    this.accessCode,
    this.facility,
    this.spot,
  });
}

class BarrierValidationResult {
  final bool valid;
  final String? action;
  final String? facility;
  final String? spot;
  final String? bookingId;
  final int? spotsAvailable;
  final String? error;

  const BarrierValidationResult({
    required this.valid,
    this.action,
    this.facility,
    this.spot,
    this.bookingId,
    this.spotsAvailable,
    this.error,
  });
}

class IncomingBooking {
  final String id;
  final String status;
  final String? userName;
  final String? userFirstName;
  final String? userLastName;
  final String? userEmail;
  final String? facilityName;
  final String? spotCode;
  final String? floorLabel;
  final String? startTime;
  final String? endTime;
  final String? accessCode;
  final String? createdAt;

  const IncomingBooking({
    required this.id,
    required this.status,
    this.userName,
    this.userFirstName,
    this.userLastName,
    this.userEmail,
    this.facilityName,
    this.spotCode,
    this.floorLabel,
    this.startTime,
    this.endTime,
    this.accessCode,
    this.createdAt,
  });

  factory IncomingBooking.fromJson(Map<String, dynamic> data) {
    return IncomingBooking(
      id: data['id'].toString(),
      status: data['status']?.toString() ?? 'pending_approval',
      userName: data['user_name'] as String?,
      userFirstName: data['user_first_name'] as String?,
      userLastName: data['user_last_name'] as String?,
      userEmail: data['user_email'] as String?,
      facilityName: data['facility_name'] as String?,
      spotCode: data['spot_code'] as String?,
      floorLabel: data['floor_label'] as String?,
      startTime: data['start_time'] as String?,
      endTime: data['end_time'] as String?,
      accessCode: data['access_code'] as String?,
      createdAt: data['created_at'] as String?,
    );
  }
}

class FloorMapArgs {
  final ParkingFloor floor;
  final ParkingLot lot;

  const FloorMapArgs({
    required this.floor,
    required this.lot,
  });
}
