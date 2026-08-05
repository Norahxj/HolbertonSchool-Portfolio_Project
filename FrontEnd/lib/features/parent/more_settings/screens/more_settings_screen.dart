import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/user_model.dart';
import '../controllers/more_settings_controller.dart';
import '../widgets/more_settings_view.dart';
import '../../profile/screens/profile_screen.dart';

class MoreSettingsScreen extends StatefulWidget {
  final bool isArabic;
  final VoidCallback onLanguageToggle;

  const MoreSettingsScreen({
    super.key,
    required this.isArabic,
    required this.onLanguageToggle,
  });

  @override
  State<MoreSettingsScreen> createState() => _MoreSettingsScreenState();
}

class _MoreSettingsScreenState extends State<MoreSettingsScreen> {
  late final MoreSettingsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = MoreSettingsController()..loadUser();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _reloadUser() async {
    await _controller.refresh();
  }

  Future<void> _openProfileScreen() async {
    final updatedUser = await Navigator.push<UserModel>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(isArabic: widget.isArabic),
      ),
    );

    if (!mounted) {
      return;
    }

    if (updatedUser != null) {
      _controller.updateUser(updatedUser);
      return;
    }

    await _reloadUser();
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isArabic
              ? 'هذه الميزة ستكون متاحة قريبًا.'
              : 'This feature is coming soon.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: MoreSettingsView(
        isArabic: widget.isArabic,
        onReload: _reloadUser,
        onLanguageToggle: widget.onLanguageToggle,
        onProfileTap: _openProfileScreen,
        onComingSoon: _showComingSoon,
      ),
    );
  }
}
