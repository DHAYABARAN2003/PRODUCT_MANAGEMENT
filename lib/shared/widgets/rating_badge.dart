import 'package:flutter/material.dart';

/// Reusable rating badge showing star icon and rating value.
class RatingBadge extends StatelessWidget {
  final double rating;
  final double size;

  const RatingBadge({
    super.key,
    required this.rating,
    this.size = 14,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _ratingColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: size,
            color: _ratingColor,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: _ratingColor,
            ),
          ),
        ],
      ),
    );
  }

  Color get _ratingColor {
    if (rating >= 4.0) return const Color(0xFF2E7D32);
    if (rating >= 3.0) return const Color(0xFFF9A825);
    return const Color(0xFFC62828);
  }
}
