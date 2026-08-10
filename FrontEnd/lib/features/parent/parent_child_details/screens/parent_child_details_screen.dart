import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/child_model.dart';
import '../../child_form/screens/child_form_screen.dart';
import '../../child_tasks/screens/child_tasks_screen.dart';
import '../../daily_feedback/screens/daily_feedback_screen.dart';
import '../../points_history/screens/points_history_screen.dart';
import '../controllers/parent_child_details_controller.dart';
import '../models/parent_child_details_action_result.dart';
import '../utils/parent_child_details_localization.dart';
import '../widgets/parent_child_details_view.dart';

class ParentChildDetailsScreen extends StatefulWidget {
  final ChildModel child;
  final int? points;
  final int progressPercentage;

  const ParentChildDetailsScreen({
    super.key,
    required this.child,
    required this.points,
    required this.progressPercentage,
  });

  @override
  State<ParentChildDetailsScreen> createState() {
    return _ParentChildDetailsScreenState();
  }
}

class _ParentChildDetailsScreenState extends State<ParentChildDetailsScreen> {
  late final ParentChildDetailsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ParentChildDetailsController()..loadTasks(widget.child.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteChild() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.deleteChildConfirmationTitle(widget.child.name),
            textAlign: TextAlign.start,
          ),
          content: Text(
            context.l10n.deleteChildConfirmationDescription,
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(context.l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result = await _controller.deleteChild();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(result);
      return;
    }

    _showMessage(context.l10n.childDeletedSuccessfully);

    Navigator.pop(context, true);
  }

  Future<void> _openEditChild() async {
    final updatedChild = await Navigator.push<ChildModel>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildFormScreen.edit(child: widget.child);
        },
      ),
    );

    if (!mounted || updatedChild == null) {
      return;
    }

    Navigator.pop(context, true);
  }

  Future<void> _copyAccessCode() async {
    final accessCode = widget.child.accessCode;

    if (accessCode.trim().isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: accessCode));

    if (!mounted) {
      return;
    }

    _showMessage(context.l10n.childAccessCodeCopied);
  }

  void _openPointsHistory() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PointsHistoryScreen(
            childId: widget.child.id,
            childName: widget.child.name,
          );
        },
      ),
    );
  }

  void _openDailyFeedback() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return DailyFeedbackScreen(child: widget.child);
        },
      ),
    );
  }

  void _openTasks() {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildTasksScreen(
            childId: widget.child.id,
            childName: widget.child.name,
          );
        },
      ),
    );
  }

  void _showActionError(ParentChildDetailsActionResult result) {
    final message =
        result.backendMessage ??
        result.errorCode?.localized(context) ??
        context.l10n.failedToDeleteChild;

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ParentChildDetailsView(
        child: widget.child,
        points: widget.points,
        progressPercentage: widget.progressPercentage,
        onBack: _goBack,
        onCopyAccessCode: _copyAccessCode,
        onPointsHistoryTap: _openPointsHistory,
        onDailyFeedbackTap: _openDailyFeedback,
        onTasksTap: _openTasks,
        onEditChildTap: _openEditChild,
        onDeleteChildTap: _confirmDeleteChild,
      ),
    );
  }
}
