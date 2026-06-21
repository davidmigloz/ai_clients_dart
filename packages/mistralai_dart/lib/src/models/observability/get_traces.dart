import 'package:meta/meta.dart';

import 'feed_result.dart';
import 'get_trace.dart';

/// Response containing a paginated feed of traces.
@immutable
class GetTraces {
  /// The paginated traces results.
  final FeedResult<GetTrace> traces;

  /// Creates a [GetTraces].
  const GetTraces({required this.traces});

  /// Creates a [GetTraces] from JSON.
  factory GetTraces.fromJson(Map<String, dynamic> json) => GetTraces(
    traces: FeedResult<GetTrace>.fromJson(
      json['traces'] as Map<String, dynamic>? ?? const {},
      GetTrace.fromJson,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'traces': traces.toJson((e) => e.toJson())};

  /// Creates a copy with replaced values.
  GetTraces copyWith({FeedResult<GetTrace>? traces}) =>
      GetTraces(traces: traces ?? this.traces);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetTraces) return false;
    if (runtimeType != other.runtimeType) return false;
    return traces == other.traces;
  }

  @override
  int get hashCode => traces.hashCode;

  @override
  String toString() => 'GetTraces(traces: $traces)';
}
