import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Requests on-demand compaction with `compact-2026-09-04`.
///
/// The API returns a signed summary block without generating a conversation
/// reply. Reuse the summary block unchanged on later requests.
@immutable
final class CompactionConfig {
  /// Replaces the server's default summarization prompt for this request.
  ///
  /// The API treats an empty or whitespace-only string as absent.
  final String? instructions;

  /// Requests a signed summary of the supplied conversation.
  const CompactionConfig.summarize({this.instructions});

  /// Creates a [CompactionConfig] from JSON.
  factory CompactionConfig.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'summarize') {
      throw const FormatException('Expected compaction type "summarize"');
    }
    return CompactionConfig.summarize(
      instructions: json['instructions'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': 'summarize',
    'instructions': ?instructions,
  };

  /// Creates a copy with replaced values.
  CompactionConfig copyWith({Object? instructions = unsetCopyWithValue}) =>
      CompactionConfig.summarize(
        instructions: instructions == unsetCopyWithValue
            ? this.instructions
            : instructions as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactionConfig && instructions == other.instructions;

  @override
  int get hashCode => instructions.hashCode;

  @override
  String toString() =>
      'CompactionConfig(hasInstructions: ${instructions != null})';
}
