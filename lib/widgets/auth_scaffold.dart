import 'package:flutter/material.dart';
import '../core/theme.dart';

class AuthScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(size: Size(170, 120), painter: _SwooshPainter()),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(title, style: text.headlineLarge),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: text.bodyLarge?.copyWith(color: AppColors.muted),
                      ),
                      const SizedBox(height: 28),
                      child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwooshPainter extends CustomPainter {
  const _SwooshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final orange = Path()
      ..moveTo(60, 0)
      ..lineTo(170, 0)
      ..lineTo(170, 90)
      ..cubicTo(140, 70, 100, 40, 60, 0)
      ..close();
    final brown = Path()
      ..moveTo(95, 0)
      ..lineTo(170, 0)
      ..lineTo(170, 70)
      ..cubicTo(140, 55, 115, 30, 95, 0)
      ..close();
    canvas.drawPath(orange, Paint()..color = AppColors.orange);
    canvas.drawPath(brown, Paint()..color = AppColors.brown);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}