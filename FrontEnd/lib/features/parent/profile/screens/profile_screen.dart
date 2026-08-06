import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/profile_controller.dart';
import '../utils/profile_localization.dart';
import '../widgets/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  final TextEditingController firstNameController =
      TextEditingController();

  final TextEditingController lastNameController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController phoneController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = ProfileController();

    _loadUser();
  }

  @override
  void dispose() {
    _controller.dispose();

    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _controller.loadUser();

    if (!mounted || user == null) {
      return;
    }

    firstNameController.text = user.firstName;
    lastNameController.text = user.lastName;
    emailController.text = user.email;
    phoneController.text = user.phone;
  }

  Future<void> _saveChanges() async {
    final result = await _controller.saveChanges(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      final message =
          result.backendMessage ??
          result.errorCode?.localized(context);

      if (message != null) {
        _showMessage(message);
      }

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.profileUpdatedSuccessfully,
        ),
      ),
    );

    Navigator.pop(context, result.user);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ProfileView(
        firstNameController: firstNameController,
        lastNameController: lastNameController,
        emailController: emailController,
        phoneController: phoneController,
        onReload: _loadUser,
        onSave: _saveChanges,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}