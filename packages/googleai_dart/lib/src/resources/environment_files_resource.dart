part of 'environments_resource.dart';

/// Lists and downloads files from a managed environment workspace.
///
/// Available on the Gemini Developer API with [ApiVersion.v1beta].
class EnvironmentFilesResource {
  const EnvironmentFilesResource._(this._environments);

  final EnvironmentsResource _environments;

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
  }) {
    _environments._ensureDeveloperBeta();
    final url = _environments.requestBuilder.buildUrl(
      _endpoint(environment, path),
      queryParams: queryParams,
    );
    final request = http.Request('GET', url)
      ..headers.addAll(_environments._buildHeaders());
    if (media) {
      request.headers['accept'] = '*/*';
      request.headers.remove('content-type');
    }
    return _environments.interceptorChain.execute(request);
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
