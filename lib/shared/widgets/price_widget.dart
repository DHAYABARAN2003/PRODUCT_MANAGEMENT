import 'package:flutter/material.dart';

class PriceWidget extends StatelessWidget {
  final double price;
  final double discountPercentage;
  final TextStyle? priceStyle;
  final TextStyle? originalPriceStyle;

  const PriceWidget({
    super.key,
    required this.price,
    this.discountPercentage = 0,
    this.priceStyle,
    this.originalPriceStyle,
  });

  double get discountedPrice => price - (price * discountPercentage / 100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${discountedPrice.toStringAsFixed(2)}',
          style: priceStyle ??
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
        ),
        if (discountPercentage > 0) ...[
          const SizedBox(width: 8),
          Text(
            '₹${price.toStringAsFixed(2)}',
            style: originalPriceStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '-${discountPercentage.toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
