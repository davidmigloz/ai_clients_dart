import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/openai_client.dart';
import '../models/containers/containers.dart';
import 'base_resource.dart';

/// Resource for container operations.
///
/// Containers provide isolated execution environments for running code
/// with access to files and dependencies.
///
/// Access this resource through [OpenAIClient.containers].
///
/// ## Example
///
/// ```dart
/// // Create a container
/// final container = await client.containers.create(
///   CreateContainerRequest(
///     name: 'my-container',
///     fileIds: ['file-abc123'],
///   ),
/// );
///
/// // List container files
/// final files = await client.containers.files.list(container.id);
///
/// // Clean up
/// await client.containers.delete(container.id);
/// ```
class ContainersResource extends BaseResource {
  /// Creates a [ContainersResource] with the given client.
  ContainersResource(super.client);

  static const _endpoint = '/containers';

  ContainerFilesResource? _files;

  /// Container files sub-resource.
  ContainerFilesResource get files => _files ??= ContainerFilesResource(client);

  /// Lists all containers.
  ///
  /// ## Parameters
  ///
  /// - [limit] - Maximum number of containers to return.
  /// - [order] - Sort order (asc or desc).
  /// - [after] - Cursor for pagination (get containers after this ID).
  /// - [before] - Cursor for pagination (get containers before this ID).
  ///
  /// ## Returns
  ///
  /// A [ContainerList] containing the containers.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final containers = await client.containers.list(limit: 10);
  ///
  /// for (final container in containers.data) {
  ///   print('${container.name}: ${container.status}');
  /// }
  /// ```
  Future<ContainerList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return ContainerList.fromJson(json);
  }

  /// Creates a new container.
  ///
  /// ## Parameters
  ///
  /// - [request] - The container creation request.
  ///
  /// ## Returns
  ///
  /// A [Container] representing the created container.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final container = await client.containers.create(
  ///   CreateContainerRequest(
  ///     name: 'my-container',
  ///     fileIds: ['file-abc123', 'file-def456'],
  ///     expiresAfter: ContainerExpiration(
  ///       anchor: 'last_active_at',
  ///       minutes: 60,
  ///     ),
  ///   ),
  /// );
  ///
  /// print('Created container: ${container.id}');
  /// ```
  Future<Container> create(CreateContainerRequest request) async {
    final json = await postJson(_endpoint, body: request.toJson());
    return Container.fromJson(json);
  }

  /// Retrieves a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Container] with the current status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final container = await client.containers.retrieve('container-abc123');
  /// print('Name: ${container.name}');
  /// print('Status: ${container.status}');
  /// ```
  Future<Container> retrieve(String containerId) async {
    final json = await getJson('$_endpoint/$containerId');
    return Container.fromJson(json);
  }

  /// Deletes a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteContainerResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.containers.delete('container-abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteContainerResponse> delete(String containerId) async {
    final json = await deleteJson('$_endpoint/$containerId');
    return DeleteContainerResponse.fromJson(json);
  }
}

/// Resource for container file operations.
///
/// Container files are files that have been added to a container
/// for use in isolated execution environments.
class ContainerFilesResource extends BaseResource {
  /// Creates a [ContainerFilesResource] with the given client.
  ContainerFilesResource(super.client);

  /// Lists files in a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container.
  /// - [limit] - Maximum number of files to return.
  /// - [order] - Sort order (asc or desc).
  /// - [after] - Cursor for pagination (get files after this ID).
  /// - [before] - Cursor for pagination (get files before this ID).
  ///
  /// ## Returns
  ///
  /// A [ContainerFileList] containing the files.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final files = await client.containers.files.list('container-abc123');
  ///
  /// for (final file in files.data) {
  ///   print('${file.path}: ${file.bytes} bytes');
  /// }
  /// ```
  Future<ContainerFileList> list(
    String containerId, {
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      '/containers/$containerId/files',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return ContainerFileList.fromJson(json);
  }

  /// Creates a file in a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container.
  /// - [bytes] - The file content as bytes.
  /// - [filename] - The path/filename for the file in the container.
  /// - [fileId] - Optional existing file ID to copy.
  ///
  /// ## Returns
  ///
  /// A [ContainerFile] representing the created file.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Upload new file
  /// final file = await client.containers.files.create(
  ///   'container-abc123',
  ///   bytes: File('data.json').readAsBytesSync(),
  ///   filename: '/app/data.json',
  /// );
  ///
  /// // Copy existing file
  /// final copied = await client.containers.files.create(
  ///   'container-abc123',
  ///   fileId: 'file-xyz789',
  /// );
  /// ```
  Future<ContainerFile> create(
    String containerId, {
    List<int>? bytes,
    String? filename,
    String? fileId,
  }) async {
    final url = client.buildUrl('/containers/$containerId/files');
    final httpRequest = http.MultipartRequest('POST', url);

    if (bytes != null && filename != null) {
      httpRequest.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      );
    }
    if (fileId != null) {
      httpRequest.fields['file_id'] = fileId;
    }

    final response = await client.postMultipart(request: httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ContainerFile.fromJson(json);
  }

  /// Retrieves a file from a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container.
  /// - [fileId] - The ID of the file.
  ///
  /// ## Returns
  ///
  /// A [ContainerFile] with the file metadata.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final file = await client.containers.files.retrieve(
  ///   'container-abc123',
  ///   'file-xyz789',
  /// );
  /// print('Path: ${file.path}');
  /// ```
  Future<ContainerFile> retrieve(String containerId, String fileId) async {
    final json = await getJson('/containers/$containerId/files/$fileId');
    return ContainerFile.fromJson(json);
  }

  /// Deletes a file from a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container.
  /// - [fileId] - The ID of the file.
  ///
  /// ## Returns
  ///
  /// A [DeleteContainerFileResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.containers.files.delete(
  ///   'container-abc123',
  ///   'file-xyz789',
  /// );
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteContainerFileResponse> delete(
    String containerId,
    String fileId,
  ) async {
    final json = await deleteJson('/containers/$containerId/files/$fileId');
    return DeleteContainerFileResponse.fromJson(json);
  }

  /// Retrieves the content of a file from a container.
  ///
  /// ## Parameters
  ///
  /// - [containerId] - The ID of the container.
  /// - [fileId] - The ID of the file.
  ///
  /// ## Returns
  ///
  /// The file content as bytes.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final content = await client.containers.files.retrieveContent(
  ///   'container-abc123',
  ///   'file-xyz789',
  /// );
  /// File('output.txt').writeAsBytesSync(content);
  /// ```
  Future<Uint8List> retrieveContent(String containerId, String fileId) async {
    // ErrorInterceptor handles error responses, so we can return bodyBytes directly
    final response = await client.get(
      '/containers/$containerId/files/$fileId/content',
    );
    return response.bodyBytes;
  }
}
