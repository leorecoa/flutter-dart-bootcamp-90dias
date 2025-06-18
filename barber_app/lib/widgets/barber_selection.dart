import 'package:flutter/material.dart';
import '../models/barber.dart';
import '../utils/constants.dart';

class BarberSelection extends StatefulWidget {
  final List<Barber> barbers;
  final Function(Barber) onSelected;

  const BarberSelection({
    Key? key,
    required this.barbers,
    required this.onSelected,
  }) : super(key: key);

  @override
  State<BarberSelection> createState() => _BarberSelectionState();
}

class _BarberSelectionState extends State<BarberSelection> {
  Barber? _selectedBarber;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.barbers.length,
        itemBuilder: (context, index) {
          final barber = widget.barbers[index];
          final isSelected = _selectedBarber?.id == barber.id;
          
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedBarber = barber;
              });
              widget.onSelected(barber);
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary.withAlpha(51) : AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(
                  color: isSelected ? AppColors.secondary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.secondary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    barber.name.split(' ')[0],
                    style: TextStyle(
                      color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.secondary,
                        size: 14,
                      ),
                      Text(
                        ' ${barber.rating}',
                        style: TextStyle(
                          color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}