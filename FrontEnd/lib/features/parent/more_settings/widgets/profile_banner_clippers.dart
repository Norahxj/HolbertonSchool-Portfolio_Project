import 'package:flutter/material.dart';

class BackWaveClipper extends CustomClipper<Path> {
  const BackWaveClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.48)
      ..cubicTo(
        size.width * 0.20,
        size.height * 0.05,
        size.width * 0.40,
        size.height * 0.95,
        size.width * 0.62,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.12,
        size.width * 0.90,
        size.height * 0.20,
        size.width,
        size.height * 0.58,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class FrontWaveClipper extends CustomClipper<Path> {
  const FrontWaveClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.22,
        size.width * 0.34,
        size.height * 0.95,
        size.width * 0.54,
        size.height * 0.65,
      )
      ..cubicTo(
        size.width * 0.74,
        size.height * 0.35,
        size.width * 0.86,
        size.height * 0.30,
        size.width,
        size.height * 0.68,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
