import 'package:flutter/material.dart';
import '../models/barber.dart';
import '../utils/constants.dart';
import 'rating_bar.dart';

class BarberCard extends StatelessWidget {
  final Barber barber;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDetails;

  const BarberCard({
    Key? key,
    required this.barber,
    this.isSelected = false,
    required this.onTap,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: showDetails ? double.infinity : 140,
        margin: const EdgeInsets.only(right: 16, bottom: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withAlpha(30)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: showDetails ? _buildDetailedCard() : _buildCompactCard(),
      ),
    );
  }

  Widget _buildCompactCard() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withAlpha(isSelected ? 50 : 0),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: barber.imageUrl.isNotEmpty
                ? Image.network(
                    barber.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        color: AppColors.secondary,
                        size: 36,
                      );
                    },
                  )
                : const Icon(
                    Icons.person,
                    color: AppColors.secondary,
                    size: 36,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          barber.name.split(' ')[0],
          style: TextStyle(
            color: isSelected ? AppColors.secondary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        RatingBar(
          rating: barber.rating,
          size: 14,
          showRatingText: false,
        ),
      ],
    );
  }

  Widget _buildDetailedCard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              border: Border.all(
                color: isSelected ? AppColors.secondary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withAlpha(isSelected ? 50 : 0),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: barber.imageUrl.isNotEmpty
                  ? Image.network(
                      barber.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          color: AppColors.secondary,
                          size: 40,
                        );
                      },
                    )
                  : const Icon(
                      Icons.person,
                      color: AppColors.secondary,
                      size: 40,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barber.name,
                  style: TextStyle(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                RatingBar(
                  rating: barber.rating,
                  size: 16,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: barber.specialties.map((specialty) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondary.withAlpha(100),
                        ),
                      ),
                      child: Text(
                        specialty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(
              Icons.check_circle,
              color: AppColors.secondary,
              size: 24,
            ),
        ],
      ),
    );
  }
}
