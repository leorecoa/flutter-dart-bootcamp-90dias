import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class DateSelector extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime) onDateSelected;
  final int daysToShow;

  const DateSelector({
    Key? key,
    required this.initialDate,
    required this.onDateSelected,
    this.daysToShow = 14,
  }) : super(key: key);

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late DateTime _selectedDate;
  late List<DateTime> _dates;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _generateDates();
    _scrollController = ScrollController();
    
    // Scroll to selected date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final index = _dates.indexWhere((date) => 
        date.year == _selectedDate.year && 
        date.month == _selectedDate.month && 
        date.day == _selectedDate.day
      );
      
      if (index >= 0) {
        _scrollController.animateTo(
          index * 80.0, // Item width + padding
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _generateDates() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    
    _dates = List.generate(widget.daysToShow, (index) {
      return startDate.add(Duration(days: index));
    });
    
    // Ensure selected date is in range
    if (_selectedDate.isBefore(startDate)) {
      _selectedDate = startDate;
    } else if (_selectedDate.isAfter(startDate.add(Duration(days: widget.daysToShow - 1)))) {
      _selectedDate = startDate.add(Duration(days: widget.daysToShow - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, bottom: 12),
          child: Text(
            'Selecione a data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: _dates.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final date = _dates[index];
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday = date.year == DateTime.now().year &&
                  date.month == DateTime.now().month &&
                  date.day == DateTime.now().day;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                  widget.onDateSelected(date);
                },
                child: Container(
                  width: 70,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? AppColors.secondary.withAlpha(100)
                            : Colors.black.withAlpha(20),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('EEE').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : isToday
                                  ? AppColors.secondary.withAlpha(30)
                                  : Colors.transparent,
                          border: Border.all(
                            color: isToday && !isSelected
                                ? AppColors.secondary
                                : Colors.transparent,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.secondary
                                  : isToday
                                      ? AppColors.secondary
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        DateFormat('MMM').format(date).toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}