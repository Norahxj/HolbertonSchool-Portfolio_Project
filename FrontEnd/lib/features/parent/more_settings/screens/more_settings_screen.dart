import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../models/user_model.dart';
import '../../profile/screens/profile_screen.dart';
import '../controllers/more_settings_controller.dart';
import '../widgets/more_settings_view.dart';

class MoreSettingsScreen extends StatefulWidget {
  final VoidCallback onLoggedOut;

  const MoreSettingsScreen({super.key, required this.onLoggedOut});

  @override
  State<MoreSettingsScreen> createState() {
    return _MoreSettingsScreenState();
  }
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
        builder: (_) {
          return  const ProfileScreen();
        },
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.comingSoonMessage)));
  }

  Future<void> _logout() async {
    final success = await _controller.logout();

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.logoutFailed)));

      return;
    }

    widget.onLoggedOut();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: MoreSettingsView(
        onReload: _reloadUser,
        onProfileTap: _openProfileScreen,
        onComingSoon: _showComingSoon,
        onLogout: _logout,
      ),
    );
  }
}
