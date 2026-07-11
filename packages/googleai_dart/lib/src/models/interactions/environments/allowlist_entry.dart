part of 'environments.dart';

/// A single allowed outbound domain in an environment's network egress
/// configuration.
class AllowlistEntry {
  /// The allowed outbound domain. Use `*` to allow all domains while still
  /// injecting headers on specific ones.
  final String domain;

  /// Headers to inject on all outbound requests matching this [domain].
  ///
  /// Each entry is a flat `{header_name: header_value}` object; the egress
  /// proxy injects these automatically. The spec accepts a single dict or a
  /// list of dicts; a single dict is normalized to a one-element list.
  final List<Map<String, String>>? transform;

  /// Creates an [AllowlistEntry].
  const AllowlistEntry({required this.domain, this.transform});

  /// Creates an [AllowlistEntry] from JSON.
  ///
  /// `transform` accepts either a single `{header_name: header_value}` object
  /// or a list of such objects; a single object is normalized to a
  /// one-element list.
  factory AllowlistEntry.fromJson(Map<String, dynamic> json) => AllowlistEntry(
    domain: json['domain'] as String,
    transform: switch (json['transform']) {
      final List<dynamic> list =>
        list
            .map((e) => (e as Map<String, dynamic>).cast<String, String>())
            .toList(),
      final Map<String, dynamic> map => [map.cast<String, String>()],
      _ => null,
    },
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'domain': domain,
    if (transform != null) 'transform': transform,
  };

  /// Creates a copy with replaced values.
  AllowlistEntry copyWith({
    Object? domain = unsetCopyWithValue,
    Object? transform = unsetCopyWithValue,
  }) {
    return AllowlistEntry(
      domain: domain == unsetCopyWithValue ? this.domain : domain! as String,
      transform: transform == unsetCopyWithValue
          ? this.transform
          : transform as List<Map<String, String>>?,
    );
  }
}
