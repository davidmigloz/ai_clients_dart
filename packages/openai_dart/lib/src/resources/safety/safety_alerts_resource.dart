import 'package:http/http.dart' as http;

import '../../models/safety/safety.dart';
import '../base_resource.dart';
import 'safety_resource_helpers.dart';

/// Read-only retrieval of safety alerts belonging to the authenticated project.
class SafetyAlertsResource extends ResourceBase {
  /// Creates the alert resource using shared HTTP infrastructure.
  SafetyAlertsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Retrieves the project alert referenced by a verified notification's data ID.
  ///
  /// The project API key requires `api.safety.alerts.read`. [safetyAlertId] may
  /// contain at most 38 Unicode characters and is encoded as one path segment.
  /// Empty segments and the exact `.` or `..` segments cannot identify this route
  /// in Dart's URI transport. The webhook event ID is a separate notification
  /// identifier.
  ///
  /// A returned `requestPaused` value describes successful block registration;
  /// it does not confirm that execution stopped or earlier effects were undone.
  /// [SafetyAlert.detailedExplanation] is temporarily available for eligible
  /// zero data retention alerts and omitted when unavailable. Its presence is
  /// retained separately from a null value; a null reason does not establish
  /// eligibility. The service determines availability.
  /// Workspace `safety.org_alert.created` notices use the separate
  /// `api.chatgpt.com` administrator API and must not be routed here.
  Future<SafetyAlert> retrieve(
    String safetyAlertId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = safetyResourcePath(
      '/safety/alerts',
      safetyAlertId,
      maximumLength: 38,
      context: 'Safety alert',
    );
    final request = http.Request('GET', requestBuilder.buildUrl(path))
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return parseSafetyResponse(response, SafetyAlert.fromJson, 'SafetyAlert');
  }
}
