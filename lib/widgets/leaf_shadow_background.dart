import 'dart:math';
import 'package:flutter/material.dart';

class LeafShadowBackground extends StatefulWidget {
  const LeafShadowBackground({super.key});

  @override
  State<LeafShadowBackground> createState() => _LeafShadowBackgroundState();
}

class _LeafShadowBackgroundState extends State<LeafShadowBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 15 seconds for a slow, elegant sway
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _LeafShadowPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class _LeafShadowPainter extends CustomPainter {
  final double animationValue;

  _LeafShadowPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4A4A4A).withOpacity(0.04) // Very soft, elegant shadow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 35); // High blur for shadow effect

    // Gentle swaying motions
    double sway1 = sin(animationValue * 2 * pi) * 0.08;
    double sway2 = cos(animationValue * 2 * pi) * 0.1;
    double sway3 = sin(animationValue * 3 * pi) * 0.06;
    double sway4 = cos(animationValue * pi) * 0.09;

    // Top left cluster
    _drawLeafCluster(
      canvas,
      paint,
      Offset(size.width * 0.05, size.height * 0.1),
      sway1 + pi / 4,
      1.6,
    );

    // Bottom right cluster
    _drawLeafCluster(
      canvas,
      paint,
      Offset(size.width * 0.95, size.height * 0.75),
      sway2 - pi * 0.8,
      2.2,
    );

    // Top right cluster
    _drawLeafCluster(
      canvas,
      paint,
      Offset(size.width * 0.85, size.height * 0.05),
      sway3 + pi * 0.6,
      1.4,
    );

    // Bottom left cluster
    _drawLeafCluster(
      canvas,
      paint,
      Offset(size.width * 0.15, size.height * 0.85),
      sway4 - pi / 6,
      1.8,
    );
  }

  void _drawLeafCluster(Canvas canvas, Paint paint, Offset center, double rotation, double scale) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    // Draw a branch of leaves
    _drawLeaf(canvas, paint, const Offset(0, 0), 0, 1.0);
    _drawLeaf(canvas, paint, const Offset(30, 20), pi / 5, 0.8);
    _drawLeaf(canvas, paint, const Offset(25, -25), -pi / 4, 0.9);
    _drawLeaf(canvas, paint, const Offset(60, 10), pi / 8, 0.7);
    _drawLeaf(canvas, paint, const Offset(55, -15), -pi / 6, 0.75);

    canvas.restore();
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset offset, double rotation, double scale) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.rotate(rotation);
    canvas.scale(scale);

    final path = Path();
    path.moveTo(0, 0);
    // Draw a simple leaf shape
    path.quadraticBezierTo(25, -15, 50, 0);
    path.quadraticBezierTo(25, 15, 0, 0);

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LeafShadowPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
