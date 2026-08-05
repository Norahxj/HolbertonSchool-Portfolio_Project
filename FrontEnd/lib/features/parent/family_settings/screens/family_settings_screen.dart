import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../controllers/family_settings_controller.dart';
import '../widgets/family_settings_view.dart';

class FamilySettingsScreen extends StatefulWidget {
  final bool isArabic;

  const FamilySettingsScreen({super.key, required this.isArabic});

  @override
  State<FamilySettingsScreen> createState() => _FamilySettingsScreenState();
}

class _FamilySettingsScreenState extends State<FamilySettingsScreen> {
  late final FamilySettingsController _controller;

  bool get isArabic => widget.isArabic;

  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController inviteEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = FamilySettingsController(isArabic: isArabic);

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

    familyNameController.text = _controller.displayFamilyName(
      _controller.originalFamilyName,
    );
  }

  Future<void> _acceptInvitation(String invitationId) async {
    final errorMessage = await _controller.acceptInvitation(invitationId);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    _showMessage(
      isArabic
          ? 'تم قبول الدعوة والانضمام إلى العائلة'
          : 'Invitation accepted and joined the family',
    );
  }

  Future<void> _rejectInvitation(String invitationId) async {
    final errorMessage = await _controller.rejectInvitation(invitationId);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    _showMessage(isArabic ? 'تم رفض الدعوة' : 'Invitation rejected');
  }

  Future<void> _saveFamilyName() async {
    final errorMessage = await _controller.saveFamilyName(
      familyNameController.text,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    familyNameController.text = _controller.displayFamilyName(
      _controller.originalFamilyName,
    );

    _showMessage(isArabic ? 'تم تحديث اسم العائلة' : 'Family name updated');
  }

  Future<void> _sendInvitation() async {
    final errorMessage = await _controller.sendInvitation(
      inviteEmailController.text,
    );

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      _showMessage(errorMessage, isError: true);
      return;
    }

    inviteEmailController.clear();

    _showMessage(
      isArabic ? 'تم إرسال الدعوة بنجاح' : 'Invitation sent successfully',
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : AppColors.success,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant FamilySettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isArabic == widget.isArabic) {
      return;
    }

    _controller.updateLanguage(widget.isArabic);

    familyNameController.text = _controller.displayFamilyName(
      _controller.originalFamilyName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: FamilySettingsView(
        isArabic: isArabic,
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
