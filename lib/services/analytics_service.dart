import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(analytics: _analytics);

  // Log specific Super Admin events
  Future<void> logCompanyCreated(String name, String plan) async {
    await _analytics.logEvent(
      name: 'company_created',
      parameters: {
        'company_name': name,
        'plan': plan,
      },
    );
  }

  Future<void> logRevenueViewed() async {
    await _analytics.logEvent(name: 'revenue_dashboard_viewed');
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
