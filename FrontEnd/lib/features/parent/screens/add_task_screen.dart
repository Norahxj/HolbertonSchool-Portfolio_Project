import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/screen_background.dart';

// Add Task wizard (Screens 9-12).
//
// This first pass is static/placeholder only: every step just updates
// simple local state, and there are no backend calls yet. The 4 mockup
// screens are combined into one file, switching on currentStep.
class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  // Which step of the wizard is showing right now: 0, 1, 2, or 3.
  int currentStep = 0;

  // Step 0: which children this task is for (more than one is allowed).
  bool isKhaledSelected = true;
  bool isNouraSelected = false;
  bool isSalmanSelected = true;

  // Step 1: which task type/category is picked. Null means none yet.
  int? selectedTaskType;

  // Step 2: task name, description, points, and the trust toggle.
  final TextEditingController taskNameController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  int taskPoints = 10;
  bool trustChild = true;

  // Step 3: how often the task repeats. 0 = daily, 1 = weekly, 2 = monthly.
  int selectedFrequency = 1;

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }

  void _goToNextStep() {
    setState(() {
      currentStep = currentStep + 1;
    });
  }

  void _goToPreviousStep() {
    setState(() {
      currentStep = currentStep - 1;
    });
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
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _stepTitle,
                          style: AppTextStyles.arabicTitle,
                        ),
                      ),
                    ),
                    _RoundBackButton(onTap: () => Navigator.pop(context)),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  _stepSubtitle,
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                if (currentStep == 0) _buildChooseChildStep(),
                if (currentStep == 1) _buildTaskTypeStep(),
                if (currentStep == 2) _buildTaskDetailsStep(),
                if (currentStep == 3) _buildTaskScheduleStep(),

                const SizedBox(height: AppSpacing.xl),

                _buildBottomButtons(),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // The title text shown at the top for the current step.
  String get _stepTitle {
    if (currentStep == 0) return 'إضافة مهمة';
    if (currentStep == 1) return 'نوع المهمة';
    if (currentStep == 2) return 'تفاصيل المهمة';
    return 'جدول المهمة';
  }

  // The subtitle text shown below the title for the current step.
  String get _stepSubtitle {
    if (currentStep == 0) return 'لمن هذه المهمة؟ (يمكن اختيار أكثر من طفل)';
    if (currentStep == 1) return 'ما نوع المهمة؟';
    if (currentStep == 2) return 'لنُضِف تفاصيل المهمة';
    return 'كم مرة يجب تنفيذ هذه المهمة؟';
  }

  // ---- Step 0: choose child ----

  Widget _buildChooseChildStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ChildChip(
              name: 'خالد',
              avatarColor: const Color(0xFFDFF3E4),
              iconColor: const Color(0xFF4CAF50),
              isSelected: isKhaledSelected,
              onTap: () {
                setState(() {
                  isKhaledSelected = !isKhaledSelected;
                });
              },
            ),
            _ChildChip(
              name: 'نورة',
              avatarColor: const Color(0xFFFBE3EA),
              iconColor: const Color(0xFFD1637F),
              isSelected: isNouraSelected,
              onTap: () {
                setState(() {
                  isNouraSelected = !isNouraSelected;
                });
              },
            ),
            _ChildChip(
              name: 'سلمان',
              avatarColor: const Color(0xFFDCEBFB),
              iconColor: const Color(0xFF4A90D9),
              isSelected: isSalmanSelected,
              onTap: () {
                setState(() {
                  isSalmanSelected = !isSalmanSelected;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'المهام تساعد الأطفال على بناء العادات والقيم وكسب نقاط نور.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'إضافة سريعة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        const _QuickAddCategory(
          icon: Icons.shopping_bag_outlined,
          label: 'المهام اليومية',
        ),
        const SizedBox(height: AppSpacing.md),
        const _QuickAddCategory(
          icon: Icons.mosque_outlined,
          label: 'المهام الثقافية',
        ),
        const SizedBox(height: AppSpacing.md),
        const _QuickAddCategory(
          icon: Icons.credit_card,
          label: 'المهام المالية',
        ),
      ],
    );
  }

  // ---- Step 1: task type ----

  Widget _buildTaskTypeStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.mosque_outlined,
                label: 'المهام الثقافية',
                isSelected: selectedTaskType == 0,
                onTap: () {
                  setState(() {
                    selectedTaskType = 0;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.shopping_bag_outlined,
                label: 'المهام اليومية',
                isSelected: selectedTaskType == 1,
                onTap: () {
                  setState(() {
                    selectedTaskType = 1;
                  });
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.md),

        Row(
          children: [
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.menu_book_outlined,
                label: 'المهام الدينية',
                isSelected: selectedTaskType == 2,
                onTap: () {
                  setState(() {
                    selectedTaskType = 2;
                  });
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _TaskTypeCard(
                icon: Icons.credit_card,
                label: 'المهام المالية',
                isSelected: selectedTaskType == 3,
                onTap: () {
                  setState(() {
                    selectedTaskType = 3;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---- Step 2: task details ----

  Widget _buildTaskDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'اسم المهمة',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _TaskTextField(
          controller: taskNameController,
          hint: 'مثال: ترتيب سريرك',
        ),

        const SizedBox(height: AppSpacing.lg),

        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'الوصف',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _TaskTextField(
          controller: taskDescriptionController,
          hint: 'صف المهمة باختصار...',
          maxLines: 2,
        ),

        const SizedBox(height: AppSpacing.lg),

        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            'نقاط نور',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _PointsButton(
                icon: Icons.add,
                onTap: () {
                  setState(() {
                    taskPoints = taskPoints + 5;
                  });
                },
              ),
              const SizedBox(width: AppSpacing.sm),
              _PointsButton(
                icon: Icons.remove,
                onTap: () {
                  // Do not let points go below zero.
                  if (taskPoints > 0) {
                    setState(() {
                      taskPoints = taskPoints - 5;
                    });
                  }
                },
              ),
              const Spacer(),
              Text(
                '$taskPoints نقطة',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.auto_awesome, color: AppColors.gold, size: 18),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Text(
                  'نقاط نور تحفّز الأطفال وتشجعهم على الاستمرار.',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    trustChild = !trustChild;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: trustChild ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: trustChild
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'هل تثق بجدية طفلك في هذه المهمة؟',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'إذا وثقت، ستُعتمد المهمة تلقائيًا بدون الحاجة لمراجعتك',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Step 3: task schedule ----

  Widget _buildTaskScheduleStep() {
    return Column(
      children: [
        _FrequencyCard(
          title: 'يوميًا',
          subtitle: 'تُنفَّذ المهمة كل يوم',
          isSelected: selectedFrequency == 0,
          onTap: () {
            setState(() {
              selectedFrequency = 0;
            });
          },
        ),

        const SizedBox(height: AppSpacing.md),

        _FrequencyCard(
          title: 'مرة في الأسبوع',
          subtitle: 'تُنفَّذ المهمة مرة في الأسبوع',
          isSelected: selectedFrequency == 1,
          onTap: () {
            setState(() {
              selectedFrequency = 1;
            });
          },
          extraContent: selectedFrequency == 1
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'اختيار اليوم',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'اليوم: الأحد',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                )
              : null,
        ),

        const SizedBox(height: AppSpacing.md),

        _FrequencyCard(
          title: 'شهريًا',
          subtitle: 'تُنفَّذ المهمة مرة في الشهر',
          isSelected: selectedFrequency == 2,
          onTap: () {
            setState(() {
              selectedFrequency = 2;
            });
          },
        ),
      ],
    );
  }

  // ---- Bottom buttons (change depending on the current step) ----

  Widget _buildBottomButtons() {
    // Step 0 only has a single full-width "Next" button.
    if (currentStep == 0) {
      return AppButton(
        text: 'التالي',
        onPressed: _goToNextStep,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.primaryGradient,
        ),
      );
    }

    // The last step shows "Save" instead of "Next".
    final isLastStep = currentStep == 3;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppButton(
            text: isLastStep ? 'حفظ المهمة' : 'التالي',
            onPressed: () {
              if (isLastStep) {
                // TODO: Save the new task once backend integration is
                // ready.
                Navigator.pop(context);
              } else {
                _goToNextStep();
              }
            },
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.primaryGradient,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: SizedBox(
            height: 56,
            child: OutlinedButton(
              onPressed: _goToPreviousStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'رجوع',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Round back button in the top-right corner. Always exits the whole
// wizard, no matter which step is showing (same as every mockup screen).
class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RoundBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: const SizedBox(
          width: 44,
          height: 44,
          child: Icon(
            Icons.arrow_forward_rounded,
            size: 18,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}

// One child avatar + name used on Step 0, with a checkmark badge when
// selected. Tapping toggles that child in or out of the task.
class _ChildChip extends StatelessWidget {
  final String name;
  final Color avatarColor;
  final Color iconColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildChip({
    required this.name,
    required this.avatarColor,
    required this.iconColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person, color: iconColor, size: 24),
                ),
                if (isSelected)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// One "quick add" category placeholder shown on Step 0. Static only, same
// simplification already used on the Reward Management screen: a plain
// light border instead of a dashed one.
class _QuickAddCategory extends StatelessWidget {
  final IconData icon;
  final String label;

  const _QuickAddCategory({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(icon, color: AppColors.primaryDark, size: 18),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'ستظهر هنا المهام المقترحة',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

// One selectable task-type card shown on Step 1, arranged in a 2x2 grid.
class _TaskTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TaskTypeCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primaryDark, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple rounded text field used for the task name and description on
// Step 2.
class _TaskTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _TaskTextField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
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
      ),
    );
  }
}

// The small round + / - buttons next to the points value on Step 2.
class _PointsButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PointsButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: icon == Icons.add ? AppColors.primary : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: icon == Icons.add ? Colors.white : AppColors.primaryDark,
        ),
      ),
    );
  }
}

// One selectable frequency card shown on Step 3 (daily/weekly/monthly).
// extraContent is an optional row shown below the title when this card
// is selected, e.g. the weekly day picker placeholder.
class _FrequencyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? extraContent;

  const _FrequencyCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.primaryDark,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (extraContent != null) ...[
              const SizedBox(height: AppSpacing.sm),
              extraContent!,
            ],
          ],
        ),
      ),
    );
  }
}
