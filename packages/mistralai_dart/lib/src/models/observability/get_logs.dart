import 'package:meta/meta.dart';

import 'feed_result.dart';
import 'get_log.dart';

/// Response containing a paginated feed of logs.
@immutable
class GetLogs {
  /// The paginated logs results.
  final FeedResult<GetLog> logs;

  /// Creates a [GetLogs].
  const GetLogs({required this.logs});

  /// Creates a [GetLogs] from JSON.
  factory GetLogs.fromJson(Map<String, dynamic> json) => GetLogs(
    logs: FeedResult<GetLog>.fromJson(
      json['logs'] as Map<String, dynamic>? ?? const {},
      GetLog.fromJson,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'logs': logs.toJson((e) => e.toJson())};

  /// Creates a copy with replaced values.
  GetLogs copyWith({FeedResult<GetLog>? logs}) =>
      GetLogs(logs: logs ?? this.logs);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GetLogs) return false;
    if (runtimeType != other.runtimeType) return false;
    return logs == other.logs;
  }

  @override
  int get hashCode => logs.hashCode;

  @override
  String toString() => 'GetLogs(logs: $logs)';
}
