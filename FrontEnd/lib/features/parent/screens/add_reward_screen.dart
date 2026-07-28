import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/reward_suggestion_model.dart';
import '../../../services/reward_api_service.dart';

// Allows the parent to create a real reward for a selected child.
class AddRewardScreen extends StatefulWidget {
  final String childId;
  final RewardSuggestionModel? suggestion;

  const AddRewardScreen({super.key, required this.childId, this.suggestion});

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final RewardApiService _rewardApiService = RewardApiService();

  bool get isArabic =>
      Localizations.localeOf(context).languageCode == 'ar';

  String tr(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  List<String> get weekDays => isArabic
      ? const [
          'الأحد',
          'الإثنين',
          'الثلاثاء',
          'الأربعاء',
          'الخميس',
          'الجمعة',
          'السبت',
        ]
      : const [
          'Sunday',
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
        ];

  int selectedUnlockDay = 3;

  bool isSaving = false;

  String? nameError;

  @override
  void initState() {
    super.initState();

    final suggestion = widget.suggestion;

    if (suggestion != null) {
      nameController.text = suggestion.rewardName;
      descriptionController.text = suggestion.description;

      selectedUnlockDay = suggestion.unlockDay.clamp(0, 6);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  Future<void> _saveReward() async {
    if (isSaving) return;

    final rewardName = nameController.text.trim();

    final description = descriptionController.text.trim();

    setState(() {
      nameError = null;
    });

    if (rewardName.isEmpty) {
      setState(() {
        nameError = tr(
          'اكتب اسم المكافأة أولًا',
          'Enter the reward name first',
        );
      });

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await _rewardApiService.createReward(
        childId: widget.childId,
        rewardName: rewardName,
        description: description.isEmpty ? null : description,
        unlockDay: selectedUnlockDay,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } on DioException catch (error) {
      if (!mounted) return;

      final message = _readBackendMessage(error);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            message ??
                tr(
                  'تعذّر حفظ المكافأة',
                  'Could not save the reward',
                ),
          ),
        ),
      );

      debugPrint(
        'Save reward failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'حدث خطأ أثناء حفظ المكافأة',
              'An error occurred while saving the reward',
            ),
          ),
        ),
      );

      debugPrint('Save reward failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  textDirection: isArabic ? TextDirection.ltr : TextDirection.rtl,
                  children: [
                    const SizedBox(width: 44),

                    Expanded(
                      child: Center(
                        child: Text(
                          tr(
                            'مكافأة جديدة',
                            'New Reward',
                          ),
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),

                    const AppBackButton(),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                _FieldLabel(
                  tr(
                    'اسم المكافأة',
                    'Reward name',
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                _RewardTextField(
                  controller: nameController,
                  isArabic: isArabic,
                  hint: tr(
                    'مثال: رحلة إلى الحديقة',
                    'Example: A trip to the park',
                  ),
                  errorText: nameError,
                ),

                const SizedBox(height: AppSpacing.lg),

                _FieldLabel(
                  tr(
                    'وصف المكافأة',
                    'Reward description',
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                _RewardTextField(
                  controller: descriptionController,
                  isArabic: isArabic,
                  hint: tr(
                    'مثال: زيارة نهاية الأسبوع للحديقة مع العائلة',
                    'Example: A weekend visit to the park with the family',
                  ),
                  maxLines: 3,
                ),

                const SizedBox(height: AppSpacing.lg),

                _FieldLabel(
                  tr(
                    'تفتح المكافأة كل',
                    'Reward unlock day',
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: isArabic ? WrapAlignment.end : WrapAlignment.start,
                  children: [
                    for (int index = 0; index < weekDays.length; index++)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedUnlockDay = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selectedUnlockDay == index
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            weekDays[index],
                            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: selectedUnlockDay == index
                                  ? Colors.white
                                  : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_outlined,
                        color: AppColors.primary,
                        size: 19,
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      Expanded(
                        child: Text(
                          isArabic
                              ? 'ستصبح المكافأة متاحة للطفل يوم '
                                    '${weekDays[selectedUnlockDay]} من كل أسبوع.'
                              : 'The reward will become available to the child '
                                    'every ${weekDays[selectedUnlockDay]}.',
                          textAlign: isArabic ? TextAlign.right : TextAlign.left,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  text: isSaving
                      ? tr(
                          'جارٍ الحفظ...',
                          'Saving...',
                        )
                      : tr(
                          'حفظ المكافأة',
                          'Save Reward',
                        ),
                  onPressed: isSaving ? null : _saveReward,
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

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Localizations.localeOf(context).languageCode == 'ar';

    return Align(
      alignment: isArabic ? Alignment.centerRight : Alignment.centerLeft,
      child: Text(
        text,
        textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _RewardTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? errorText;
  final bool isArabic;

  const _RewardTextField({
    required this.controller,
    required this.hint,
    required this.isArabic,
    this.maxLines = 1,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: isArabic ? TextAlign.right : TextAlign.left,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
    );
  }
}
