import 'package:latlong2/latlong.dart';

class FoodTruck {
  const FoodTruck({
    required this.id,
    required this.name,
    this.description,
    this.cuisineType,
    required this.latitude,
    required this.longitude,
    this.isOpen = true,
    this.status = 'Ouvert',
    this.openingHours,
    this.imageUrl,
    this.ownerId,
  });

  final String id;
  final String name;
  final String? description;
  final String? cuisineType;
  final double latitude;
  final double longitude;
  final bool isOpen;
  final String status;
  final Map<String, DayHours>? openingHours;
  final String? imageUrl;
  final String? ownerId;

  LatLng get position => LatLng(latitude, longitude);

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
      cuisineType: json['cuisine_type'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['is_open'] as bool? ?? true,
      status: json['status'] as String? ?? 'Ouvert',
      openingHours: hoursMap.isNotEmpty ? hoursMap : null,
      imageUrl: json['image_url'] as String?,
      ownerId: json['owner_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'cuisine_type': cuisineType,
      'latitude': latitude,
      'longitude': longitude,
      'is_open': isOpen,
      'status': status,
      'opening_hours': openingHours?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'image_url': imageUrl,
      'owner_id': ownerId,
    };
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
