import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'container_json_helpers.dart';
import 'container_memory_limit.dart';
import 'container_network_policy.dart';

/// A container for isolated execution environments.
///
/// Containers provide isolated environments for running code
/// with access to files and dependencies.
///
/// ## Example
///
/// ```dart
/// final container = await client.containers.retrieve('container-abc123');
/// print('Name: ${container.name}');
/// print('Status: ${container.status}');
/// ```
@immutable
class Container {
  /// Creates a [Container].
  const Container({
    required this.id,
    required this.object,
    required this.name,
    required this.createdAt,
    required this.status,
    this.lastActiveAt,
    this.expiresAfter,
    this.memoryLimit,
    this.networkPolicy,
  });

  /// Creates a [Container] from JSON.
  factory Container.fromJson(Map<String, dynamic> json) {
    final expiration = optionalContainerMap(json, 'expires_after', 'Container');
    final memory = optionalContainerString(json, 'memory_limit', 'Container');
    final policy = optionalContainerMap(json, 'network_policy', 'Container');
    return Container(
      id: requireContainerString(json['id'], 'Container.id'),
      object: requireContainerString(json['object'], 'Container.object'),
      name: requireContainerString(json['name'], 'Container.name'),
      createdAt: requireContainerInt(
        json['created_at'],
        'Container.created_at',
      ),
      status: requireContainerString(json['status'], 'Container.status'),
      lastActiveAt: optionalContainerInt(json, 'last_active_at', 'Container'),
      expiresAfter: expiration == null
          ? null
          : ContainerExpirationInfo.fromJson(expiration),
      memoryLimit: memory == null
          ? null
          : ContainerMemoryLimit.fromJson(memory),
      networkPolicy: policy == null
          ? null
          : ContainerNetworkPolicyInfo.fromJson(policy),
    );
  }

  /// Unique identifier for the container.
  final String id;

  /// The type of this object.
  final String object;

  /// Name of the container.
  final String name;

  /// Unix timestamp (in seconds) when the container was created.
  final int createdAt;

  /// Status of the container (e.g., running, active, deleted).
  final String status;

  /// Unix timestamp (in seconds) when the container was last active.
  final int? lastActiveAt;

  /// Container expiration configuration.
  final ContainerExpirationInfo? expiresAfter;

  /// The memory limit configured for the container.
  final ContainerMemoryLimit? memoryLimit;

  /// The returned network policy, which does not contain domain secrets.
  final ContainerNetworkPolicyInfo? networkPolicy;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// The last active time as a DateTime, if available.
  DateTime? get lastActiveAtDateTime => lastActiveAt != null
      ? DateTime.fromMillisecondsSinceEpoch(lastActiveAt! * 1000)
      : null;

  /// Whether the container is active.
  bool get isActive => status == 'running' || status == 'active';

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'name': name,
    'created_at': createdAt,
    'status': status,
    if (lastActiveAt != null) 'last_active_at': lastActiveAt,
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
    if (memoryLimit != null) 'memory_limit': memoryLimit!.toJson(),
    if (networkPolicy != null) 'network_policy': networkPolicy!.toJson(),
  };

  /// Creates a copy with replaced fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  Container copyWith({
    String? id,
    String? object,
    String? name,
    int? createdAt,
    String? status,
    Object? lastActiveAt = unsetCopyWithValue,
    Object? expiresAfter = unsetCopyWithValue,
    Object? memoryLimit = unsetCopyWithValue,
    Object? networkPolicy = unsetCopyWithValue,
  }) => Container(
    id: id ?? this.id,
    object: object ?? this.object,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    status: status ?? this.status,
    lastActiveAt: lastActiveAt == unsetCopyWithValue
        ? this.lastActiveAt
        : lastActiveAt as int?,
    expiresAfter: expiresAfter == unsetCopyWithValue
        ? this.expiresAfter
        : expiresAfter as ContainerExpirationInfo?,
    memoryLimit: memoryLimit == unsetCopyWithValue
        ? this.memoryLimit
        : memoryLimit as ContainerMemoryLimit?,
    networkPolicy: networkPolicy == unsetCopyWithValue
        ? this.networkPolicy
        : networkPolicy as ContainerNetworkPolicyInfo?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Container &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          name == other.name &&
          createdAt == other.createdAt &&
          status == other.status &&
          lastActiveAt == other.lastActiveAt &&
          expiresAfter == other.expiresAfter &&
          memoryLimit == other.memoryLimit &&
          networkPolicy == other.networkPolicy;

  @override
  int get hashCode => Object.hash(
    id,
    object,
    name,
    createdAt,
    status,
    lastActiveAt,
    expiresAfter,
    memoryLimit,
    networkPolicy,
  );

  @override
  String toString() =>
      'Container(id: $id, object: $object, name: $name, createdAt: $createdAt, '
      'status: $status, lastActiveAt: $lastActiveAt, expiresAfter: $expiresAfter, '
      'memoryLimit: $memoryLimit, networkPolicy: $networkPolicy)';
}

/// A list of containers.
@immutable
class ContainerList {
  /// Creates a [ContainerList].
  ///
  /// Takes a defensive, unmodifiable copy of [data].
  ContainerList({
    required this.object,
    required List<Container> data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  }) : data = List.unmodifiable(data);

  /// Creates a [ContainerList] from JSON.
  factory ContainerList.fromJson(Map<String, dynamic> json) {
    return ContainerList(
      object: requireContainerLiteral(
        json['object'],
        'list',
        'ContainerList.object',
      ),
      data: parseContainerObjects(
        json['data'],
        Container.fromJson,
        'ContainerList.data',
      ),
      firstId: json['first_id'] == null
          ? null
          : requireContainerString(json['first_id'], 'ContainerList.first_id'),
      lastId: json['last_id'] == null
          ? null
          : requireContainerString(json['last_id'], 'ContainerList.last_id'),
      hasMore: requireContainerBool(json['has_more'], 'ContainerList.has_more'),
    );
  }

  /// The object type, which is always `list`.
  final String object;

  /// The list of containers.
  final List<Container> data;

  /// The ID of the first container in the list, or null if empty.
  ///
  /// Accepts omitted or null pagination IDs for empty lists and compatible
  /// providers, although the canonical schema requires a string.
  final String? firstId;

  /// The ID of the last container in the list, or null if empty.
  ///
  /// Accepts omitted or null pagination IDs for empty lists and compatible
  /// providers, although the canonical schema requires a string.
  final String? lastId;

  /// Whether there are more containers available.
  final bool hasMore;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of containers.
  int get length => data.length;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((c) => c.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  /// Creates a copy with replaced fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  ContainerList copyWith({
    String? object,
    List<Container>? data,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
    bool? hasMore,
  }) => ContainerList(
    object: object ?? this.object,
    data: data ?? this.data,
    firstId: firstId == unsetCopyWithValue ? this.firstId : firstId as String?,
    lastId: lastId == unsetCopyWithValue ? this.lastId : lastId as String?,
    hasMore: hasMore ?? this.hasMore,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listsEqual(data, other.data) &&
          firstId == other.firstId &&
          lastId == other.lastId &&
          hasMore == other.hasMore;

  @override
  int get hashCode =>
      Object.hash(object, listHash(data), firstId, lastId, hasMore);

  @override
  String toString() =>
      'ContainerList(object: $object, data: ${data.length} containers, '
      'firstId: $firstId, lastId: $lastId, hasMore: $hasMore)';
}

/// The response from deleting a container.
@immutable
class DeleteContainerResponse {
  /// Creates a [DeleteContainerResponse].
  const DeleteContainerResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteContainerResponse] from JSON.
  factory DeleteContainerResponse.fromJson(Map<String, dynamic> json) {
    return DeleteContainerResponse(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'container.deleted',
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted container.
  final String id;

  /// The object type.
  final String object;

  /// Whether the container was successfully deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  /// Creates a copy with replaced fields.
  DeleteContainerResponse copyWith({
    String? id,
    String? object,
    bool? deleted,
  }) => DeleteContainerResponse(
    id: id ?? this.id,
    object: object ?? this.object,
    deleted: deleted ?? this.deleted,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteContainerResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, object, deleted);

  @override
  String toString() =>
      'DeleteContainerResponse(id: $id, object: $object, deleted: $deleted)';
}

/// Container expiration configuration.
@immutable
class ContainerExpiration {
  /// Creates a [ContainerExpiration].
  const ContainerExpiration({required this.anchor, required this.minutes});

  /// Creates a [ContainerExpiration] from JSON.
  factory ContainerExpiration.fromJson(Map<String, dynamic> json) {
    return ContainerExpiration(
      anchor: requireContainerLiteral(
        json['anchor'],
        'last_active_at',
        'ContainerExpiration.anchor',
      ),
      minutes: requireContainerInt(
        json['minutes'],
        'ContainerExpiration.minutes',
      ),
    );
  }

  /// Time anchor for the expiration time.
  ///
  /// Currently only 'last_active_at' is supported.
  final String anchor;

  /// Number of minutes after the anchor time when the container expires.
  final int minutes;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'anchor': anchor, 'minutes': minutes};

  /// Creates a copy with replaced fields.
  ContainerExpiration copyWith({String? anchor, int? minutes}) =>
      ContainerExpiration(
        anchor: anchor ?? this.anchor,
        minutes: minutes ?? this.minutes,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerExpiration &&
          runtimeType == other.runtimeType &&
          anchor == other.anchor &&
          minutes == other.minutes;

  @override
  int get hashCode => Object.hash(anchor, minutes);

  @override
  String toString() =>
      'ContainerExpiration(anchor: $anchor, minutes: $minutes)';
}

/// Expiration information returned for a container.
///
/// Unlike request [ContainerExpiration], each member may be omitted
/// independently, including when the response contains an empty object.
@immutable
class ContainerExpirationInfo {
  /// Creates a [ContainerExpirationInfo].
  const ContainerExpirationInfo({this.anchor, this.minutes});

  /// Creates a [ContainerExpirationInfo] from JSON.
  factory ContainerExpirationInfo.fromJson(Map<String, dynamic> json) =>
      ContainerExpirationInfo(
        anchor: json.containsKey('anchor')
            ? requireContainerLiteral(
                json['anchor'],
                'last_active_at',
                'ContainerExpirationInfo.anchor',
              )
            : null,
        minutes: optionalContainerInt(
          json,
          'minutes',
          'ContainerExpirationInfo',
        ),
      );

  /// The reference point for the expiration, if returned.
  final String? anchor;

  /// Minutes after the reference point when the container expires, if returned.
  final int? minutes;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (anchor != null) 'anchor': anchor,
    if (minutes != null) 'minutes': minutes,
  };

  /// Creates a copy with replaced fields.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  ContainerExpirationInfo copyWith({
    Object? anchor = unsetCopyWithValue,
    Object? minutes = unsetCopyWithValue,
  }) => ContainerExpirationInfo(
    anchor: anchor == unsetCopyWithValue ? this.anchor : anchor as String?,
    minutes: minutes == unsetCopyWithValue ? this.minutes : minutes as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerExpirationInfo &&
          runtimeType == other.runtimeType &&
          anchor == other.anchor &&
          minutes == other.minutes;

  @override
  int get hashCode => Object.hash(anchor, minutes);

  @override
  String toString() =>
      'ContainerExpirationInfo(anchor: $anchor, minutes: $minutes)';
}
