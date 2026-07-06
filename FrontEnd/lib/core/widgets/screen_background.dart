import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class ScreenBackground extends StatelessWidget {
  final Widget child;

  const ScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFEFE7FA), AppColors.background],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -40, left: -30, child: _SoftCircle(size: 120)),
          Positioned(bottom: -50, right: -30, child: _SoftCircle(size: 150)),
          child,
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  final double size;

  const _SoftCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.6),
        shape: BoxShape.circle,
      ),
    );
  }
}
