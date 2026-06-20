import 'package:meta/meta.dart';

/// Request body to update the run info of an ingestion pipeline
/// configuration (beta).
@immutable
class UpdateRunInfo {
  /// When the run was executed.
  final DateTime executionTime;

  /// The number of chunks produced by the run.
  final int chunksCount;

  /// Creates an [UpdateRunInfo].
  const UpdateRunInfo({required this.executionTime, required this.chunksCount});

  /// Creates an [UpdateRunInfo] from JSON.
  factory UpdateRunInfo.fromJson(Map<String, dynamic> json) => UpdateRunInfo(
    executionTime: DateTime.parse(json['execution_time'] as String),
    chunksCount: json['chunks_count'] as int,
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'execution_time': executionTime.toIso8601String(),
    'chunks_count': chunksCount,
  };

  /// Creates a copy with the given fields replaced.
  UpdateRunInfo copyWith({DateTime? executionTime, int? chunksCount}) =>
      UpdateRunInfo(
        executionTime: executionTime ?? this.executionTime,
        chunksCount: chunksCount ?? this.chunksCount,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateRunInfo &&
          runtimeType == other.runtimeType &&
          executionTime == other.executionTime &&
          chunksCount == other.chunksCount;

  @override
  int get hashCode => Object.hash(executionTime, chunksCount);

  @override
  String toString() =>
      'UpdateRunInfo(executionTime: $executionTime, chunksCount: $chunksCount)';
}
