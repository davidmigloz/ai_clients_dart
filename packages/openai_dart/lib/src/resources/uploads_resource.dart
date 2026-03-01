import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/files/files.dart';
import 'base_resource.dart';

/// Resource for multipart upload operations.
///
/// The Uploads API allows uploading large files in parts, which is useful
/// for files larger than 512 MB.
///
/// Access this resource through [OpenAIClient.uploads].
///
/// ## Example
///
/// ```dart
/// // Create an upload
/// final upload = await client.uploads.create(
///   CreateUploadRequest(
///     filename: 'large-file.jsonl',
///     purpose: FilePurpose.fineTune,
///     bytes: fileSize,
///     mimeType: 'application/jsonl',
///   ),
/// );
///
/// // Add parts
/// for (final chunk in chunks) {
///   await client.uploads.addPart(upload.id, data: chunk);
/// }
///
/// // Complete the upload
/// final file = await client.uploads.complete(upload.id);
/// ```
class UploadsResource extends ResourceBase {
  /// Creates an [UploadsResource].
  UploadsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/uploads';

  /// Creates a new upload for a large file.
  ///
  /// After creating an upload, add parts using [addPart], then
  /// finalize with [complete].
  ///
  /// ## Parameters
  ///
  /// - [request] - The upload creation request.
  ///
  /// ## Returns
  ///
  /// An [Upload] object with the upload ID and status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final upload = await client.uploads.create(
  ///   CreateUploadRequest(
  ///     filename: 'large-training-data.jsonl',
  ///     purpose: FilePurpose.fineTune,
  ///     bytes: 1024 * 1024 * 100, // 100 MB
  ///     mimeType: 'application/jsonl',
  ///   ),
  /// );
  ///
  /// print('Upload ID: ${upload.id}');
  /// ```
  Future<Upload> create(CreateUploadRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Upload.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Adds a part to an upload.
  ///
  /// Parts can be added in any order. Each part must be at least 5 MB
  /// (except the last part) and at most 64 MB.
  ///
  /// ## Parameters
  ///
  /// - [uploadId] - The ID of the upload.
  /// - [data] - The part data as bytes.
  ///
  /// ## Returns
  ///
  /// An [UploadPart] with the part information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final part = await client.uploads.addPart(
  ///   upload.id,
  ///   data: chunkBytes,
  /// );
  ///
  /// print('Added part: ${part.id}');
  /// ```
  Future<UploadPart> addPart(String uploadId, {required List<int> data}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$uploadId/parts');
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      http.MultipartFile.fromBytes('data', data, filename: 'part'),
    );
    request.headers.addAll(requestBuilder.buildMultipartHeaders());

    final response = await interceptorChain.execute(request);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UploadPart.fromJson(json);
  }

  /// Completes an upload and creates a file.
  ///
  /// The parts are assembled in the order specified by [partIds].
  ///
  /// ## Parameters
  ///
  /// - [uploadId] - The ID of the upload to complete.
  /// - [partIds] - The ordered list of part IDs.
  /// - [md5] - Optional MD5 checksum for verification.
  ///
  /// ## Returns
  ///
  /// An [Upload] with status "completed" and a file reference.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final completed = await client.uploads.complete(
  ///   upload.id,
  ///   partIds: ['part-abc', 'part-def', 'part-ghi'],
  /// );
  ///
  /// print('File ID: ${completed.file?.id}');
  /// ```
  Future<Upload> complete(
    String uploadId, {
    required List<String> partIds,
    String? md5,
  }) async {
    ensureNotClosed?.call();
    final request = CompleteUploadRequest(partIds: partIds, md5: md5);
    final url = requestBuilder.buildUrl('$_endpoint/$uploadId/complete');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Upload.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Cancels an upload.
  ///
  /// No parts can be added after cancellation, and any uploaded
  /// parts will be deleted.
  ///
  /// ## Parameters
  ///
  /// - [uploadId] - The ID of the upload to cancel.
  ///
  /// ## Returns
  ///
  /// An [Upload] with status "cancelled".
  ///
  /// ## Example
  ///
  /// ```dart
  /// final cancelled = await client.uploads.cancel(upload.id);
  /// print('Status: ${cancelled.status}');
  /// ```
  Future<Upload> cancel(String uploadId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$uploadId/cancel');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    final response = await interceptorChain.execute(httpRequest);
    return Upload.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
