import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'cache_miss_reason.dart';

/// Response-level cache diagnostics (Beta).
///
/// Returned on a [Message] when prompt-cache diagnostics were requested via
/// [DiagnosticsParam] and the `cache-diagnosis-2026-04-07` beta header.
@immutable
class Diagnostics {
  /// Why the prompt-cache lookup missed.
  ///
  /// The key is always present, but is `null` when the diagnosis is still
  /// pending — the response was serialized before the background prompt-cache
  /// comparison completed. A `null` value here does NOT mean "no divergence":
  /// when no divergence is detected the API signals it by leaving the
  /// message-level [Message.diagnostics] itself `null`, not via this field.
  final CacheMissReason? cacheMissReason;

  /// Creates a [Diagnostics].
  const Diagnostics({this.cacheMissReason});

  /// Creates a [Diagnostics] from JSON.
  factory Diagnostics.fromJson(Map<String, dynamic> json) {
    return Diagnostics(
      cacheMissReason: json['cache_miss_reason'] != null
          ? CacheMissReason.fromJson(
              json['cache_miss_reason'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'cache_miss_reason': cacheMissReason?.toJson(),
  };

  /// Creates a copy with replaced values.
  Diagnostics copyWith({Object? cacheMissReason = unsetCopyWithValue}) {
    return Diagnostics(
      cacheMissReason: cacheMissReason == unsetCopyWithValue
          ? this.cacheMissReason
          : cacheMissReason as CacheMissReason?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Diagnostics &&
          runtimeType == other.runtimeType &&
          cacheMissReason == other.cacheMissReason;

  @override
  int get hashCode => cacheMissReason.hashCode;

  @override
  String toString() => 'Diagnostics(cacheMissReason: $cacheMissReason)';
}
