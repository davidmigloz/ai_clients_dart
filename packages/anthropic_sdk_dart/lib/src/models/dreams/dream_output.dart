import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// An output destination a Dream writes consolidated memories into.
///
/// Variants:
/// - [DreamMemoryStoreOutput] — an output memory store (type: `memory_store`)
/// - [UnknownDreamOutput] — unrecognized type (preserves raw JSON)
sealed class DreamOutput {
  const DreamOutput();

  /// Creates a [DreamOutput] from JSON.
  factory DreamOutput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'memory_store' => DreamMemoryStoreOutput.fromJson(json),
      _ => UnknownDreamOutput.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An output memory store the dream writes consolidated memories into.
@immutable
class DreamMemoryStoreOutput extends DreamOutput {
  /// Object type. Always `memory_store`.
  final String type;

  /// The ID of the memory store the dream writes to.
  final String memoryStoreId;

  /// Creates a [DreamMemoryStoreOutput].
  const DreamMemoryStoreOutput({
    this.type = 'memory_store',
    required this.memoryStoreId,
  });

  /// Creates a [DreamMemoryStoreOutput] from JSON.
  factory DreamMemoryStoreOutput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'memory_store') {
      throw FormatException(
        'DreamMemoryStoreOutput: expected type "memory_store", got "$type"',
      );
    }
    return DreamMemoryStoreOutput(
      type: type!,
      memoryStoreId: json['memory_store_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'memory_store_id': memoryStoreId,
  };

  /// Creates a copy with replaced values.
  DreamMemoryStoreOutput copyWith({String? type, String? memoryStoreId}) {
    return DreamMemoryStoreOutput(
      type: type ?? this.type,
      memoryStoreId: memoryStoreId ?? this.memoryStoreId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamMemoryStoreOutput &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          memoryStoreId == other.memoryStoreId;

  @override
  int get hashCode => Object.hash(type, memoryStoreId);

  @override
  String toString() =>
      'DreamMemoryStoreOutput(type: $type, memoryStoreId: $memoryStoreId)';
}

/// Unrecognized [DreamOutput] — preserves raw JSON for forward compatibility.
@immutable
class UnknownDreamOutput extends DreamOutput {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownDreamOutput].
  const UnknownDreamOutput({required this.rawJson});

  /// Creates an [UnknownDreamOutput] from JSON.
  factory UnknownDreamOutput.fromJson(Map<String, dynamic> json) {
    return UnknownDreamOutput(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDreamOutput &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownDreamOutput(rawJson: $rawJson)';
}
