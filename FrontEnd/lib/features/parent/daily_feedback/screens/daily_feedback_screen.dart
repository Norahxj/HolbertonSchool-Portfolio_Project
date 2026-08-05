import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/child_model.dart';
import '../controllers/daily_feedback_controller.dart';
import '../widgets/daily_feedback_view.dart';

class DailyFeedbackScreen extends StatefulWidget {
  final ChildModel child;
  final bool isArabic;

  const DailyFeedbackScreen({
    super.key,
    required this.child,
    required this.isArabic,
  });

  @override
  State<DailyFeedbackScreen> createState() => _DailyFeedbackScreenState();
}

class _DailyFeedbackScreenState extends State<DailyFeedbackScreen> {
  late final DailyFeedbackController _controller;

  bool get isArabic => widget.isArabic;

  @override
  void initState() {
    super.initState();

    _controller = DailyFeedbackController(
      child: widget.child,
      isArabic: widget.isArabic,
    )..loadFeedback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    final result = await _controller.submitFeedback();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      final message = result.errorMessage;

      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic ? 'تم حفظ التقييم بنجاح ✓' : 'Feedback saved successfully ✓',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: DailyFeedbackView(
        isArabic: isArabic,
        onSubmit: _submitFeedback,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
