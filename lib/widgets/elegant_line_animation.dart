import 'dart:ui';
import 'package:flutter/material.dart';

class ElegantLineAnimation extends StatefulWidget {
  const ElegantLineAnimation({super.key});

  @override
  State<ElegantLineAnimation> createState() => _ElegantLineAnimationState();
}

class _ElegantLineAnimationState extends State<ElegantLineAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // 10 seconds for a slow, graceful drawing effect
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60, // Fixed height for the ribbon
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _ElegantLinePainter(_animation.value),
          );
        },
      ),
    );
  }
}

class _ElegantLinePainter extends CustomPainter {
  final double progress;

  _ElegantLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF444444).withOpacity(0.3) // Soft dark gray, low opacity
      ..strokeWidth = 1.0 // Ultra-thin
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double cy = h / 2;

    path.moveTo(0, cy);

    // Smooth wave leading into the first loop
    path.cubicTo(
      w * 0.1, cy - h * 0.6,
      w * 0.2, cy + h * 0.6,
      w * 0.3, cy,
    );

    // Subtle infinity ribbon loop
    path.cubicTo(
      w * 0.55, cy - h * 1.8, // Control point 1: Pull far right and up
      w * 0.35, cy + h * 1.8, // Control point 2: Pull back left and down (creates the intersection)
      w * 0.6, cy,            // End point: Recover and move right
    );
    
    // Second subtle loop (smaller)
    path.cubicTo(
      w * 0.8, cy + h * 1.2,
      w * 0.7, cy - h * 1.2,
      w * 0.85, cy,
    );

    // Flow off the edge
    path.quadraticBezierTo(w * 0.95, cy + h * 0.4, w, cy);

    // Animate the path drawing by extracting a segment
    final pathMetrics = path.computeMetrics().toList();
    if (pathMetrics.isNotEmpty) {
      final metric = pathMetrics.first;
      
      // We'll extract a portion of the path that moves along the curve
      // For a continuous elegant feel, we can just draw from 0 to current progress
      final extractPath = metric.extractPath(0.0, metric.length * progress);
      canvas.drawPath(extractPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ElegantLinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
