import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/child_model.dart';
import '../../../models/daily_feedback_model.dart';
import '../../../services/daily_feedback_api_service.dart';
import '../../../core/widgets/app_page_header.dart';

/// Parent screen to submit and view daily mood feedback for each child.
///
/// Requirement #7: Parent can select a mood emoji for each child and submit.
/// If today's feedback already exists, it shows the current mood and allows
/// editing. The history list shows all past feedback entries.
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
  final DailyFeedbackApiService _feedbackService = DailyFeedbackApiService();

  late final ChildModel _selectedChild;

  List<DailyFeedbackModel> _feedbackHistory = [];
  DailyFeedbackModel? _todayFeedback;

  String? _selectedMood;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  bool get isArabic => widget.isArabic;

  bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

  @override
void initState() {
  super.initState();

  _selectedChild = widget.child;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadFeedbackForChild(_selectedChild.id);
  });
}

  
  Future<void> _loadFeedbackForChild(String childId) async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final history =
        await _feedbackService.getFeedbackForChild(childId);
history.sort(
  (first, second) =>
      second.feedbackDate.compareTo(first.feedbackDate),
);
    if (!mounted) return;

    final today = DateTime.now();

    DailyFeedbackModel? todayFeedback;

    for (final feedback in history) {
      if (_isSameDay(feedback.feedbackDate, today)) {
        todayFeedback = feedback;
        break;
      }
    }

    setState(() {
      _feedbackHistory = history;
      _todayFeedback = todayFeedback;
      _selectedMood = todayFeedback?.mood;
      _isLoading = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _error = isArabic
          ? 'تعذّر تحميل سجل التقييم'
          : 'Unable to load feedback history';

      _isLoading = false;
    });
  }
}

  Future<void> _submitFeedback() async {
  if (_selectedMood == null || _isSubmitting) {
    return;
  }

  setState(() {
    _isSubmitting = true;
  });

  try {
    late final DailyFeedbackModel savedFeedback;

    if (_todayFeedback != null) {
      savedFeedback = await _feedbackService.updateFeedback(
        feedbackId: _todayFeedback!.id,
        mood: _selectedMood!,
      );
    } else {
      savedFeedback = await _feedbackService.createFeedback(
        childId: _selectedChild.id,
        mood: _selectedMood!,
      );
    }

    if (!mounted) return;

    setState(() {
      _todayFeedback = savedFeedback;
      _selectedMood = savedFeedback.mood;

      final existingIndex = _feedbackHistory.indexWhere(
        (feedback) => feedback.id == savedFeedback.id,
      );

      if (existingIndex == -1) {
        _feedbackHistory.insert(0, savedFeedback);
      } else {
        _feedbackHistory[existingIndex] = savedFeedback;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تم حفظ التقييم بنجاح ✓'
              : 'Feedback saved successfully ✓',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isArabic
              ? 'تعذّر حفظ التقييم. حاول مرة أخرى.'
              : 'Unable to save feedback. Please try again.',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
  @override
  Widget build(BuildContext context) {
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
         isArabic: isArabic,
        title: isArabic
            ? 'التقييم اليومي'
            : 'Daily Feedback',
        onBack: () {
          Navigator.pop(context);
        },
      ),
    ),
  ),
),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!, style: const TextStyle(color: AppColors.error)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
  _loadFeedbackForChild(_selectedChild.id);
},
                    child: Text(
                      isArabic ? 'إعادة المحاولة' : 'Try Again',
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  

                  // ── Today's mood picker ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _todayFeedback != null
                              ? isArabic
                                  ? 'تقييم اليوم (يمكنك التعديل)'
                                  : 'Today\'s Feedback (You Can Edit It)'
                              : isArabic
                                  ? 'كيف كان يوم ${_selectedChild.name}؟'
                                  : 'How was ${_selectedChild.name}\'s day?',
                          style: AppTextStyles.arabicTitle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 12,
                          children: kMoodValues.map((mood) {
                            final isSelected = _selectedMood == mood;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedMood = mood),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.background,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _moodEmoji(mood),
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _moodShortLabel(mood),
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        ElevatedButton(
                          onPressed: (_selectedMood != null && !_isSubmitting)
                              ? _submitFeedback
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  _todayFeedback != null
                                      ? isArabic
                                          ? 'تحديث التقييم'
                                          : 'Update Feedback'
                                      : isArabic
                                          ? 'حفظ التقييم'
                                          : 'Save Feedback',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // ── History ────────────────────────────────────────────
                  if (_feedbackHistory.isNotEmpty) ...[
                    Text(
                      isArabic ? 'سجل التقييمات' : 'Feedback History',
                      style: AppTextStyles.arabicTitle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _feedbackHistory.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final fb = _feedbackHistory[index];
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _moodEmoji(fb.mood),
                                style: const TextStyle(fontSize: 28),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _moodShortLabel(fb.mood),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      _formatDate(fb.feedbackDate),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'HAPPY':
        return '😊';
      case 'PROUD':
        return '🌟';
      case 'GREAT':
        return '🎉';
      case 'LOVE':
        return '❤️';
      case 'STRONG':
        return '💪';
      case 'STAR':
        return '⭐';
      default:
        return '😊';
    }
  }

  String _moodShortLabel(String mood) {
    switch (mood) {
      case 'HAPPY':
        return isArabic ? 'سعيد' : 'Happy';
      case 'PROUD':
        return isArabic ? 'فخور' : 'Proud';
      case 'GREAT':
        return isArabic ? 'رائع' : 'Great';
      case 'LOVE':
        return isArabic ? 'محبوب' : 'Loved';
      case 'STRONG':
        return isArabic ? 'قوي' : 'Strong';
      case 'STAR':
        return isArabic ? 'نجم' : 'Star';
      default:
        return mood;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}