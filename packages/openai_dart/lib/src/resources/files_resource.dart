import 'dart:convert';

import 'package:http/http.dart' as http;

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
class FilesResource extends ResourceBase {
  /// Creates a [FilesResource].
  FilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

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
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (purpose != null) queryParams['purpose'] = purpose.toJson();
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return FileList.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: filename),
    );
    request.fields['purpose'] = purpose.toJson();
    request.headers.addAll(requestBuilder.buildMultipartHeaders());

    final response = await interceptorChain.execute(request);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$fileId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return FileObject.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$fileId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteFileResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$fileId/content');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    // ErrorInterceptor handles error responses, so we can return body directly
    final response = await interceptorChain.execute(httpRequest);
    return response.body;
  }
}
