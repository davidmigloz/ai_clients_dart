/// Kind of OpenTelemetry trace scope span.
enum TempoTraceScopeKind {
  /// Internal span.
  spanKindInternal('SPAN_KIND_INTERNAL'),

  /// Server span.
  spanKindServer('SPAN_KIND_SERVER'),

  /// Client span.
  spanKindClient('SPAN_KIND_CLIENT'),

  /// Unknown kind (forward-compatibility fallback).
  unknown('unknown');

  const TempoTraceScopeKind(this.value);

  /// The string value of this enum member.
  final String value;

  /// Creates a [TempoTraceScopeKind] from a JSON string value.
  static TempoTraceScopeKind fromJson(String? value) {
    if (value == null) return TempoTraceScopeKind.unknown;
    return TempoTraceScopeKind.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TempoTraceScopeKind.unknown,
    );
  }

  /// Returns the string value for JSON serialization.
  String toJson() => value;
}
