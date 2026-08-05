import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../add_child/widgets/add_child_view.dart';
import '../add_child/controllers/add_child_controller.dart';

class AddChildScreen extends StatefulWidget {
  final bool isArabic;

  const AddChildScreen({super.key, required this.isArabic});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  late final AddChildController _controller;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AddChildController(isArabic: widget.isArabic);
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

  Future<void> _saveChild() async {
    final saved = await _controller.saveChild(
      name: nameController.text,
      phone: phoneController.text,
    );

    if (!mounted) {
      return;
    }

    if (!saved) {
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
        content: Text(tr('تمت إضافة الطفل بنجاح', 'Child added successfully')),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddChildView(
        isArabic: widget.isArabic,
        nameController: nameController,
        phoneController: phoneController,
        onBack: () {
          Navigator.pop(context);
        },
        onPickDate: _pickDate,
        onSave: _saveChild,
      ),
    );
  }
}
