import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../models/child_model.dart';
import '../../../../models/task_suggestion_model.dart';
import '../models/add_task_errors.dart';
import '../models/add_task_save_result.dart';
import '../models/add_task_week_day.dart';
import '../models/task_draft.dart';
import '../repositories/add_task_repository.dart';
import '../utils/add_task_backend_error_mapper.dart';
import '../utils/add_task_validator.dart';

class AddTaskController extends ChangeNotifier {
  final AddTaskRepository _repository;

  AddTaskController({AddTaskRepository? repository})
    : _repository = repository ?? AddTaskRepository();

  final List<ChildModel> _children = [];
  final List<String> _selectedChildIds = [];
  final List<TaskSuggestionModel> _taskSuggestions = [];

  bool _isLoadingChildren = false;
  bool _isLoadingSuggestions = false;
  bool _isSaving = false;
  bool _isDisposed = false;

  bool _childrenRequestRunning = false;
  int _suggestionsRequestVersion = 0;

  int _currentStep = 0;
  int? _selectedTaskType;
  int _taskPoints = 10;
  bool _trustChild = true;
  int _selectedFrequency = 1;

  AddTaskWeekDay _selectedWeeklyDay = AddTaskWeekDay.sunday;

  int _selectedMonthlyDay = 1;

  AddTaskErrorCode? _titleError;
  AddTaskErrorCode? _descriptionError;
  AddTaskErrorCode? _pointsError;
  AddTaskErrorCode? _categoryError;
  AddTaskErrorCode? _childError;

  String? _frequencyBackendError;
  String? _recurrenceDayBackendError;

  bool _hasSuggestionsError = false;
  String? _suggestionsBackendMessage;

  List<ChildModel> get children => List.unmodifiable(_children);

  List<String> get selectedChildIds => List.unmodifiable(_selectedChildIds);

  List<TaskSuggestionModel> get taskSuggestions =>
      List.unmodifiable(_taskSuggestions);

  bool get isLoadingChildren => _isLoadingChildren;

  bool get isLoadingSuggestions => _isLoadingSuggestions;

  bool get isSaving => _isSaving;

  bool get hasSuggestionsError => _hasSuggestionsError;

  String? get suggestionsBackendMessage => _suggestionsBackendMessage;

  int get currentStep => _currentStep;

  int? get selectedTaskType => _selectedTaskType;

  int get taskPoints => _taskPoints;

  bool get trustChild => _trustChild;

  int get selectedFrequency => _selectedFrequency;

  AddTaskWeekDay get selectedWeeklyDay => _selectedWeeklyDay;

  int get selectedMonthlyDay => _selectedMonthlyDay;

  AddTaskErrorCode? get titleError => _titleError;

  AddTaskErrorCode? get descriptionError => _descriptionError;

  AddTaskErrorCode? get pointsError => _pointsError;

  AddTaskErrorCode? get categoryError => _categoryError;

  AddTaskErrorCode? get childError => _childError;

  String? get frequencyBackendError => _frequencyBackendError;

  String? get recurrenceDayBackendError => _recurrenceDayBackendError;

  List<AddTaskWeekDay> get weekDays => AddTaskWeekDay.values;

  String get taskFrequency {
    switch (_selectedFrequency) {
      case 0:
        return 'DAILY';
      case 1:
        return 'WEEKLY';
      case 2:
        return 'MONTHLY';
      default:
        return 'ONCE';
    }
  }

  int? get recurrenceDay {
    if (_selectedFrequency == 1) {
      return _selectedWeeklyDay.backendValue;
    }

    if (_selectedFrequency == 2) {
      return _selectedMonthlyDay;
    }

    return null;
  }

  String get category {
    switch (_selectedTaskType) {
      case 0:
        return 'SOCIAL';
      case 1:
        return 'MORAL';
      case 2:
        return 'RELIGIOUS';
      case 3:
        return 'FINANCIAL';
      default:
        return 'MORAL';
    }
  }

  Future<void> loadChildren() async {
    if (_childrenRequestRunning) {
      return;
    }

    _childrenRequestRunning = true;
    _isLoadingChildren = true;
    _notify();

    try {
      final loadedChildren = await _repository.getChildren();

      _children
        ..clear()
        ..addAll(loadedChildren);

      _selectedChildIds.removeWhere(
        (id) => !_children.any((child) => child.id == id),
      );
    } on DioException catch (error) {
      debugPrint(
        'Loading children failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Loading children failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isLoadingChildren = false;
      _childrenRequestRunning = false;
      _notify();
    }
  }

  Future<void> toggleChild({
    required String childId,
    required String languageCode,
  }) async {
    if (_selectedChildIds.contains(childId)) {
      _selectedChildIds.remove(childId);
    } else {
      _selectedChildIds.add(childId);
    }

    _childError = null;

    if (_selectedChildIds.isEmpty) {
      _taskSuggestions.clear();
      _clearSuggestionsError();
      _notify();
      return;
    }

    _notify();

    if (_selectedTaskType != null) {
      await loadTaskSuggestions(languageCode: languageCode);
    }
  }

  Future<void> selectTaskType({
    required int taskType,
    required String languageCode,
  }) async {
    if (taskType < 0 || taskType > 3) {
      return;
    }

    _selectedTaskType = taskType;
    _categoryError = null;
    _notify();

    await loadTaskSuggestions(languageCode: languageCode);
  }

  Future<void> loadTaskSuggestions({required String languageCode}) async {
    if (_selectedChildIds.isEmpty || _selectedTaskType == null) {
      return;
    }

    final requestVersion = ++_suggestionsRequestVersion;

    _isLoadingSuggestions = true;
    _clearSuggestionsError();
    _taskSuggestions.clear();
    _notify();

    try {
      final suggestions = await _repository.getTaskSuggestions(
        childIds: List.unmodifiable(_selectedChildIds),
        category: category,
        languageCode: languageCode,
      );

      if (requestVersion != _suggestionsRequestVersion) {
        return;
      }

      _taskSuggestions
        ..clear()
        ..addAll(suggestions);
    } on DioException catch (error) {
      if (requestVersion != _suggestionsRequestVersion) {
        return;
      }

      _hasSuggestionsError = true;
      _suggestionsBackendMessage = AddTaskBackendErrorMapper.readBackendMessage(
        error,
      );

      debugPrint(
        'Loading task suggestions failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error, stackTrace) {
      if (requestVersion != _suggestionsRequestVersion) {
        return;
      }

      _hasSuggestionsError = true;

      debugPrint(
        'Loading task suggestions failed: '
        '$error\n$stackTrace',
      );
    } finally {
      if (requestVersion == _suggestionsRequestVersion) {
        _isLoadingSuggestions = false;
        _notify();
      }
    }
  }

  void applyTaskSuggestion(TaskSuggestionModel suggestion) {
    _taskPoints = suggestion.points.clamp(1, 100);

    _trustChild = suggestion.isAutoVerified;

    switch (suggestion.taskFrequency.toUpperCase()) {
      case 'DAILY':
        _selectedFrequency = 0;
        break;

      case 'WEEKLY':
        _selectedFrequency = 1;
        _selectedWeeklyDay = AddTaskWeekDayBackendValue.fromBackend(
          suggestion.recurrenceDay,
        );
        break;

      case 'MONTHLY':
        _selectedFrequency = 2;
        _selectedMonthlyDay = (suggestion.recurrenceDay ?? 1).clamp(1, 31);
        break;
    }

    _currentStep = 1;
    clearErrors();
    _notify();
  }

  void increasePoints() {
    if (_taskPoints >= 100) {
      return;
    }

    _taskPoints = (_taskPoints + 5).clamp(1, 100);

    _pointsError = null;
    _notify();
  }

  void decreasePoints() {
    if (_taskPoints <= 1) {
      return;
    }

    _taskPoints = (_taskPoints - 5).clamp(1, 100);

    _pointsError = null;
    _notify();
  }

  void toggleTrustChild() {
    _trustChild = !_trustChild;
    _notify();
  }

  void selectFrequency(int frequency) {
    if (frequency < 0 || frequency > 2) {
      return;
    }

    _selectedFrequency = frequency;
    _frequencyBackendError = null;
    _recurrenceDayBackendError = null;
    _notify();
  }

  void selectWeeklyDay(AddTaskWeekDay day) {
    _selectedWeeklyDay = day;
    _recurrenceDayBackendError = null;
    _notify();
  }

  void selectMonthlyDay(int day) {
    _selectedMonthlyDay = day.clamp(1, 31);
    _recurrenceDayBackendError = null;
    _notify();
  }

  bool goToNextStep({required String title, required String description}) {
    clearErrors();

    if (_currentStep == 0) {
      final result = AddTaskValidator.validateStepOne(
        childIds: _selectedChildIds,
        taskType: _selectedTaskType,
      );

      _applyValidation(result);

      if (!result.isValid) {
        _notify();
        return false;
      }

      _currentStep = 1;
      _notify();
      return true;
    }

    final details = AddTaskValidator.validateDetails(
      title: title.trim(),
      description: description.trim(),
      points: _taskPoints,
    );

    _applyValidation(details);

    if (!details.isValid) {
      _notify();
      return false;
    }

    return false;
  }

  bool goToPreviousStep() {
    if (_currentStep == 0) {
      return false;
    }

    _currentStep = 0;
    _notify();

    return true;
  }

  Future<AddTaskSaveResult> saveTask({
    required String title,
    required String description,
  }) async {
    if (_isSaving) {
      return const AddTaskSaveResult.validationFailure();
    }

    clearErrors();

    final cleanTitle = title.trim();
    final cleanDescription = description.trim();

    final validation = AddTaskValidator.validateAll(
      childIds: _selectedChildIds,
      taskType: _selectedTaskType,
      title: cleanTitle,
      description: cleanDescription,
      points: _taskPoints,
    );

    _applyValidation(validation);

    if (!validation.isValid) {
      _currentStep = validation.hasStepOneError ? 0 : 1;

      _notify();

      return const AddTaskSaveResult.validationFailure();
    }

    _isSaving = true;
    _notify();

    try {
      final draft = TaskDraft(
        childIds: List.unmodifiable(_selectedChildIds),
        title: cleanTitle,
        description: cleanDescription,
        points: _taskPoints,
        frequency: taskFrequency,
        recurrenceDay: recurrenceDay,
        category: category,
        isAutoVerified: _trustChild,
      );

      await _repository.createTask(draft);

      return const AddTaskSaveResult.success();
    } on DioException catch (error) {
      final backendErrors = AddTaskBackendErrorMapper.readFieldErrors(error);

      _applyBackendErrors(backendErrors);

      _currentStep = backendErrors.hasStepOneError ? 0 : 1;

      return AddTaskSaveResult.failure(
        errorCode: AddTaskSaveErrorCode.generic,
        backendMessage: AddTaskBackendErrorMapper.readBackendMessage(error),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Creating task failed: '
        '$error\n$stackTrace',
      );

      return const AddTaskSaveResult.failure(
        errorCode: AddTaskSaveErrorCode.generic,
      );
    } finally {
      _isSaving = false;
      _notify();
    }
  }

  void reset() {
    _suggestionsRequestVersion++;

    _selectedChildIds.clear();
    _taskSuggestions.clear();

    _currentStep = 0;
    _selectedTaskType = null;
    _taskPoints = 10;
    _trustChild = true;
    _selectedFrequency = 1;
    _selectedWeeklyDay = AddTaskWeekDay.sunday;
    _selectedMonthlyDay = 1;

    _isLoadingSuggestions = false;

    clearErrors();
    _clearSuggestionsError();
    _notify();
  }

  void clearErrors() {
    _titleError = null;
    _descriptionError = null;
    _pointsError = null;
    _categoryError = null;
    _frequencyBackendError = null;
    _recurrenceDayBackendError = null;
    _childError = null;
  }

  void _applyValidation(AddTaskValidationResult result) {
    _childError = result.childError;
    _categoryError = result.categoryError;
    _titleError = result.titleError;
    _descriptionError = result.descriptionError;
    _pointsError = result.pointsError;
  }

  void _applyBackendErrors(AddTaskBackendErrors errors) {
    _childError = errors.childError;
    _categoryError = errors.categoryError;
    _titleError = errors.titleError;
    _descriptionError = errors.descriptionError;
    _pointsError = errors.pointsError;

    _frequencyBackendError = errors.frequencyError;

    _recurrenceDayBackendError = errors.recurrenceDayError;
  }

  void _clearSuggestionsError() {
    _hasSuggestionsError = false;
    _suggestionsBackendMessage = null;
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _suggestionsRequestVersion++;
    super.dispose();
  }
}
