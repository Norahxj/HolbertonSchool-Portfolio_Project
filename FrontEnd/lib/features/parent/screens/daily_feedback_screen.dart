import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/child_model.dart';
import '../../../models/daily_feedback_model.dart';
import 'package:frontend/features/parent/services/child_api_service.dart';
import '../../../services/daily_feedback_api_service.dart';

/// Parent screen to submit and view daily mood feedback for each child.
///
/// Requirement #7: Parent can select a mood emoji for each child and submit.
/// If today's feedback already exists, it shows the current mood and allows
/// editing. The history list shows all past feedback entries.
class DailyFeedbackScreen extends StatefulWidget {
  const DailyFeedbackScreen({super.key});

  @override
  State<DailyFeedbackScreen> createState() => _DailyFeedbackScreenState();
}

class _DailyFeedbackScreenState extends State<DailyFeedbackScreen> {
  final DailyFeedbackApiService _feedbackService = DailyFeedbackApiService();
  final ChildApiService _childService = ChildApiService();

  List<ChildModel> _children = [];
  ChildModel? _selectedChild;

  List<DailyFeedbackModel> _feedbackHistory = [];
  DailyFeedbackModel? _todayFeedback;

  String? _selectedMood;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    try {
      final children = await _childService.getChildren();
      if (mounted) {
        setState(() {
          _children = children;
          if (children.isNotEmpty) {
            _selectedChild = children.first;
          }
          _isLoading = false;
        });
        if (_selectedChild != null) {
          await _loadFeedbackForChild(_selectedChild!.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'تعذّر تحميل بيانات الأطفال';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadFeedbackForChild(String childId) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _todayFeedback = null;
      _selectedMood = null;
    });

    try {
      final results = await Future.wait([
        _feedbackService.getFeedbackForChild(childId),
        _feedbackService.getTodayFeedback(childId),
      ]);

      if (mounted) {
        final history = results[0] as List<DailyFeedbackModel>;
        final today = results[1] as DailyFeedbackModel?;
        setState(() {
          _feedbackHistory = history;
          _todayFeedback = today;
          _selectedMood = today?.mood;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'تعذّر تحميل سجل التقييم';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitFeedback() async {
    if (_selectedChild == null || _selectedMood == null) return;

    setState(() => _isSubmitting = true);

    try {
      if (_todayFeedback != null) {
        // Update existing feedback
        await _feedbackService.updateFeedback(
          feedbackId: _todayFeedback!.id,
          mood: _selectedMood!,
        );
      } else {
        // Create new feedback
        await _feedbackService.createFeedback(
          childId: _selectedChild!.id,
          mood: _selectedMood!,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التقييم بنجاح ✓'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadFeedbackForChild(_selectedChild!.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر حفظ التقييم. حاول مرة أخرى.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text('التقييم اليومي', style: AppTextStyles.arabicTitle),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
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
                    onPressed: _loadChildren,
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Child selector ─────────────────────────────────────
                  if (_children.length > 1) ...[
                    Text('اختر الطفل', style: AppTextStyles.body),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _children.map((child) {
                          final isSelected = _selectedChild?.id == child.id;
                          return Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedChild = child);
                                _loadFeedbackForChild(child.id);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.card,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Text(
                                  child.name,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

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
                              ? 'تقييم اليوم (يمكنك التعديل)'
                              : 'كيف كان يوم ${_selectedChild?.name ?? "الطفل"}؟',
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
                                      ? 'تحديث التقييم'
                                      : 'حفظ التقييم',
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
                    Text('سجل التقييمات', style: AppTextStyles.arabicTitle),
                    const SizedBox(height: AppSpacing.md),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _feedbackHistory.length,
                      separatorBuilder: (_, __) =>
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
                                      kMoodLabels[fb.mood] ?? fb.mood,
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
        return 'سعيد';
      case 'PROUD':
        return 'فخور';
      case 'GREAT':
        return 'رائع';
      case 'LOVE':
        return 'محبوب';
      case 'STRONG':
        return 'قوي';
      case 'STAR':
        return 'نجم';
      default:
        return mood;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
