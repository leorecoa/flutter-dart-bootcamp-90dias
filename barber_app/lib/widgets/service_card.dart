import 'package:flutter/material.dart';
import '../models/service.dart';
import '../utils/constants.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem do serviço
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.borderRadius),
                  topRight: Radius.circular(AppSizes.borderRadius),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.content_cut,
                  color: AppColors.secondary,
                  size: 40,
                ),
              ),
            ),
            
            // Informações do serviço
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: AppTextStyles.subheading.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: AppColors.secondary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.durationMinutes} min',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (service.hasDiscount) ...[
                    Text(
                      'R\$${service.price.toStringAsFixed(2)}',
                      style: AppTextStyles.priceDiscount.copyWith(fontSize: 12),
                    ),
                    Text(
                      'R\$${service.discountPrice.toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(fontSize: 14),
                    ),
                  ] else
                    Text(
                      'R\$${service.price.toStringAsFixed(2)}',
                      style: AppTextStyles.price.copyWith(fontSize: 14),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}