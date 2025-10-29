import 'package:flutter/material.dart';
import 'dart:math';

/// Widget tła z efektem gwiazd
class StarryBackground extends StatelessWidget {
  final Widget child;
  final int starCount;

  const StarryBackground({
    super.key,
    required this.child,
    this.starCount = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient tła
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0E27), // Ciemny granat góra
                Color(0xFF1A1F3A), // Nieco jaśniejszy dół
                Color(0xFF0A0E27),
              ],
            ),
          ),
        ),
        // Gwiazdy
        CustomPaint(
          painter: StarsPainter(starCount: starCount),
          child: Container(),
        ),
        // Treść
        child,
      ],
    );
  }
}

/// Painter rysujący gwiazdy
class StarsPainter extends CustomPainter {
  final int starCount;
  final Random random = Random(); // Usuń seed

  StarsPainter({required this.starCount});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      final opacity = random.nextDouble() * 0.5 + 0.5; // Zwiększ widoczność

      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}