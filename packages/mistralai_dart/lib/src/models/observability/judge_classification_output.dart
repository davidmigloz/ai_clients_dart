import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'judge_classification_output_option.dart';

/// Classification judge output configuration.
@immutable
class JudgeClassificationOutput {
  /// Output type discriminator (always "CLASSIFICATION").
  final String type;

  /// The classification options.
  final List<JudgeClassificationOutputOption> options;

  /// Creates a [JudgeClassificationOutput].
  JudgeClassificationOutput({
    this.type = 'CLASSIFICATION',
    required List<JudgeClassificationOutputOption> options,
  }) : options = List.unmodifiable(options);

  /// Creates a [JudgeClassificationOutput] from JSON.
  factory JudgeClassificationOutput.fromJson(Map<String, dynamic> json) =>
      JudgeClassificationOutput(
        type: json['type'] as String? ?? 'CLASSIFICATION',
        options:
            (json['options'] as List?)
                ?.map(
                  (e) => JudgeClassificationOutputOption.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'options': options.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! JudgeClassificationOutput) return false;
    if (runtimeType != other.runtimeType) return false;
    return type == other.type && listsEqual(options, other.options);
  }

  @override
  int get hashCode => Object.hash(type, listHash(options));

  @override
  String toString() =>
      'JudgeClassificationOutput(type: $type, '
      'options: ${options.length} options)';
}
