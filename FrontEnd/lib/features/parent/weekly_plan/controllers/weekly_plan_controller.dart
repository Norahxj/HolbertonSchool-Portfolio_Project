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

  String? _errorMessage;
  String? _successMessage;

  String? get selectedChildId => _selectedChildId;

  WeeklyPlanResult? get result => _result;

  WeeklyPlan? get plan => _result?.plan;

  bool get isGenerating => _isGenerating;

  bool get isApproving => _isApproving;

  bool get hasPlan => _result != null;

  String? get errorMessage => _errorMessage;

  String? get successMessage => _successMessage;

  bool get canGenerate {
    return (
      _selectedChildId != null
      && !_isGenerating
      && !_isApproving
    );
  }

  bool get canApprove {
    return (
      _result != null
      && _result!.proposalStatus == 'PENDING'
      && !_isGenerating
      && !_isApproving
    );
  }

  void selectChild(
    String childId,
  ) {
    if (_selectedChildId == childId) {
      return;
    }

    _selectedChildId = childId;

    _result = null;
    _errorMessage = null;
    _successMessage = null;

    notifyListeners();
  }

  Future<void> generatePlan() async {
    final childId = _selectedChildId;

    if (childId == null) {
      return;
    }

    _isGenerating = true;
    _errorMessage = null;
    _successMessage = null;
    _result = null;

    notifyListeners();

    try {
      _result = await repository.generateWeeklyPlan(
        childId,
      );
    } on WeeklyPlanException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = (
        'Unable to generate weekly plan.'
      );
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
    _errorMessage = null;
    _successMessage = null;

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

      _successMessage = (
        'Weekly plan approved successfully.'
      );

      return true;
    } on WeeklyPlanException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = (
        'Unable to approve weekly plan.'
      );
      return false;
    } finally {
      _isApproving = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void reset() {
    _selectedChildId = null;
    _result = null;
    _isGenerating = false;
    _isApproving = false;
    _errorMessage = null;
    _successMessage = null;

    notifyListeners();
  }
}