import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/edit_child_view.dart';
import '../../../../models/child_model.dart';
import '../controllers/edit_child_controller.dart';

class EditChildScreen extends StatefulWidget {
  final ChildModel child;
  final bool isArabic;

  const EditChildScreen({
    super.key,
    required this.child,
    required this.isArabic,
  });

  @override
  State<EditChildScreen> createState() => _EditChildScreenState();
}

class _EditChildScreenState extends State<EditChildScreen> {
  late final EditChildController _controller;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.child.name);

    phoneController = TextEditingController(text: widget.child.phone ?? '');

    _controller = EditChildController(
      child: widget.child,
      isArabic: widget.isArabic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  String tr(String arabic, String english) {
    return widget.isArabic ? arabic : english;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.initialBirthDate,
      firstDate: _controller.earliestBirthDate,
      lastDate: _controller.latestBirthDate,
      helpText: tr('اختر تاريخ الميلاد', 'Select date of birth'),
      cancelText: tr('إلغاء', 'Cancel'),
      confirmText: tr('اختيار', 'Select'),
    );

    if (picked == null) {
      return;
    }

    _controller.selectBirthDate(picked);
  }

  Future<void> _saveChanges() async {
    final updatedChild = await _controller.saveChanges(
      name: nameController.text,
      phone: phoneController.text,
    );

    if (!mounted) {
      return;
    }

    if (updatedChild == null) {
      final message = _controller.errorMessage;

      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            'تم تعديل بيانات الطفل بنجاح',
            'Child information updated successfully',
          ),
        ),
      ),
    );

    Navigator.pop(context, updatedChild);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: EditChildView(
        isArabic: widget.isArabic,
        nameController: nameController,
        phoneController: phoneController,
        onBack: () {
          Navigator.pop(context);
        },
        onPickDate: _pickDate,
        onSave: _saveChanges,
      ),
    );
  }
}
