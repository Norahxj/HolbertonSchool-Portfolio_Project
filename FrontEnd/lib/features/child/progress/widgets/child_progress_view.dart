import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/localization/localization_extension.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/child_progress_controller.dart';
import 'progress_error_state.dart';
import 'progress_stat_tile.dart';
import 'progress_summary_card.dart';
import 'progress_trophies_section.dart';
import 'progress_weekly_bar_chart.dart';

class ChildProgressView
    extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRetry;

  const ChildProgressView({
    super.key,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final controller =
        context.watch<
            ChildProgressController>();

    if (controller.isLoading) {
      return const Scaffold(
        backgroundColor:
            AppColors.background,
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    if (controller.hasError) {
      return Scaffold(
        backgroundColor:
            AppColors.background,
        body: ProgressErrorState(
          onRetry: onRetry,
        ),
      );
    }

    final progressMessage =
        _progressMessage(
      context,
      controller,
    );

    return Scaffold(
      backgroundColor:
          Colors.transparent,
      body: ScreenBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(),
              padding:
                  const EdgeInsets.all(
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  Text(
                    context
                        .l10n
                        .childProgressTitle,
                    style:
                        AppTextStyles
                            .arabicTitle,
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.lg,
                  ),

                  ProgressSummaryCard(
                    percent: controller
                        .weeklyPercent,
                    message:
                        progressMessage,
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.lg,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child:
                            ProgressStatTile(
                          icon: Icons
                              .water_drop,
                          iconColor:
                              const Color(
                            0xFFDE9A3E,
                          ),
                          value:
                              '${controller.currentStreak}',
                          label: context
                              .l10n
                              .progressDayStreak,
                        ),
                      ),

                      const SizedBox(
                        width:
                            AppSpacing.sm,
                      ),

                      Expanded(
                        child:
                            ProgressStatTile(
                          icon: Icons
                              .check_circle_outline,
                          iconColor:
                              AppColors
                                  .success,
                          value:
                              '${controller.totalCompleted}',
                          label: context
                              .l10n
                              .progressCompletedTasks,
                        ),
                      ),

                      const SizedBox(
                        width:
                            AppSpacing.sm,
                      ),

                      Expanded(
                        child:
                            ProgressStatTile(
                          icon: Icons
                              .auto_awesome,
                          iconColor:
                              AppColors.gold,
                          value:
                              '${controller.points}',
                          label: context
                              .l10n
                              .progressPointsBalance,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.xl,
                  ),

                  ProgressTrophiesSection(
                    completedByCategory:
                        controller
                            .completedByCategory,
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.xl,
                  ),

                  Align(
                    alignment:
                        AlignmentDirectional
                            .centerStart,
                    child: Text(
                      context
                          .l10n
                          .progressWeeklyActivity,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color: AppColors
                            .textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.sm,
                  ),

                  ProgressWeeklyBarChart(
                    activity: controller
                        .weeklyActivity,
                  ),

                  const SizedBox(
                    height:
                        AppSpacing.lg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _progressMessage(
    BuildContext context,
    ChildProgressController controller,
  ) {
    if (controller.weeklyTotal == 0) {
      return context
          .l10n
          .progressNoTasksThisWeek;
    }

    if (controller.weeklyCompleted ==
        controller.weeklyTotal) {
      return context
          .l10n
          .progressAllTasksCompleted;
    }

    return context.l10n
        .progressCompletedOfTotal(
      controller.weeklyCompleted,
      controller.weeklyTotal,
    );
  }
}