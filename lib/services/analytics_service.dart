import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logEvent(
      String eventName, Map<String, Object> parameters) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }
}
