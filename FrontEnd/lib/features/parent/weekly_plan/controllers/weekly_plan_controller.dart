import 'package:flutter/foundation.dart';

import '../models/weekly_plan_models.dart';
import '../repositories/weekly_plan_repository.dart';

class WeeklyPlanController extends ChangeNotifier {
  final WeeklyPlanRepository repository;

  WeeklyPlanController({
    required this.repository,
  });

  String? _selectedChildId;
  WeeklyPlanResult? _result;

  bool _isGenerating = false;
  bool _isApproving = false;
  bool _isRejecting = false;

  WeeklyPlanErrorType? _errorType;

  bool _approvalSucceeded = false;
  bool _rejectionSucceeded = false;

  String? get selectedChildId => _selectedChildId;

  WeeklyPlanResult? get result => _result;

  WeeklyPlan? get plan => _result?.plan;

  bool get isGenerating => _isGenerating;

  bool get isApproving => _isApproving;

  bool get isRejecting => _isRejecting;

  bool get hasPlan => _result != null;

  WeeklyPlanErrorType? get errorType => _errorType;

  bool get approvalSucceeded => _approvalSucceeded;

  bool get rejectionSucceeded => _rejectionSucceeded;

  bool get canGenerate {
    return _selectedChildId != null &&
        !_isGenerating &&
        !_isApproving &&
        !_isRejecting;
  }

  bool get canApprove {
    return _result != null &&
        _result!.proposalStatus == 'PENDING' &&
        !_isGenerating &&
        !_isApproving &&
        !_isRejecting;
  }

  bool get canReject {
    return _result != null &&
        _result!.proposalStatus == 'PENDING' &&
        !_isGenerating &&
        !_isApproving &&
        !_isRejecting;
  }

  void selectChild(String childId) {
    if (_selectedChildId == childId) {
      return;
    }

    _selectedChildId = childId;
    _result = null;
    _errorType = null;
    _approvalSucceeded = false;
    _rejectionSucceeded = false;

    notifyListeners();
  }

  Future<void> generatePlan() async {
    final childId = _selectedChildId;

    if (childId == null) {
      return;
    }

    _isGenerating = true;
    _errorType = null;
    _approvalSucceeded = false;
    _rejectionSucceeded = false;
    _result = null;

    notifyListeners();

    try {
      _result = await repository.generateWeeklyPlan(
        childId,
      );
    } on WeeklyPlanException catch (error) {
      _errorType = error.type;
    } catch (_) {
      _errorType = WeeklyPlanErrorType.generateFailed;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  Future<bool> approvePlan({
    required String languageCode,
  }) async {
    final currentResult = _result;

    if (currentResult == null) {
      return false;
    }

    _isApproving = true;
    _errorType = null;
    _approvalSucceeded = false;
    _rejectionSucceeded = false;

    notifyListeners();

    try {
      final approval = await repository.approveWeeklyPlan(
        proposalId: currentResult.proposalId,
        languageCode: languageCode,
      );

      _result = WeeklyPlanResult(
        proposalId: currentResult.proposalId,
        proposalStatus: approval.proposalStatus,
        childId: currentResult.childId,
        plan: currentResult.plan,
        revisionCount: currentResult.revisionCount,
      );

      _approvalSucceeded = true;

      return true;
    } on WeeklyPlanException catch (error) {
      _errorType = error.type;
      return false;
    } catch (_) {
      _errorType = WeeklyPlanErrorType.approveFailed;
      return false;
    } finally {
      _isApproving = false;
      notifyListeners();
    }
  }

  Future<bool> rejectPlan() async {
    final currentResult = _result;

    if (currentResult == null) {
      return false;
    }

    _isRejecting = true;
    _errorType = null;
    _approvalSucceeded = false;
    _rejectionSucceeded = false;

    notifyListeners();

    try {
      await repository.rejectWeeklyPlan(
        proposalId: currentResult.proposalId,
      );

      _result = WeeklyPlanResult(
        proposalId: currentResult.proposalId,
        proposalStatus: 'REJECTED',
        childId: currentResult.childId,
        plan: currentResult.plan,
        revisionCount: currentResult.revisionCount,
      );

      _rejectionSucceeded = true;

      return true;
    } on WeeklyPlanException catch (error) {
      _errorType = error.type;
      return false;
    } catch (_) {
      _errorType = WeeklyPlanErrorType.rejectFailed;
      return false;
    } finally {
      _isRejecting = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorType = null;
    _approvalSucceeded = false;
    _rejectionSucceeded = false;

    notifyListeners();
  }

  void reset() {
    _selectedChildId = null;
    _result = null;

    _isGenerating = false;
    _isApproving = false;
    _isRejecting = false;

    _errorType = null;

    _approvalSucceeded = false;
    _rejectionSucceeded = false;

    notifyListeners();
  }
}