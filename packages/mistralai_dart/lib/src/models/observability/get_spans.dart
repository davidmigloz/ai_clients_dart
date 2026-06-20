import 'package:meta/meta.dart';

import 'feed_result.dart';
import 'get_span.dart';

/// Response containing a paginated feed of spans.
@immutable
class GetSpans {
  /// The paginated spans results.
  final FeedResult<GetSpan> spans;

  /// Creates a [GetSpans].
  const GetSpans({required this.spans});

  /// Creates a [GetSpans] from JSON.
  factory GetSpans.fromJson(Map<String, dynamic> json) => GetSpans(
    spans: FeedResult<GetSpan>.fromJson(
      json['spans'] as Map<String, dynamic>? ?? const {},
      GetSpan.fromJson,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'spans': spans.toJson((e) => e.toJson())};

  /// Creates a copy with replaced values.
  GetSpans copyWith({FeedResult<GetSpan>? spans}) =>
      GetSpans(spans: spans ?? this.spans);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetSpans) return false;
    if (runtimeType != other.runtimeType) return false;
    return spans == other.spans;
  }

  @override
  int get hashCode => spans.hashCode;

  @override
  String toString() => 'GetSpans(spans: $spans)';
}
