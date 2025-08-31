import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:task_flow/core/utils/logger.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebasePerformance _performance;

  AnalyticsService({
    required FirebaseAnalytics analytics,
    required FirebasePerformance performance,
  }) : _analytics = analytics,
       _performance = performance;

  /// Log a custom event
  Future<void> logEvent(String name, [Map<String, Object>? parameters]) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
    } catch (e) {
      // Silently fail to avoid disrupting user experience
      Logger.error('Failed to log analytics event: $e');
    }
  }

  /// Log user login
  Future<void> logLogin(String method) async {
    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      // Silently fail to avoid disrupting user experience
      Logger.error('Failed to log login event: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
    } catch (e) {
      // Silently fail to avoid disrupting user experience
      Logger.error('Failed to log screen view: $e');
    }
  }

  /// Log task creation
  Future<void> logTaskCreated() async {
    await logEvent('task_created');
  }

  /// Log task completion
  Future<void> logTaskCompleted() async {
    await logEvent('task_completed');
  }

  /// Log workspace creation
  Future<void> logWorkspaceCreated() async {
    await logEvent('workspace_created');
  }

  /// Log project creation
  Future<void> logProjectCreated() async {
    await logEvent('project_created');
  }

  /// Start a performance trace
  Future<Trace> startTrace(String name) async {
    try {
      final trace = _performance.newTrace(name);
      await trace.start();
      return trace;
    } catch (e) {
      // Return a mock trace that does nothing
      return _MockTrace();
    }
  }

  /// Start an HTTP request trace
  Future<HttpMetric> startHttpTrace(String url, HttpMethod method) async {
    try {
      final trace = _performance.newHttpMetric(url, method);
      await trace.start();
      return trace;
    } catch (e) {
      // Return a mock trace that does nothing
      return _MockHttpMetric();
    }
  }
}

/// Mock trace for when performance monitoring fails
class _MockTrace implements Trace {
  void incrementCounter(String name, [int incrementBy = 1]) {}

  @override
  void putAttribute(String name, String value) {}

  @override
  String? getAttribute(String name) => null;

  @override
  Map<String, String> getAttributes() => <String, String>{};

  @override
  int getMetric(String name) => 0;

  @override
  void incrementMetric(String name, int incrementBy) {}

  @override
  void removeAttribute(String name) {}

  @override
  void setMetric(String name, int value) {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}

/// Mock HTTP metric for when performance monitoring fails
class _MockHttpMetric implements HttpMetric {
  @override
  int? get httpResponseCode => null;

  @override
  set httpResponseCode(int? code) {}

  @override
  int? get requestPayloadSize => null;

  @override
  set requestPayloadSize(int? size) {}

  @override
  int? get responsePayloadSize => null;

  @override
  set responsePayloadSize(int? size) {}

  @override
  String? get responseContentType => null;

  @override
  set responseContentType(String? type) {}

  @override
  void putAttribute(String name, String value) {}

  @override
  String? getAttribute(String name) => null;

  @override
  Map<String, String> getAttributes() => <String, String>{};

  @override
  void removeAttribute(String name) {}

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}
}
