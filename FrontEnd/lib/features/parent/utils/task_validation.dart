import 'dart:ui';

class TaskValidation {
  static bool get isArabic =>
      PlatformDispatcher.instance.locale.languageCode == 'ar';

  static String? validateChildren(List<String> childIds) {
    if (childIds.isEmpty) {
      return isArabic
          ? 'الرجاء اختيار طفل واحد على الأقل'
          : 'Please select at least one child';
    }
    return null;
  }

  static String? validateCategory(String? category) {
    if (category == null || category.isEmpty) {
      return isArabic
          ? 'اختر الفئة أولاً'
          : 'Please select a category first';
    }

    return null;
  }

  static String? validateTitle(String title) {
    if (title.trim().isEmpty) {
      return isArabic
          ? 'اسم المهمة مطلوب'
          : 'Task name is required';
    }
    return null;
  }

  static String? validateDescription(String description) {
    if (description.trim().isEmpty) {
      return isArabic
          ? 'الوصف مطلوب'
          : 'Description is required';
    }
    return null;
  }

  static String? validatePoints(int points) {
    if (points < 1 || points > 100) {
      return isArabic
          ? 'عدد النقاط يجب أن يكون بين 1 و100'
          : 'Points must be between 1 and 100';
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
        return isArabic
            ? 'الرجاء اختيار طفل واحد على الأقل'
            : 'Please select at least one child';

      case 'Must be greater than or equal to 1 and less than or equal to 100.':
        return isArabic
            ? 'عدد النقاط يجب أن يكون بين 1 و100'
            : 'Points must be between 1 and 100';

      case 'Length must be between 2 and 100.':
        return isArabic
            ? 'اسم المهمة يجب أن يكون بين حرفين و100 حرف'
            : 'Task name must be between 2 and 100 characters';

      case 'Length must be between 2 and 500.':
        return isArabic
            ? 'الوصف يجب أن يكون بين حرفين و500 حرف'
            : 'Description must be between 2 and 500 characters';

      default:
        return message;
    }
  }
}
