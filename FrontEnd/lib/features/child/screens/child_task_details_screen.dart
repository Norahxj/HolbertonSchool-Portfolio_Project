import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/task_assignment_model.dart';
import '../../../services/task_api_service.dart';

class ChildTaskDetailsScreen extends StatefulWidget {
  final TaskAssignmentModel assignment;
  final IconData icon;
  final bool isArabic;

  const ChildTaskDetailsScreen({
    super.key,
    required this.assignment,
    required this.icon,
    required this.isArabic,
  });

  @override
  State<ChildTaskDetailsScreen> createState() => _ChildTaskDetailsScreenState();
}

class _ChildTaskDetailsScreenState extends State<ChildTaskDetailsScreen> {
  final TaskApiService _taskApiService = TaskApiService();

  late String _status;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    _status = widget.assignment.normalizedStatus;
  }

  bool get _canComplete {
    return _status == 'PENDING';
  }

  bool get _isPendingReview {
    return _status == 'PENDING_REVIEW' || _status == 'COMPLETED';
  }

  bool get _isApproved {
    return _status == 'APPROVED';
  }

  bool get _isRejected {
    return _status == 'REJECTED';
  }

  Future<void> _completeTask() async {
    if (!_canComplete || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _taskApiService.completeAssignment(widget.assignment.id);

      if (!mounted) return;

      setState(() {
        if (widget.assignment.task.isAutoVerified) {
          _status = 'APPROVED';
        } else {
          _status = 'PENDING_REVIEW';
        }
      });

      final message = widget.assignment.task.isAutoVerified
    ? (widget.isArabic
          ? 'أحسنت! اكتملت المهمة وأُضيفت نقاطك.'
          : 'Well done! The task is complete and your points were added.')
    : (widget.isArabic
          ? 'أحسنت! أُرسلت المهمة إلى ولي أمرك للمراجعة.'
          : 'Well done! The task was sent to your guardian for review.');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on DioException catch (error) {
      if (!mounted) return;

      final backendMessage = _readBackendMessage(error);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
  backendMessage ??
      (widget.isArabic
          ? 'تعذّر إكمال المهمة. حاول مرة أخرى.'
          : 'Could not complete the task. Please try again.'),
),
        ),
      );

      debugPrint(
        'Complete assignment failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      if (!mounted) return;

     ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text(
      widget.isArabic
          ? 'حدث خطأ أثناء إكمال المهمة.'
          : 'An error occurred while completing the task.',
    ),
  ),
);

      debugPrint('Complete assignment failed: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }

  String _frequencyText(String frequency) {
  switch (frequency.toUpperCase()) {
    case 'DAILY':
      return widget.isArabic ? 'يوميًا' : 'Daily';

    case 'WEEKLY':
      return widget.isArabic ? 'أسبوعيًا' : 'Weekly';

    case 'MONTHLY':
      return widget.isArabic ? 'شهريًا' : 'Monthly';

    default:
      return frequency.isEmpty
          ? (widget.isArabic ? 'غير محدد' : 'Not specified')
          : frequency;
  }
}

  String get _statusText {
  if (_isApproved) {
    return widget.isArabic ? 'مكتملة ومعتمدة' : 'Completed and approved';
  }

  if (_isPendingReview) {
    return widget.isArabic
        ? 'بانتظار مراجعة ولي الأمر'
        : 'Waiting for guardian review';
  }

  if (_isRejected) {
    return widget.isArabic ? 'مرفوضة' : 'Rejected';
  }

  return widget.isArabic ? 'جاهزة للإنجاز' : 'Ready to complete';
}

  Color get _statusColor {
    if (_isApproved) {
      return AppColors.success;
    }

    if (_isPendingReview) {
      return const Color(0xFFC08A3E);
    }

    if (_isRejected) {
      return AppColors.error;
    }

    return AppColors.primary;
  }

  Color get _statusBackground {
    if (_isApproved) {
      return const Color(0xFFE8F5EA);
    }

    if (_isPendingReview) {
      return const Color(0xFFFFF4D6);
    }

    if (_isRejected) {
      return const Color(0xFFF9DEDE);
    }

    return AppColors.primaryLight;
  }

  IconData get _statusIcon {
    if (_isApproved) {
      return Icons.check_circle_rounded;
    }

    if (_isPendingReview) {
      return Icons.hourglass_top_rounded;
    }

    if (_isRejected) {
      return Icons.cancel_rounded;
    }

    return Icons.task_alt_rounded;
  }

  String get _buttonText {
  if (_isApproved) {
    return widget.isArabic ? 'تم اعتماد المهمة' : 'Task approved';
  }

  if (_isPendingReview) {
    return widget.isArabic ? 'بانتظار المراجعة' : 'Waiting for review';
  }

  if (_isRejected) {
    return widget.isArabic ? 'تم رفض المهمة' : 'Task rejected';
  }

  return widget.isArabic ? 'أنجزت المهمة' : 'I completed the task';
}

  IconData get _buttonIcon {
    if (_isApproved) {
      return Icons.check_circle_rounded;
    }

    if (_isPendingReview) {
      return Icons.hourglass_top_rounded;
    }

    if (_isRejected) {
      return Icons.close_rounded;
    }

    return Icons.check_rounded;
  }

  String get _verificationMessage {
  if (widget.assignment.task.isAutoVerified) {
    return widget.isArabic
        ? 'ستُعتمد هذه المهمة تلقائيًا عند إتمامها، '
              'وتُضاف النقاط مباشرة إلى رصيدك.'
        : 'This task will be approved automatically when completed, '
              'and the points will be added directly to your balance.';
  }

  return widget.isArabic
      ? 'عند إتمامك المهمة سيراجعها ولي أمرك، '
            'وبعد الاعتماد تُضاف النقاط إلى رصيدك.'
      : 'After you complete the task, your guardian will review it. '
            'Once approved, the points will be added to your balance.';
}

  @override
  Widget build(BuildContext context) {
    final task = widget.assignment.task;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
  alignment: widget.isArabic
      ? Alignment.centerRight
      : Alignment.centerLeft,
  child: _RoundBackButton(
  isArabic: widget.isArabic,
  onTap: () {
    Navigator.pop(context, true);
  },
),
              ),

              const SizedBox(height: AppSpacing.lg),

              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Icon(
                    widget.icon,
                    color: AppColors.primaryDark,
                    size: 56,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Text(
                task.title,
                style: AppTextStyles.arabicTitle,
                textAlign: TextAlign.center,
                 textDirection:
      widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
              ),

              const SizedBox(height: AppSpacing.sm),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: AppColors.gold,
                    size: 18,
                  ),

                  const SizedBox(width: 4),

                  Text(
                    widget.isArabic
    ? '${task.points} نقاط نور'
    : '${task.points} Noor Points',
                    textDirection:
    widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC08A3E),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _statusBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_statusIcon, color: _statusColor, size: 16),

                      const SizedBox(width: 6),

                      Text(
                        _statusText,
                        textDirection:
    widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
  alignment: widget.isArabic
      ? Alignment.centerRight
      : Alignment.centerLeft,
  child: Text(
    widget.isArabic ? 'الوصف' : 'Description',
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  ),
),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      task.description.isEmpty
    ? (widget.isArabic
          ? 'لا يوجد وصف لهذه المهمة.'
          : 'There is no description for this task.')
    : task.description,
                      textAlign:
    widget.isArabic ? TextAlign.right : TextAlign.left,
textDirection:
    widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
  mainAxisAlignment: widget.isArabic
      ? MainAxisAlignment.end
      : MainAxisAlignment.start,
  children: [
                        Text(
                          _frequencyText(task.taskFrequency),
                          textDirection:
    widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),

                        const SizedBox(width: 6),

                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
  textDirection:
      widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
  children: [
    const Icon(
      Icons.auto_awesome,
      color: AppColors.primary,
      size: 18,
    ),

    const SizedBox(width: AppSpacing.sm),

    Expanded(
      child: Text(
        _verificationMessage,
        textAlign:
            widget.isArabic ? TextAlign.right : TextAlign.left,
        textDirection:
            widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: const TextStyle(
          fontSize: 13,
          height: 1.5,
          color: AppColors.textPrimary,
        ),
      ),
    ),
  ],
),
              ),

              const SizedBox(height: AppSpacing.xl),

              GestureDetector(
                onTap: _canComplete && !_isSubmitting ? _completeTask : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _canComplete
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.primaryGradient,
                          )
                        : null,
                    color: _canComplete ? null : _statusBackground,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
    mainAxisAlignment: MainAxisAlignment.center,
    textDirection:
        widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
    children: [
      Text(
        _buttonText,
        textDirection:
            widget.isArabic ? TextDirection.rtl : TextDirection.ltr,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _canComplete
              ? Colors.white
              : _statusColor,
        ),
      ),

      const SizedBox(width: AppSpacing.sm),

      Icon(
        _buttonIcon,
        color: _canComplete
            ? Colors.white
            : _statusColor,
        size: 20,
      ),
    ],
  ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isArabic;

  const _RoundBackButton({
    required this.onTap,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLight,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
  width: 44,
  height: 44,
  child: Icon(
    isArabic
        ? Icons.arrow_forward_rounded
        : Icons.arrow_back_rounded,
    size: 18,
    color: AppColors.primaryDark,
  ),
),
      ),
    );
  }
}
