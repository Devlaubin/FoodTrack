import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:foodtruck_app/domain/foodtruck_icons.dart';

class FoodTruck {
  const FoodTruck({
    required this.id,
    required this.name,
    this.description,
    this.bio,
    this.cuisineType,
    this.phone,
    this.serviceType,
    this.socialInstagram,
    this.socialFacebook,
    this.socialTiktok,
    this.socialX,
    this.socialWebsite,
    required this.latitude,
    required this.longitude,
    this.isOpen = true,
    this.status = 'Ouvert',
    this.openingHours,
    this.imageUrl,
    this.ownerId,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.proSince,
  });

  final String id;
  final String name;
  final String? description;
  final String? bio;
  final String? cuisineType;
  final String? phone;
  final String? serviceType;
  final String? socialInstagram;
  final String? socialFacebook;
  final String? socialTiktok;
  final String? socialX;
  final String? socialWebsite;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final String status;
  final Map<String, DayHours>? openingHours;
  final String? imageUrl;
  final String? ownerId;
  final double averageRating;
  final int reviewCount;
  final DateTime? proSince;

  LatLng get position => LatLng(latitude, longitude);

  /// Returns the IconData for this foodtruck's chosen logo.
  /// Falls back to [Icons.fastfood] if no icon is selected.
  IconData get logoIcon => resolveIcon(imageUrl);

  factory FoodTruck.fromJson(Map<String, dynamic> json) {
    final hoursMap = <String, DayHours>{};
    if (json['opening_hours'] != null && json['opening_hours'] is Map) {
      final hours = json['opening_hours'] as Map<String, dynamic>;
      hours.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          hoursMap[key] = DayHours.fromJson(value);
        }
      });
    }

    return FoodTruck(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      bio: json['bio'] as String?,
      cuisineType: json['cuisine_type'] as String?,
      phone: json['phone'] as String?,
      serviceType: json['service_type'] as String?,
      socialInstagram: json['social_instagram'] as String?,
      socialFacebook: json['social_facebook'] as String?,
      socialTiktok: json['social_tiktok'] as String?,
      socialX: json['social_x'] as String?,
      socialWebsite: json['social_website'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['is_open'] as bool? ?? true,
      status: json['status'] as String? ?? 'Ouvert',
      openingHours: hoursMap.isNotEmpty ? hoursMap : null,
      imageUrl: json['image_url'] as String?,
      ownerId: json['owner_id'] as String?,
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['review_count'] as int? ?? 0,
      proSince: json['pro_since'] != null
          ? DateTime.tryParse(json['pro_since'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'bio': bio,
      'cuisine_type': cuisineType,
      'phone': phone,
      'service_type': serviceType,
      'social_instagram': socialInstagram,
      'social_facebook': socialFacebook,
      'social_tiktok': socialTiktok,
      'social_x': socialX,
      'social_website': socialWebsite,
      'latitude': latitude,
      'longitude': longitude,
      'is_open': isOpen,
      'status': status,
      'opening_hours': openingHours?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'image_url': imageUrl,
      'owner_id': ownerId,
      'average_rating': averageRating,
      'review_count': reviewCount,
      'pro_since': proSince?.toIso8601String(),
    };
  }

  /// Returns a copy of this foodtruck with the given fields replaced.
  FoodTruck copyWith({
    String? name,
    String? description,
    String? bio,
    String? cuisineType,
    String? phone,
    String? serviceType,
    String? socialInstagram,
    String? socialFacebook,
    String? socialTiktok,
    String? socialX,
    String? socialWebsite,
    double? latitude,
    double? longitude,
    bool? isOpen,
    String? status,
    Map<String, DayHours>? openingHours,
    String? imageUrl,
    double? averageRating,
    int? reviewCount,
  }) {
    return FoodTruck(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      bio: bio ?? this.bio,
      cuisineType: cuisineType ?? this.cuisineType,
      phone: phone ?? this.phone,
      serviceType: serviceType ?? this.serviceType,
      socialInstagram: socialInstagram ?? this.socialInstagram,
      socialFacebook: socialFacebook ?? this.socialFacebook,
      socialTiktok: socialTiktok ?? this.socialTiktok,
      socialX: socialX ?? this.socialX,
      socialWebsite: socialWebsite ?? this.socialWebsite,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isOpen: isOpen ?? this.isOpen,
      status: status ?? this.status,
      openingHours: openingHours ?? this.openingHours,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      proSince: proSince,
    );
  }

  String? getTodayHours() {
    if (openingHours == null) return null;

    final now = DateTime.now();
    final dayNames = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final todayKey = dayNames[now.weekday % 7];
    final today = openingHours![todayKey];

    if (today == null) return null;
    return '${today.openTime} - ${today.closeTime}';
  }

  bool get isCurrentlyOpen {
    if (!isOpen || openingHours == null) return false;

    final now = DateTime.now();
    final dayNames = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final todayKey = dayNames[now.weekday % 7];
    final today = openingHours![todayKey];

    if (today == null) return false;

    try {
      final openParts = today.openTime.split(':');
      final closeParts = today.closeTime.split(':');

      final openHour = int.parse(openParts[0]);
      final openMin = int.parse(openParts[1]);
      final closeHour = int.parse(closeParts[0]);
      final closeMin = int.parse(closeParts[1]);

      final openMinutes = openHour * 60 + openMin;
      final closeMinutes = closeHour * 60 + closeMin;
      final nowMinutes = now.hour * 60 + now.minute;

      if (closeMinutes < openMinutes) {
        // Overnight hours
        return nowMinutes >= openMinutes || nowMinutes < closeMinutes;
      }

      return nowMinutes >= openMinutes && nowMinutes < closeMinutes;
    } catch (_) {
      return isOpen;
    }
  }
}

class DayHours {
  const DayHours({
    required this.openTime,
    required this.closeTime,
  });

  final String openTime;
  final String closeTime;

  factory DayHours.fromJson(Map<String, dynamic> json) {
    return DayHours(
      openTime: json['open'] as String? ?? '09:00',
      closeTime: json['close'] as String? ?? '18:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open': openTime,
      'close': closeTime,
    };
  }
}
