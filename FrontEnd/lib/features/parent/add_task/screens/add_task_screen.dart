import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_suggestion_model.dart';
import '../controllers/add_task_controller.dart';
import '../models/add_task_save_result.dart';
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
  State<AddTaskScreen> createState() {
    return _AddTaskScreenState();
  }
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  late final AddTaskController _controller;

  final ScrollController _scrollController = ScrollController();

  final TextEditingController _taskNameController = TextEditingController();

  final TextEditingController _taskDescriptionController =
      TextEditingController();

  String get _languageCode {
    return Localizations.localeOf(context).languageCode;
  }

  @override
  void initState() {
    super.initState();

    _controller = AddTaskController()..loadChildren();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_controller.selectedChildIds.isNotEmpty &&
        _controller.selectedTaskType != null) {
      _controller.loadTaskSuggestions(languageCode: _languageCode);
    }
  }

  @override
  void didUpdateWidget(covariant AddTaskScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.childrenVersion != widget.childrenVersion) {
      _controller.loadChildren();
    }

    if (oldWidget.resetVersion != widget.resetVersion) {
      _resetForm();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _taskNameController.dispose();
    _taskDescriptionController.dispose();
    _controller.dispose();

    super.dispose();
  }

  void _goToNextStep() {
    FocusScope.of(context).unfocus();

    final moved = _controller.goToNextStep(
      title: _taskNameController.text,
      description: _taskDescriptionController.text,
    );

    if (moved) {
      _scrollToTop();
    }
  }

  void _goToPreviousStep() {
    FocusScope.of(context).unfocus();

    final moved = _controller.goToPreviousStep();

    if (!moved) {
      _resetForm();
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

    if (!mounted || selectedDay == null) {
      return;
    }

    _controller.selectMonthlyDay(selectedDay);
  }

  Future<void> _saveTask() async {
    FocusScope.of(context).unfocus();

    final result = await _controller.saveTask(
      title: _taskNameController.text,
      description: _taskDescriptionController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _handleSaveFailure(result);
      _scrollToTop();
      return;
    }

    _resetForm();
    widget.onTaskSaved();
  }

  void _applySuggestion(TaskSuggestionModel suggestion) {
    _controller.applyTaskSuggestion(suggestion);

    _taskNameController.text = suggestion.title;

    _taskDescriptionController.text = suggestion.description;

    _scrollToTop();
  }

  void _handleSaveFailure(AddTaskSaveResult result) {
    final message =
        result.backendMessage ?? result.errorCode?.localized(context);

    if (message == null || message.trim().isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _resetForm() {
    _controller.reset();
    _taskNameController.clear();
    _taskDescriptionController.clear();

    _scrollToTop();
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

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddTaskView(
        scrollController: _scrollController,
        taskNameController: _taskNameController,
        taskDescriptionController: _taskDescriptionController,
        languageCode: _languageCode,
        onRefresh: _controller.loadChildren,
        onNext: _goToNextStep,
        onBack: _goToPreviousStep,
        onSave: _saveTask,
        onMonthlyDayPicker: _showMonthlyDayPicker,
        onSuggestionTap: _applySuggestion,
      ),
    );
  }
}
