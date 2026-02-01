import 'package:meta/meta.dart';

import 'container.dart';

/// Request to create a new container.
///
/// ## Example
///
/// ```dart
/// final container = await client.containers.create(
///   CreateContainerRequest(
///     name: 'my-container',
///     fileIds: ['file-abc123'],
///     expiresAfter: ContainerExpiration(
///       anchor: 'last_active_at',
///       minutes: 60,
///     ),
///   ),
/// );
/// ```
@immutable
class CreateContainerRequest {
  /// Creates a [CreateContainerRequest].
  const CreateContainerRequest({this.name, this.fileIds, this.expiresAfter});

  /// Name of the container to create.
  final String? name;

  /// IDs of files to copy to the container.
  final List<String>? fileIds;

  /// Container expiration time configuration.
  final ContainerExpiration? expiresAfter;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (fileIds != null) 'file_ids': fileIds,
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateContainerRequest &&
          runtimeType == other.runtimeType &&
          name == other.name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'CreateContainerRequest(name: $name)';
}
