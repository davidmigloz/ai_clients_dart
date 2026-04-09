import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_trace_batch.dart';

/// Response for getting trace data.
@immutable
class TempoGetTraceResponse {
  /// The trace batches.
  final List<TempoTraceBatch>? batches;

  /// Creates a [TempoGetTraceResponse].
  TempoGetTraceResponse({List<TempoTraceBatch>? batches})
    : batches = batches != null ? List.unmodifiable(batches) : null;

  /// Creates a [TempoGetTraceResponse] from JSON.
  factory TempoGetTraceResponse.fromJson(Map<String, dynamic> json) =>
      TempoGetTraceResponse(
        batches: (json['batches'] as List?)
            ?.map((e) => TempoTraceBatch.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (batches != null) 'batches': batches?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  TempoGetTraceResponse copyWith({Object? batches = unsetCopyWithValue}) {
    return TempoGetTraceResponse(
      batches: batches == unsetCopyWithValue
          ? this.batches
          : batches as List<TempoTraceBatch>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TempoGetTraceResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(batches, other.batches)) return false;
    return true;
  }

  @override
  int get hashCode => listHash(batches);

  @override
  String toString() =>
      'TempoGetTraceResponse(batches: ${batches?.length ?? 'null'})';
}
