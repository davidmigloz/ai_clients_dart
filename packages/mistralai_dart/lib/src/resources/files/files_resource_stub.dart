import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/files/file_list.dart';
import '../../models/files/file_object.dart';
import '../../models/files/file_purpose.dart';
import '../../models/files/signed_url.dart';
import '../base_resource.dart';

/// Resource for the Files API (stub implementation).
///
/// This is used on platforms that don't support file operations natively.
/// Upload operations will throw [UnsupportedError].
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
  /// This method is not supported on this platform.
  ///
  /// Throws [UnsupportedError] always.
  Future<FileObject> upload({
    String? filePath,
    Stream<List<int>>? contentStream,
    List<int>? bytes,
    String? fileName,
    required FilePurpose purpose,
  }) {
    throw UnsupportedError(
      'File upload is not supported on this platform. '
      'Use dart:io or web platform.',
    );
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
