import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/screen_background.dart';
import 'package:frontend/features/parent/services/child_api_service.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

// Add Child screen (Screen 5).
class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final ChildApiService childApiService = ChildApiService();
  bool get isArabic {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  int selectedAvatarIndex = 0;

  DateTime? selectedDate;
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  String? nameError;
  String? birthDateError;
  String? phoneError;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    // A child must be between 6 and 18 years old.
    final earliestBirthDate = DateTime(now.year - 18, now.month, now.day);

    final latestBirthDate = DateTime(now.year - 6, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 7, now.month, now.day),
      firstDate: earliestBirthDate,
      lastDate: latestBirthDate,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        birthDateError = null;
      });
    }
  }

  String get _dateLabel {
    if (selectedDate == null) {
      return tr(
        'تاريخ الميلاد',
        'Date of birth',
      );
    }

    final date = selectedDate!;

    return '${date.day}/${date.month}/${date.year}';
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

  Future<void> _saveChild() async {
    setState(() {
      nameError = null;
      phoneError = null;
      birthDateError = null;
    });

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty) {
      setState(() {
        nameError = tr(
          'اسم الطفل مطلوب',
          'Child name is required',
        );
      });

      return;
    }

    if (name.length < 2) {
      setState(() {
        nameError = tr(
          'يجب أن يتكون اسم الطفل من حرفين على الأقل',
          'Child name must contain at least 2 characters',
        );
      });

      return;
    }

    final validName = RegExp(r'^[a-zA-Z\u0600-\u06FF\s]+$');

    if (!validName.hasMatch(name)) {
      setState(() {
        nameError = tr(
          'يجب أن يحتوي الاسم على حروف عربية أو إنجليزية فقط',
          'The name must contain letters only',
        );
      });

      return;
    }

    if (selectedDate == null) {
      setState(() {
        birthDateError = tr(
          'تاريخ الميلاد مطلوب',
          'Date of birth is required',
        );
      });

      return;
    }

    if (phone.isNotEmpty && !RegExp(r'^05\d{8}$').hasMatch(phone)) {
      setState(() {
        phoneError = tr(
          'أدخل رقم جوال سعودي صحيح يبدأ بـ 05',
          'Enter a valid Saudi phone number starting with 05',
        );
      });

      return;
    }

    final birthDate =
        '${selectedDate!.year}-'
        '${selectedDate!.month.toString().padLeft(2, '0')}-'
        '${selectedDate!.day.toString().padLeft(2, '0')}';

    setState(() {
      isLoading = true;
    });

    try {
      await childApiService.addChild(
        name: name,
        birthDate: birthDate,
        avatarIndex: selectedAvatarIndex,
        phone: phone.isEmpty ? null : phone,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'تمت إضافة الطفل بنجاح',
              'Child added successfully',
            ),
          ),
        ),
      );

      Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;

      debugPrint(
        'Add child failed: '
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
        'تعذر إضافة الطفل. حاولي مرة أخرى.',
        'Could not add the child. Please try again.',
      );

      if (responseData is Map) {
        final backendMessage = responseData['error'] ?? responseData['message'];

        if (backendMessage is String && backendMessage.trim().isNotEmpty) {
          switch (backendMessage) {
            case 'Phone number already used':
              message = tr(
                'رقم الجوال مستخدم بالفعل.',
                'This phone number is already in use.',
              );
              break;

            case 'Parent is not assigned to a family':
              message = tr(
                'حساب ولي الأمر غير مرتبط بأسرة.',
                'The parent account is not linked to a family.',
              );
              break;

            case 'Parent access required':
              message = tr(
                'إضافة الأطفال متاحة لولي الأمر فقط.',
                'Only parents can add children.',
              );
              break;

            case 'Parent not found':
              message = tr(
                'تعذّر العثور على حساب ولي الأمر.',
                'The parent account could not be found.',
              );
              break;

            case 'Could not create child':
              message = tr(
                'تعذّر إنشاء حساب الطفل.',
                'Could not create the child account.',
              );
              break;

            default:
              message = backendMessage;
          }
        }
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;

      debugPrint('Unexpected add child error: $error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'حدث خطأ غير متوقع أثناء إضافة الطفل.',
              'An unexpected error occurred while adding the child.',
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
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Align(
  alignment: isArabic
      ? Alignment.centerRight
      : Alignment.centerLeft,
  child: AppBackButton(
    onTap: () {
      Navigator.pop(context);
    },
  ),
),

                const SizedBox(height: AppSpacing.lg),

                Text(
                  tr(
                    'إضافة طفل',
                    'Add Child',
                  ),
                  style: AppTextStyles.arabicTitle,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  tr(
                    'أضف معلومات طفلك لبدء رحلته',
                    'Add your child’s information to begin their journey',
                  ),
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                Text(
                  tr(
                    'اختر صورة رمزية',
                    'Choose an avatar',
                  ),
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
                  label: tr(
                    'اسم الطفل',
                    'Child name',
                  ),
                  hint: tr(
                    'اسم الطفل',
                    'Child name',
                  ),
                  icon: Icons.person_outline,
                  controller: nameController,
                  errorText: nameError,
                  isArabic: isArabic,
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
                      alignment: isArabic
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Text(
                        birthDateError!,
                        textAlign:
                            isArabic ? TextAlign.right : TextAlign.left,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.xs),

                Text(
                  tr(
                    'يفتح التقويم لاختيار التاريخ',
                    'Open the calendar to select a date',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                AppTextField(
                  label: tr(
                    'رقم الجوال',
                    'Phone number',
                  ),
                  hint: tr(
                    'رقم الجوال (اختياري)',
                    'Phone number (optional)',
                  ),
                  icon: Icons.phone_outlined,
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  errorText: phoneError,
                  isArabic: isArabic,
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: isLoading
                      ? tr(
                          'جاري الحفظ...',
                          'Saving...',
                        )
                      : tr(
                          'حفظ',
                          'Save',
                        ),
                  onPressed: isLoading ? null : _saveChild,
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
          border: isSelected
              ? Border.all(
                  color: AppColors.primary,
                  width: 3,
                )
              : Border.all(
                  color: Colors.transparent,
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
                textAlign: TextAlign.right,
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
