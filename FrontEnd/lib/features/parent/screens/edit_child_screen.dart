import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/child_model.dart';
import '../services/child_api_service.dart';

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
  final ChildApiService childApiService = ChildApiService();

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  DateTime? selectedDate;
  late int selectedAvatarIndex;

  bool isLoading = false;

  String? nameError;
  String? birthDateError;
  String? phoneError;

  String tr(String arabic, String english) {
    return widget.isArabic ? arabic : english;
  }

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.child.name);

    phoneController = TextEditingController(text: widget.child.phone ?? '');

    selectedAvatarIndex = widget.child.avatarIndex;

    selectedDate = DateTime.tryParse(widget.child.birthDate);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final earliestBirthDate = DateTime(now.year - 18, now.month, now.day);

    final latestBirthDate = DateTime(now.year - 6, now.month, now.day);

    DateTime initialDate =
        selectedDate ?? DateTime(now.year - 7, now.month, now.day);

    if (initialDate.isBefore(earliestBirthDate)) {
      initialDate = earliestBirthDate;
    }

    if (initialDate.isAfter(latestBirthDate)) {
      initialDate = latestBirthDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: earliestBirthDate,
      lastDate: latestBirthDate,
      helpText: tr('اختر تاريخ الميلاد', 'Select date of birth'),
      cancelText: tr('إلغاء', 'Cancel'),
      confirmText: tr('اختيار', 'Select'),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
      birthDateError = null;
    });
  }

  String get _dateLabel {
    if (selectedDate == null) {
      return tr('تاريخ الميلاد', 'Date of birth');
    }

    final date = selectedDate!;

    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatBirthDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }

  String? _firstError(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }

    if (value is String && value.trim().isNotEmpty) {
      return value;
    }

    return null;
  }

  bool _validateFields() {
    setState(() {
      nameError = null;
      phoneError = null;
      birthDateError = null;
    });

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      setState(() {
        nameError = tr('اسم الطفل مطلوب', 'Child name is required');
      });

      return false;
    }

    if (name.length < 2) {
      setState(() {
        nameError = tr(
          'يجب أن يتكون اسم الطفل من حرفين على الأقل',
          'Child name must contain at least 2 characters',
        );
      });

      return false;
    }

    final validName = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');

    if (!validName.hasMatch(name)) {
      setState(() {
        nameError = tr(
          'يجب أن يحتوي الاسم على حروف عربية أو إنجليزية فقط',
          'The name must contain letters only',
        );
      });

      return false;
    }

    if (selectedDate == null) {
      setState(() {
        birthDateError = tr('تاريخ الميلاد مطلوب', 'Date of birth is required');
      });

      return false;
    }

    if (phone.isNotEmpty && !RegExp(r'^05\d{8}$').hasMatch(phone)) {
      setState(() {
        phoneError = tr(
          'أدخل رقم جوال سعودي صحيح يبدأ بـ 05',
          'Enter a valid Saudi phone number starting with 05',
        );
      });

      return false;
    }

    return true;
  }

  Future<void> _saveChanges() async {
    if (!_validateFields()) return;

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    setState(() {
      isLoading = true;
    });

    try {
      final updatedChild = await childApiService.updateChild(
        childId: widget.child.id,
        name: name,
        birthDate: _formatBirthDate(selectedDate!),
        avatarIndex: selectedAvatarIndex,
        phone: phone.isEmpty ? null : phone,
      );

      if (!mounted) return;

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
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint(
        'Update child failed: '
        '${error.response?.statusCode} '
        '${error.response?.data}',
      );

      final responseData = error.response?.data;

      if (responseData is Map) {
        final errors = responseData['errors'];

        if (errors is Map) {
          setState(() {
            nameError = _firstError(errors['name']);
            phoneError = _firstError(errors['phone']);
            birthDateError = _firstError(errors['birth_date']);
          });

          if (nameError != null ||
              phoneError != null ||
              birthDateError != null) {
            return;
          }
        }
      }

      String message = tr(
        'تعذّر تعديل بيانات الطفل. حاولي مرة أخرى.',
        'Could not update the child. Please try again.',
      );

      if (responseData is Map) {
        final backendMessage = responseData['error'] ?? responseData['message'];

        switch (backendMessage) {
          case 'Phone number already used':
            message = tr(
              'رقم الجوال مستخدم بالفعل.',
              'This phone number is already in use.',
            );
            break;

          case 'Child not found':
            message = tr(
              'لم يتم العثور على الطفل.',
              'The child was not found.',
            );
            break;

          case 'Parent access required':
            message = tr(
              'تعديل بيانات الطفل متاح لولي الأمر فقط.',
              'Only parents can update child information.',
            );
            break;

          case 'Failed to update child':
            message = tr('تعذّر حفظ التعديلات.', 'Could not save the changes.');
            break;
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      debugPrint('Unexpected update child error: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'حدث خطأ غير متوقع أثناء تعديل الطفل.',
              'An unexpected error occurred while updating the child.',
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        body: ScreenBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Align(
                    alignment: widget.isArabic
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: AppBackButton(
                      isArabic: widget.isArabic,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  Text(
                    tr('تعديل بيانات الطفل', 'Edit Child Information'),
                    style: AppTextStyles.arabicTitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    tr(
                      'عدّل معلومات الطفل ثم اضغط حفظ',
                      'Update the child information, then save',
                    ),
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  Text(
                    tr('اختر صورة رمزية', 'Choose an avatar'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _AvatarOption(
                        imagePath: 'assets/avatars/avatar_boy_1v.jpg',
                        backgroundColor: const Color(0xFFD9F0DD),
                        isSelected: selectedAvatarIndex == 0,
                        onTap: () {
                          setState(() {
                            selectedAvatarIndex = 0;
                          });
                        },
                      ),
                      _AvatarOption(
                        imagePath: 'assets/avatars/avatar_boy_2v.jpg',
                        backgroundColor: const Color(0xFFD7E9F7),
                        isSelected: selectedAvatarIndex == 1,
                        onTap: () {
                          setState(() {
                            selectedAvatarIndex = 1;
                          });
                        },
                      ),
                      _AvatarOption(
                        imagePath: 'assets/avatars/avatar_girl_1v.jpg',
                        backgroundColor: AppColors.primaryLight,
                        isSelected: selectedAvatarIndex == 2,
                        onTap: () {
                          setState(() {
                            selectedAvatarIndex = 2;
                          });
                        },
                      ),
                      _AvatarOption(
                        imagePath: 'assets/avatars/avatar_girl_2v.jpg',
                        backgroundColor: const Color(0xFFFBE3EA),
                        isSelected: selectedAvatarIndex == 3,
                        onTap: () {
                          setState(() {
                            selectedAvatarIndex = 3;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  AppTextField(
                    label: tr('اسم الطفل', 'Child name'),
                    hint: tr('اسم الطفل', 'Child name'),
                    icon: Icons.person_outline,
                    controller: nameController,
                    errorText: nameError,
                    isArabic: widget.isArabic,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  _BirthDateField(
                    label: _dateLabel,
                    hasValue: selectedDate != null,
                    onTap: _pickDate,
                  ),

                  if (birthDateError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Align(
                        alignment: widget.isArabic
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Text(
                          birthDateError!,
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: tr('رقم الجوال', 'Phone number'),
                    hint: tr('رقم الجوال (اختياري)', 'Phone number (optional)'),
                    icon: Icons.phone_outlined,
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    errorText: phoneError,
                    isArabic: widget.isArabic,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  AppButton(
                    text: isLoading
                        ? tr('جارٍ الحفظ...', 'Saving...')
                        : tr('حفظ التعديلات', 'Save Changes'),
                    onPressed: isLoading ? null : _saveChanges,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: AppColors.primaryGradient,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  final String imagePath;
  final Color backgroundColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarOption({
    required this.imagePath,
    required this.backgroundColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        height: 68,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            imagePath,
            width: 58,
            height: 58,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.person_rounded,
                color: AppColors.primary,
                size: 32,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _BirthDateField extends StatelessWidget {
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  const _BirthDateField({
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.keyboard_arrow_down,
              size: 18,
              color: AppColors.textSecondary,
            ),

            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),

            const Icon(
              Icons.calendar_today_outlined,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
