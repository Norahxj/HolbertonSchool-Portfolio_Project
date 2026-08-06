import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/child_model.dart';
import '../controllers/child_form_controller.dart';
import '../widgets/child_form_view.dart';

class ChildFormScreen extends StatefulWidget {
  final ChildModel? child;
  final bool isArabic;

  const ChildFormScreen.add({super.key, required this.isArabic}) : child = null;

  const ChildFormScreen.edit({
    super.key,
    required ChildModel child,
    required this.isArabic,
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

  bool get isArabic => widget.isArabic;

  bool get isEditMode => widget.isEditMode;

  @override
  void initState() {
    super.initState();

    final child = widget.child;

    nameController = TextEditingController(text: child?.name ?? '');

    phoneController = TextEditingController(text: child?.phone ?? '');

    if (child == null) {
      _controller = ChildFormController.add(isArabic: widget.isArabic);
    } else {
      _controller = ChildFormController.edit(
        child: child,
        isArabic: widget.isArabic,
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

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _controller.initialBirthDate,
      firstDate: _controller.earliestBirthDate,
      lastDate: _controller.latestBirthDate,
      helpText: tr('اختر تاريخ الميلاد', 'Select date of birth'),
      cancelText: tr('إلغاء', 'Cancel'),
      confirmText: tr('اختيار', 'Select'),
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
      final message = result.errorMessage ?? _controller.errorMessage;

      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      return;
    }

    final successMessage = isEditMode
        ? tr(
            'تم تعديل بيانات الطفل بنجاح',
            'Child information updated successfully',
          )
        : tr('تمت إضافة الطفل بنجاح', 'Child added successfully');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(successMessage)));

    if (isEditMode) {
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
