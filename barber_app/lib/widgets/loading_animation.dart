import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LoadingAnimation extends StatefulWidget {
  final double size;
  final Color color;
  final String? message;

  const LoadingAnimation({
    Key? key,
    this.size = 50.0,
    this.color = AppColors.secondary,
    this.message,
  }) : super(key: key);

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 1,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: _buildScissorsIcon(),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: widget.size * 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildScissorsIcon() {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: ScissorsPainter(color: widget.color),
      ),
    );
  }
}

class ScissorsPainter extends CustomPainter {
  final Color color;

  ScissorsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw scissors
    final handleLength = size.width * 0.4;
    final bladeLength = size.width * 0.3;

    // First blade
    canvas.drawLine(
      center,
      Offset(center.dx + bladeLength, center.dy - bladeLength),
      paint,
    );

    // Second blade
    canvas.drawLine(
      center,
      Offset(center.dx + bladeLength, center.dy + bladeLength),
      paint,
    );

    // First handle
    canvas.drawLine(
      center,
      Offset(center.dx - handleLength, center.dy - handleLength * 0.5),
      paint,
    );

    // Second handle
    canvas.drawLine(
      center,
      Offset(center.dx - handleLength, center.dy + handleLength * 0.5),
      paint,
    );

    // Center circle
    canvas.drawCircle(center, size.width * 0.08, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
