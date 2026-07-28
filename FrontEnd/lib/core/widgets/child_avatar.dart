import 'package:flutter/material.dart';

class ChildAvatar extends StatelessWidget {
  final int avatarIndex;
  final double size;

  const ChildAvatar({
    super.key,
    required this.avatarIndex,
    this.size = 48,
  });

  static const List<String> _avatars = [
    'assets/avatars/avatar_boy_1.jpg',
    'assets/avatars/avatar_boy_2.jpg',
    'assets/avatars/avatar_girl_1.jpg',
    'assets/avatars/avatar_girl_2.jpg',
  ];

  int get _safeAvatarIndex {
    if (avatarIndex < 0 || avatarIndex >= _avatars.length) {
      return 0;
    }

    return avatarIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: const BoxDecoration(
        color: Color(0xFFF4EFFA),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Image.asset(
          _avatars[_safeAvatarIndex],
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Icon(
              Icons.person_rounded,
              size: size * 0.65,
              color: const Color(0xFF8157A8),
            );
          },
        ),
      ),
    );
  }
}