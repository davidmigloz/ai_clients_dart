import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// An input source a Dream reads from.
///
/// Variants:
/// - [DreamMemoryStoreInput] — an input memory store (type: `memory_store`)
/// - [DreamSessionsInput] — input session transcripts (type: `sessions`)
/// - [UnknownDreamInput] — unrecognized type (preserves raw JSON)
sealed class DreamInput {
  const DreamInput();

  /// Creates a [DreamInput] from JSON.
  factory DreamInput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'memory_store' => DreamMemoryStoreInput.fromJson(json),
      'sessions' => DreamSessionsInput.fromJson(json),
      _ => UnknownDreamInput.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// An input memory store the dream reads from. The dream never mutates this
/// store.
@immutable
class DreamMemoryStoreInput extends DreamInput {
  /// Object type. Always `memory_store`.
  final String type;

  /// The ID of the memory store to read from.
  final String memoryStoreId;

  /// Creates a [DreamMemoryStoreInput].
  const DreamMemoryStoreInput({
    this.type = 'memory_store',
    required this.memoryStoreId,
  });

  /// Creates a [DreamMemoryStoreInput] from JSON.
  factory DreamMemoryStoreInput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'memory_store') {
      throw FormatException(
        'DreamMemoryStoreInput: expected type "memory_store", got "$type"',
      );
    }
    return DreamMemoryStoreInput(
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
  DreamMemoryStoreInput copyWith({String? type, String? memoryStoreId}) {
    return DreamMemoryStoreInput(
      type: type ?? this.type,
      memoryStoreId: memoryStoreId ?? this.memoryStoreId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamMemoryStoreInput &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          memoryStoreId == other.memoryStoreId;

  @override
  int get hashCode => Object.hash(type, memoryStoreId);

  @override
  String toString() =>
      'DreamMemoryStoreInput(type: $type, memoryStoreId: $memoryStoreId)';
}

/// Input session transcripts the dream reads.
@immutable
class DreamSessionsInput extends DreamInput {
  /// Object type. Always `sessions`.
  final String type;

  /// IDs of the sessions to read transcripts from.
  final List<String> sessionIds;

  /// Creates a [DreamSessionsInput].
  const DreamSessionsInput({this.type = 'sessions', required this.sessionIds});

  /// Creates a [DreamSessionsInput] from JSON.
  factory DreamSessionsInput.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type != 'sessions') {
      throw FormatException(
        'DreamSessionsInput: expected type "sessions", got "$type"',
      );
    }
    final rawIds = json['session_ids'] as List? ?? [];
    final sessionIds = rawIds.map((e) {
      if (e is! String) {
        throw FormatException(
          'DreamSessionsInput.session_ids: expected String, got '
          '${e.runtimeType}',
        );
      }
      return e;
    }).toList();
    return DreamSessionsInput(type: type!, sessionIds: sessionIds);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'session_ids': sessionIds};

  /// Creates a copy with replaced values.
  DreamSessionsInput copyWith({String? type, List<String>? sessionIds}) {
    return DreamSessionsInput(
      type: type ?? this.type,
      sessionIds: sessionIds ?? this.sessionIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DreamSessionsInput &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          listsEqual(sessionIds, other.sessionIds);

  @override
  int get hashCode => Object.hash(type, listHash(sessionIds));

  @override
  String toString() =>
      'DreamSessionsInput(type: $type, sessionIds: $sessionIds)';
}

/// Unrecognized [DreamInput] — preserves raw JSON for forward compatibility.
@immutable
class UnknownDreamInput extends DreamInput {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownDreamInput].
  const UnknownDreamInput({required this.rawJson});

  /// Creates an [UnknownDreamInput] from JSON.
  factory UnknownDreamInput.fromJson(Map<String, dynamic> json) {
    return UnknownDreamInput(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDreamInput &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownDreamInput(rawJson: $rawJson)';
}
