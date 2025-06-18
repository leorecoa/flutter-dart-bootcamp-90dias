import 'package:flutter/material.dart';
import '../utils/constants.dart';

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final bool showRatingText;
  final bool interactive;
  final ValueChanged<double>? onRatingChanged;

  const RatingBar({
    Key? key,
    required this.rating,
    this.size = 16,
    this.showRatingText = true,
    this.interactive = false,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: interactive
                  ? () => onRatingChanged?.call(index + 1.0)
                  : null,
              child: Icon(
                index < rating.floor()
                    ? Icons.star
                    : index < rating
                        ? Icons.star_half
                        : Icons.star_border,
                color: AppColors.secondary,
                size: size,
              ),
            );
          }),
        ),
        if (showRatingText) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}