import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum NotificationType { success, error, info, warning }

class CustomNotification extends StatelessWidget {
  final String message;
  final NotificationType type;
  final VoidCallback? onDismiss;
  final Duration duration;
  final bool showIcon;

  const CustomNotification({
    Key? key,
    required this.message,
    this.type = NotificationType.info,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
    this.showIcon = true,
  }) : super(key: key);

  // Static method to show notification
  static void show({
    required BuildContext context,
    required String message,
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    bool showIcon = true,
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: CustomNotification(
            message: message,
            type: type,
            duration: duration,
            showIcon: showIcon,
            onDismiss: () {
              overlayEntry.remove();
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(duration, () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(AppSizes.borderRadius),
            boxShadow: [
              BoxShadow(
                color: _getShadowColor(),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              if (showIcon) ...[
                _getIcon(),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: _getTextColor(),
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: _getTextColor(),
                  size: 18,
                ),
                onPressed: onDismiss,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (type) {
      case NotificationType.success:
        return Colors.green.shade800;
      case NotificationType.error:
        return Colors.red.shade800;
      case NotificationType.warning:
        return Colors.orange.shade800;
      case NotificationType.info:
      default:
        return AppColors.secondary;
    }
  }

  Color _getShadowColor() {
    switch (type) {
      case NotificationType.success:
        return Colors.green.withAlpha(100);
      case NotificationType.error:
        return Colors.red.withAlpha(100);
      case NotificationType.warning:
        return Colors.orange.withAlpha(100);
      case NotificationType.info:
      default:
        return AppColors.secondary.withAlpha(100);
    }
  }

  Color _getTextColor() {
    return Colors.white;
  }

  Widget _getIcon() {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case NotificationType.success:
        iconData = Icons.check_circle;
        iconColor = Colors.white;
        break;
      case NotificationType.error:
        iconData = Icons.error;
        iconColor = Colors.white;
        break;
      case NotificationType.warning:
        iconData = Icons.warning;
        iconColor = Colors.white;
        break;
      case NotificationType.info:
      default:
        iconData = Icons.info;
        iconColor = Colors.white;
        break;
    }

    return Icon(
      iconData,
      color: iconColor,
      size: 24,
    );
  }
}
