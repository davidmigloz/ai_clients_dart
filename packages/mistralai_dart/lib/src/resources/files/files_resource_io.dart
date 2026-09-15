import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;

import '../../errors/exceptions.dart';
import '../../models/files/file_list.dart';
import '../../models/files/file_object.dart';
import '../../models/files/file_purpose.dart';
import '../../models/files/signed_url.dart';
import '../base_resource.dart';

/// Resource for the Files API (IO implementation).
///
/// Provides access to file upload, listing, and management operations.
/// This implementation supports file uploads from the file system.
class FilesResource extends ResourceBase {
  /// Creates a [FilesResource].
  FilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Uploads a file for use in fine-tuning or batch jobs.
  ///
  /// This method supports three input modes (exactly one must be provided):
  /// - [filePath]: Path to a file on the file system
  /// - [contentStream]: A stream of bytes for streaming uploads
  /// - [bytes]: The file content as a list of bytes
  ///
  /// Required parameters:
  /// - [purpose]: The purpose of the file (fine-tune, batch, ocr, audio)
  /// - [fileName]: Required when using [contentStream] or [bytes]
  ///
  /// Returns a [FileObject] with metadata about the uploaded file.
  ///
  /// Example:
  /// ```dart
  /// // From file path
  /// final file = await client.files.upload(
  ///   filePath: '/path/to/training.jsonl',
  ///   purpose: FilePurpose.fineTune,
  /// );
  ///
  /// // From bytes
  /// final file = await client.files.upload(
  ///   bytes: fileBytes,
  ///   fileName: 'training.jsonl',
  ///   purpose: FilePurpose.fineTune,
  /// );
  /// ```
  Future<FileObject> upload({
    String? filePath,
    Stream<List<int>>? contentStream,
    List<int>? bytes,
    String? fileName,
    required FilePurpose purpose,
  }) async {
    // Validate that exactly one input method is provided
    final inputCount = [
      filePath,
      contentStream,
      bytes,
    ].where((input) => input != null).length;

    if (inputCount != 1) {
      throw const ValidationException(
        message:
            'Exactly one of filePath, contentStream, or bytes must be provided',
        fieldErrors: {
          'upload': [
            'Provide exactly one of: filePath, contentStream, or bytes',
          ],
        },
      );
    }

    // Prepare the upload data
    final List<int> fileBytes;
    final String finalFileName;

    if (filePath != null) {
      final file = io.File(filePath);
      if (!file.existsSync()) {
        throw const ValidationException(
          message: 'File not found',
          fieldErrors: {
            'filePath': ['File does not exist'],
          },
        );
      }
      fileBytes = await file.readAsBytes();
      finalFileName = fileName ?? file.uri.pathSegments.last;
    } else if (contentStream != null) {
      if (fileName == null) {
        throw const ValidationException(
          message: 'fileName is required when using contentStream',
          fieldErrors: {
            'fileName': ['fileName must be provided with contentStream'],
          },
        );
      }
      fileBytes = await contentStream.fold<List<int>>(
        [],
        (buffer, chunk) => buffer..addAll(chunk),
      );
      finalFileName = fileName;
    } else {
      if (fileName == null) {
        throw const ValidationException(
          message: 'fileName is required when using bytes',
          fieldErrors: {
            'fileName': ['fileName must be provided with bytes'],
          },
        );
      }
      fileBytes = bytes!;
      finalFileName = fileName;
    }

    // Build a fresh, unfinalized multipart request per attempt so the
    // retry wrapper can replay the body.
    http.MultipartRequest buildRequest() =>
        http.MultipartRequest('POST', requestBuilder.buildUrl('/v1/files'))
          ..headers.addAll(requestBuilder.buildHeaders())
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: finalFileName,
            ),
          )
          ..fields['purpose'] = filePurposeToString(purpose);

    // Route through the interceptor chain like every other endpoint so
    // auth, logging and error mapping apply to uploads too.
    final response = await interceptorChain.execute(
      buildRequest(),
      requestFactory: buildRequest,
    );

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FileObject.fromJson(responseBody);
  }

  /// Lists uploaded files.
  ///
  /// Optionally filter by [purpose] and paginate with [page] and [pageSize].
  Future<FileList> list({
    FilePurpose? purpose,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, String>{
      if (purpose != null) 'purpose': filePurposeToString(purpose),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl('/v1/files', queryParams: queryParams);
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FileList.fromJson(responseBody);
  }

  /// Retrieves metadata for a specific file.
  ///
  /// The [fileId] is the unique identifier of the file.
  Future<FileObject> retrieve({required String fileId}) async {
    final url = requestBuilder.buildUrl('/v1/files/$fileId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FileObject.fromJson(responseBody);
  }

  /// Deletes a file.
  ///
  /// The [fileId] is the unique identifier of the file to delete.
  Future<FileObject> delete({required String fileId}) async {
    final url = requestBuilder.buildUrl('/v1/files/$fileId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FileObject.fromJson(responseBody);
  }

  /// Downloads a file's content.
  ///
  /// The [fileId] is the unique identifier of the file to download.
  ///
  /// Returns the file content as bytes.
  Future<List<int>> download({required String fileId}) async {
    final url = requestBuilder.buildUrl('/v1/files/$fileId/content');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

    return response.bodyBytes;
  }

  /// Gets a pre-signed URL for downloading a file.
  ///
  /// The [fileId] is the unique identifier of the file.
  /// The [expiresIn] is the number of seconds until the URL expires (default: 86400).
  Future<SignedUrl> getSignedUrl({
    required String fileId,
    int? expiresIn,
  }) async {
    final url = requestBuilder.buildUrl('/v1/files/$fileId/url');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final body = <String, dynamic>{'expiry': ?expiresIn};

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(body);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SignedUrl.fromJson(responseBody);
  }
}
