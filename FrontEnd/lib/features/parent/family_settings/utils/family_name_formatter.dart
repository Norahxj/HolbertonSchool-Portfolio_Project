class FamilyNameFormatter {
  const FamilyNameFormatter._();

  static String normalizeForSaving({
    required String displayedName,
    required String originalName,
  }) {
    final normalizedOriginal = removeFamilyDecoration(originalName);

    final normalizedDisplayed = removeFamilyDecoration(displayedName);

    if (normalizedDisplayed == normalizedOriginal) {
      return originalName.trim();
    }

    return normalizedDisplayed;
  }

  static String removeFamilyDecoration(String value) {
    var result = value.trim();

    result = result.replaceFirst(
      RegExp(r'^عائلة\s+', caseSensitive: false),
      '',
    );

    result = result.replaceFirst(
      RegExp(r'\s+family$', caseSensitive: false),
      '',
    );

    result = result.replaceFirst(RegExp(r"['’]s$", caseSensitive: false), '');

    return result.trim();
  }
}
