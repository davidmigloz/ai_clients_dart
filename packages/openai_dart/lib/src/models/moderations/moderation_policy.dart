import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// How a moderation policy should act on flagged content.
///
/// Used by [ModerationConfigParam.mode].
enum ModerationMode {
  /// Unknown mode (fallback for unrecognized values).
  unknown('unknown'),

  /// Only score the content; do not block it.
  score('score'),

  /// Block the content when it is flagged.
  block('block');

  const ModerationMode(this.value);

  /// The JSON value for this mode.
  final String value;

  /// Creates a [ModerationMode] from a JSON value.
  factory ModerationMode.fromJson(String json) {
    return ModerationMode.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ModerationMode.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}

/// The moderation policy for a response input or output.
@immutable
class ModerationConfigParam {
  /// Creates a [ModerationConfigParam].
  const ModerationConfigParam({required this.mode});

  /// Creates a [ModerationConfigParam] from JSON.
  factory ModerationConfigParam.fromJson(Map<String, dynamic> json) {
    return ModerationConfigParam(
      mode: ModerationMode.fromJson(json['mode'] as String),
    );
  }

  /// Whether flagged content should only be scored or also blocked.
  final ModerationMode mode;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'mode': mode.toJson()};

  /// Creates a copy with the given fields replaced.
  ModerationConfigParam copyWith({ModerationMode? mode}) =>
      ModerationConfigParam(mode: mode ?? this.mode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationConfigParam &&
          runtimeType == other.runtimeType &&
          mode == other.mode;

  @override
  int get hashCode => mode.hashCode;

  @override
  String toString() => 'ModerationConfigParam(mode: $mode)';
}

/// The policy to apply to moderated response input and output.
///
/// Set on [ModerationConfig.policy] to control, independently, whether
/// flagged input and output are only scored or also blocked.
@immutable
class ModerationPolicyParam {
  /// Creates a [ModerationPolicyParam].
  const ModerationPolicyParam({this.input, this.output});

  /// Creates a [ModerationPolicyParam] from JSON.
  factory ModerationPolicyParam.fromJson(Map<String, dynamic> json) {
    return ModerationPolicyParam(
      input: json['input'] != null
          ? ModerationConfigParam.fromJson(
              json['input'] as Map<String, dynamic>,
            )
          : null,
      output: json['output'] != null
          ? ModerationConfigParam.fromJson(
              json['output'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The moderation policy for the response input.
  final ModerationConfigParam? input;

  /// The moderation policy for the response output.
  final ModerationConfigParam? output;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (input != null) 'input': input!.toJson(),
    if (output != null) 'output': output!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  ModerationPolicyParam copyWith({
    Object? input = unsetCopyWithValue,
    Object? output = unsetCopyWithValue,
  }) {
    return ModerationPolicyParam(
      input: input == unsetCopyWithValue
          ? this.input
          : input as ModerationConfigParam?,
      output: output == unsetCopyWithValue
          ? this.output
          : output as ModerationConfigParam?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationPolicyParam &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          output == other.output;

  @override
  int get hashCode => Object.hash(input, output);

  @override
  String toString() => 'ModerationPolicyParam(input: $input, output: $output)';
}
