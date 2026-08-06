import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../models/child_model.dart';
import '../controllers/child_form_controller.dart';
import '../utils/child_form_localization.dart';
import '../widgets/child_form_view.dart';

class ChildFormScreen extends StatefulWidget {
  final ChildModel? child;

  const ChildFormScreen.add({
    super.key,
  }) : child = null;

  const ChildFormScreen.edit({
    super.key,
    required ChildModel child,
  }) : child = child;

  bool get isEditMode => child != null;

  @override
  State<ChildFormScreen> createState() {
    return _ChildFormScreenState();
  }
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  late final ChildFormController _controller;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    final child = widget.child;

    nameController = TextEditingController(
      text: child?.name ?? '',
    );

    phoneController = TextEditingController(
      text: child?.phone ?? '',
    );

    if (child == null) {
      _controller = ChildFormController.add();
    } else {
      _controller = ChildFormController.edit(
        child: child,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _controller.initialBirthDate,
      firstDate: _controller.earliestBirthDate,
      lastDate: _controller.latestBirthDate,
      helpText: context.l10n.selectDateOfBirth,
      cancelText: context.l10n.cancel,
      confirmText: context.l10n.select,
    );

    if (pickedDate == null) {
      return;
    }

    _controller.selectBirthDate(pickedDate);
  }

  Future<void> _save() async {
    final result = await _controller.save(
      name: nameController.text,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }

      return;
    }

    final successMessage = widget.isEditMode
        ? context.l10n.childUpdatedSuccessfully
        : context.l10n.childAddedSuccessfully;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMessage),
      ),
    );

    if (widget.isEditMode) {
      Navigator.pop(context, result.child);
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildFormView(
        isEditMode: widget.isEditMode,
        nameController: nameController,
        phoneController: phoneController,
        onBack: () {
          Navigator.pop(context);
        },
        onPickDate: _pickDate,
        onSave: _save,
      ),
    );
  }
}