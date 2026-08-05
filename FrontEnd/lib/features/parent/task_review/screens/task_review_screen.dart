import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/task_review_view.dart';
import '../controllers/task_review_controller.dart';
import '../models/review_task.dart';

class TaskReviewScreen extends StatefulWidget {
  final bool isArabic;

  const TaskReviewScreen({super.key, required this.isArabic});

  @override
  State<TaskReviewScreen> createState() => _TaskReviewScreenState();
}

class _TaskReviewScreenState extends State<TaskReviewScreen> {
  late final TaskReviewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TaskReviewController(isArabic: widget.isArabic)
      ..loadPendingTasks();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String tr(String arabic, String english) {
    return widget.isArabic ? arabic : english;
  }

  Future<void> _approveTask(ReviewTask item) async {
    final errorMessage = await _controller.approveTask(item);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tr('تم قبول مهمة ', 'Task accepted: ')}'
          '"${item.assignment.task.title}"',
        ),
      ),
    );
  }

  Future<void> _sendBackForRetry(ReviewTask item) async {
    final errorMessage = await _controller.sendBackForRetry(item);

    if (!mounted) {
      return;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${tr('تم إرسال المهمة لإعادة المحاولة: ', 'Task sent back for another try: ')}'
          '"${item.assignment.task.title}"',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: TaskReviewView(
        isArabic: widget.isArabic,
        onApprove: _approveTask,
        onRetry: _sendBackForRetry,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
