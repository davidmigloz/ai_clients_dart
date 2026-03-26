/// The service tier for a request.
enum ServiceTier {
  /// Default service tier, which is standard.
  unspecified,

  /// Standard service tier.
  standard,

  /// Flex service tier.
  flex,

  /// Priority service tier.
  priority,
}

/// Parses a [ServiceTier] from its string representation.
///
/// Unrecognized values return `null`.
ServiceTier? serviceTierFromString(String? value) {
  return switch (value) {
    'unspecified' => ServiceTier.unspecified,
    'standard' => ServiceTier.standard,
    'flex' => ServiceTier.flex,
    'priority' => ServiceTier.priority,
    _ => null,
  };
}

/// Converts a [ServiceTier] to its string representation.
String serviceTierToString(ServiceTier value) {
  return switch (value) {
    ServiceTier.unspecified => 'unspecified',
    ServiceTier.standard => 'standard',
    ServiceTier.flex => 'flex',
    ServiceTier.priority => 'priority',
  };
}
