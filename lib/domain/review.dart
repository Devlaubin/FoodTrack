class Review {
  const Review({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
  });

  final String id;
  final String authorName;
  final int rating;
  final String comment;
}
