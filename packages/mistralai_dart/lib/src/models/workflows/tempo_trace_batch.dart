import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_trace_resource.dart';
import 'tempo_trace_scope_span.dart';

/// A batch of trace data.
@immutable
class TempoTraceBatch {
  /// The trace resource.
  final TempoTraceResource resource;

  /// The scope spans.
  final List<TempoTraceScopeSpan>? scopeSpans;

  /// Creates a [TempoTraceBatch].
  TempoTraceBatch({
    required this.resource,
    List<TempoTraceScopeSpan>? scopeSpans,
  }) : scopeSpans = scopeSpans != null ? List.unmodifiable(scopeSpans) : null;

  /// Creates a [TempoTraceBatch] from JSON.
  factory TempoTraceBatch.fromJson(Map<String, dynamic> json) =>
      TempoTraceBatch(
        resource: TempoTraceResource.fromJson(
          json['resource'] as Map<String, dynamic>,
        ),
        scopeSpans: (json['scopeSpans'] as List?)
            ?.map(
              (e) => TempoTraceScopeSpan.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'resource': resource.toJson(),
    if (scopeSpans != null)
      'scopeSpans': scopeSpans?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TempoTraceBatch copyWith({
    TempoTraceResource? resource,
    Object? scopeSpans = unsetCopyWithValue,
  }) {
    return TempoTraceBatch(
      resource: resource ?? this.resource,
      scopeSpans: scopeSpans == unsetCopyWithValue
          ? this.scopeSpans
          : scopeSpans as List<TempoTraceScopeSpan>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoTraceBatch) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(scopeSpans, other.scopeSpans)) return false;
    return resource == other.resource;
  }

  @override
  int get hashCode => Object.hash(resource, listHash(scopeSpans));

  @override
  String toString() =>
      'TempoTraceBatch(resource: $resource, scopeSpans: ${scopeSpans?.length ?? 'null'})';
}
