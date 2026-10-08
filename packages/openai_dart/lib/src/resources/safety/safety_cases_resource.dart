import 'package:http/http.dart' as http;

import '../../models/safety/safety.dart';
import '../base_resource.dart';
import 'safety_resource_helpers.dart';

/// Read-only retrieval of safety cases belonging to an organization.
class SafetyCasesResource extends ResourceBase {
  /// Creates the case resource using shared HTTP infrastructure.
  SafetyCasesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Retrieves the case referenced by a verified notification's data ID.
  ///
  /// Use a restricted API key from the same organization with `api.safety.read`.
  /// [safetyCaseId] may contain at most 128 Unicode characters and is encoded as
  /// one path segment. Empty segments and the exact `.` or `..` segments cannot
  /// identify this route in Dart's URI transport. The webhook event ID and returned
  /// `entityIdentifier` identify the notification and application entity,
  /// respectively, rather than the case to retrieve.
  Future<SafetyCase> retrieve(
    String safetyCaseId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final path = safetyResourcePath(
      '/safety/cases',
      safetyCaseId,
      maximumLength: 128,
      context: 'Safety case',
    );
    final request = http.Request('GET', requestBuilder.buildUrl(path))
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(
      request,
      abortTrigger: abortTrigger,
    );
    return parseSafetyResponse(response, SafetyCase.fromJson, 'SafetyCase');
  }
}
