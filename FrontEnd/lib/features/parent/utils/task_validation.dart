class TaskValidation {
  static String? validateChildren(List<String> childIds) {
    if (childIds.isEmpty) {
      return 'الرجاء اختيار طفل واحد على الأقل';
    }
    return null;
  }

  static String? validateTitle(String title) {
    if (title.trim().isEmpty) {
      return 'اسم المهمة مطلوب';
    }
    return null;
  }

  static String? validateDescription(String description) {
    if (description.trim().isEmpty) {
      return 'الوصف مطلوب';
    }
    return null;
  }

  static String? validatePoints(int points) {
    if (points < 1 || points > 100) {
      return 'عدد النقاط يجب أن يكون بين 1 و100';
    }
    return null;
  }

  static String? backendError(dynamic error) {
    if (error == null) return null;

    final message = error is List && error.isNotEmpty
        ? error.first.toString()
        : error.toString();

    return mapBackendError(message);
  }

  static String? mapBackendError(String message) {
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
}