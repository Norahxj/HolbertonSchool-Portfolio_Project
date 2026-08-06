import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../models/child_model.dart';
import '../../../../models/task_suggestion_model.dart';
import '../../../../services/task_api_service.dart';
import '../../services/child_api_service.dart';

class AddTaskController extends ChangeNotifier {
  final TaskApiService _taskApiService;
  final ChildApiService _childApiService;

  AddTaskController({
    required this.isArabic,
    TaskApiService? taskApiService,
    ChildApiService? childApiService,
  }) : _taskApiService = taskApiService ?? TaskApiService(),
       _childApiService = childApiService ?? ChildApiService();

  final bool isArabic;

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

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  String? _suggestionsError;

  String? get suggestionsError => _suggestionsError;

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

  String _selectedWeeklyDay = 'الأحد';

  String get selectedWeeklyDay => _selectedWeeklyDay;

  int _selectedMonthlyDay = 1;

  int get selectedMonthlyDay => _selectedMonthlyDay;

  String? _titleError;

  String? get titleError => _titleError;

  String? _descriptionError;

  String? get descriptionError => _descriptionError;

  String? _pointsError;

  String? get pointsError => _pointsError;

  String? _categoryError;

  String? get categoryError => _categoryError;

  String? _frequencyError;

  String? get frequencyError => _frequencyError;

  String? _recurrenceDayError;

  String? get recurrenceDayError => _recurrenceDayError;

  String? _childError;

  String? get childError => _childError;

  List<String> get weekDays => const [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  String text(String arabic, String english) {
    return isArabic ? arabic : english;
  }

  String weekDayLabel(String day) {
    if (isArabic) {
      return day;
    }

    switch (day) {
      case 'الأحد':
        return 'Sunday';
      case 'الإثنين':
        return 'Monday';
      case 'الثلاثاء':
        return 'Tuesday';
      case 'الأربعاء':
        return 'Wednesday';
      case 'الخميس':
        return 'Thursday';
      case 'الجمعة':
        return 'Friday';
      case 'السبت':
        return 'Saturday';
      default:
        return day;
    }
  }

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
        case 'الإثنين':
          return 0;
        case 'الثلاثاء':
          return 1;
        case 'الأربعاء':
          return 2;
        case 'الخميس':
          return 3;
        case 'الجمعة':
          return 4;
        case 'السبت':
          return 5;
        case 'الأحد':
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

  String get stepTitle {
    if (_currentStep == 0) {
      return text('إضافة مهمة', 'Add Task');
    }

    return text('تفاصيل المهمة', 'Task Details');
  }

  String get stepSubtitle {
    if (_currentStep == 0) {
      return text(
        'لمن هذه المهمة؟ (يمكن اختيار أكثر من طفل)',
        'Who is this task for? (You can select more than one child)',
      );
    }

    return text(
      'أضيفي تفاصيل المهمة وحددي تكرارها',
      'Add the task details and choose how often it repeats',
    );
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
    } else if (_selectedChildIds.isEmpty) {
      _taskSuggestions.clear();
      _suggestionsError = null;
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
    _suggestionsError = null;
    _taskSuggestions.clear();
    notifyListeners();

    try {
      final suggestions = await _taskApiService.getTaskSuggestions({
        'child_ids': _selectedChildIds,
        'category': category,
        'lang': isArabic ? 'ar' : 'en',
      });

      _taskSuggestions
        ..clear()
        ..addAll(suggestions);
    } on DioException catch (error) {
      _suggestionsError =
          error.response?.data?['error']?.toString() ??
          text('تعذر تحميل المهام المقترحة', 'Unable to load suggested tasks');

      debugPrint(
        'Loading task suggestions failed: '
        'status=${error.response?.statusCode}, '
        'data=${error.response?.data}',
      );
    } catch (error) {
      _suggestionsError = text(
        'تعذر تحميل المهام المقترحة',
        'Unable to load suggested tasks',
      );

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

        switch (suggestion.recurrenceDay) {
          case 0:
            _selectedWeeklyDay = 'الإثنين';
            break;
          case 1:
            _selectedWeeklyDay = 'الثلاثاء';
            break;
          case 2:
            _selectedWeeklyDay = 'الأربعاء';
            break;
          case 3:
            _selectedWeeklyDay = 'الخميس';
            break;
          case 4:
            _selectedWeeklyDay = 'الجمعة';
            break;
          case 5:
            _selectedWeeklyDay = 'السبت';
            break;
          case 6:
            _selectedWeeklyDay = 'الأحد';
            break;
        }
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
    _frequencyError = null;
    _recurrenceDayError = null;
    notifyListeners();
  }

  void selectWeeklyDay(String day) {
    _selectedWeeklyDay = day;
    _recurrenceDayError = null;
    notifyListeners();
  }

  void selectMonthlyDay(int day) {
    _selectedMonthlyDay = day.clamp(1, 31).toInt();
    _recurrenceDayError = null;
    notifyListeners();
  }

  bool goToNextStep() {
    clearErrors();

    if (_currentStep == 0) {
      var hasError = false;

      if (_selectedChildIds.isEmpty) {
        _childError = text(
          'الرجاء اختيار طفل واحد على الأقل',
          'Please select at least one child',
        );
        hasError = true;
      }

      if (_selectedTaskType == null) {
        _categoryError = text(
          'الرجاء اختيار نوع المهمة',
          'Please select a task type',
        );
        hasError = true;
      }

      if (hasError) {
        notifyListeners();
        return false;
      }
    }

    if (_currentStep == 1) {
      final hasError = !_validateDetails();

      if (hasError) {
        notifyListeners();
        return false;
      }
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
    _frequencyError = null;
    _recurrenceDayError = null;
    _childError = null;
  }

  bool _validateDetails() {
    var hasError = false;

    final title = taskNameController.text.trim();
    final description = taskDescriptionController.text.trim();

    if (title.isEmpty) {
      _titleError = text('اسم المهمة مطلوب', 'Task name is required');
      hasError = true;
    }

    if (description.isEmpty) {
      _descriptionError = text('الوصف مطلوب', 'Description is required');
      hasError = true;
    }

    if (_taskPoints < 1 || _taskPoints > 100) {
      _pointsError = text(
        'عدد النقاط يجب أن يكون بين 1 و100',
        'Points must be between 1 and 100',
      );
      hasError = true;
    }

    return !hasError;
  }

  Future<AddTaskSaveResult> saveTask() async {
    if (_isSaving) {
      return const AddTaskSaveResult();
    }

    clearErrors();

    var hasError = false;

    if (_selectedChildIds.isEmpty) {
      _childError = text(
        'الرجاء اختيار طفل واحد على الأقل',
        'Please select at least one child',
      );
      hasError = true;
    }

    if (_selectedTaskType == null) {
      _categoryError = text(
        'الرجاء اختيار نوع المهمة',
        'Please select a task type',
      );
      hasError = true;
    }

    if (!_validateDetails()) {
      hasError = true;
    }

    if (hasError) {
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

      if (_childError != null || _categoryError != null) {
        _currentStep = 0;
      } else {
        _currentStep = 1;
      }

      return AddTaskSaveResult(errorMessage: _readGeneralError(error));
    } catch (error) {
      debugPrint('Creating task failed: $error');

      return AddTaskSaveResult(
        errorMessage: text(
          'حدث خطأ أثناء حفظ المهمة',
          'An error occurred while saving the task',
        ),
      );
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

    _titleError = mapBackendError(_getError(errors['title']));

    _descriptionError = mapBackendError(_getError(errors['description']));

    _pointsError = mapBackendError(_getError(errors['points']));

    _childError = mapBackendError(_getError(errors['child_ids']));

    _categoryError = mapBackendError(_getError(errors['category']));

    _frequencyError = mapBackendError(_getError(errors['task_frequency']));

    _recurrenceDayError = mapBackendError(_getError(errors['recurrence_day']));
  }

  String? _readGeneralError(DioException error) {
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

  String? mapBackendError(String? message) {
    switch (message) {
      case 'Shorter than minimum length 1.':
        return text(
          'الرجاء اختيار طفل واحد على الأقل',
          'Please select at least one child',
        );

      case 'Must be greater than or equal to 1 and less than or equal to 100.':
        return text(
          'عدد النقاط يجب أن يكون بين 1 و100',
          'Points must be between 1 and 100',
        );

      case 'Length must be between 2 and 100.':
        return text(
          'اسم المهمة يجب أن يكون بين حرفين و100 حرف',
          'Task name must be between 2 and 100 characters',
        );

      case 'Length must be between 2 and 500.':
        return text(
          'الوصف يجب أن يكون بين حرفين و500 حرف',
          'Description must be between 2 and 500 characters',
        );

      default:
        return message;
    }
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
  final String? errorMessage;

  const AddTaskSaveResult({this.isSuccess = false, this.errorMessage});
}
