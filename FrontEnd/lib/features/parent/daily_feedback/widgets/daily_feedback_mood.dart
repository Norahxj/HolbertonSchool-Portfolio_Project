import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extension.dart';

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

  static String label({required BuildContext context, required String mood}) {
    final l10n = context.l10n;

    switch (mood) {
      case 'HAPPY':
        return l10n.moodHappy;

      case 'PROUD':
        return l10n.moodProud;

      case 'GREAT':
        return l10n.moodGreat;

      case 'LOVE':
        return l10n.moodLoved;

      case 'STRONG':
        return l10n.moodStrong;

      case 'STAR':
        return l10n.moodStar;

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
