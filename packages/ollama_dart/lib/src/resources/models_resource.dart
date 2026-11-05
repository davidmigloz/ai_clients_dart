import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models/copy_request.dart';
import '../models/models/create_request.dart';
import '../models/models/delete_request.dart';
import '../models/models/list_response.dart';
import '../models/models/ps_response.dart';
import '../models/models/pull_request.dart';
import '../models/models/push_request.dart';
import '../models/models/show_manifests_response.dart';
import '../models/models/show_request.dart';
import '../models/models/show_response.dart';
import '../models/models/status_event.dart';
import '../models/models/status_response.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Models API.
///
/// Provides model management operations: list, show, create, copy, delete,
/// pull, and push.
class ModelsResource extends ResourceBase with StreamingResource {
  /// Creates a [ModelsResource].
  ModelsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all locally available models.
  ///
  /// Returns a [ListResponse] containing model summaries.
  Future<ListResponse> list() async {
    final url = requestBuilder.buildUrl('/api/tags');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListResponse.fromJson(responseBody);
  }

  /// Lists currently running models.
  ///
  /// Returns a [PsResponse] containing running model information.
  Future<PsResponse> ps() async {
    final url = requestBuilder.buildUrl('/api/ps');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return PsResponse.fromJson(responseBody);
  }

  /// Shows details for a specific model.
  ///
  /// The [request] contains the model name, optional verbose flag, and
  /// system/options overrides. Verbose responses may include tensor metadata.
  ///
  /// Returns a [ShowResponse] with model details.
  Future<ShowResponse> show({required ShowRequest request}) async {
    if (request.allManifests == true) {
      throw ArgumentError('Use showManifests for all_manifests responses.');
    }
    final url = requestBuilder.buildUrl('/api/show');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ShowResponse.fromJson(responseBody);
  }

  /// Shows model information for every child in a manifest list.
  ///
  /// Sets `all_manifests` regardless of the value in [request]. The response
  /// shape differs from [show] and includes per-runner model details.
  Future<ShowManifestsResponse> showManifests({
    required ShowRequest request,
    Future<void>? abortTrigger,
  }) async {
    if (request.runner != null && request.runner!.isNotEmpty) {
      throw ArgumentError('runner and all_manifests cannot be combined.');
    }
    final httpRequest =
        http.Request('POST', requestBuilder.buildUrl('/api/show'))
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: {'Content-Type': 'application/json'},
            ),
          )
          ..body = jsonEncode(request.copyWith(allManifests: true).toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ShowManifestsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a new model.
  ///
  /// The [request] contains the model configuration.
  ///
  /// Returns a [StatusResponse] when complete.
  Future<StatusResponse> create({required CreateRequest request}) async {
    final url = requestBuilder.buildUrl('/api/create');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return StatusResponse.fromJson(responseBody);
  }

  /// Creates a new model with streaming progress.
  ///
  /// The [request] contains the model configuration.
  ///
  /// Returns a stream of [StatusEvent] progress updates.
  /// The optional [abortTrigger] cancels the request and response stream.
  Stream<StatusEvent> createStream({
    required CreateRequest request,
    Future<void>? abortTrigger,
  }) {
    return streamRequest(
      createRequest: () {
        final url = requestBuilder.buildUrl('/api/create');

        final headers = requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        );

        // Ensure stream is true for streaming
        final requestData = request.copyWith(stream: true);

        final httpRequest = http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = jsonEncode(requestData.toJson());
        return httpRequest;
      },
      abortTrigger: abortTrigger,
      fromJson: StatusEvent.fromJson,
    );
  }

  /// Copies a model.
  ///
  /// The [request] contains the source and destination names.
  /// Returns the server status, including warnings about unavailable variants.
  /// Older servers with an empty success body return an empty status response.
  Future<StatusResponse> copy({required CopyRequest request}) async {
    final url = requestBuilder.buildUrl('/api/copy');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    return response.body.trim().isEmpty
        ? const StatusResponse()
        : StatusResponse.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>,
          );
  }

  /// Deletes a model.
  ///
  /// The [request] contains the model name to delete.
  Future<void> delete({required DeleteRequest request}) async {
    final url = requestBuilder.buildUrl('/api/delete');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('DELETE', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Pulls a model from the registry.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a [StatusResponse] when complete.
  Future<StatusResponse> pull({required PullRequest request}) async {
    final url = requestBuilder.buildUrl('/api/pull');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return StatusResponse.fromJson(responseBody);
  }

  /// Pulls a model from the registry with streaming progress.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a stream of [StatusEvent] progress updates.
  /// The optional [abortTrigger] cancels the request and response stream.
  Stream<StatusEvent> pullStream({
    required PullRequest request,
    Future<void>? abortTrigger,
  }) {
    return streamRequest(
      createRequest: () {
        final url = requestBuilder.buildUrl('/api/pull');

        final headers = requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        );

        // Ensure stream is true for streaming
        final requestData = request.copyWith(stream: true);

        final httpRequest = http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = jsonEncode(requestData.toJson());
        return httpRequest;
      },
      abortTrigger: abortTrigger,
      fromJson: StatusEvent.fromJson,
    );
  }

  /// Pushes a model to the registry.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a [StatusResponse] when complete.
  Future<StatusResponse> push({required PushRequest request}) async {
    final url = requestBuilder.buildUrl('/api/push');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return StatusResponse.fromJson(responseBody);
  }

  /// Pushes a model to the registry with streaming progress.
  ///
  /// The [request] contains the model name and options.
  ///
  /// Returns a stream of [StatusEvent] progress updates.
  /// The optional [abortTrigger] cancels the request and response stream.
  Stream<StatusEvent> pushStream({
    required PushRequest request,
    Future<void>? abortTrigger,
  }) {
    return streamRequest(
      createRequest: () {
        final url = requestBuilder.buildUrl('/api/push');

        final headers = requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        );

        // Ensure stream is true for streaming
        final requestData = request.copyWith(stream: true);

        final httpRequest = http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = jsonEncode(requestData.toJson());
        return httpRequest;
      },
      abortTrigger: abortTrigger,
      fromJson: StatusEvent.fromJson,
    );
  }
}
