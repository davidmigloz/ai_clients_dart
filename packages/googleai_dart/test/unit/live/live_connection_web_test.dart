@TestOn('browser')
library;

import 'dart:async';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

class _PendingProvider implements AuthProvider {
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() => credentials.future;
}

void main() {
  test('closing Live cancels the pending browser credential lookup', () async {
    final provider = _PendingProvider();
    final client = GoogleAIClient(
      config: GoogleAIConfig(authProvider: provider),
    );
    final live = client.createLiveClient();
    addTearDown(client.close);

    final connection = expectLater(
      live.connect(model: 'gemini-3.8-live'),
      throwsA(isA<LiveConnectionException>()),
    );
    await live.close();
    await connection;
    provider.credentials.completeError(StateError('late credential failure'));
    await Future<void>.delayed(Duration.zero);
  });

  test(
    'closing Live aborts a browser upgrade and allows reconnection',
    () async {
      final fixture = spawnHybridCode('''
      import 'dart:convert';
      import 'dart:io';
      import 'package:stream_channel/stream_channel.dart';

      Future<void> hybridMain(StreamChannel<Object?> channel) async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        var attempts = 0;
        server.listen((request) async {
          if (attempts++ == 0) {
            final socket = await request.response.detachSocket(writeHeaders: false);
            socket.listen(
              (_) {},
              onDone: () => channel.sink.add('disconnected'),
            );
            channel.sink.add('pending');
            return;
          }
          final socket = await WebSocketTransformer.upgrade(request);
          socket.listen((frame) {
            final setup = jsonDecode(frame as String) as Map<String, dynamic>;
            if (setup.containsKey('setup')) {
              socket.add(utf8.encode('{"setupComplete":{"sessionId":"browser"}}'));
            } else {
              socket.add('{"serverContent":{"turnComplete":true}}');
            }
          });
        });
        channel.sink.add(server.port);
        channel.stream.listen((_) {}, onDone: () => server.close(force: true));
      }
    ''');
      final states = StreamIterator(fixture.stream);
      addTearDown(states.cancel);
      addTearDown(fixture.sink.close);
      const deadline = Duration(seconds: 8);
      Future<bool> nextState(String phase) => states.moveNext().timeout(
        deadline,
        onTimeout: () =>
            throw StateError('Browser socket fixture timed out: $phase'),
      );
      expect(await nextState('listening'), isTrue);
      final port = (states.current as num).toInt();
      final client = GoogleAIClient(
        config: GoogleAIConfig(
          baseUrl: 'http://127.0.0.1:$port',
          authProvider: const EphemeralTokenProvider(
            'auth_tokens/browser-fixture',
          ),
        ),
      );
      addTearDown(client.close);
      final live = client.createLiveClient();
      addTearDown(live.close);

      final connection = expectLater(
        live.connect(model: 'gemini-3.8-live'),
        throwsA(isA<LiveConnectionException>()),
      );
      expect(await nextState('upgrade requested'), isTrue);
      expect(states.current, 'pending');
      await live.close().timeout(deadline);
      await connection.timeout(deadline);
      expect(await nextState('peer disconnected'), isTrue);
      expect(states.current, 'disconnected');

      final session = await live
          .connect(model: 'gemini-3.8-live')
          .timeout(deadline);
      expect(session.sessionId, 'browser');
      final response = session.messages.first;
      session.sendText('Hello');
      final message =
          await response.timeout(deadline) as BidiGenerateContentServerContent;
      expect(message.turnComplete, isTrue);
    },
  );

  test(
    'rejects Vertex OAuth headers before a browser network attempt',
    () async {
      final client = GoogleAIClient(
        config: GoogleAIConfig.vertexAI(
          projectId: 'P',
          authProvider: const BearerTokenProvider('adc-secret'),
        ),
      );
      final live = client.createLiveClient();
      addTearDown(client.close);
      addTearDown(live.close);

      await expectLater(
        live.connect(model: 'gemini-3.8-live'),
        throwsA(
          isA<LiveConnectionException>()
              .having(
                (error) => error.message,
                'guidance',
                contains('Vertex AI Live requires OAuth headers'),
              )
              .having((error) => error.uri?.query, 'URI query', isEmpty)
              .having(
                (error) => '${error.message} ${error.cause}',
                'diagnostics',
                isNot(contains('adc-secret')),
              ),
        ),
      );
    },
  );

  test('guides browser ephemeral auth to query placement', () async {
    final client = GoogleAIClient(
      config: const GoogleAIConfig.googleAI(
        authProvider: EphemeralTokenProvider(
          'auth_tokens/header-secret',
          placement: EphemeralTokenPlacement.header,
        ),
        defaultQueryParams: {'key': 'config-secret'},
      ),
    );
    final live = client.createLiveClient();
    addTearDown(client.close);
    addTearDown(live.close);

    await expectLater(
      live.connect(model: 'gemini-3.8-live'),
      throwsA(
        isA<LiveConnectionException>()
            .having(
              (error) => error.message,
              'guidance',
              contains('connect(accessToken: ...)'),
            )
            .having(
              (error) => error.uri?.path,
              'URI path',
              endsWith('.BidiGenerateContentConstrained'),
            )
            .having((error) => error.uri?.query, 'URI query', isEmpty)
            .having(
              (error) => '${error.message} ${error.cause}',
              'diagnostics',
              allOf(
                isNot(contains('header-secret')),
                isNot(contains('config-secret')),
              ),
            ),
      ),
    );
  });
}
