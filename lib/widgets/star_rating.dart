import 'package:flutter/material.dart';
import 'package:foodtruck_app/theme/colors.dart';

/// Displays a row of 5 stars.
/// - If [rating] is provided it shows a read-only rating (supports halves).
/// - If [onRatingChanged] is provided, stars become interactive (tap to rate).
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    this.rating = 0,
    this.size = 18,
    this.onRatingChanged,
    this.showValue = false,
  });

  final double rating;
  final double size;
  final ValueChanged<int>? onRatingChanged;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final interactive = onRatingChanged != null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: interactive ? () => onRatingChanged!(i) : null,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: interactive ? 2 : 1),
              child: Icon(_iconFor(i), size: size, color: _colorFor(i)),
            ),
          ),
        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: FoodtrackColors.noirBrule,
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconFor(int star) {
    if (onRatingChanged != null) {
      // Interactive: show filled/outline based on current rating (rounded).
      final threshold = rating.round();
      return star <= threshold ? Icons.star_rounded : Icons.star_border_rounded;
    }

    // Read-only with half-star support.
    if (rating >= star - 0.25) {
      return Icons.star_rounded;
    }
    if (rating >= star - 0.75) {
      return Icons.star_half_rounded;
    }
    return Icons.star_border_rounded;
  }

  Color _colorFor(int star) {
    if (onRatingChanged != null) {
      final threshold = rating.round();
      return star <= threshold
          ? FoodtrackColors.jauneMoutarde
          : FoodtrackColors.noirBrule.withOpacity(0.2);
    }
    if (rating >= star - 0.25) {
      return FoodtrackColors.jauneMoutarde;
    }
    if (rating >= star - 0.75) {
      return FoodtrackColors.jauneMoutarde;
    }
    return FoodtrackColors.noirBrule.withOpacity(0.2);
  }
}
