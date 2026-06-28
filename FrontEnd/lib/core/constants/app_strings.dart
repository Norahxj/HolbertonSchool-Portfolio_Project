class AppStrings {
  static String welcomeTitle(bool isArabic) {
    return isArabic ? 'مرحبًا بك في أصالة' : 'Welcome to Asalah';
  }

  static String welcomeSubtitle(bool isArabic) {
    return isArabic
        ? 'منصة تساعد الأطفال على بناء عادات مالية وتنمية قيمهم'
        : 'A platform that helps children build financial habits and grow their values.';
  }

  static String parent(bool isArabic) {
    return isArabic ? 'ولي الأمر' : 'Parent';
  }

  static String child(bool isArabic) {
    return isArabic ? 'طفل' : 'Child';
  }

  static String changeLanguage(bool isArabic) {
    return isArabic ? 'English' : 'العربية';
  }
}
