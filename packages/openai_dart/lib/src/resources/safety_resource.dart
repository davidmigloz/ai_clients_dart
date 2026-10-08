import 'base_resource.dart';
import 'safety/safety_alerts_resource.dart';
import 'safety/safety_cases_resource.dart';

/// Explicit retrieval of project safety alerts and organization safety cases.
///
/// Receiving or verifying a safety webhook does not request these details.
/// Applications choose which separately scoped client to use for each lookup.
/// Workspace alerts on `api.chatgpt.com` use a separate administrator API.
class SafetyResource extends ResourceBase {
  /// Creates the safety namespace using the client's shared HTTP infrastructure.
  SafetyResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  SafetyAlertsResource? _alerts;
  SafetyCasesResource? _cases;

  /// Retrieves project alerts with the `api.safety.alerts.read` permission.
  SafetyAlertsResource get alerts => _alerts ??= SafetyAlertsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Retrieves organization cases with the `api.safety.read` permission.
  SafetyCasesResource get cases => _cases ??= SafetyCasesResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );
}
