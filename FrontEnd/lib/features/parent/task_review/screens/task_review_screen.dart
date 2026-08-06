import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/task_review_controller.dart';
import '../models/review_task.dart';
import '../utils/task_review_localization.dart';
import '../widgets/task_review_view.dart';

class TaskReviewScreen extends StatefulWidget {
  const TaskReviewScreen({super.key});

  @override
  State<TaskReviewScreen> createState() {
    return _TaskReviewScreenState();
  }
}

class _TaskReviewScreenState extends State<TaskReviewScreen> {
  late final TaskReviewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TaskReviewController()..loadPendingTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _approveTask(ReviewTask item) async {
    final result = await _controller.approveTask(item);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(result);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.taskAcceptedSuccessfully(item.assignment.task.title),
        ),
      ),
    );
  }

  Future<void> _sendBackForRetry(ReviewTask item) async {
    final result = await _controller.sendBackForRetry(item);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(result);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.taskSentForRetrySuccessfully(item.assignment.task.title),
        ),
      ),
    );
  }

  void _showActionError(TaskReviewActionResult result) {
    final message =
        result.backendMessage ??
        result.errorCode?.localized(context) ??
        context.l10n.taskReviewGenericError;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: TaskReviewView(
        onApprove: _approveTask,
        onRetry: _sendBackForRetry,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
