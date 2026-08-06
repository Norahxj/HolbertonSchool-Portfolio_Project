import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../screens/parent_main_screen.dart';
import '../controllers/add_task_controller.dart';
import '../widgets/add_task_view.dart';

class AddTaskScreen extends StatefulWidget {
  final int resetVersion;
  final bool isArabic;
  final VoidCallback onLanguageToggle;
  final int childrenVersion;

  const AddTaskScreen({
    super.key,
    this.resetVersion = 0,
    this.isArabic = true,
    this.childrenVersion = 0,
    required this.onLanguageToggle,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final AddTaskController _controller;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _controller = AddTaskController(isArabic: widget.isArabic)..loadChildren();
  }

  @override
  void didUpdateWidget(covariant AddTaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.childrenVersion != widget.childrenVersion) {
      _controller.loadChildren();
    }

    if (oldWidget.isArabic != widget.isArabic &&
        _controller.selectedChildIds.isNotEmpty &&
        _controller.selectedTaskType != null) {
      _controller.loadTaskSuggestions();
    }

    if (oldWidget.resetVersion != widget.resetVersion) {
      _controller.reset();
      _scrollToTop();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();

    super.dispose();
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _goToNextStep() {
    final moved = _controller.goToNextStep();

    if (moved) {
      _scrollToTop();
    }
  }

  void _goToPreviousStep() {
    final moved = _controller.goToPreviousStep();

    if (!moved) {
      Navigator.pop(context);
      return;
    }

    _scrollToTop();
  }

  Future<void> _showMonthlyDayPicker() async {
    final selectedDay = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.text(
                    'اختر يوم الشهر',
                    'Choose a day of the month',
                  ),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 31,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = day == _controller.selectedMonthlyDay;

                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.pop(context, day);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AppColors.primaryDark,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedDay != null) {
      _controller.selectMonthlyDay(selectedDay);
    }
  }

  Future<void> _saveTask() async {
    final result = await _controller.saveTask();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      final message = result.errorMessage;

      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      _scrollToTop();
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ParentMainScreen(
            initialIndex: 2,
            isArabic: widget.isArabic,
            onLanguageToggle: widget.onLanguageToggle,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddTaskView(
        isArabic: widget.isArabic,
        scrollController: _scrollController,
        onRefresh: _controller.loadChildren,
        onNext: _goToNextStep,
        onBack: _goToPreviousStep,
        onSave: _saveTask,
        onMonthlyDayPicker: _showMonthlyDayPicker,
        onSuggestionApplied: _scrollToTop,
      ),
    );
  }
}
