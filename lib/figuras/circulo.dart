import 'package:flutter/material.dart';

class Circulo extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;

  Circulo({
    required this.radius,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);

    // radio máximo permitido
    final double halfMinSide = (size.shortestSide - strokeWidth) / 2.0;
    final double maxR = radius.clamp(0.0, halfMinSide);

    Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, maxR, paint);
  }

  @override
  bool shouldRepaint(Circulo old) {
    return old.radius != radius ||
        old.color != color ||
        old.strokeWidth != strokeWidth;
  }
}
