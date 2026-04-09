import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_trace_scope.dart';
import 'tempo_trace_span.dart';

/// A trace scope with its spans.
@immutable
class TempoTraceScopeSpan {
  /// The trace scope.
  final TempoTraceScope scope;

  /// The spans in this scope.
  final List<TempoTraceSpan>? spans;

  /// Creates a [TempoTraceScopeSpan].
  TempoTraceScopeSpan({required this.scope, List<TempoTraceSpan>? spans})
    : spans = spans != null ? List.unmodifiable(spans) : null;

  /// Creates a [TempoTraceScopeSpan] from JSON.
  factory TempoTraceScopeSpan.fromJson(Map<String, dynamic> json) =>
      TempoTraceScopeSpan(
        scope: TempoTraceScope.fromJson(json['scope'] as Map<String, dynamic>),
        spans: (json['spans'] as List?)
            ?.map((e) => TempoTraceSpan.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'scope': scope.toJson(),
    if (spans != null) 'spans': spans?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TempoTraceScopeSpan copyWith({
    TempoTraceScope? scope,
    Object? spans = unsetCopyWithValue,
  }) {
    return TempoTraceScopeSpan(
      scope: scope ?? this.scope,
      spans: spans == unsetCopyWithValue
          ? this.spans
          : spans as List<TempoTraceSpan>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceScopeSpan) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(spans, other.spans)) return false;
    return scope == other.scope;
  }

  @override
  int get hashCode => Object.hash(scope, listHash(spans));

  @override
  String toString() =>
      'TempoTraceScopeSpan(scope: $scope, spans: ${spans?.length ?? 'null'})';
}
