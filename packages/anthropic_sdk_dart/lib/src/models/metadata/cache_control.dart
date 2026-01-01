import 'package:meta/meta.dart';

/// Time-to-live values for cache control.
enum CacheTtl {
  /// 5 minutes TTL.
  ttl5m('5m'),

  /// 1 hour TTL.
  ttl1h('1h');

  const CacheTtl(this.value);

  /// JSON value for the TTL.
  final String value;

  /// Converts a string to [CacheTtl].
  static CacheTtl fromJson(String value) => switch (value) {
    '5m' => CacheTtl.ttl5m,
    '1h' => CacheTtl.ttl1h,
    _ => throw FormatException('Unknown CacheTtl: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}

/// Cache control configuration for ephemeral caching.
///
/// When applied to content, enables prompt caching with the specified TTL.
@immutable
class CacheControlEphemeral {
  /// The time-to-live for the cache control breakpoint.
  ///
  /// Defaults to `5m` (5 minutes).
  final CacheTtl? ttl;

  /// Creates a [CacheControlEphemeral].
  const CacheControlEphemeral({this.ttl});

  /// Creates a [CacheControlEphemeral] from JSON.
  factory CacheControlEphemeral.fromJson(Map<String, dynamic> json) {
    return CacheControlEphemeral(
      ttl: json['ttl'] != null
          ? CacheTtl.fromJson(json['ttl'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'ephemeral',
    if (ttl != null) 'ttl': ttl!.toJson(),
  };

  /// Creates a copy with replaced values.
  CacheControlEphemeral copyWith({CacheTtl? ttl}) {
    return CacheControlEphemeral(ttl: ttl ?? this.ttl);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CacheControlEphemeral &&
          runtimeType == other.runtimeType &&
          ttl == other.ttl;

  @override
  int get hashCode => ttl.hashCode;

  @override
  String toString() => 'CacheControlEphemeral(ttl: $ttl)';
}
