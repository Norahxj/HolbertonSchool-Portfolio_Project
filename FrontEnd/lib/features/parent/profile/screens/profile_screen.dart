import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/profile_controller.dart';
import '../models/profile_save_result.dart';
import '../utils/profile_localization.dart';
import '../widgets/profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _controller = ProfileController();

    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    _loadUser();
  }

  @override
  void dispose() {
    _controller.dispose();

    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await _controller.loadUser();

    if (!mounted || user == null) {
      return;
    }

    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
  }

  Future<void> _saveChanges() async {
    FocusScope.of(context).unfocus();

    final result = await _controller.saveChanges(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _handleSaveFailure(result);
      return;
    }

    _showMessage(
      context.l10n.profileUpdatedSuccessfully,
    );

    Navigator.pop(context, result.user);
  }

  void _handleSaveFailure(ProfileSaveResult result) {
    final message =
        result.backendMessage ??
        result.errorCode?.localized(context);

    if (message == null || message.trim().isEmpty) {
      return;
    }

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ProfileView(
        firstNameController: _firstNameController,
        lastNameController: _lastNameController,
        emailController: _emailController,
        phoneController: _phoneController,
        onReload: _loadUser,
        onSave: _saveChanges,
        onBack: _goBack,
      ),
    );
  }
}