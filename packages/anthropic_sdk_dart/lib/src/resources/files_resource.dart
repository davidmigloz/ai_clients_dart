import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/request_auth.dart';
import '../models/files/file_delete_response.dart';
import '../models/files/file_list_response.dart';
import '../models/files/file_metadata.dart';
import '../platform/local_file.dart';
import '../utils/path_segment.dart';
import 'base_resource.dart';
import 'media_type.dart';
import 'resource_request.dart';

/// Resource for the Files API.
///
/// Provides access to file upload, listing, and management operations. Files
/// can be used as part of message content (e.g., for vision or document
/// understanding).
///
/// The Files API is generally available. Use `betas` to opt into additional
/// beta features and `workspaceId` for request-level workspace routing.
class FilesResource extends ResourceBase {
  /// Creates a [FilesResource].
  FilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Uploads a file from a file path.
  ///
  /// This method requires a platform with `dart:io`. Use [uploadBytes] when
  /// the application obtains the file from a browser.
  ///
  /// The [filePath] is the path to the file to upload.
  /// The [mimeType] is optional; if not provided, it will be inferred
  /// from the file extension.
  /// The [expiresInSeconds] sets the file's expiration, in seconds from
  /// upload time. Must be between 3600 (one hour) and 7776000 (ninety days).
  /// Omit to use the platform default (the file never expires).
  ///
  /// Returns a [FileMetadata] with information about the uploaded file.
  ///
  /// Example:
  /// ```dart
  /// final file = await client.files.upload(
  ///   filePath: '/path/to/image.jpg',
  ///   mimeType: 'image/jpeg',
  ///   expiresInSeconds: 86400,
  /// );
  /// print('Uploaded file: ${file.id}, expires at: ${file.expiresAt}');
  /// ```
  Future<FileMetadata> upload({
    required String filePath,
    String? mimeType,
    int? expiresInSeconds,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final (bytes: bytes, name: fileName) = await readLocalFile(filePath);

    return uploadBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      expiresInSeconds: expiresInSeconds,
      betas: betas,
      workspaceId: workspaceId,
    );
  }

  /// Uploads a file from bytes.
  ///
  /// The [bytes] is the file content.
  /// The [fileName] is the name to use for the file.
  /// The [mimeType] is optional; if not provided, it will be inferred
  /// from the file extension.
  /// The [expiresInSeconds] sets the file's expiration, in seconds from
  /// upload time. Must be between 3600 (one hour) and 7776000 (ninety days).
  /// Omit to use the platform default (the file never expires).
  ///
  /// Returns a [FileMetadata] with information about the uploaded file.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await someFile.readAsBytes();
  /// final file = await client.files.uploadBytes(
  ///   bytes: bytes,
  ///   fileName: 'document.pdf',
  ///   mimeType: 'application/pdf',
  ///   expiresInSeconds: 3600,
  /// );
  /// ```
  Future<FileMetadata> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
    int? expiresInSeconds,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    if (expiresInSeconds != null &&
        (expiresInSeconds < 3600 || expiresInSeconds > 7776000)) {
      throw ArgumentError.value(
        expiresInSeconds,
        'expiresInSeconds',
        'must be between 3600 (one hour) and 7776000 (ninety days)',
      );
    }

    final inferredMimeType = mimeType ?? _inferMimeType(fileName);

    final uri = requestBuilder.buildUrl('/v1/files');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    )..removeWhere((name, _) => name.toLowerCase() == 'content-type');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: parseMediaTypeOrOctetStream(inferredMimeType),
        ),
      );
    if (expiresInSeconds != null) {
      request.fields['expires_in_seconds'] = expiresInSeconds.toString();
    }

    // Add authentication header
    await _applyAuthentication(request);
    ensureNotClosed?.call();

    final response = await sendResourceRequest(
      httpClient,
      request,
      timeout: config.timeout,
      ensureNotClosed: ensureNotClosed,
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return FileMetadata.fromJson(json);
  }

  /// Lists uploaded files.
  ///
  /// The [limit] specifies the maximum number of files to return (1-1000,
  /// default 20).
  /// The [page] is the opaque, `page_`-prefixed cursor from a previous
  /// response's [FileListResponse.nextPage]. Mutually exclusive with [ids].
  /// The [ids] restricts the result set to files whose id is in this list
  /// (at most 100 entries). When supplied, the response is always a single
  /// page ([FileListResponse.nextPage] is `null`) and is mutually exclusive
  /// with [page] and [limit].
  /// The [scopeId] filters by scope ID, returning only files associated with
  /// that scope (e.g., a session ID). This requires the Managed Agents beta.
  /// The current Managed Agents beta header is sent for scoped listings
  /// unless a Managed Agents beta is already configured.
  /// The [beforeId] and [afterId] cursors require the `files-api-2025-04-14`
  /// or `managed-agents-2026-04-01` beta header.
  /// They cannot be combined with [page] or [ids].
  /// The [betas] and [workspaceId] override configured routing for this call.
  ///
  /// Returns a [FileListResponse] with the list of files and pagination info.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.files.list(limit: 10);
  /// for (final file in response.data) {
  ///   print('${file.id}: ${file.filename}');
  /// }
  /// ```
  Future<FileListResponse> list({
    int? limit,
    String? page,
    List<String>? ids,
    String? scopeId,
    String? beforeId,
    String? afterId,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'ids[]': ?ids,
      'scope_id': ?scopeId,
      'before_id': ?beforeId,
      'after_id': ?afterId,
    };

    final url = requestBuilder.buildUrl(
      '/v1/files',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
    if (url.queryParameters.containsKey('scope_id')) {
      final selected =
          headers['anthropic-beta']
              ?.split(',')
              .map((beta) => beta.trim())
              .where((beta) => beta.isNotEmpty) ??
          const <String>[];
      if (!selected.any((beta) => beta.startsWith('managed-agents-'))) {
        headers['anthropic-beta'] = [
          ...selected,
          'managed-agents-2026-04-01',
        ].join(',');
      }
    }
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return FileListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Gets metadata for a specific file.
  ///
  /// The [fileId] is the unique identifier of the file.
  ///
  /// Returns a [FileMetadata] with the file's metadata.
  ///
  /// Example:
  /// ```dart
  /// final file = await client.files.retrieve(fileId: 'file_abc123');
  /// print('File size: ${file.sizeBytes} bytes');
  /// ```
  Future<FileMetadata> retrieve({
    required String fileId,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/files/${encodePathSegment(fileId, 'fileId')}',
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return FileMetadata.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a file.
  ///
  /// The [fileId] is the unique identifier of the file to delete.
  ///
  /// Returns a [FileDeleteResponse] confirming the deletion.
  ///
  /// Example:
  /// ```dart
  /// final response = await client.files.deleteFile(fileId: 'file_abc123');
  /// print('Deleted: ${response.id}');
  /// ```
  Future<FileDeleteResponse> deleteFile({
    required String fileId,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/files/${encodePathSegment(fileId, 'fileId')}',
    );
    final headers = requestBuilder.buildHeaders(
      betas: betas,
      workspaceId: workspaceId,
    );
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    return FileDeleteResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Downloads the content of a file.
  ///
  /// The [fileId] is the unique identifier of the file to download.
  ///
  /// Returns the file content as bytes.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await client.files.download(fileId: 'file_abc123');
  /// print('Downloaded ${bytes.length} bytes');
  /// ```
  Future<Uint8List> download({
    required String fileId,
    List<String> betas = const [],
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final uri = requestBuilder.buildUrl(
      '/v1/files/${encodePathSegment(fileId, 'fileId')}/content',
    );
    final headers =
        requestBuilder.buildHeaders(betas: betas, workspaceId: workspaceId)
          ..removeWhere(
            (name, _) =>
                const {'accept', 'content-type'}.contains(name.toLowerCase()),
          )
          ..['accept'] = 'application/binary';

    final request = http.Request('GET', uri)..headers.addAll(headers);

    // Apply authentication before sending (bypasses interceptor chain)
    await _applyAuthentication(request);
    ensureNotClosed?.call();

    final response = await sendResourceRequest(
      httpClient,
      request,
      timeout: config.timeout,
      ensureNotClosed: ensureNotClosed,
    );

    return response.bodyBytes;
  }

  /// Infers MIME type from file extension.
  String _inferMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'txt' => 'text/plain',
      'json' => 'application/json',
      'xml' => 'application/xml',
      'html' || 'htm' => 'text/html',
      'css' => 'text/css',
      'js' => 'application/javascript',
      'mp3' => 'audio/mpeg',
      'mp4' => 'video/mp4',
      'wav' => 'audio/wav',
      'webm' => 'video/webm',
      _ => 'application/octet-stream',
    };
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = config.authProvider;
    if (authProvider == null) return;

    request.headers.addAll(
      await resolveCredentialHeaders(request.headers, authProvider),
    );
  }
}
