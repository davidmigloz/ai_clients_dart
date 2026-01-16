/// Service tier for request processing.
enum ServiceTier {
  /// Unknown service tier (fallback for unrecognized values).
  unknown('unknown'),

  /// Automatic tier selection.
  auto('auto'),

  /// Default tier.
  defaultTier('default'),

  /// Flex tier (lower priority, lower cost).
  flex('flex'),

  /// Priority tier (higher priority).
  priority('priority');

  /// The JSON value for this service tier.
  final String value;

  const ServiceTier(this.value);

  /// Creates a [ServiceTier] from a JSON value.
  factory ServiceTier.fromJson(String json) {
    return ServiceTier.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ServiceTier.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
