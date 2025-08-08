// lib/widgets/live_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../app_colors.dart';

// This is a reusable, code-based animation widget
class LiveBackground extends StatefulWidget {
  final int numberOfStars;
  const LiveBackground({super.key, this.numberOfStars = 200});

  @override
  State<LiveBackground> createState() => _LiveBackgroundState();
}

class _LiveBackgroundState extends State<LiveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _stars = List.generate(
      widget.numberOfStars,
      (index) => _Star(
        position: Offset(Random().nextDouble(), Random().nextDouble()),
        radius: Random().nextDouble() * 1.5 + 0.5,
        twinkleSpeed: Random().nextDouble() * 2 + 1,
      ),
    );
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
          size: Size.infinite,
          painter: _StarfieldPainter(
            time: _controller.value,
            stars: _stars,
          ),
        );
      },
    );
  }
}

// This CustomPainter handles the drawing of each star
class _StarfieldPainter extends CustomPainter {
  final double time;
  final List<_Star> stars;

  _StarfieldPainter({required this.time, required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    for (var star in stars) {
      final opacity = (sin(time * 2 * pi * star.twinkleSpeed) + 1) / 2;
      final paint = Paint()
        ..color = AppColors.lightAccent.withOpacity(opacity * 0.8)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(star.position.dx * size.width, star.position.dy * size.height),
        star.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// A simple class to hold the properties of each star
class _Star {
  final Offset position;
  final double radius;
  final double twinkleSpeed;

  _Star({required this.position, required this.radius, required this.twinkleSpeed});
}