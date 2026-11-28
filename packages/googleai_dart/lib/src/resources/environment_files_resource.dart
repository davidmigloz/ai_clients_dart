part of 'environments_resource.dart';

/// Lists, downloads, and uploads files in a managed environment workspace.
///
/// Available on the Gemini Developer API with [ApiVersion.v1beta].
class EnvironmentFilesResource {
  EnvironmentFilesResource._(this._environments);

  final EnvironmentsResource _environments;

  static const _downloadRedactor = Redactor(
    redactionList: [
      'location',
      'key',
      'api_key',
      'x-goog-api-key',
      'access_token',
      'authorization',
    ],
  );

  static const int _uploadChunkSize = 8 * 1024 * 1024;

  // Signed URL transfers run without auth, logging, or automatic replay.
  late final _mediaTransport = InterceptorChain(
    httpClient: _environments.httpClient,
    interceptors: const [],
    ensureNotClosed: _environments.ensureNotClosed,
  );

  /// Lists directory contents or retrieves the metadata of a single file.
  ///
  /// Pass the environment ID or its `environments/{id}` resource name.
  /// [path] is relative to the workspace root and defaults to the root.
  /// Use [recursive] to include descendants and [pageToken] to fetch the
  /// next page of up to [pageSize] entries.
  Future<GetEnvironmentFilesResponse> list({
    required String environment,
    String path = '',
    int? pageSize,
    String? pageToken,
    bool? recursive,
  }) async {
    final response = await _get(
      environment,
      path,
      queryParams: {
        if (pageSize != null) 'page_size': pageSize.toString(),
        'page_token': ?pageToken,
        if (recursive != null) 'recursive': recursive.toString(),
      },
    );
    return GetEnvironmentFilesResponse.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  /// Downloads file bytes or a directory as a tar archive.
  ///
  /// Pass the environment ID or its `environments/{id}` resource name.
  /// [path] is relative to the workspace root and defaults to the root.
  /// Use [recursive] to include nested directories in an archive.
  ///
  /// Native clients follow signed download redirects without forwarding client
  /// credentials. Browsers require a server or gateway that serves bytes
  /// directly because browser HTTP clients cannot expose the redirect URL.
  Future<Uint8List> download({
    required String environment,
    String path = '',
    bool? recursive,
  }) async {
    final response = await _get(
      environment,
      path,
      queryParams: {
        'alt': 'media',
        if (recursive != null) 'recursive': recursive.toString(),
      },
      media: true,
    );
    return response.bodyBytes;
  }

  /// Uploads [bytes] to a workspace-relative [path].
  ///
  /// Pass the environment ID or its `environments/{id}` resource name.
  /// Set [extract] to unpack an archive into the destination directory and
  /// [overwrite] to allow replacement of existing files.
  ///
  /// The client starts an authenticated resumable session and sends the bytes
  /// in chunks. The result contains the metadata of the uploaded files.
  Future<GetEnvironmentFilesResponse> upload({
    required String environment,
    required String path,
    required List<int> bytes,
    String mimeType = 'application/octet-stream',
    bool? extract,
    bool? overwrite,
  }) async {
    _environments._ensureDeveloperBeta();
    _environments.ensureNotClosed?.call();
    final endpoint = _endpoint(environment, path, allowRoot: false);
    if (mimeType.trim().isEmpty) {
      throw ArgumentError.value(
        mimeType,
        'mimeType',
        'A MIME type is required.',
      );
    }
    final data = Uint8List.fromList(bytes);
    final url = _environments.requestBuilder.buildUploadUrl(
      '/upload$endpoint',
      queryParams: {
        if (extract != null) 'extract': extract.toString(),
        if (overwrite != null) 'overwrite': overwrite.toString(),
      },
    );
    final start = http.Request('PUT', url)
      ..headers.addAll(
        _environments._buildHeaders({
          'Accept': '*/*',
          'X-Goog-Upload-Command': 'start',
          'X-Goog-Upload-Protocol': 'resumable',
          'X-Goog-Upload-Header-Content-Length': '${data.length}',
          'X-Goog-Upload-Header-Content-Type': mimeType,
        }),
      )
      ..headers.remove('content-type');
    final handshake = await AuthInterceptor(config: _environments.config)
        .intercept(
          RequestContext(request: start),
          (context) => _sendUpload(context.request as http.Request, 'start'),
        );
    final session = _uploadSession(handshake, url);

    var offset = 0;
    while (true) {
      final end = min(offset + _uploadChunkSize, data.length);
      final isFinal = end == data.length;
      // The signed session URL is the sole credential for these requests.
      final chunk = http.Request('POST', session)
        ..headers['x-goog-upload-offset'] = '$offset'
        ..headers['x-goog-upload-command'] = isFinal
            ? 'upload, finalize'
            : 'upload'
        ..bodyBytes = Uint8List.sublistView(data, offset, end);
      final response = await _sendUpload(chunk, 'transfer');
      final status = response.headers['x-goog-upload-status'];
      if (status != null && status != (isFinal ? 'final' : 'active')) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Environment upload returned an unexpected session status.',
        );
      }
      if (isFinal) return _parseUploadResult(response, status);
      offset = end;
    }
  }

  Future<http.Response> _sendUpload(http.Request request, String phase) async {
    final abort = Completer<void>();
    final limit = _environments.config.timeout;
    TimeoutException timeoutError() => TimeoutException(
      message: 'Environment upload $phase timed out.',
      timeout: limit,
      elapsed: limit,
    );
    request.followRedirects = false;
    final http.Response response;
    try {
      response = await _mediaTransport
          .execute(
            request,
            abortTrigger: abort.future,
            checkActive: () {
              if (abort.isCompleted) throw timeoutError();
            },
          )
          .timeout(
            limit,
            onTimeout: () {
              abort.complete();
              throw timeoutError();
            },
          );
    } on http.ClientException {
      // Transport errors can contain the upload URL and its session credential.
      throw ApiException(
        statusCode: 0,
        message: 'Environment upload $phase failed.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Environment upload $phase failed.',
      );
    }
    return response;
  }

  static Uri _uploadSession(http.Response response, Uri startUrl) {
    final sessionHeader = response.headers['x-goog-upload-url'];
    final session = sessionHeader == null ? null : Uri.tryParse(sessionHeader);
    if (session == null ||
        session.host.isEmpty ||
        session.userInfo.isNotEmpty ||
        session.hasFragment ||
        !(session.scheme == 'https' ||
            (session.scheme == 'http' && session.origin == startUrl.origin))) {
      throw ApiException(
        statusCode: response.statusCode,
        message:
            'Environment upload returned a missing or invalid session URL.',
      );
    }
    return session;
  }

  static GetEnvironmentFilesResponse _parseUploadResult(
    http.Response response,
    String? status,
  ) {
    try {
      if (response.bodyBytes.isEmpty && status == 'final') {
        return const GetEnvironmentFilesResponse();
      }
      final json = jsonDecode(utf8.decode(response.bodyBytes));
      if (json is Map<String, dynamic>) {
        if (json.containsKey('files') || json.containsKey('next_page_token')) {
          return GetEnvironmentFilesResponse.fromJson(json);
        }
        final file = json['file'];
        if (file is Map<String, dynamic>) {
          return GetEnvironmentFilesResponse(
            files: [EnvironmentFile.fromJson(file)],
          );
        }
        if (json.containsKey('name') || json.containsKey('path')) {
          return GetEnvironmentFilesResponse(
            files: [EnvironmentFile.fromJson(json)],
          );
        }
        if (json.isEmpty) return const GetEnvironmentFilesResponse();
      }
    } on FormatException {
      // JSON and UTF-8 failures can include the original response contents.
    } on TypeError {
      // Report invalid metadata without exposing returned values.
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: 'Environment upload returned invalid file metadata.',
    );
  }

  Future<http.Response> _get(
    String environment,
    String path, {
    required Map<String, String> queryParams,
    bool media = false,
  }) async {
    _environments._ensureDeveloperBeta();
    var url = _environments.requestBuilder.buildUrl(
      _endpoint(environment, path),
      queryParams: queryParams,
    );
    if (!media && url.queryParametersAll.containsKey('alt')) {
      url = url.replace(
        queryParameters: Map.of(url.queryParametersAll)..remove('alt'),
      );
    }
    final request = http.Request('GET', url)
      ..headers.addAll(_environments._buildHeaders())
      ..headers['accept'] = media ? '*/*' : 'application/json';
    if (media) {
      request.followRedirects = false;
      request.headers.remove('content-type');
    }
    final response = await _environments.interceptorChain.execute(
      request,
      diagnosticRedactor: media ? _downloadRedactor : null,
      skipResponseBodyDiagnostics: media,
    );
    return media ? _followDownloadRedirects(response, url) : response;
  }

  Future<http.Response> _followDownloadRedirects(
    http.Response initialResponse,
    Uri initialUrl,
  ) async {
    const redirectCodes = {301, 302, 303, 307, 308};
    var response = initialResponse;
    var url = initialUrl;
    var redirects = 0;
    while (redirectCodes.contains(response.statusCode)) {
      final location = response.headers['location'];
      final reference = location == null || location.isEmpty
          ? null
          : Uri.tryParse(location);
      final target = reference == null ? null : url.resolveUri(reference);
      if (++redirects > 5 ||
          target == null ||
          target.host.isEmpty ||
          target.userInfo.isNotEmpty ||
          !(target.isScheme('https') ||
              (url.isScheme('http') && target.isScheme('http')))) {
        throw ApiException(
          statusCode: response.statusCode,
          message: 'Invalid environment file download redirect.',
        );
      }
      url = target;
      final request = http.Request('GET', url)
        ..followRedirects = false
        ..headers['accept'] = '*/*';
      try {
        response = await _mediaTransport.execute(request);
      } on http.ClientException {
        throw const ApiException(
          statusCode: 0,
          message: 'The environment file download redirect failed.',
        );
      }
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'The environment file download failed.',
      );
    }
    return response;
  }

  static String _endpoint(
    String environment,
    String path, {
    bool allowRoot = true,
  }) {
    const prefix = 'environments/';
    final id = environment.startsWith(prefix)
        ? environment.substring(prefix.length)
        : environment;
    if (id.isEmpty || id == '.' || id == '..') {
      throw ArgumentError.value(environment, 'environment', 'Invalid ID.');
    }

    final relativePath = path.replaceFirst(RegExp(r'^/+'), '');
    final base = '/{version}/environments/${Uri.encodeComponent(id)}/files';
    if (relativePath.isEmpty) {
      if (allowRoot) return base;
      throw ArgumentError.value(
        path,
        'path',
        'A destination path is required.',
      );
    }

    final segments = relativePath.split('/');
    if (segments.any((segment) => segment == '.' || segment == '..')) {
      throw ArgumentError.value(
        path,
        'path',
        'Use a path relative to the workspace without dot segments.',
      );
    }
    return '$base/${segments.map(Uri.encodeComponent).join('/')}';
  }
}
