import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../errors/exceptions.dart';
import '../../models/files/file_list.dart';
import '../../models/files/file_object.dart';
import '../../models/files/file_purpose.dart';
import '../../models/files/signed_url.dart';
import '../base_resource.dart';

/// Resource for the Files API (Web implementation).
///
/// Provides access to file upload, listing, and management operations.
/// This implementation supports file uploads from bytes on web platforms.
class FilesResource extends ResourceBase {
  /// Creates a [FilesResource].
  FilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Uploads a file for use in fine-tuning or batch jobs.
  ///
  /// On web, only [bytes] with [fileName] is supported.
  ///
  /// Required parameters:
  /// - [bytes]: The file content as a list of bytes
  /// - [fileName]: The name of the file
  /// - [purpose]: The purpose of the file (fine-tune, batch, ocr, audio)
  ///
  /// Returns a [FileObject] with metadata about the uploaded file.
  ///
  /// Example:
  /// ```dart
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
    // On web, only bytes is supported
    if (filePath != null) {
      throw const ValidationException(
        message: 'filePath is not supported on web. Use bytes instead.',
        fieldErrors: {
          'filePath': ['Not supported on web platform'],
        },
      );
    }

    if (contentStream != null) {
      throw const ValidationException(
        message: 'contentStream is not supported on web. Use bytes instead.',
        fieldErrors: {
          'contentStream': ['Not supported on web platform'],
        },
      );
    }

    if (bytes == null) {
      throw const ValidationException(
        message: 'bytes is required for file upload on web',
        fieldErrors: {
          'bytes': ['Required for web platform'],
        },
      );
    }

    if (fileName == null) {
      throw const ValidationException(
        message: 'fileName is required when using bytes',
        fieldErrors: {
          'fileName': ['fileName must be provided with bytes'],
        },
      );
    }

    // Create multipart request
    final url = requestBuilder.buildUrl('/v1/files');
    final request = http.MultipartRequest('POST', url);

    // Add headers
    final headers = requestBuilder.buildHeaders();
    request.headers.addAll(headers);

    // Add file
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: fileName),
    );

    // Add purpose
    request.fields['purpose'] = filePurposeToString(purpose);

    // Send request
    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 400) {
      throw _mapHttpError(response);
    }

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

  /// Maps HTTP errors to exceptions.
  MistralException _mapHttpError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    var message = 'HTTP $statusCode error';

    try {
      final errorDetails = jsonDecode(body);
      if (errorDetails is Map<String, dynamic>) {
        message = errorDetails['message']?.toString() ?? message;
      }
    } catch (_) {
      if (body.length < 200 && body.isNotEmpty) {
        message = body;
      }
    }

    if (statusCode == 429) {
      return RateLimitException(code: statusCode, message: message);
    }

    return ApiException(code: statusCode, message: message);
  }
}
