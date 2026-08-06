import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../models/child_model.dart';
import '../controllers/daily_feedback_controller.dart';
import '../utils/daily_feedback_localization.dart';
import '../widgets/daily_feedback_view.dart';

class DailyFeedbackScreen extends StatefulWidget {
  final ChildModel child;

  const DailyFeedbackScreen({super.key, required this.child});

  @override
  State<DailyFeedbackScreen> createState() {
    return _DailyFeedbackScreenState();
  }
}

class _DailyFeedbackScreenState extends State<DailyFeedbackScreen> {
  late final DailyFeedbackController _controller;

  @override
  void initState() {
    super.initState();

    _controller = DailyFeedbackController(child: widget.child)..loadFeedback();
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
      final message = result.errorCode?.localized(context);

      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
      }

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.feedbackSavedSuccessfully),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: DailyFeedbackView(
        onSubmit: _submitFeedback,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
