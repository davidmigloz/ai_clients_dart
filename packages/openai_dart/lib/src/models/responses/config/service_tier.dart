import 'package:meta/meta.dart';

/// Service tier for request processing.
///
/// Known tiers are available as static constants (e.g., [ServiceTier.auto],
/// [ServiceTier.defaultTier], [ServiceTier.flex], [ServiceTier.scale],
/// [ServiceTier.priority]).
/// Providers may define
/// additional tiers; use the [ServiceTier.new] constructor for custom values
/// (e.g., `ServiceTier('batch')`).
@immutable
class ServiceTier {
  /// Automatic tier selection.
  static const auto = ServiceTier('auto');

  /// Default tier.
  static const defaultTier = ServiceTier('default');

  /// Flex tier for cost-effective processing.
  static const flex = ServiceTier('flex');

  /// Scale tier.
  static const scale = ServiceTier('scale');

  /// Priority tier (higher priority).
  static const priority = ServiceTier('priority');

  /// The raw string value for this tier.
  final String value;

  /// Creates a [ServiceTier] with the given [value].
  ///
  /// Use static constants for well-known tiers (e.g., [ServiceTier.auto]).
  /// Use this constructor for provider-specific tiers:
  /// ```dart
  /// const customTier = ServiceTier('batch');
  /// ```
  const ServiceTier(this.value);

  /// Creates a [ServiceTier] from a JSON value.
  factory ServiceTier.fromJson(String json) => switch (json) {
    'auto' => auto,
    'default' => defaultTier,
    'flex' => flex,
    'scale' => scale,
    'priority' => priority,
    _ => ServiceTier(json),
  };

  /// Converts to JSON value.
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceTier &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ServiceTier($value)';
}
