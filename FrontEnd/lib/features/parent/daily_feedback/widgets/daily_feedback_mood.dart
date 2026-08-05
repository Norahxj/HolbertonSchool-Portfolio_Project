class DailyFeedbackMood {
  static String emoji(String mood) {
    switch (mood) {
      case 'HAPPY':
        return '😊';
      case 'PROUD':
        return '🌟';
      case 'GREAT':
        return '🎉';
      case 'LOVE':
        return '❤️';
      case 'STRONG':
        return '💪';
      case 'STAR':
        return '⭐';
      default:
        return '😊';
    }
  }

  static String label({required String mood, required bool isArabic}) {
    switch (mood) {
      case 'HAPPY':
        return isArabic ? 'سعيد' : 'Happy';
      case 'PROUD':
        return isArabic ? 'فخور' : 'Proud';
      case 'GREAT':
        return isArabic ? 'رائع' : 'Great';
      case 'LOVE':
        return isArabic ? 'محبوب' : 'Loved';
      case 'STRONG':
        return isArabic ? 'قوي' : 'Strong';
      case 'STAR':
        return isArabic ? 'نجم' : 'Star';
      default:
        return mood;
    }
  }

  static String formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}/$month/$day';
  }
}
