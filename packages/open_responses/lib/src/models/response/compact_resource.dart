import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import '../items/output_item.dart';
import 'usage.dart';

/// A compacted response resource.
///
/// Returned by the `POST /responses/compact` endpoint. Contains the
/// compacted list of output items and token accounting for the compaction
/// pass.
@immutable
class CompactResource {
  /// The unique identifier for the compacted response.
  final String id;

  /// The object type. Always `response.compaction`.
  final String object;

  /// Unix timestamp (in seconds) when the compacted conversation was
  /// created.
  final int createdAt;

  /// The compacted list of output items.
  final List<OutputItem> output;

  /// Token accounting for the compaction pass, including cached, reasoning,
  /// and total tokens.
  final Usage usage;

  /// Creates a [CompactResource].
  const CompactResource({
    required this.id,
    this.object = 'response.compaction',
    required this.createdAt,
    required this.output,
    required this.usage,
  });

  /// Creates a [CompactResource] from JSON.
  factory CompactResource.fromJson(Map<String, dynamic> json) {
    return CompactResource(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'response.compaction',
      createdAt: json['created_at'] as int,
      output: (json['output'] as List)
          .map((e) => OutputItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      usage: Usage.fromJson(json['usage'] as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'output': output.map((e) => e.toJson()).toList(),
    'usage': usage.toJson(),
  };

  /// Creates a copy with replaced values.
  CompactResource copyWith({
    String? id,
    String? object,
    int? createdAt,
    List<OutputItem>? output,
    Usage? usage,
  }) {
    return CompactResource(
      id: id ?? this.id,
      object: object ?? this.object,
      createdAt: createdAt ?? this.createdAt,
      output: output ?? this.output,
      usage: usage ?? this.usage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactResource &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          createdAt == other.createdAt &&
          listsEqual(output, other.output) &&
          usage == other.usage;

  @override
  int get hashCode =>
      Object.hash(id, object, createdAt, Object.hashAll(output), usage);

  @override
  String toString() =>
      'CompactResource(id: $id, object: $object, createdAt: $createdAt, output: ${output.length} items, usage: $usage)';
}
