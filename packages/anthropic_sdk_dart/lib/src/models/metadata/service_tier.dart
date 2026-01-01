/// Service tier for request capacity (input).
enum ServiceTierRequest {
  /// Automatically select the best available tier.
  auto_('auto'),

  /// Use standard capacity only.
  standardOnly('standard_only');

  const ServiceTierRequest(this.value);

  /// JSON value for the service tier.
  final String value;

  /// Converts a string to [ServiceTierRequest].
  static ServiceTierRequest fromJson(String value) => switch (value) {
    'auto' => ServiceTierRequest.auto_,
    'standard_only' => ServiceTierRequest.standardOnly,
    _ => throw FormatException('Unknown ServiceTierRequest: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}

/// Service tier used for the response (output).
enum ServiceTierResponse {
  /// Standard capacity tier.
  standard('standard'),

  /// Priority capacity tier.
  priority('priority'),

  /// Batch processing tier.
  batch('batch');

  const ServiceTierResponse(this.value);

  /// JSON value for the service tier.
  final String value;

  /// Converts a string to [ServiceTierResponse].
  static ServiceTierResponse fromJson(String value) => switch (value) {
    'standard' => ServiceTierResponse.standard,
    'priority' => ServiceTierResponse.priority,
    'batch' => ServiceTierResponse.batch,
    _ => throw FormatException('Unknown ServiceTierResponse: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}
