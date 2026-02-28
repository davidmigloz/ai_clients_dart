import 'package:meta/meta.dart';

import 'common/equality_helpers.dart';
import 'items/output_item.dart';
import 'response_input.dart';
import 'response_usage.dart';

/// A compacted response object returned by `responses.compact`.
@immutable
class ResponseCompaction {
  /// Unique identifier for the compacted response.
  final String id;

  /// Object type, always `response.compaction`.
  final String object;

  /// The compacted output items.
  final List<OutputItem> output;

  /// Unix timestamp (seconds) when the compaction was created.
  final int createdAt;

  /// Token usage for the compaction pass.
  final ResponseUsage usage;

  /// Creates a [ResponseCompaction].
  const ResponseCompaction({
    required this.id,
    required this.object,
    required this.output,
    required this.createdAt,
    required this.usage,
  });

  /// Creates a [ResponseCompaction] from JSON.
  factory ResponseCompaction.fromJson(Map<String, dynamic> json) {
    return ResponseCompaction(
      id: json['id'] as String,
      object: json['object'] as String,
      output: (json['output'] as List<dynamic>)
          .map((e) => OutputItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['created_at'] as int,
      usage: ResponseUsage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  /// Converts the compact output to [ResponseInput] for the next API call.
  ///
  /// This serializes each [OutputItem] to JSON and wraps them as
  /// [ResponseInputRawJson], which passes the JSON through directly.
  /// The compact output item JSON is valid API input, so no conversion
  /// is needed.
  ResponseInput toInput() =>
      ResponseInput.fromOutputItems(output.map((e) => e.toJson()).toList());

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'output': output.map((e) => e.toJson()).toList(),
    'created_at': createdAt,
    'usage': usage.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseCompaction &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          listsEqual(output, other.output) &&
          createdAt == other.createdAt &&
          usage == other.usage;

  @override
  int get hashCode => Object.hash(id, object, output, createdAt, usage);

  @override
  String toString() =>
      'ResponseCompaction(id: $id, output: ${output.length} items)';
}
