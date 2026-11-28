part of 'environments_resource.dart';

/// Lists and downloads files from a managed environment workspace.
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

  late final _downloadTransport = InterceptorChain(
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
        response = await _downloadTransport.execute(request);
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

  static String _endpoint(String environment, String path) {
    const prefix = 'environments/';
    final id = environment.startsWith(prefix)
        ? environment.substring(prefix.length)
        : environment;
    if (id.isEmpty || id == '.' || id == '..') {
      throw ArgumentError.value(environment, 'environment', 'Invalid ID.');
    }

    final relativePath = path.replaceFirst(RegExp(r'^/+'), '');
    final base = '/{version}/environments/${Uri.encodeComponent(id)}/files';
    if (relativePath.isEmpty) return base;

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
