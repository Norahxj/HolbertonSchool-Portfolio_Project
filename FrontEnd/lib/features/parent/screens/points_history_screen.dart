import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/app_page_header.dart';
import '../../../core/widgets/screen_background.dart';
import '../../../models/points_history_model.dart';
import '../../../services/points_history_api_service.dart';

class PointsHistoryScreen extends StatefulWidget {
  final String childId;
  final String childName;
  final bool isArabic;

  const PointsHistoryScreen({
    super.key,
    required this.childId,
    required this.childName,
    required this.isArabic,
  });

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen> {
  final PointsHistoryApiService _service = PointsHistoryApiService();

  late Future<List<PointsHistoryModel>> _historyFuture;

  bool get isArabic => widget.isArabic;

  @override
  void initState() {
    super.initState();

    _historyFuture = _service.getChildHistory(widget.childId);
  }

  Future<void> _reloadHistory() async {
    final future = _service.getChildHistory(widget.childId);

    setState(() {
      _historyFuture = future;
    });

    await future;
  }

  @override
  Widget build(BuildContext context) {
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
                    ? 'سجل نقاط ${widget.childName}'
                    : '${widget.childName}\'s Points History',
                onBack: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: ScreenBackground(
          child: FutureBuilder<List<PointsHistoryModel>>(
            future: _historyFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _ErrorState(isArabic: isArabic, onRetry: _reloadHistory);
              }

              final history = snapshot.data ?? <PointsHistoryModel>[];

              if (history.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _reloadHistory,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.55,
                        child: _EmptyState(isArabic: isArabic),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _reloadHistory,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: history.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return _HistoryCard(
                      item: history[index],
                      isArabic: isArabic,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PointsHistoryModel item;
  final bool isArabic;

  const _HistoryCard({required this.item, required this.isArabic});

  bool get isAdded => item.points >= 0;

  String get _title {
    if (item.taskAssignment != null) {
      final taskTitle = item.taskAssignment!.task.title;

      return isArabic ? 'إكمال مهمة: $taskTitle' : 'Task completed: $taskTitle';
    }

    if (item.wishlist != null) {
      final wishName = item.wishlist!.name;

      return isArabic ? 'تحقيق أمنية: $wishName' : 'Wish achieved: $wishName';
    }

    return isArabic ? 'تحديث في النقاط' : 'Points update';
  }

  String get _date {
    final date = item.createdAt.toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isAdded ? AppColors.primaryLight : AppColors.goldLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isAdded ? Icons.add_circle_outline : Icons.card_giftcard,
              color: isAdded ? AppColors.primary : AppColors.gold,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _date,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          Text(
            '${isAdded ? '+' : ''}${item.points}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: isAdded ? AppColors.primary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isArabic;

  const _EmptyState({required this.isArabic});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.history, size: 58, color: AppColors.textSecondary),

          const SizedBox(height: AppSpacing.md),

          Text(
            isArabic ? 'لا يوجد سجل نقاط حتى الآن' : 'No points history yet',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            isArabic
                ? 'ستظهر هنا النقاط المكتسبة والمخصومة.'
                : 'Earned and deducted points will appear here.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final bool isArabic;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.isArabic, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isArabic
                ? 'تعذّر تحميل سجل النقاط.'
                : 'Could not load points history.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error),
          ),

          const SizedBox(height: AppSpacing.md),

          ElevatedButton(
            onPressed: onRetry,
            child: Text(isArabic ? 'إعادة المحاولة' : 'Try again'),
          ),
        ],
      ),
    );
  }
}
