import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../controllers/daily_feedback_controller.dart';
import '../utils/daily_feedback_localization.dart';
import 'daily_feedback_error_state.dart';
import 'feedback_history_section.dart';
import 'today_feedback_card.dart';

class DailyFeedbackView extends StatelessWidget {
  final Future<void> Function() onSubmit;
  final VoidCallback onBack;

  const DailyFeedbackView({
    super.key,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<DailyFeedbackController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(76),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: AppPageHeader(
              title: context.l10n.dailyFeedback,
              onBack: onBack,
            ),
          ),
        ),
      ),
      body: controller.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : controller.errorCode != null
              ? DailyFeedbackErrorState(
                  message: controller.errorCode!.localized(context),
                  onRetry: controller.loadFeedback,
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TodayFeedbackCard(
                        childName: controller.child.name,
                        todayFeedback: controller.todayFeedback,
                        selectedMood: controller.selectedMood,
                        isSubmitting: controller.isSubmitting,
                        onMoodSelected: controller.selectMood,
                        onSubmit: onSubmit,
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      FeedbackHistorySection(
                        feedbackHistory: controller.feedbackHistory,
                      ),
                    ],
                  ),
                ),
    );
  }
}