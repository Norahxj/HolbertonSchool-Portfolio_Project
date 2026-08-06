import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/family_settings_controller.dart';
import '../models/family_settings_result.dart';
import '../utils/family_settings_localization.dart';
import '../widgets/family_settings_view.dart';

class FamilySettingsScreen extends StatefulWidget {
  const FamilySettingsScreen({super.key});

  @override
  State<FamilySettingsScreen> createState() {
    return _FamilySettingsScreenState();
  }
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  late final FamilySettingsController _controller;

  late final TextEditingController _familyNameController;

  late final TextEditingController _inviteEmailController;

  @override
  void initState() {
    super.initState();

    _controller = FamilySettingsController();

    _familyNameController = TextEditingController();

    _inviteEmailController = TextEditingController();

    _loadFamilyData();
  }

  @override
  void dispose() {
    _controller.dispose();
    _familyNameController.dispose();
    _inviteEmailController.dispose();

    super.dispose();
  }

  Future<void> _loadFamilyData() async {
    await _controller.loadFamilyData();

    if (!mounted) {
      return;
    }

    _syncFamilyNameField();
  }

  Future<void> _saveFamilyName() async {
    FocusScope.of(context).unfocus();

    final result = await _controller.saveFamilyName(_familyNameController.text);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showResultError(result);
      return;
    }

    _syncFamilyNameField();

    _showMessage(context.l10n.familyNameUpdatedSuccessfully);
  }

  Future<void> _sendInvitation() async {
    FocusScope.of(context).unfocus();

    final result = await _controller.sendInvitation(
      _inviteEmailController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showResultError(result);
      return;
    }

    _inviteEmailController.clear();

    _showMessage(context.l10n.invitationSentSuccessfully);
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final result = await _controller.acceptInvitation(invitationId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showResultError(result);
      return;
    }

    _syncFamilyNameField();

    _showMessage(context.l10n.invitationAcceptedSuccessfully);
  }

  Future<void> _rejectInvitation(String invitationId) async {
    final result = await _controller.rejectInvitation(invitationId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showResultError(result);
      return;
    }

    _showMessage(context.l10n.invitationRejectedSuccessfully);
  }

  void _syncFamilyNameField() {
    _familyNameController.text = displayLocalizedFamilyName(
      context,
      _controller.originalFamilyName,
    );
  }

  void _showResultError(FamilySettingsActionResult result) {
    final message =
        result.errorCode?.localized(context) ??
        result.backendMessage ??
        context.l10n.familySettingsGenericError;

    _showMessage(message, isError: true);
  }

  void _showMessage(String message, {bool isError = false}) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.error : AppColors.success,
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
      child: FamilySettingsView(
        familyNameController: _familyNameController,
        inviteEmailController: _inviteEmailController,
        onReload: _loadFamilyData,
        onSaveFamilyName: _saveFamilyName,
        onSendInvitation: _sendInvitation,
        onAcceptInvitation: _acceptInvitation,
        onRejectInvitation: _rejectInvitation,
        onBack: _goBack,
      ),
    );
  }
}
