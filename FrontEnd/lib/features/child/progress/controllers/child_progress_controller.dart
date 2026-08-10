import 'package:flutter/foundation.dart';

import '../../../../models/child_progress_summary_model.dart';
import '../../../../models/task_assignment_model.dart';
import '../models/progress_trophy_kind.dart';
import '../repositories/child_progress_repository.dart';

class ChildProgressController extends ChangeNotifier {
  final ChildProgressRepository _repository;

  ChildProgressController({
    ChildProgressRepository? repository,
  }) : _repository =
            repository ?? ChildProgressRepository();

  List<TaskAssignmentModel> _assignments = [];

  ChildProgressSummaryModel _summary =
      const ChildProgressSummaryModel(
    totalCompleted: 0,
    currentStreak: 0,
    completedByCategory: {},
  );

  int _points = 0;

  bool _isLoading = false;
  bool _isDisposed = false;
  bool _hasError = false;

  List<TaskAssignmentModel> get assignments {
    return List.unmodifiable(_assignments);
  }

  int get points => _points;

  bool get isLoading => _isLoading;

  bool get hasError => _hasError;

  int get totalCompleted {
    return _summary.totalCompleted;
  }

  int get currentStreak {
    return _summary.currentStreak;
  }

  int get weeklyCompleted {
    return _assignments.where(_isApprovedAssignment).length;
  }

  int get weeklyTotal {
    return _assignments.length;
  }

  int get weeklyPercent {
    if (_assignments.isEmpty) {
      return 0;
    }

    return ((weeklyCompleted / _assignments.length) * 100)
        .round()
        .clamp(0, 100);
  }

  List<int> get weeklyActivity {
    final counts = List<int>.filled(7, 0);

    for (final assignment in _assignments) {
      if (!_isApprovedAssignment(assignment)) {
        continue;
      }

      final completionDate =
          _completionDate(assignment);

      if (completionDate == null) {
        continue;
      }

      final index = completionDate.weekday % 7;

      counts[index]++;
    }

    return counts;
  }

  Map<ProgressTrophyKind, int>
      get completedByCategory {
    return {
      ProgressTrophyKind.daily:
          _summary.completedByCategory['DAILY'] ?? 0,
      ProgressTrophyKind.cultural:
          _summary.completedByCategory['CULTURAL'] ?? 0,
      ProgressTrophyKind.financial:
          _summary.completedByCategory['FINANCIAL'] ?? 0,
      ProgressTrophyKind.religious:
          _summary.completedByCategory['RELIGIOUS'] ?? 0,
    };
  }

  Future<void> loadProgress() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _hasError = false;
    _notify();

    try {
      final data =
          await _repository.getProgressData();

      _assignments = data.assignments;
      _points = data.points;
      _summary = data.summary;
    } catch (error, stackTrace) {
      _hasError = true;

      debugPrint(
        'Progress loading error: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  bool _isApprovedAssignment(
    TaskAssignmentModel assignment,
  ) {
    return assignment.normalizedStatus ==
        'APPROVED';
  }

  DateTime? _completionDate(
    TaskAssignmentModel assignment,
  ) {
    if (!_isApprovedAssignment(assignment)) {
      return null;
    }

    return assignment.approvedAt?.toLocal() ??
        assignment.completedAt?.toLocal();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}