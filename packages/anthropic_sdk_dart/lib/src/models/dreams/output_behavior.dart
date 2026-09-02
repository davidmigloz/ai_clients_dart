import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Where a dream job writes its consolidated memories.
///
/// Variants:
/// - [OutputBehaviorCreateNew] — the default: create a new output memory
///   store.
/// - [OutputBehaviorUpdateExisting] — write into an existing memory store.
/// - [UnknownOutputBehavior] — unrecognized behavior, for forward
///   compatibility.
sealed class OutputBehavior {
  const OutputBehavior();

  /// Creates an [OutputBehavior] from JSON.
  ///
  /// Dispatches on the `type` discriminator; unrecognized values fall back to
  /// [UnknownOutputBehavior].
  factory OutputBehavior.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'create_new' => OutputBehaviorCreateNew.fromJson(json),
      'update_existing' => OutputBehaviorUpdateExisting.fromJson(json),
      _ => UnknownOutputBehavior(rawJson: json),
    };
  }

  /// Creates an [OutputBehaviorCreateNew].
  factory OutputBehavior.createNew() => const OutputBehaviorCreateNew();

  /// Creates an [OutputBehaviorUpdateExisting] targeting [memoryStoreId].
  factory OutputBehavior.updateExisting(String memoryStoreId) =>
      OutputBehaviorUpdateExisting(memoryStoreId: memoryStoreId);

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The default destination: the job creates a new output memory store as a
/// clone of the `memory_store` input and writes the consolidated memories
/// into it. The input store is never mutated.
@immutable
class OutputBehaviorCreateNew extends OutputBehavior {
  /// The behavior type, always 'create_new'.
  String get type => 'create_new';

  /// Creates an [OutputBehaviorCreateNew].
  const OutputBehaviorCreateNew();

  /// Creates an [OutputBehaviorCreateNew] from JSON.
  factory OutputBehaviorCreateNew.fromJson(Map<String, dynamic> _) {
    return const OutputBehaviorCreateNew();
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputBehaviorCreateNew && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'OutputBehaviorCreateNew()';
}

/// The job writes the consolidated memories into this existing memory store
/// instead of creating one. In EAP the store must be the job's own
/// `memory_store` input, so the job consolidates the store in place.
@immutable
class OutputBehaviorUpdateExisting extends OutputBehavior {
  /// The behavior type, always 'update_existing'.
  String get type => 'update_existing';

  /// ID of the existing memory store to write into.
  final String memoryStoreId;

  /// Creates an [OutputBehaviorUpdateExisting].
  const OutputBehaviorUpdateExisting({required this.memoryStoreId});

  /// Creates an [OutputBehaviorUpdateExisting] from JSON.
  factory OutputBehaviorUpdateExisting.fromJson(Map<String, dynamic> json) {
    return OutputBehaviorUpdateExisting(
      memoryStoreId: json['memory_store_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'memory_store_id': memoryStoreId,
  };

  /// Creates a copy with replaced values.
  OutputBehaviorUpdateExisting copyWith({String? memoryStoreId}) {
    return OutputBehaviorUpdateExisting(
      memoryStoreId: memoryStoreId ?? this.memoryStoreId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputBehaviorUpdateExisting &&
          runtimeType == other.runtimeType &&
          memoryStoreId == other.memoryStoreId;

  @override
  int get hashCode => memoryStoreId.hashCode;

  @override
  String toString() =>
      'OutputBehaviorUpdateExisting(memoryStoreId: $memoryStoreId)';
}

/// Unrecognized [OutputBehavior] type — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownOutputBehavior extends OutputBehavior {
  /// The raw JSON.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownOutputBehavior].
  const UnknownOutputBehavior({required this.rawJson});

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownOutputBehavior &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownOutputBehavior(rawJson: $rawJson)';
}
