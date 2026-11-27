import '../../models/billing/billing.dart';
import '../base_resource.dart';
import '../platform_resource.dart';

/// Read-only billing settings for the authenticated dashboard customer (beta).
///
/// The API expects the configured public API key as an x-api-key header.
/// Access depends on the key's billing context.
class BillingResource extends ResourceBase with PlatformResource {
  /// Creates a [BillingResource].
  BillingResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Retrieves the current API and Vibe budgets.
  Future<BillingBudget> getBudget() => requestPlatform(
    'GET',
    '/v1/billing/budget',
    (json) => BillingBudget.fromJson(json! as Map<String, dynamic>),
    authInApiKeyHeader: true,
  );

  /// Retrieves the subscription and pay-as-you-go settings.
  Future<BillingSubscription> getSubscription() => requestPlatform(
    'GET',
    '/v1/billing/subscription',
    (json) => BillingSubscription.fromJson(json! as Map<String, dynamic>),
    authInApiKeyHeader: true,
  );
}
