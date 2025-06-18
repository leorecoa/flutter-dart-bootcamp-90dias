import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TimeSelector extends StatefulWidget {
  final List<DateTime> availableTimes;
  final DateTime? selectedTime;
  final Function(DateTime) onTimeSelected;

  const TimeSelector({
    Key? key,
    required this.availableTimes,
    this.selectedTime,
    required this.onTimeSelected,
  }) : super(key: key);

  @override
  State<TimeSelector> createState() => _TimeSelectorState();
}

class _TimeSelectorState extends State<TimeSelector> {
  DateTime? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.selectedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'Selecione o horário',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        widget.availableTimes.isEmpty
            ? _buildNoTimesAvailable()
            : _buildTimeGrid(),
      ],
    );
  }

  Widget _buildNoTimesAvailable() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        border: Border.all(color: Colors.red.withAlpha(100)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.access_time,
            color: Colors.red,
            size: 40,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhum horário disponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Por favor, selecione outra data ou barbeiro',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    // Group times by morning, afternoon, evening
    final morning = <DateTime>[];
    final afternoon = <DateTime>[];
    final evening = <DateTime>[];

    for (final time in widget.availableTimes) {
      final hour = time.hour;
      if (hour < 12) {
        morning.add(time);
      } else if (hour < 18) {
        afternoon.add(time);
      } else {
        evening.add(time);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (morning.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Manhã',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _buildTimeSection(morning),
            const SizedBox(height: 16),
          ],
          if (afternoon.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Tarde',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _buildTimeSection(afternoon),
            const SizedBox(height: 16),
          ],
          if (evening.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Noite',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            _buildTimeSection(evening),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSection(List<DateTime> times) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: times.map((time) {
        final isSelected = _selectedTime != null &&
            _selectedTime!.hour == time.hour &&
            _selectedTime!.minute == time.minute;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedTime = time;
            });
            widget.onTimeSelected(time);
          },
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.secondary : AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSizes.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? AppColors.secondary.withAlpha(100)
                      : Colors.black.withAlpha(20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}