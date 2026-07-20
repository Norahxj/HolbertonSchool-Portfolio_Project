import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../models/child_model.dart';
import '../../../models/task_suggestion_model.dart';
import '../../../services/child_api_service.dart';
import '../../../services/task_api_service.dart';

class AddTaskController {
  final TaskApiService taskApiService = TaskApiService();
  final ChildApiService childApiService = ChildApiService();

  List<ChildModel> children = [];
  List<String> selectedChildIds = [];

  bool isLoadingChildren = true;

  List<TaskSuggestionModel> suggestions = [];
  bool isLoadingSuggestions = false;

  final taskNameController = TextEditingController();
  final taskDescriptionController = TextEditingController();

  int taskPoints = 10;
  bool trustChild = true;

  int selectedFrequency = 1;

  String selectedWeeklyDay = 'الأحد';

  int selectedMonthlyDay = 1;

  String? titleError;
  String? descriptionError;
  String? pointsError;
  String? frequencyError;
  String? recurrenceDayError;
  String? childError;

  final weekDays = const [
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  final monthlyDays = const [
    1,
    5,
    10,
    15,
    20,
    25,
    30,
  ];

  Future<void> loadChildren() async {
    try {
      children = await childApiService.getChildren();
      isLoadingChildren = false;
    } on DioException {
      isLoadingChildren = false;
    }
  }

  Future<void> selectChild(String childId) async {
    if (selectedChildIds.contains(childId)) {
      selectedChildIds.remove(childId);
    } else {
      selectedChildIds.add(childId);
    }

    await loadSuggestions();
  }

  Future<void> loadSuggestions() async {
    if (selectedChildIds.isEmpty) {
      suggestions = [];
      return;
    }

    isLoadingSuggestions = true;

    try {
      final response =
          await taskApiService.getTaskSuggestions(
        selectedChildIds,
      );

      suggestions = response.data.suggestions;
      isLoadingSuggestions = false;
    } on DioException {
      suggestions = [];
      isLoadingSuggestions = false;
    }
  }

  void useSuggestion(
    TaskSuggestionModel suggestion,
  ) {
    taskNameController.text = suggestion.title;

    taskDescriptionController.text =
        suggestion.description;

    taskPoints = suggestion.points;

    trustChild = suggestion.isAutoVerified;

    selectedFrequency = frequencyToInt(
      suggestion.taskFrequency,
    );

    if (suggestion.recurrenceDay != null) {
      if (suggestion.taskFrequency == 'WEEKLY') {
        selectedWeeklyDay =
            weekDays[suggestion.recurrenceDay!];
      }

      if (suggestion.taskFrequency == 'MONTHLY') {
        selectedMonthlyDay =
            suggestion.recurrenceDay!;
      }
    }
  }

  String get taskFrequency {
    switch (selectedFrequency) {
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
    if (selectedFrequency == 1) {
      return weekDays.indexOf(
        selectedWeeklyDay,
      );
    }

    if (selectedFrequency == 2) {
      return selectedMonthlyDay;
    }

    return null;
  }

  int frequencyToInt(String frequency) {
    switch (frequency) {
      case 'DAILY':
        return 0;

      case 'WEEKLY':
        return 1;

      case 'MONTHLY':
        return 2;

      default:
        return 0;
    }
  }

  bool validateChildren() {
    childError = null;

    if (selectedChildIds.isEmpty) {
      childError =
          'الرجاء اختيار طفل واحد على الأقل';

      return false;
    }

    return true;
  }

  bool validateDetails() {
    titleError = null;
    descriptionError = null;
    pointsError = null;

    if (taskNameController.text.trim().isEmpty) {
      titleError = 'اسم المهمة مطلوب';
    }

    if (taskDescriptionController.text.trim().isEmpty) {
      descriptionError = 'الوصف مطلوب';
    }

    if (taskPoints < 1 || taskPoints > 100) {
      pointsError =
          'عدد النقاط يجب أن يكون بين 1 و100';
    }
    return titleError == null &&
        descriptionError == null &&
        pointsError == null;
  }

  Future<void> saveTask() async {
    await taskApiService.createTask({
      'child_ids': selectedChildIds,
      'title': taskNameController.text.trim(),
      'description':
          taskDescriptionController.text.trim(),
      'points': taskPoints,
      'task_frequency': taskFrequency,
      'recurrence_day': recurrenceDay,
      'category': 'MORAL',
      'is_auto_verified': trustChild,
    });
  }

  void handleBackendErrors(
    DioException error,
  ) {
    final errors = error.response?.data['errors'];

    titleError = backendError(
      errors?['title'],
    );

    descriptionError = backendError(
      errors?['description'],
    );

    pointsError = backendError(
      errors?['points'],
    );

    childError = backendError(
      errors?['child_ids'],
    );

    frequencyError = backendError(
      errors?['task_frequency'],
    );

    recurrenceDayError = backendError(
      errors?['recurrence_day'],
    );
  }

  String? backendError(dynamic error) {
    if (error == null) {
      return null;
    }

    final message = error is List &&
            error.isNotEmpty
        ? error.first.toString()
        : error.toString();

    return mapBackendError(message);
  }

  String? mapBackendError(String message) {
    switch (message) {
      case 'Shorter than minimum length 1.':
        return 'الرجاء اختيار طفل واحد على الأقل';

      case 'Must be greater than or equal to 1 and less than or equal to 100.':
        return 'عدد النقاط يجب أن يكون بين 1 و100';

      case 'Length must be between 2 and 100.':
        return 'اسم المهمة يجب أن يكون بين حرفين و100 حرف';

      case 'Length must be between 2 and 500.':
        return 'الوصف يجب أن يكون بين حرفين و500 حرف';

      default:
        return message;
    }
  }

  void dispose() {
    taskNameController.dispose();
    taskDescriptionController.dispose();
  }
}