import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../models/files/generated_file.dart';
import '../models/files/list_generated_files_response.dart';
import 'base_resource.dart';
import 'media_download.dart';
import 'operations_resource.dart';

/// Resource for the Generated Files API.
///
/// Provides access to generated file operations (e.g., videos from Veo).
class GeneratedFilesResource extends ResourceBase {
  /// Creates a [GeneratedFilesResource].
  GeneratedFilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists the generated files owned by the requesting project.
  ///
  /// Generated files are files created by the API (e.g., videos from Veo).
  ///
  /// The [pageSize] parameter specifies the maximum number of GeneratedFiles to return
  /// (default is 10, max is 50). The [pageToken] is used for pagination.
  ///
  /// Returns a [ListGeneratedFilesResponse] with the list of generated files.
  Future<ListGeneratedFilesResponse> list({
    int? pageSize,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      if (pageSize != null) 'pageSize': pageSize.toString(),
      'pageToken': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/generatedFiles',
      queryParams: queryParams,
    );

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListGeneratedFilesResponse.fromJson(responseBody);
  }

  /// Gets a generated file.
  ///
  /// The [name] is the resource name of the generated file (e.g., "generatedFiles/abc-123").
  ///
  /// Use [download] to retrieve the file content.
  ///
  /// Returns a [GeneratedFile] with the file's metadata.
  Future<GeneratedFile> get({required String name}) async {
    final url = requestBuilder.buildUrl('/{version}/$name');

    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return GeneratedFile.fromJson(responseBody);
  }

  /// Downloads a Developer API `v1beta` generated file as raw bytes.
  ///
  /// Pass a bare ID or a `generatedFiles/{id}` name. Browser transports
  /// require an endpoint that serves the bytes directly.
  Future<Uint8List> download({
    required String name,
    Future<void>? abortTrigger,
  }) async {
    if (config.apiMode != ApiMode.googleAI ||
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError(
        'Generated file download requires the Gemini Developer API v1beta.',
      );
    }
    final resource = mediaResourceName(this, 'generatedFiles', name);
    final bytes = await downloadDeveloperMedia(
      this,
      '/{version}/$resource',
      abortTrigger: abortTrigger,
    );
    return bytes;
  }

  /// Access operations for this generated file.
  OperationsResource operations({required String generatedFile}) {
    return OperationsResource(
      parent: 'generatedFiles/$generatedFile',
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
    );
  }
}
