import 'package:meta/meta.dart';

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
  });

  /// Creates a [Container] from JSON.
  factory Container.fromJson(Map<String, dynamic> json) {
    return Container(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'container',
      name: json['name'] as String,
      createdAt: json['created_at'] as int,
      status: json['status'] as String,
      lastActiveAt: json['last_active_at'] as int?,
      expiresAfter: json['expires_after'] != null
          ? ContainerExpiration.fromJson(
              json['expires_after'] as Map<String, dynamic>,
            )
          : null,
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

  /// Status of the container (e.g., active, deleted).
  final String status;

  /// Unix timestamp (in seconds) when the container was last active.
  final int? lastActiveAt;

  /// Container expiration configuration.
  final ContainerExpiration? expiresAfter;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// The last active time as a DateTime, if available.
  DateTime? get lastActiveAtDateTime => lastActiveAt != null
      ? DateTime.fromMillisecondsSinceEpoch(lastActiveAt! * 1000)
      : null;

  /// Whether the container is active.
  bool get isActive => status == 'active';

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'name': name,
    'created_at': createdAt,
    'status': status,
    if (lastActiveAt != null) 'last_active_at': lastActiveAt,
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Container && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Container(id: $id, name: $name, status: $status)';
}

/// A list of containers.
@immutable
class ContainerList {
  /// Creates a [ContainerList].
  const ContainerList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [ContainerList] from JSON.
  factory ContainerList.fromJson(Map<String, dynamic> json) {
    return ContainerList(
      object: json['object'] as String? ?? 'list',
      data: (json['data'] as List<dynamic>)
          .map((e) => Container.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  /// The object type, which is always `list`.
  final String object;

  /// The list of containers.
  final List<Container> data;

  /// The ID of the first container in the list, or null if empty.
  final String? firstId;

  /// The ID of the last container in the list, or null if empty.
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(object, data.length);

  @override
  String toString() => 'ContainerList(${data.length} containers)';
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteContainerResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, deleted);

  @override
  String toString() => 'DeleteContainerResponse(id: $id, deleted: $deleted)';
}

/// Container expiration configuration.
@immutable
class ContainerExpiration {
  /// Creates a [ContainerExpiration].
  const ContainerExpiration({required this.anchor, required this.minutes});

  /// Creates a [ContainerExpiration] from JSON.
  factory ContainerExpiration.fromJson(Map<String, dynamic> json) {
    return ContainerExpiration(
      anchor: json['anchor'] as String,
      minutes: json['minutes'] as int,
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
