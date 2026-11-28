import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '../../auth/auth_provider.dart';
import '../../client/config.dart';
import '../../errors/exceptions.dart';
import '../../models/common/register_files_request.dart';
import '../../models/common/register_files_response.dart';
import '../../utils/redactor.dart';
import '../base_resource.dart';
import '../media_download.dart';

/// Shared Files API behavior for the IO, web, and stub resources.
abstract class FilesResourceBase extends ResourceBase {
  /// Creates the shared resource.
  FilesResourceBase({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _credentialQueryKeys = {
    'key',
    'api_key',
    'api-key',
    'x-goog-api-key',
    'access_token',
  };

  /// Validates that the Files API is only used with Google AI.
  @protected
  void validateGoogleAIOnly() {
    if (config.apiMode == ApiMode.vertexAI) {
      throw UnsupportedError(
        'Files API is only available with Google AI (Gemini API). '
        'Vertex AI does not have a Files API. '
        'For Vertex AI, use Cloud Storage URIs (gs://...) or base64-encoded data directly. '
        'See: https://cloud.google.com/vertex-ai/generative-ai/docs/multimodal/send-multimodal-prompts',
      );
    }
  }

  /// Downloads a generated Gemini file by its ID or `files/{id}` name.
  ///
  /// Use `get` or `list` to find API-generated files with a download URI.
  /// Uploaded and Cloud Storage-registered inputs are available for prompting
  /// and metadata. This operation is available on Developer API `v1` and
  /// `v1beta`.
  ///
  /// Browser transports require an endpoint that serves the bytes directly
  /// because browsers cannot expose a signed redirect's location to the SDK.
  Future<List<int>> download({
    required String name,
    Future<void>? abortTrigger,
  }) async {
    validateGoogleAIOnly();
    if (config.apiVersion != ApiVersion.v1 &&
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError('File download requires v1 or v1beta.');
    }
    final resource = mediaResourceName(this, 'files', name);
    final bytes = await downloadDeveloperMedia(
      this,
      '/{version}/$resource:download',
      abortTrigger: abortTrigger,
    );
    return bytes;
  }

  /// Registers existing Google Cloud Storage objects with the Gemini Files API.
  ///
  /// Supply `gs://bucket/object` values in [uris]. The Gemini service agent
  /// must be able to read each object. Supply an OAuth bearer [authProvider]
  /// or configure the client with one. [quotaProjectId] sets the
  /// `x-goog-user-project` header when provided. Browser network access also
  /// depends on the endpoint's CORS configuration.
  Future<RegisterFilesResponse> register({
    required List<String> uris,
    AuthProvider? authProvider,
    String? quotaProjectId,
  }) async {
    ensureNotClosed?.call();
    validateGoogleAIOnly();
    if (config.apiVersion != ApiVersion.v1 &&
        config.apiVersion != ApiVersion.v1beta) {
      throw UnsupportedError('Files registration requires v1 or v1beta.');
    }
    if (uris.isEmpty || !uris.every(_isStorageObjectUri)) {
      throw const ValidationException(
        message: 'Provide at least one gs://bucket/object URI.',
        fieldErrors: {
          'uris': ['Each URI must name a Google Cloud Storage object.'],
        },
      );
    }

    final body = jsonEncode(RegisterFilesRequest(uris: uris).toJson());
    final credentials = await (authProvider ?? config.authProvider)
        ?.getCredentials();
    if (credentials is! BearerTokenCredentials ||
        credentials.token.trim().isEmpty) {
      throw const ValidationException(
        message: 'Files registration requires an OAuth bearer token.',
        fieldErrors: {
          'authProvider': [
            'Supply a provider returning BearerTokenCredentials.',
          ],
        },
      );
    }

    final url = requestBuilder.buildUrl('/{version}/files:register');
    final query = Map<String, dynamic>.of(url.queryParametersAll)
      ..removeWhere(
        (name, _) => _credentialQueryKeys.contains(name.toLowerCase()),
      );
    final headers = requestBuilder.buildHeaders()
      ..removeWhere(
        (name, _) =>
            name.toLowerCase() == 'authorization' ||
            name.toLowerCase() == 'x-goog-api-key',
      );
    final request = http.Request('POST', url.replace(queryParameters: query))
      ..followRedirects = false
      ..headers.addAll(headers)
      ..headers['Authorization'] = 'Bearer ${credentials.token}'
      ..headers['Content-Type'] = 'application/json'
      ..body = body;
    if (quotaProjectId != null) {
      request.headers['x-goog-user-project'] = quotaProjectId;
    }
    final response = await interceptorChain.execute(
      request,
      skipAuthentication: true,
      diagnosticRedactor: Redactor.forSecrets(
        secrets: [credentials.token],
        redactionList: const ['authorization'],
      ),
    );
    try {
      return RegisterFilesResponse.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } on FormatException {
      // The original exception can include the response body or an echoed token.
    } on TypeError {
      // A successful response can still have a malformed payload.
    }
    throw const FormatException('Invalid Gemini Files registration response.');
  }

  static bool _isStorageObjectUri(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.scheme == 'gs' &&
        uri.host.isNotEmpty &&
        uri.path.length > 1;
  }
}
