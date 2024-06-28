import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_uxcam/flutter_uxcam.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AnalyticsService {

  static Future<void> removeUser() async {
    await FirebaseAnalytics.instance.setUserId(id: null);
    await FlutterUxcam.setUserIdentity(null);
    await Sentry.configureScope((scope) => scope.setUser(null));
  }

  static Future<void> logEvent(String name, {Map<String, dynamic>? parameters}) async {
    await FirebaseAnalytics.instance.logEvent(name: name, parameters: parameters);

    if (parameters != null) {
      await FlutterUxcam.logEventWithProperties(name, parameters);
    } else {
      await FlutterUxcam.logEvent(name);
    }

    Sentry.metrics().increment(name, tags: parameters?.map((key, value) => MapEntry(key, value.toString())));
  }
}
