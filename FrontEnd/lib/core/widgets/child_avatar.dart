import 'package:flutter/material.dart';

class ChildAvatar extends StatelessWidget {
  final String childId;
  final double size;

  const ChildAvatar({
    super.key,
    required this.childId,
    this.size = 48,
  });

  static const List<String> _avatars = [
    'assets/avatars/avatar_boy_1.png',
    'assets/avatars/avatar_boy_2.png',
    'assets/avatars/avatar_girl_1.png',
    'assets/avatars/avatar_girl_2.png',
  ];

  int _avatarIndex() {
    if (childId.isEmpty) {
      return 0;
    }

    final hash = childId.codeUnits.fold<int>(
      0,
      (total, value) => total + value,
    );

    return hash % _avatars.length;
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
          _avatars[_avatarIndex()],
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}