import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/family_settings_controller.dart';
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

  final TextEditingController familyNameController = TextEditingController();

  final TextEditingController inviteEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = FamilySettingsController();

    _loadFamilyData();
  }

  @override
  void dispose() {
    _controller.dispose();
    familyNameController.dispose();
    inviteEmailController.dispose();

    super.dispose();
  }

  Future<void> _loadFamilyData() async {
    await _controller.loadFamilyData();

    if (!mounted) {
      return;
    }

    _updateDisplayedFamilyName();
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

    _updateDisplayedFamilyName();

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

  Future<void> _saveFamilyName() async {
    final result = await _controller.saveFamilyName(familyNameController.text);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showResultError(result);
      return;
    }

    _updateDisplayedFamilyName();

    _showMessage(context.l10n.familyNameUpdatedSuccessfully);
  }

  Future<void> _sendInvitation() async {
    final result = await _controller.sendInvitation(inviteEmailController.text);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showResultError(result);
      return;
    }

    inviteEmailController.clear();

    _showMessage(context.l10n.invitationSentSuccessfully);
  }

  void _updateDisplayedFamilyName() {
    familyNameController.text = displayLocalizedFamilyName(
      context,
      _controller.originalFamilyName,
    );
  }

  void _showResultError(FamilySettingsActionResult result) {
  _showMessage(
    result.errorCode?.localized(context) ??
        result.backendMessage ??
        context.l10n.familySettingsGenericError,
    isError: true,
  );
}

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: FamilySettingsView(
        familyNameController: familyNameController,
        inviteEmailController: inviteEmailController,
        onReload: _loadFamilyData,
        onSaveFamilyName: _saveFamilyName,
        onSendInvitation: _sendInvitation,
        onAcceptInvitation: _acceptInvitation,
        onRejectInvitation: _rejectInvitation,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
