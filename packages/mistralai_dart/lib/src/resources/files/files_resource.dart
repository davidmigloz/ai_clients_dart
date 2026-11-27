import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../errors/exceptions.dart';
import '../../models/files/file_list.dart';
import '../../models/files/file_object.dart';
import '../../models/files/file_purpose.dart';
import '../../models/files/file_visibility.dart';
import '../../models/files/signed_url.dart';
import '../base_resource.dart';
import 'file_input_stub.dart' if (dart.library.io) 'file_input_io.dart';

/// Resource for the Files API.
///
/// File paths and input streams are available on native platforms. Upload
/// bytes with a file name in both native and browser applications.
class FilesResource extends ResourceBase {
  /// Creates a [FilesResource].
  FilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Uploads a file with optional API [purpose], [expiry], and [visibility].
  ///
  /// Provide exactly one of [bytes], [filePath], or [contentStream].
  /// Browser uploads use [bytes] only. Pass [fileName] when uploading [bytes]
  /// or a [contentStream]. [mimeType] sets the content type of the file part.
  Future<FileObject> upload({
    String? filePath,
    Stream<List<int>>? contentStream,
    List<int>? bytes,
    String? fileName,
    FilePurpose? purpose,
    int? expiry,
    FileVisibility? visibility,
    String? mimeType,
  }) async {
    ensureNotClosed?.call();
    if (!supportsLocalFiles) {
      if (!const bool.fromEnvironment('dart.library.js_interop')) {
        throw UnsupportedError(
          'File upload requires a native or web platform.',
        );
      }
      if (filePath != null || contentStream != null) {
        throw const ValidationException(
          message: 'Use bytes for browser uploads.',
          fieldErrors: {
            'upload': [
              'File paths and input streams require a native platform',
            ],
          },
        );
      }
    }

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
      final file = await readLocalFile(filePath);
      fileBytes = file.bytes;
      finalFileName = fileName ?? file.fileName;
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

    final mediaType = mimeType == null ? null : MediaType.parse(mimeType);
    // Build a fresh multipart body for each retry from the buffered bytes.
    http.MultipartRequest buildRequest() =>
        http.MultipartRequest('POST', requestBuilder.buildUrl('/v1/files'))
          ..headers.addAll(requestBuilder.buildHeaders())
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: finalFileName,
              contentType: mediaType,
            ),
          )
          ..fields.addAll({
            if (purpose != null) 'purpose': filePurposeToString(purpose),
            if (expiry != null) 'expiry': expiry.toString(),
            if (visibility != null) 'visibility': visibility.value,
          });

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
    bool? includeTotal,
    List<String>? sampleTypes,
    List<String>? sources,
    String? search,
    List<String>? mimeTypes,
  }) async {
    final queryParams = <String, dynamic>{
      if (purpose != null) 'purpose': filePurposeToString(purpose),
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (includeTotal != null) 'include_total': includeTotal.toString(),
      'sample_type': ?sampleTypes,
      'source': ?sources,
      'search': ?search,
      'mimetypes': ?mimeTypes,
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
    final url = requestBuilder.buildUrl(
      '/v1/files/${Uri.encodeComponent(fileId)}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return FileObject.fromJson(responseBody);
  }

  /// Deletes a file.
  ///
  /// The API returns the deleted file's ID, object type, and deletion flag.
  Future<FileObject> delete({required String fileId}) async {
    final url = requestBuilder.buildUrl(
      '/v1/files/${Uri.encodeComponent(fileId)}',
    );
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
    final url = requestBuilder.buildUrl(
      '/v1/files/${Uri.encodeComponent(fileId)}/content',
    );
    final headers = requestBuilder.buildHeaders()
      ..removeWhere((name, _) {
        final key = name.toLowerCase();
        return key == 'content-type' || key == 'accept';
      })
      ..['accept'] = 'application/octet-stream';

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);

    return response.bodyBytes;
  }

  /// Gets a pre-signed URL for downloading a file.
  ///
  /// [expiryHours] is the URL lifetime in hours, from 1 through 168. Omit it
  /// to let the API use its default. Existing calls using [expiresIn] specify
  /// seconds, which round up to the next whole hour. Supply only one option.
  Future<SignedUrl> getSignedUrl({
    required String fileId,
    int? expiresIn,
    int? expiryHours,
  }) async {
    if (expiresIn != null && expiryHours != null) {
      throw ArgumentError('Specify either expiresIn or expiryHours.');
    }
    final hours =
        expiryHours ??
        (expiresIn == null
            ? null
            : (expiresIn / Duration.secondsPerHour).ceil());
    if (hours != null && (hours < 1 || hours > 168)) {
      throw ArgumentError.value(hours, 'expiryHours', 'Must be from 1 to 168.');
    }

    final url = requestBuilder.buildUrl(
      '/v1/files/${Uri.encodeComponent(fileId)}/url',
      queryParams: {if (hours != null) 'expiry': hours.toString()},
    );
    final httpRequest = http.Request('GET', url)
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SignedUrl.fromJson(responseBody);
  }
}
