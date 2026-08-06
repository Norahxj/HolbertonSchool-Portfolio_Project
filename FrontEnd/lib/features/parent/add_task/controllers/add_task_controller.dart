import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../../../models/task_suggestion_model.dart';
import '../../../../services/task_api_service.dart';
import '../../services/child_api_service.dart';

enum AddTaskWeekDay {
  sunday,
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
}

enum AddTaskErrorCode {
  selectAtLeastOneChild,
  selectTaskType,
  taskNameRequired,
  descriptionRequired,
  pointsRange,
  taskNameLength,
  descriptionLength,
}

enum AddTaskSaveErrorCode { generic }

class AddTaskController extends ChangeNotifier {
  final TaskApiService _taskApiService;
  final ChildApiService _childApiService;

  AddTaskController({
    required String languageCode,
    TaskApiService? taskApiService,
    ChildApiService? childApiService,
  }) : _languageCode = languageCode,
       _taskApiService = taskApiService ?? TaskApiService(),
       _childApiService = childApiService ?? ChildApiService();

  String _languageCode;

  String get languageCode => _languageCode;

  final TextEditingController taskNameController = TextEditingController();

  final TextEditingController taskDescriptionController =
      TextEditingController();

  final List<ChildModel> _children = [];

  List<ChildModel> get children => List.unmodifiable(_children);

  final List<String> _selectedChildIds = [];

  List<String> get selectedChildIds => List.unmodifiable(_selectedChildIds);

  final List<TaskSuggestionModel> _taskSuggestions = [];

  List<TaskSuggestionModel> get taskSuggestions =>
      List.unmodifiable(_taskSuggestions);

  bool _isLoadingChildren = true;

  bool get isLoadingChildren => _isLoadingChildren;

  bool _isLoadingSuggestions = false;

  bool get isLoadingSuggestions => _isLoadingSuggestions;

  bool _hasSuggestionsError = false;

  bool get hasSuggestionsError => _hasSuggestionsError;

  String? _suggestionsBackendMessage;

  String? get suggestionsBackendMessage => _suggestionsBackendMessage;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  int _currentStep = 0;

  int get currentStep => _currentStep;

  int? _selectedTaskType;

  int? get selectedTaskType => _selectedTaskType;

  int _taskPoints = 10;

  int get taskPoints => _taskPoints;

  bool _trustChild = true;

  bool get trustChild => _trustChild;

  int _selectedFrequency = 1;

  int get selectedFrequency => _selectedFrequency;

  AddTaskWeekDay _selectedWeeklyDay = AddTaskWeekDay.sunday;

  AddTaskWeekDay get selectedWeeklyDay => _selectedWeeklyDay;

  int _selectedMonthlyDay = 1;

  int get selectedMonthlyDay => _selectedMonthlyDay;

  AddTaskErrorCode? _titleError;

  AddTaskErrorCode? get titleError => _titleError;

  AddTaskErrorCode? _descriptionError;

  AddTaskErrorCode? get descriptionError => _descriptionError;

  AddTaskErrorCode? _pointsError;

  AddTaskErrorCode? get pointsError => _pointsError;

  AddTaskErrorCode? _categoryError;

  AddTaskErrorCode? get categoryError => _categoryError;

  String? _frequencyBackendError;

  String? get frequencyBackendError => _frequencyBackendError;

  String? _recurrenceDayBackendError;

  String? get recurrenceDayBackendError => _recurrenceDayBackendError;

  AddTaskErrorCode? _childError;

  AddTaskErrorCode? get childError => _childError;

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
      switch (_selectedWeeklyDay) {
        case AddTaskWeekDay.monday:
          return 0;
        case AddTaskWeekDay.tuesday:
          return 1;
        case AddTaskWeekDay.wednesday:
          return 2;
        case AddTaskWeekDay.thursday:
          return 3;
        case AddTaskWeekDay.friday:
          return 4;
        case AddTaskWeekDay.saturday:
          return 5;
        case AddTaskWeekDay.sunday:
          return 6;
      }
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

  Future<void> updateLanguage(String languageCode) async {
    if (_languageCode == languageCode) {
      return;
    }

    _languageCode = languageCode;

    if (_selectedChildIds.isNotEmpty && _selectedTaskType != null) {
      await loadTaskSuggestions();
    }
  }

  Future<void> loadChildren() async {
    _isLoadingChildren = true;
    notifyListeners();

    try {
      final loadedChildren = await _childApiService.getChildren();

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
    } catch (error) {
      debugPrint('Loading children failed: $error');
    } finally {
      _isLoadingChildren = false;
      notifyListeners();
    }
  }

  Future<void> toggleChild(String childId) async {
    if (_selectedChildIds.contains(childId)) {
      _selectedChildIds.remove(childId);
    } else {
      _selectedChildIds.add(childId);
    }

    _childError = null;
    notifyListeners();

    if (_selectedTaskType != null && _selectedChildIds.isNotEmpty) {
      await loadTaskSuggestions();
      return;
    }

    if (_selectedChildIds.isEmpty) {
      _taskSuggestions.clear();
      _clearSuggestionsError();
      notifyListeners();
    }
  }

  Future<void> selectTaskType(int taskType) async {
    _selectedTaskType = taskType;
    _categoryError = null;
    notifyListeners();

    await loadTaskSuggestions();
  }

  Future<void> loadTaskSuggestions() async {
    if (_selectedChildIds.isEmpty || _selectedTaskType == null) {
      return;
    }

    _isLoadingSuggestions = true;
    _clearSuggestionsError();
    _taskSuggestions.clear();
    notifyListeners();

    try {
      final suggestions = await _taskApiService.getTaskSuggestions({
        'child_ids': _selectedChildIds,
        'category': category,
        'lang': _languageCode,
      });

      _taskSuggestions
        ..clear()
        ..addAll(suggestions);
    } on DioException catch (error) {
      _hasSuggestionsError = true;
      _suggestionsBackendMessage = _readBackendMessage(error);

      debugPrint(
        'Loading task suggestions failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      _hasSuggestionsError = true;
      _suggestionsBackendMessage = null;

      debugPrint('Loading task suggestions failed: $error');
    } finally {
      _isLoadingSuggestions = false;
      notifyListeners();
    }
  }

  void applyTaskSuggestion(TaskSuggestionModel suggestion) {
    taskNameController.text = suggestion.title;
    taskDescriptionController.text = suggestion.description;

    _taskPoints = suggestion.points;
    _trustChild = suggestion.isAutoVerified;

    switch (suggestion.taskFrequency) {
      case 'DAILY':
        _selectedFrequency = 0;
        break;

      case 'WEEKLY':
        _selectedFrequency = 1;
        _selectedWeeklyDay = _weekDayFromBackend(suggestion.recurrenceDay);
        break;

      case 'MONTHLY':
        _selectedFrequency = 2;

        final day = suggestion.recurrenceDay;

        if (day != null && day >= 1 && day <= 31) {
          _selectedMonthlyDay = day;
        }
        break;
    }

    _currentStep = 1;
    clearErrors();
    notifyListeners();
  }

  void increasePoints() {
    if (_taskPoints >= 100) {
      return;
    }

    _taskPoints = (_taskPoints + 5).clamp(1, 100).toInt();

    _pointsError = null;
    notifyListeners();
  }

  void decreasePoints() {
    if (_taskPoints <= 1) {
      return;
    }

    _taskPoints = (_taskPoints - 5).clamp(1, 100).toInt();

    _pointsError = null;
    notifyListeners();
  }

  void toggleTrustChild() {
    _trustChild = !_trustChild;
    notifyListeners();
  }

  void selectFrequency(int frequency) {
    _selectedFrequency = frequency;
    _frequencyBackendError = null;
    _recurrenceDayBackendError = null;
    notifyListeners();
  }

  void selectWeeklyDay(AddTaskWeekDay day) {
    _selectedWeeklyDay = day;
    _recurrenceDayBackendError = null;
    notifyListeners();
  }

  void selectMonthlyDay(int day) {
    _selectedMonthlyDay = day.clamp(1, 31).toInt();

    _recurrenceDayBackendError = null;
    notifyListeners();
  }

  bool goToNextStep() {
    clearErrors();

    if (_currentStep == 0) {
      var hasError = false;

      if (_selectedChildIds.isEmpty) {
        _childError = AddTaskErrorCode.selectAtLeastOneChild;

        hasError = true;
      }

      if (_selectedTaskType == null) {
        _categoryError = AddTaskErrorCode.selectTaskType;

        hasError = true;
      }

      if (hasError) {
        notifyListeners();
        return false;
      }
    }

    if (_currentStep == 1 && !_validateDetails()) {
      notifyListeners();
      return false;
    }

    _currentStep++;
    notifyListeners();

    return true;
  }

  bool goToPreviousStep() {
    if (_currentStep == 0) {
      return false;
    }

    _currentStep--;
    notifyListeners();

    return true;
  }

  void reset() {
    _currentStep = 0;
    clearErrors();
    notifyListeners();
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

  bool _validateDetails() {
    var isValid = true;

    final title = taskNameController.text.trim();

    final description = taskDescriptionController.text.trim();

    if (title.isEmpty) {
      _titleError = AddTaskErrorCode.taskNameRequired;

      isValid = false;
    }

    if (description.isEmpty) {
      _descriptionError = AddTaskErrorCode.descriptionRequired;

      isValid = false;
    }

    if (_taskPoints < 1 || _taskPoints > 100) {
      _pointsError = AddTaskErrorCode.pointsRange;

      isValid = false;
    }

    return isValid;
  }

  Future<AddTaskSaveResult> saveTask() async {
    if (_isSaving) {
      return const AddTaskSaveResult();
    }

    clearErrors();

    var isValid = true;

    if (_selectedChildIds.isEmpty) {
      _childError = AddTaskErrorCode.selectAtLeastOneChild;

      isValid = false;
    }

    if (_selectedTaskType == null) {
      _categoryError = AddTaskErrorCode.selectTaskType;

      isValid = false;
    }

    if (!_validateDetails()) {
      isValid = false;
    }

    if (!isValid) {
      _currentStep = _childError != null || _categoryError != null ? 0 : 1;

      notifyListeners();

      return const AddTaskSaveResult();
    }

    _isSaving = true;
    notifyListeners();

    try {
      await _taskApiService.createTask({
        'child_ids': _selectedChildIds,
        'title': taskNameController.text.trim(),
        'description': taskDescriptionController.text.trim(),
        'points': _taskPoints,
        'task_frequency': taskFrequency,
        if (recurrenceDay != null) 'recurrence_day': recurrenceDay,
        'category': category,
        'is_auto_verified': _trustChild,
      });

      return const AddTaskSaveResult(isSuccess: true);
    } on DioException catch (error) {
      _handleBackendErrors(error);

      _currentStep = _childError != null || _categoryError != null ? 0 : 1;

      return AddTaskSaveResult(backendMessage: _readBackendMessage(error));
    } catch (error) {
      debugPrint('Creating task failed: $error');

      return const AddTaskSaveResult(errorCode: AddTaskSaveErrorCode.generic);
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _handleBackendErrors(DioException error) {
    final data = error.response?.data;

    if (data is! Map) {
      return;
    }

    final errors = data['errors'];

    if (errors is! Map) {
      return;
    }

    _titleError = _mapBackendFieldError(_getError(errors['title']));

    _descriptionError = _mapBackendFieldError(_getError(errors['description']));

    _pointsError = _mapBackendFieldError(_getError(errors['points']));

    _childError = _mapBackendFieldError(_getError(errors['child_ids']));

    _categoryError = _mapBackendFieldError(_getError(errors['category']));

    _frequencyBackendError = _getError(errors['task_frequency']);

    _recurrenceDayBackendError = _getError(errors['recurrence_day']);
  }

  AddTaskErrorCode? _mapBackendFieldError(String? message) {
    switch (message) {
      case 'Shorter than minimum length 1.':
        return AddTaskErrorCode.selectAtLeastOneChild;

      case 'Must be greater than or equal to 1 and less than or equal to 100.':
        return AddTaskErrorCode.pointsRange;

      case 'Length must be between 2 and 100.':
        return AddTaskErrorCode.taskNameLength;

      case 'Length must be between 2 and 500.':
        return AddTaskErrorCode.descriptionLength;

      default:
        return null;
    }
  }

  String? _readBackendMessage(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      return data['error']?.toString() ?? data['message']?.toString();
    }

    return null;
  }

  String? _getError(dynamic error) {
    if (error == null) {
      return null;
    }

    if (error is List && error.isNotEmpty) {
      return error.first.toString();
    }

    return error.toString();
  }

  AddTaskWeekDay _weekDayFromBackend(int? recurrenceDay) {
    switch (recurrenceDay) {
      case 0:
        return AddTaskWeekDay.monday;
      case 1:
        return AddTaskWeekDay.tuesday;
      case 2:
        return AddTaskWeekDay.wednesday;
      case 3:
        return AddTaskWeekDay.thursday;
      case 4:
        return AddTaskWeekDay.friday;
      case 5:
        return AddTaskWeekDay.saturday;
      case 6:
      default:
        return AddTaskWeekDay.sunday;
    }
  }

  void _clearSuggestionsError() {
    _hasSuggestionsError = false;
    _suggestionsBackendMessage = null;
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
    super.dispose();
  }
}

class AddTaskSaveResult {
  final bool isSuccess;
  final AddTaskSaveErrorCode? errorCode;
  final String? backendMessage;

  const AddTaskSaveResult({
    this.isSuccess = false,
    this.errorCode,
    this.backendMessage,
  });
}
