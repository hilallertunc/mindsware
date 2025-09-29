import 'package:shared_preferences/shared_preferences.dart';

class SurveyManager {
  static const _kFirstCompleted = 'survey_first_completed';
  static const _kLastShownAt = 'survey_last_shown_at';
  static const Duration surveyInterval = Duration(days: 7);

  static Future<bool> shouldShowSurvey() async {
    final prefs = await SharedPreferences.getInstance();
    final firstCompleted = prefs.getBool(_kFirstCompleted) ?? false;
    final lastShownMs = prefs.getInt(_kLastShownAt);
    if (!firstCompleted) {
      return true;
    }

    if (lastShownMs == null) {
      return true; 
    }

    final lastShown = DateTime.fromMillisecondsSinceEpoch(lastShownMs);
    final now = DateTime.now();
    return now.difference(lastShown) >= surveyInterval;
  }

  static Future<void> markSurveyShownNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLastShownAt, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> markSurveyCompletedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFirstCompleted, true);
    await prefs.setInt(_kLastShownAt, DateTime.now().millisecondsSinceEpoch);
  }
}
