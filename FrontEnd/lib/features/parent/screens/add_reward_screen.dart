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

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final List<String> weekDays = const [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
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
        nameError = 'اكتب اسم المكافأة أولًا';
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
      ).showSnackBar(SnackBar(content: Text(message ?? 'تعذّر حفظ المكافأة')));

      debugPrint(
        'Save reward failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء حفظ المكافأة')),
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
                  textDirection: TextDirection.ltr,
                  children: [
                    const SizedBox(width: 44),

                    Expanded(
                      child: Center(
                        child: Text(
                          'مكافأة جديدة',
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),

                    const AppBackButton(),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                const _FieldLabel('اسم المكافأة'),

                const SizedBox(height: AppSpacing.sm),

                _RewardTextField(
                  controller: nameController,
                  hint: 'مثال: رحلة إلى الحديقة',
                  errorText: nameError,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('وصف المكافأة'),

                const SizedBox(height: AppSpacing.sm),

                _RewardTextField(
                  controller: descriptionController,
                  hint: 'مثال: زيارة نهاية الأسبوع للحديقة مع العائلة',
                  maxLines: 3,
                ),

                const SizedBox(height: AppSpacing.lg),

                const _FieldLabel('تفتح المكافأة كل'),

                const SizedBox(height: AppSpacing.sm),

                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  alignment: WrapAlignment.end,
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
                            textDirection: TextDirection.rtl,
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
                          'ستصبح المكافأة متاحة للطفل يوم '
                          '${weekDays[selectedUnlockDay]} من كل أسبوع.',
                          textAlign: TextAlign.right,
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
                  text: isSaving ? 'جارٍ الحفظ...' : 'حفظ المكافأة',
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
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        textDirection: TextDirection.rtl,
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

  const _RewardTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
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
