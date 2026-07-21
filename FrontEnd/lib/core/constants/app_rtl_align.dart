import 'package:flutter/material.dart';

class RtlAlign extends StatelessWidget {
  final Widget child;

  const RtlAlign({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: isArabic
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: child,
    );
  }
}