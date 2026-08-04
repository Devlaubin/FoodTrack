/// A rating + optional comment left by a user on a foodtruck.
class Review {
  const Review({
    required this.id,
    required this.foodtruckId,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String foodtruckId;
  final String userId;
  final String authorName;
  final int rating;
  final String comment;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      foodtruckId: json['foodtruck_id'] as String,
      userId: json['user_id'] as String,
      authorName: json['author_name'] as String? ?? 'Client',
      rating: (json['rating'] as num?)?.toInt() ?? 5,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodtruck_id': foodtruckId,
      'user_id': userId,
      'author_name': authorName,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

