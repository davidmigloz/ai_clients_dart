import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request to pull/download a model.
@immutable
class PullRequest {
  /// Runner variant to download from a model manifest list.
  final String? runner;

  /// Name of the model to download.
  final String model;

  /// Allow downloading over insecure connections.
  final bool? insecure;

  /// Stream progress updates.
  final bool? stream;

  /// Creates a [PullRequest].
  const PullRequest({
    required this.model,
    this.runner,
    this.insecure,
    this.stream,
  });

  /// Creates a [PullRequest] from JSON.
  factory PullRequest.fromJson(Map<String, dynamic> json) => PullRequest(
    runner: json['runner'] as String?,
    model: json['model'] as String,
    insecure: json['insecure'] as bool?,
    stream: json['stream'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (runner != null) 'runner': runner,
    'model': model,
    if (insecure != null) 'insecure': insecure,
    if (stream != null) 'stream': stream,
  };

  /// Creates a copy with replaced values.
  PullRequest copyWith({
    Object? runner = unsetCopyWithValue,
    String? model,
    Object? insecure = unsetCopyWithValue,
    Object? stream = unsetCopyWithValue,
  }) {
    return PullRequest(
      runner: identical(runner, unsetCopyWithValue)
          ? this.runner
          : runner as String?,
      model: model ?? this.model,
      insecure: insecure == unsetCopyWithValue
          ? this.insecure
          : insecure as bool?,
      stream: stream == unsetCopyWithValue ? this.stream : stream as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PullRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          runner == other.runner &&
          insecure == other.insecure &&
          stream == other.stream;

  @override
  int get hashCode => Object.hash(model, runner, insecure, stream);

  @override
  String toString() =>
      'PullRequest(model: $model, runner: $runner, insecure: $insecure, stream: $stream)';
}
