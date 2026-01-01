import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../models/files/file_delete_response.dart';
import '../models/files/file_list_response.dart';
import '../models/files/file_metadata.dart';
import 'base_resource.dart';

/// Beta header for the Files API.
const _betaHeader = 'files-api-2025-04-14';

/// Resource for the Files API (IO implementation).
///
/// Provides access to file upload, listing, and management operations.
/// This is a beta feature and requires the `anthropic-beta` header.
///
/// Files can be used as part of message content (e.g., for vision or
/// document understanding).
class FilesResource extends ResourceBase {
  final http.Client _httpClient;

  /// Creates a [FilesResource].
  FilesResource({
    required super.chain,
    required super.requestBuilder,
    required http.Client httpClient,
  }) : _httpClient = httpClient;

  /// Uploads a file from a file path.
  ///
  /// The [filePath] is the path to the file to upload.
  /// The [mimeType] is optional; if not provided, it will be inferred
  /// from the file extension.
  ///
  /// Returns a [FileMetadata] with information about the uploaded file.
  ///
  /// Example:
  /// ```dart
  /// final file = await client.files.upload(
  ///   filePath: '/path/to/image.jpg',
  ///   mimeType: 'image/jpeg',
  /// );
  /// print('Uploaded file: ${file.id}');
  /// ```
  Future<FileMetadata> upload({
    required String filePath,
    String? mimeType,
  }) async {
    final file = io.File(filePath);
    if (!file.existsSync()) {
      throw ArgumentError('File not found: $filePath');
    }

    final bytes = await file.readAsBytes();
    final fileName = file.uri.pathSegments.last;
    final inferredMimeType = mimeType ?? _inferMimeType(fileName);

    return uploadBytes(
      bytes: bytes,
      fileName: fileName,
      mimeType: inferredMimeType,
    );
  }

  /// Uploads a file from bytes.
  ///
  /// The [bytes] is the file content.
  /// The [fileName] is the name to use for the file.
  /// The [mimeType] is optional; if not provided, it will be inferred
  /// from the file extension.
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
  /// );
  /// ```
  Future<FileMetadata> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    String? mimeType,
  }) async {
    final inferredMimeType = mimeType ?? _inferMimeType(fileName);

    final uri = requestBuilder.buildUrl('/v1/files');
    // Remove content-type as multipart will set its own
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    )..remove('content-type');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(headers)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: _parseMediaType(inferredMimeType),
        ),
      );

    // Add authentication header
    await _applyAuthentication(request);

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      _throwError(response);
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return FileMetadata.fromJson(json);
  }

  /// Lists uploaded files.
  ///
  /// The [limit] specifies the maximum number of files to return (1-1000,
  /// default 20).
  /// The [beforeId] returns files before this ID (for pagination).
  /// The [afterId] returns files after this ID (for pagination).
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
    String? beforeId,
    String? afterId,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'before_id': ?beforeId,
      'after_id': ?afterId,
    };

    final json = await get(
      '/v1/files',
      queryParams: queryParams.isEmpty ? null : queryParams,
      headers: {'anthropic-beta': _betaHeader},
    );

    return FileListResponse.fromJson(json);
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
  Future<FileMetadata> retrieve({required String fileId}) async {
    final json = await get(
      '/v1/files/$fileId',
      headers: {'anthropic-beta': _betaHeader},
    );

    return FileMetadata.fromJson(json);
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
  Future<FileDeleteResponse> deleteFile({required String fileId}) async {
    final json = await delete(
      '/v1/files/$fileId',
      headers: {'anthropic-beta': _betaHeader},
    );

    return FileDeleteResponse.fromJson(json);
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
  /// await io.File('downloaded.pdf').writeAsBytes(bytes);
  /// ```
  Future<Uint8List> download({required String fileId}) async {
    final uri = requestBuilder.buildUrl('/v1/files/$fileId/content');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    // We want binary, not JSON
    headers['accept'] = '*/*';
    headers.remove('content-type');

    final request = http.Request('GET', uri)..headers.addAll(headers);

    // Apply authentication before sending (bypasses interceptor chain)
    await _applyAuthentication(request);

    final streamedResponse = await _httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      _throwError(response);
    }

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

  /// Parses a MIME type string to http.MediaType.
  http.MediaType _parseMediaType(String mimeType) {
    final parts = mimeType.split('/');
    if (parts.length == 2) {
      return http.MediaType(parts[0], parts[1]);
    }
    return http.MediaType('application', 'octet-stream');
  }

  /// Throws an appropriate error from an HTTP response.
  Never _throwError(http.Response response) {
    String message;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      message = error?['message'] as String? ?? response.body;
    } catch (_) {
      message = response.body;
    }

    switch (response.statusCode) {
      case 401:
        throw AuthenticationException(message: message);
      case 429:
        throw RateLimitException(code: response.statusCode, message: message);
      case 400:
        throw ValidationException(message: message, fieldErrors: const {});
      default:
        throw ApiException(code: response.statusCode, message: message);
    }
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = requestBuilder.config.authProvider;
    if (authProvider == null) return;

    final credentials = await authProvider.getCredentials();
    switch (credentials) {
      case ApiKeyCredentials(:final apiKey):
        if (!request.headers.containsKey('x-api-key')) {
          request.headers['x-api-key'] = apiKey;
        }
      case NoAuthCredentials():
        // No authentication needed
        break;
    }
  }
}
