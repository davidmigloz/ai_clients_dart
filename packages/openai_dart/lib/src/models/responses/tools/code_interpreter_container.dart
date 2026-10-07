import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../../containers/container_json_helpers.dart';
import '../../containers/container_memory_limit.dart';
import '../../containers/container_network_policy.dart';

export '../../containers/container_memory_limit.dart';
export '../../containers/container_network_policy.dart';

/// Container configuration for the code interpreter tool.
///
/// Use an existing container ID or an automatic configuration. Skills are
/// configured through standalone creation, rather than the automatic shape.
sealed class CodeInterpreterContainer {
  /// Creates a [CodeInterpreterContainer].
  const CodeInterpreterContainer();

  /// Creates a container from JSON, preserving future object variants.
  factory CodeInterpreterContainer.fromJson(Object? json) {
    if (json is String) return CodeInterpreterContainerId(json);
    final map = requireContainerMap(json, 'CodeInterpreterContainer');
    final type = requireContainerString(
      map['type'],
      'CodeInterpreterContainer.type',
    );
    return switch (type) {
      'auto' => CodeInterpreterContainerAuto.fromJson(map),
      _ => UnknownCodeInterpreterContainer(map),
    };
  }

  /// Uses an existing container by ID.
  static CodeInterpreterContainerId id(String id) =>
      CodeInterpreterContainerId(id);

  /// Automatically creates a container with optional files and settings.
  static CodeInterpreterContainerAuto auto({
    List<String>? fileIds,
    ContainerMemoryLimit? memoryLimit,
    ContainerNetworkPolicy? networkPolicy,
  }) => CodeInterpreterContainerAuto(
    fileIds: fileIds,
    memoryLimit: memoryLimit,
    networkPolicy: networkPolicy,
  );

  /// Converts to JSON.
  Object toJson();
}

/// Uses an existing container by ID.
@immutable
class CodeInterpreterContainerId extends CodeInterpreterContainer {
  /// Creates an existing-container reference.
  const CodeInterpreterContainerId(this.id);

  /// Creates a reference from a JSON string.
  factory CodeInterpreterContainerId.fromJson(Object? json) =>
      CodeInterpreterContainerId(
        requireContainerString(json, 'CodeInterpreterContainerId'),
      );

  /// The container ID.
  final String id;

  @override
  String toJson() => id;

  /// Creates a copy with a replaced container ID.
  CodeInterpreterContainerId copyWith({String? id}) =>
      CodeInterpreterContainerId(id ?? this.id);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterContainerId &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CodeInterpreterContainerId($id)';
}

/// Automatically creates a container for code execution.
@immutable
class CodeInterpreterContainerAuto extends CodeInterpreterContainer {
  /// Creates an automatic configuration, snapshotting optional file IDs.
  CodeInterpreterContainerAuto({
    List<String>? fileIds,
    this.memoryLimit,
    this.networkPolicy,
  }) : fileIds = fileIds == null ? null : List.unmodifiable(fileIds);

  /// Creates an automatic configuration from JSON.
  factory CodeInterpreterContainerAuto.fromJson(Map<String, dynamic> json) {
    requireContainerType(json, 'auto', 'CodeInterpreterContainerAuto');
    final networkPolicy = optionalContainerMap(
      json,
      'network_policy',
      'CodeInterpreterContainerAuto',
    );
    return CodeInterpreterContainerAuto(
      fileIds: optionalContainerStrings(
        json,
        'file_ids',
        'CodeInterpreterContainerAuto',
      ),
      memoryLimit: json['memory_limit'] == null
          ? null
          : ContainerMemoryLimit.fromJson(
              requireContainerString(
                json['memory_limit'],
                'CodeInterpreterContainerAuto.memory_limit',
              ),
            ),
      networkPolicy: networkPolicy == null
          ? null
          : ContainerNetworkPolicy.fromJson(networkPolicy),
    );
  }

  /// Uploaded file IDs made available to code. The server permits at most 50.
  final List<String>? fileIds;

  /// Memory tier, such as [ContainerMemoryLimit.gb4].
  ///
  /// An explicit JSON null is normalized to omission when parsed.
  final ContainerMemoryLimit? memoryLimit;

  /// Optional outbound network access policy.
  final ContainerNetworkPolicy? networkPolicy;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'auto',
    if (fileIds != null) 'file_ids': fileIds,
    if (memoryLimit != null) 'memory_limit': memoryLimit!.toJson(),
    if (networkPolicy != null) 'network_policy': networkPolicy!.toJson(),
  };

  /// Creates a copy; pass null to explicitly clear optional settings.
  CodeInterpreterContainerAuto copyWith({
    Object? fileIds = unsetCopyWithValue,
    Object? memoryLimit = unsetCopyWithValue,
    Object? networkPolicy = unsetCopyWithValue,
  }) => CodeInterpreterContainerAuto(
    fileIds: fileIds == unsetCopyWithValue
        ? this.fileIds
        : fileIds == null
        ? null
        : List<String>.from(fileIds as List),
    memoryLimit: memoryLimit == unsetCopyWithValue
        ? this.memoryLimit
        : memoryLimit as ContainerMemoryLimit?,
    networkPolicy: networkPolicy == unsetCopyWithValue
        ? this.networkPolicy
        : networkPolicy as ContainerNetworkPolicy?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterContainerAuto &&
          runtimeType == other.runtimeType &&
          listsEqual(fileIds, other.fileIds) &&
          memoryLimit == other.memoryLimit &&
          networkPolicy == other.networkPolicy;

  @override
  int get hashCode =>
      Object.hash(listHash(fileIds), memoryLimit, networkPolicy);

  @override
  String toString() =>
      'CodeInterpreterContainerAuto(fileIds: $fileIds, '
      'memoryLimit: $memoryLimit, networkPolicy: $networkPolicy)';
}

/// A future container variant retaining its complete immutable JSON payload.
@immutable
class UnknownCodeInterpreterContainer extends CodeInterpreterContainer {
  /// Creates an unknown variant with a defensive JSON snapshot.
  UnknownCodeInterpreterContainer(Map<String, dynamic> rawJson)
    : type = requireContainerString(
        rawJson['type'],
        'UnknownCodeInterpreterContainer.type',
      ),
      rawJson = freezeContainerJsonMap(rawJson);

  /// Creates an unknown container variant from JSON.
  factory UnknownCodeInterpreterContainer.fromJson(Map<String, dynamic> json) =>
      UnknownCodeInterpreterContainer(json);

  /// The unfamiliar API discriminator.
  final String type;

  /// The recursively unmodifiable original JSON.
  final Map<String, dynamic> rawJson;

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(rawJson);

  /// Creates a copy with a replaced raw payload.
  UnknownCodeInterpreterContainer copyWith({Map<String, dynamic>? rawJson}) =>
      UnknownCodeInterpreterContainer(rawJson ?? this.rawJson);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownCodeInterpreterContainer &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => Object.hash(runtimeType, mapDeepHashCode(rawJson));

  @override
  String toString() => 'UnknownCodeInterpreterContainer(type: $type)';
}
