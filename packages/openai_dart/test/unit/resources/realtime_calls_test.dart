import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';

void main() {
  group('RealtimeCallsResource.accept', () {
    test(
      'with no request body posts {} to /realtime/calls/{id}/accept',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response('', 200);
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.realtimeSessions.calls.accept('call_abc123');

        final request = await requestCompleter.future as http.Request;
        expect(request.method, equals('POST'));
        expect(
          request.url.path,
          endsWith('/realtime/calls/call_abc123/accept'),
        );
        expect(jsonDecode(request.body), equals(<String, dynamic>{}));
      },
    );

    test(
      'with request body JSON-encodes session config and injects type=realtime',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response('', 200);
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.realtimeSessions.calls.accept(
          'call_xyz789',
          request: const RealtimeSessionCreateRequest(
            model: 'gpt-realtime-2',
            audio: RealtimeAudioConfig(
              output: RealtimeAudioConfigOutput(voice: 'alloy'),
            ),
            instructions: 'Greet the caller in English.',
          ),
        );

        final request = await requestCompleter.future as http.Request;
        expect(request.method, equals('POST'));
        expect(
          request.url.path,
          endsWith('/realtime/calls/call_xyz789/accept'),
        );
        expect(
          request.headers['authorization'] ?? request.headers['Authorization'],
          equals('Bearer sk-test-key'),
        );

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['model'], equals('gpt-realtime-2'));
        expect(body['instructions'], equals('Greet the caller in English.'));
        expect(
          body['audio'],
          equals(<String, dynamic>{
            'output': <String, dynamic>{'voice': 'alloy'},
          }),
        );
        // The accept endpoint requires a `type` discriminator on the
        // embedded session — the helper injects it when the caller didn't
        // set it explicitly.
        expect(body['type'], equals('realtime'));
      },
    );

    test('preserves explicit type discriminator from the caller', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response('', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.realtimeSessions.calls.accept(
        'call_typed',
        request: const RealtimeSessionCreateRequest(
          model: 'gpt-realtime-2',
          type: 'realtime',
        ),
      );

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['type'], equals('realtime'));
    });

    test('accepts abortTrigger parameter', () async {
      // Companion to the abort-trigger pattern shared with streaming
      // methods (see streaming_abort_test.dart): we only verify here
      // that the parameter is accepted and the request flows through.
      // The interceptor chain already has dedicated abort tests.
      final mockClient = MockClient((request) async => http.Response('', 200));

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      final completer = Completer<void>();
      await client.realtimeSessions.calls.accept(
        'call_abort',
        abortTrigger: completer.future,
      );

      // Without an abort, the request completes normally — the parameter
      // is wired through without affecting the happy path.
      expect(completer.isCompleted, isFalse);
    });
  });
}
