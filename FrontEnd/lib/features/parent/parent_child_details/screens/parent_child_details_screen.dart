import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../child_tasks/screens/child_tasks_screen.dart';
import '../../daily_feedback/screens/daily_feedback_screen.dart';
import '../../dashboard/controllers/parent_dashboard_controller.dart';
import '../../dashboard/models/parent_dashboard_data.dart';
import '../../dashboard/utils/parent_dashboard_localization.dart';
import '../../edit_child/screens/edit_child_screen.dart';
import '../../points_history/screens/points_history_screen.dart';
import '../controllers/parent_child_details_controller.dart';
import '../repositories/parent_child_details_repository.dart';
import '../widgets/parent_child_details_view.dart';

class ParentChildDetailsScreen extends StatefulWidget {
  final ParentDashboardChildItem item;

  const ParentChildDetailsScreen({super.key, required this.item});

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

    _controller = ParentChildDetailsController(ParentChildDetailsRepository())
      ..loadTasks(widget.item.child.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final childName = widget.item.child.name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            l10n.deleteChildConfirmationTitle(childName),
            textAlign: TextAlign.start,
          ),
          content: Text(
            l10n.deleteChildConfirmationDescription,
            textAlign: TextAlign.start,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(backgroundColor: AppColors.error),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final dashboardController = context.read<ParentDashboardController>();

    final deleted = await dashboardController.deleteChild(widget.item.child.id);

    if (!mounted) {
      return;
    }

    if (deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.childDeletedSuccessfully)),
      );

      Navigator.pop(context, true);
      return;
    }

    final message =
        dashboardController.backendMessage ??
        dashboardController.errorCode?.localized(context) ??
        context.l10n.failedToDeleteChild;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openEditChild() async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final updatedChild = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return EditChildScreen(child: widget.item.child, isArabic: isArabic);
        },
      ),
    );

    if (updatedChild == null || !mounted) {
      return;
    }

    await context.read<ParentDashboardController>().refresh();

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);
  }

  void _openPointsHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return PointsHistoryScreen(
            childId: widget.item.child.id,
            childName: widget.item.child.name,
          );
        },
      ),
    );
  }

  void _openDailyFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return DailyFeedbackScreen(child: widget.item.child);
        },
      ),
    );
  }

  void _openTasks() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildTasksScreen(
            childId: widget.item.child.id,
            childName: widget.item.child.name,
            controller: _controller,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ParentChildDetailsView(
        item: widget.item,
        onBack: () {
          Navigator.pop(context);
        },
        onPointsHistoryTap: _openPointsHistory,
        onDailyFeedbackTap: _openDailyFeedback,
        onTasksTap: _openTasks,
        onEditChildTap: _openEditChild,
        onDeleteChildTap: _confirmDelete,
      ),
    );
  }
}
