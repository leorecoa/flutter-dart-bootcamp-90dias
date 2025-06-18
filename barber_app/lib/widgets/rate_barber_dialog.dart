import 'package:flutter/material.dart';
import '../models/barber.dart';
import '../services/analytics_service.dart';
import '../utils/constants.dart';
import 'rating_bar.dart';

class RateBarberDialog extends StatefulWidget {
  final Barber barber;
  final Function(double, String) onSubmit;

  const RateBarberDialog({
    Key? key,
    required this.barber,
    required this.onSubmit,
  }) : super(key: key);

  static Future<void> show({
    required BuildContext context,
    required Barber barber,
    required Function(double, String) onSubmit,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return RateBarberDialog(
          barber: barber,
          onSubmit: onSubmit,
        );
      },
    );
  }

  @override
  State<RateBarberDialog> createState() => _RateBarberDialogState();
}

class _RateBarberDialogState extends State<RateBarberDialog> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Track rating event
      await AnalyticsService().trackRateBarber(widget.barber, _rating);
      
      // Submit rating
      widget.onSubmit(_rating, _commentController.text);
      
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar avaliação: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      backgroundColor: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Avalie seu barbeiro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                border: Border.all(
                  color: AppColors.secondary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: widget.barber.imageUrl != null && widget.barber.imageUrl!.isNotEmpty
                    ? Image.network(
                        widget.barber.imageUrl!,
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
            const SizedBox(height: 12),
            Text(
              widget.barber.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            RatingBar(
              rating: _rating,
              size: 40,
              showRatingText: false,
              interactive: true,
              onRatingChanged: (value) {
                setState(() {
                  _rating = value;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Deixe um comentário (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Enviar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}