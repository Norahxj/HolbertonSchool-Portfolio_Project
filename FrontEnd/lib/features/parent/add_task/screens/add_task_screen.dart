import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/add_task_controller.dart';
import '../utils/add_task_localization.dart';
import '../widgets/add_task_view.dart';

class AddTaskScreen extends StatefulWidget {
  final int resetVersion;
  final int childrenVersion;
  final VoidCallback onTaskSaved;

  const AddTaskScreen({
    super.key,
    this.resetVersion = 0,
    this.childrenVersion = 0,
    required this.onTaskSaved,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final AddTaskController _controller;

  final ScrollController _scrollController = ScrollController();

  String? _currentLanguageCode;

  @override
  void initState() {
    super.initState();

    _controller = AddTaskController(languageCode: 'ar')..loadChildren();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final languageCode = Localizations.localeOf(context).languageCode;

    if (_currentLanguageCode == languageCode) {
      return;
    }

    _currentLanguageCode = languageCode;
    _controller.updateLanguage(languageCode);
  }

  @override
  void didUpdateWidget(covariant AddTaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.childrenVersion != widget.childrenVersion) {
      _controller.loadChildren();
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
      _controller.reset();
      _scrollToTop();
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
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  sheetContext.l10n.chooseMonthDay,
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
                        Navigator.pop(sheetContext, day);
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
                          textDirection: TextDirection.ltr,
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
      final message =
          result.backendMessage ?? result.errorCode?.localized(context);

      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      _scrollToTop();
      return;
    }

    _controller.reset();
    _scrollToTop();

    widget.onTaskSaved();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddTaskView(
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
