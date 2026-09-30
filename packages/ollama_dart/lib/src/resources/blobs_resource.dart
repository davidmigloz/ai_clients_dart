import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import 'base_resource.dart';

/// Binary blob storage on a local Ollama server.
///
/// Upload model files here before referring to their SHA256 digests in
/// `CreateRequest.files`. Ollama Cloud does not provide model creation.
class BlobsResource extends ResourceBase {
  /// Creates a [BlobsResource].
  BlobsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Checks whether [digest] (including its `sha256:` prefix) exists.
  ///
  /// Only HTTP 404 returns `false`; malformed digests, authentication errors,
  /// and server failures propagate through the normal exception hierarchy.
  Future<bool> exists({
    required String digest,
    Future<void>? abortTrigger,
  }) async {
    final request = http.Request(
      'HEAD',
      requestBuilder.buildUrl('/api/blobs/${Uri.encodeComponent(digest)}'),
    )..headers.addAll(requestBuilder.buildHeaders());
    try {
      await interceptorChain.execute(request, abortTrigger: abortTrigger);
      return true;
    } on ApiException catch (error) {
      if (error.statusCode == 404) return false;
      rethrow;
    }
  }

  /// Uploads raw [bytes] under [digest], including its `sha256:` prefix.
  ///
  /// The server verifies the content digest for a new blob. An existing blob
  /// succeeds with HTTP 200, and a new blob with HTTP 201; neither returns JSON.
  /// No file IO or digest calculation is performed by this client.
  Future<void> create({
    required String digest,
    required List<int> bytes,
    Future<void>? abortTrigger,
  }) async {
    final request =
        http.Request(
            'POST',
            requestBuilder.buildUrl(
              '/api/blobs/${Uri.encodeComponent(digest)}',
            ),
          )
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: {'Content-Type': 'application/octet-stream'},
            ),
          )
          ..bodyBytes = bytes;
    await interceptorChain.execute(request, abortTrigger: abortTrigger);
  }
}
