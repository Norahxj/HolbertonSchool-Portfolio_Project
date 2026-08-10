import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../../../models/task_assignment_model.dart';
import '../controllers/child_task_details_controller.dart';
import '../models/child_task_details_action_result.dart';
import '../widgets/child_task_details_view.dart';

class ChildTaskDetailsScreen extends StatefulWidget {
  final TaskAssignmentModel assignment;
  final IconData icon;

  const ChildTaskDetailsScreen({
    super.key,
    required this.assignment,
    required this.icon,
  });

  @override
  State<ChildTaskDetailsScreen> createState() {
    return _ChildTaskDetailsScreenState();
  }
}

class _ChildTaskDetailsScreenState extends State<ChildTaskDetailsScreen> {
  late final ChildTaskDetailsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ChildTaskDetailsController()
      ..initialize(widget.assignment);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _completeTask() async {
    final result = await _controller.completeTask();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showCompleteError(result);
      return;
    }

    final message = widget.assignment.task.isAutoVerified
        ? context.l10n.childTaskAutoApprovedSuccess
        : context.l10n.childTaskSentForReviewSuccess;

    _showMessage(message);
  }

  void _showCompleteError(ChildTaskDetailsActionResult result) {
    final message =
        result.backendMessage ??
        result.errorCode?.localized(context) ??
        context.l10n.childTaskCompleteFailed;

    _showMessage(message);
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _goBack() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildTaskDetailsView(
        icon: widget.icon,
        onBack: _goBack,
        onComplete: _completeTask,
      ),
    );
  }
}

extension ChildTaskDetailsErrorCodeLocalization
    on ChildTaskDetailsErrorCode {
  String localized(BuildContext context) {
    switch (this) {
      case ChildTaskDetailsErrorCode.completeFailed:
        return context.l10n.childTaskCompleteFailed;

      case ChildTaskDetailsErrorCode.unexpectedError:
        return context.l10n.childTaskUnexpectedError;
    }
  }
}