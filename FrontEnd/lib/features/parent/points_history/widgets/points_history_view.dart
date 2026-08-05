import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/screen_background.dart';
import '../controllers/points_history_controller.dart';
import 'points_history_card.dart';
import 'points_history_empty_state.dart';
import 'points_history_error_state.dart';

class PointsHistoryView extends StatelessWidget {
  final String childName;
  final bool isArabic;
  final VoidCallback onBack;

  const PointsHistoryView({
    super.key,
    required this.childName,
    required this.isArabic,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<PointsHistoryController>();

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
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
                isArabic: isArabic,
                title: isArabic
                    ? 'سجل نقاط $childName'
                    : '$childName\'s Points History',
                onBack: onBack,
              ),
            ),
          ),
        ),
        body: ScreenBackground(
          child: controller.isLoading
              ? const Center(child: CircularProgressIndicator())
              : controller.errorMessage != null
              ? PointsHistoryErrorState(
                  isArabic: isArabic,
                  onRetry: controller.loadHistory,
                )
              : controller.history.isEmpty
              ? RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.55,
                        child: PointsHistoryEmptyState(isArabic: isArabic),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: controller.history.length,
                    separatorBuilder: (_, _) {
                      return const SizedBox(height: AppSpacing.md);
                    },
                    itemBuilder: (context, index) {
                      return PointsHistoryCard(
                        item: controller.history[index],
                        isArabic: isArabic,
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
