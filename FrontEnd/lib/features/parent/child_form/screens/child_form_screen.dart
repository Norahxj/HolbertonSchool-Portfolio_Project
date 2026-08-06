import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../models/child_model.dart';
import '../controllers/child_form_controller.dart';
import '../models/child_form_save_result.dart';
import '../utils/child_form_localization.dart';
import '../widgets/child_form_view.dart';

class ChildFormScreen extends StatefulWidget {
  final ChildModel? child;

  const ChildFormScreen.add({super.key}) : child = null;

  const ChildFormScreen.edit({super.key, required this.child});

  bool get isEditMode => child != null;

  @override
  State<ChildFormScreen> createState() {
    return _ChildFormScreenState();
  }
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  late final ChildFormController _controller;

  late final TextEditingController _nameController;

  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    final child = widget.child;

    _nameController = TextEditingController(text: child?.name ?? '');

    _phoneController = TextEditingController(text: child?.phone ?? '');

    _controller = child == null
        ? ChildFormController.add()
        : ChildFormController.edit(child: child);
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _controller.initialBirthDate,
      firstDate: _controller.earliestBirthDate,
      lastDate: _controller.latestBirthDate,
      helpText: context.l10n.selectDateOfBirth,
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.select,
    );

    if (!mounted || pickedDate == null) {
      return;
    }

    _controller.selectBirthDate(pickedDate);
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final result = await _controller.save(
      name: _nameController.text,
      phone: _phoneController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _handleSaveFailure(result);
      return;
    }

    final successMessage = widget.isEditMode
        ? context.l10n.childUpdatedSuccessfully
        : context.l10n.childAddedSuccessfully;

    _showMessage(successMessage);

    if (widget.isEditMode) {
      Navigator.pop(context, result.child);
      return;
    }

    Navigator.pop(context, true);
  }

  void _handleSaveFailure(ChildFormSaveResult result) {
    final message =
        result.backendMessage ?? result.errorCode?.localized(context);

    if (message == null || message.trim().isEmpty) {
      return;
    }

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildFormView(
        nameController: _nameController,
        phoneController: _phoneController,
        onBack: _goBack,
        onPickDate: _pickDate,
        onSave: _save,
      ),
    );
  }
}
