/// Capacity requested for a chat or agent completion.
///
/// The serving tier depends on account entitlement, model and region. Inspect
/// `UsageInfo.serviceTier` to see which tier processed a request.
final class RequestedServiceTier {
  /// Use priority capacity when available, with standard capacity as fallback.
  static const auto = RequestedServiceTier._('auto');

  /// Always use standard capacity.
  static const standardOnly = RequestedServiceTier._('standard_only');

  const RequestedServiceTier._(this.value);

  /// The value sent in the API request.
  final String value;

  /// Parses a known wire value, or returns `null` for an unknown or absent value.
  static RequestedServiceTier? fromString(String? value) => switch (value) {
    'auto' => auto,
    'standard_only' => standardOnly,
    _ => null,
  };
}
