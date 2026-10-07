@Tags(['integration'])
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final apiKey = Platform.environment['OPENAI_API_KEY'];

  test(
    'one 1GB container retains configuration across create, retrieve, and list',
    () async {
      final transport = _ContainerIdCaptureClient();
      final client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider(apiKey!),
          baseUrl: 'https://api.openai.com/v1',
          timeout: const Duration(seconds: 30),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: transport,
      );
      final name =
          'openai-dart-config-${DateTime.now().microsecondsSinceEpoch}-$pid';

      try {
        // Exactly one creation, with no model requests, files, or skills.
        final created = await client.containers.create(
          CreateContainerRequest(
            name: name,
            memoryLimit: ContainerMemoryLimit.gb1,
            networkPolicy: ContainerNetworkPolicy.disabled,
            expiresAfter: const ContainerExpiration(
              anchor: 'last_active_at',
              minutes: 20,
            ),
          ),
        );
        expect(transport.createdId, created.id);
        _expectContainer(created, id: created.id, name: name);

        final retrieved = await client.containers.retrieve(created.id);
        _expectContainer(retrieved, id: created.id, name: name);

        Container? listedContainer;
        // Listing may lag creation; retry reads only, never container creation.
        for (var attempt = 0; attempt < 4; attempt++) {
          final listed = await client.containers.list(name: name, limit: 1);
          expect(listed.object, 'list');
          for (final entry in listed.data) {
            expect(entry.name, name);
            if (entry.id == created.id) listedContainer = entry;
          }
          if (listedContainer != null) break;
          if (attempt < 3) {
            await Future<void>.delayed(const Duration(seconds: 1));
          }
        }
        expect(
          listedContainer,
          isNotNull,
          reason: 'The created container was absent after four list reads.',
        );
        _expectContainer(listedContainer!, id: created.id, name: name);
      } finally {
        try {
          // Capture happens before model parsing, so parsing/assertion failures
          // still leave an ID available for this cleanup attempt.
          final cleanupIds = <String>{};
          if (transport.createdId case final id?) {
            cleanupIds.add(id);
          } else if (transport.creationAttempted) {
            // A timed-out/malformed creation can still have created a resource.
            // Recover it using this test's unique name without another POST.
            for (var attempt = 0; attempt < 4; attempt++) {
              final recovered = await client.containers.list(
                name: name,
                limit: 1,
              );
              cleanupIds.addAll(
                recovered.data
                    .where((entry) => entry.name == name)
                    .map((e) => e.id),
              );
              if (cleanupIds.isNotEmpty) break;
              if (attempt < 3) {
                await Future<void>.delayed(const Duration(seconds: 1));
              }
            }
          }
          for (final id in cleanupIds) {
            try {
              final deleted = await client.containers.delete(id);
              expect(deleted.id, id);
              expect(deleted.deleted, isTrue);
            } on FormatException {
              fail(
                'Container DELETE returned HTTP ${transport.deleteStatus}; '
                'the public deletion parser rejected its response.',
              );
            }
          }
        } finally {
          client.close();
          // OpenAIClient does not own an injected transport.
          transport.close();
        }
      }
    },
    skip: apiKey == null || apiKey.trim().isEmpty
        ? 'OPENAI_API_KEY is not set.'
        : false,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}

void _expectContainer(
  Container container, {
  required String id,
  required String name,
}) {
  expect(container.id, isNotEmpty);
  expect(container.id, id);
  expect(container.object, 'container');
  expect(container.name, name);
  expect(container.createdAt, greaterThanOrEqualTo(0));
  expect(container.status, isNotEmpty);

  // Returned settings and individual expiration members are optional.
  if (container.memoryLimit case final memory?) {
    expect(memory, ContainerMemoryLimit.gb1);
  }
  if (container.networkPolicy case final policy?) {
    expect(policy.type, 'disabled');
  }
  if (container.expiresAfter case final expiration?) {
    if (expiration.anchor case final anchor?) {
      expect(anchor, 'last_active_at');
    }
    if (expiration.minutes case final minutes?) {
      expect(minutes, 20);
    }
  }
}

/// Captures only the created ID and DELETE status for safe cleanup/reporting.
class _ContainerIdCaptureClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  String? createdId;
  int? deleteStatus;
  bool creationAttempted = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (request.method == 'POST' && request.url.path == '/v1/containers') {
      creationAttempted = true;
    }
    final response = await _inner.send(request);
    if (request.method == 'DELETE' &&
        request.url.path.startsWith('/v1/containers/')) {
      deleteStatus = response.statusCode;
    }
    if (request.method != 'POST' ||
        request.url.path != '/v1/containers' ||
        response.statusCode < 200 ||
        response.statusCode >= 300) {
      return response;
    }

    final bytes = await response.stream.toBytes();
    try {
      final json = jsonDecode(utf8.decode(bytes));
      if (json case {'id': final String id} when id.isNotEmpty) {
        createdId = id;
      }
    } on FormatException {
      // Let the public parser report malformed responses without logging them.
    }

    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  void close() => _inner.close();
}
