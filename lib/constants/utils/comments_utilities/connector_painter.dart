import 'package:flutter/material.dart';

class ConnectorPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double avatarDiameter;
  final double lineHeight;

  ConnectorPainter({
    this.color = const Color(0xFFBDBDBD),
    this.strokeWidth = 1.2,
    required this.avatarDiameter,
    required this.lineHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    final centerX = size.width / 2;

    // line starts just below the avatar circle
    final startY = avatarDiameter;
    final endY = startY + lineHeight;

    canvas.drawLine(Offset(centerX, startY), Offset(centerX, endY), paint);
  }

  @override
  bool shouldRepaint(covariant ConnectorPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.avatarDiameter != avatarDiameter ||
      old.lineHeight != lineHeight;
}
