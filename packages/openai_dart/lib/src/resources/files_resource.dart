import 'dart:convert';

import 'package:http/http.dart' as http;

import '../client/openai_client.dart';
import '../errors/exceptions.dart';
import '../models/files/files.dart';
import 'base_resource.dart';

/// Resource for file operations.
///
/// Files are used to upload documents that can be used with the
/// Assistants API, Fine-tuning, and Batch API.
///
/// Access this resource through [OpenAIClient.files].
///
/// ## Example
///
/// ```dart
/// // Upload a file
/// final file = await client.files.upload(
///   bytes: fileBytes,
///   filename: 'training.jsonl',
///   purpose: FilePurpose.fineTune,
/// );
///
/// // List files
/// final files = await client.files.list();
/// ```
class FilesResource extends BaseResource {
  /// Creates a [FilesResource] with the given client.
  FilesResource(super.client);

  static const _endpoint = '/files';

  /// Lists all files that belong to the user's organization.
  ///
  /// ## Parameters
  ///
  /// - [purpose] - Only return files with the given purpose.
  /// - [limit] - Maximum number of files to return (1-10000, default 10000).
  /// - [order] - Sort order (asc or desc, default desc).
  /// - [after] - Cursor for pagination.
  ///
  /// ## Returns
  ///
  /// A [FileList] containing the files.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final files = await client.files.list(
  ///   purpose: FilePurpose.fineTune,
  /// );
  ///
  /// for (final file in files.data) {
  ///   print('${file.filename}: ${file.bytes} bytes');
  /// }
  /// ```
  Future<FileList> list({
    FilePurpose? purpose,
    int? limit,
    String? order,
    String? after,
  }) async {
    final queryParams = <String, String>{};
    if (purpose != null) queryParams['purpose'] = purpose.toJson();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return FileList.fromJson(json);
  }

  /// Uploads a file to OpenAI.
  ///
  /// ## Parameters
  ///
  /// - [bytes] - The file content as bytes.
  /// - [filename] - The filename with extension.
  /// - [purpose] - The intended purpose of the file.
  ///
  /// ## Returns
  ///
  /// A [FileObject] representing the uploaded file.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final file = await client.files.upload(
  ///   bytes: File('training.jsonl').readAsBytesSync(),
  ///   filename: 'training.jsonl',
  ///   purpose: FilePurpose.fineTune,
  /// );
  ///
  /// print('Uploaded: ${file.id}');
  /// ```
  Future<FileObject> upload({
    required List<int> bytes,
    required String filename,
    required FilePurpose purpose,
  }) async {
    final url = Uri.parse('${client.config.baseUrl}$_endpoint');
    final httpRequest = http.MultipartRequest('POST', url);

    _addHeaders(httpRequest);

    httpRequest.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    httpRequest.fields['purpose'] = purpose.toJson();

    final response = await httpRequest.send();
    final body = await response.stream.bytesToString();

    if (response.statusCode >= 400) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      throw createApiException(
        statusCode: response.statusCode,
        message: error?['message'] as String? ?? 'Unknown error',
        type: error?['type'] as String?,
        code: error?['code'] as String?,
        body: json,
      );
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    return FileObject.fromJson(json);
  }

  /// Retrieves information about a specific file.
  ///
  /// ## Parameters
  ///
  /// - [fileId] - The ID of the file to retrieve.
  ///
  /// ## Returns
  ///
  /// A [FileObject] with the file information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final file = await client.files.retrieve('file-abc123');
  /// print('Status: ${file.status}');
  /// ```
  Future<FileObject> retrieve(String fileId) async {
    final json = await getJson('$_endpoint/$fileId');
    return FileObject.fromJson(json);
  }

  /// Deletes a file.
  ///
  /// ## Parameters
  ///
  /// - [fileId] - The ID of the file to delete.
  ///
  /// ## Returns
  ///
  /// A [DeleteFileResponse] confirming the deletion.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.files.delete('file-abc123');
  /// print('Deleted: ${result.deleted}');
  /// ```
  Future<DeleteFileResponse> delete(String fileId) async {
    final json = await deleteJson('$_endpoint/$fileId');
    return DeleteFileResponse.fromJson(json);
  }

  /// Retrieves the content of a file.
  ///
  /// ## Parameters
  ///
  /// - [fileId] - The ID of the file to download.
  ///
  /// ## Returns
  ///
  /// The file content as a string.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final content = await client.files.retrieveContent('file-abc123');
  /// print(content);
  /// ```
  Future<String> retrieveContent(String fileId) async {
    final response = await client.get('$_endpoint/$fileId/content');

    if (response.statusCode >= 400) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      throw createApiException(
        statusCode: response.statusCode,
        message: error?['message'] as String? ?? 'Unknown error',
        type: error?['type'] as String?,
        code: error?['code'] as String?,
        body: json,
      );
    }

    return response.body;
  }

  void _addHeaders(http.MultipartRequest request) {
    if (client.config.authProvider case final authProvider?) {
      request.headers.addAll(authProvider.getHeaders());
    }
    if (client.config.organization case final org?) {
      request.headers['OpenAI-Organization'] = org;
    }
    if (client.config.project case final proj?) {
      request.headers['OpenAI-Project'] = proj;
    }
  }
}
