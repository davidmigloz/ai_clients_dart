import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Successful idle observer exceeds header timeout and keeps following events',
    () async {
      final transport = _PendingTransport();
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('synthetic'),
          timeout: Duration(milliseconds: 40),
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final received = <AgentSessionEvent>[];
      final errors = <Object>[];
      final headers = {'X-Captured': 'at-call'};
      final stream = client.agents.sessions.events.stream(
        'session',
        additionalHeaders: headers,
      );
      headers.clear();
      final sub = stream.listen(received.add, onError: errors.add);
      await transport.sent.future;
      transport.body.add(
        utf8.encode('data: {"type":"future","private":"café🚀"}\n\n'),
      );
      await Future<void>.delayed(const Duration(milliseconds: 180));
      expect(received, hasLength(1));
      expect(errors, isEmpty);
      transport.body.add(utf8.encode('data: {"type":"another-future"}\n\n'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(received, hasLength(2));
      expect(transport.request!.headers['x-captured'], 'at-call');
      await sub.cancel();
      expect(transport.cancelled, 1);
      expect(transport.calls, 1);
      expect(transport.closed, 0);
    },
  );
  for (final owned in [false, true]) {
    test(
      'Pending-header cancellation releases ${owned ? 'owned' : 'borrowed'} transport; late response is ignored',
      () async {
        final transport = _PendingTransport(pendingHeaders: true);
        final main = _PendingTransport();
        final client = OpenAIClient(
          config: const OpenAIConfig(authProvider: ApiKeyProvider('synthetic')),
          httpClient: owned ? main : transport,
          streamClientFactory: owned ? () => transport : null,
        );
        final received = <AgentSessionEvent>[];
        final sub = client.agents.sessions.events
            .stream('session')
            .listen(received.add);
        await transport.sent.future;
        sub.pause();
        await sub.cancel();
        transport.header.complete(
          http.StreamedResponse(
            transport.body.stream,
            200,
            request: transport.request,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 20));
        expect(received, isEmpty);
        expect(transport.closed, owned ? 1 : 0);
        expect(main.closed, 0);
        expect(transport.calls, 1);
        client.close();
        transport.close();
        main.close();
      },
    );
  }
  test(
    'Abort before headers never dispatches; after headers closes observation only',
    () async {
      final transport = _PendingTransport();
      final client = OpenAIClient.withApiKey(
        'synthetic',
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final before = Completer<void>()..complete();
      await expectLater(
        client.agents.sessions.events
            .stream('session', abortTrigger: before.future)
            .toList(),
        throwsA(isA<OpenAIException>()),
      );
      expect(transport.calls, 0);
      final after = Completer<void>();
      final observation = client.agents.sessions.events
          .stream('session', abortTrigger: after.future)
          .toList();
      await transport.sent.future;
      after.complete();
      await expectLater(observation, throwsA(isA<OpenAIException>()));
      expect(transport.calls, 1);
      expect(transport.cancelled, 1);
      expect(transport.closed, 0);
    },
  );
  test(
    'Failed HTTP body has total deadline even while chunks continue',
    () async {
      final transport = _PendingTransport(status: 403);
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('synthetic'),
          timeout: Duration(milliseconds: 70),
        ),
        httpClient: transport,
      );
      addTearDown(() {
        client.close();
        transport.close();
      });
      final observation = client.agents.sessions.events
          .stream('session')
          .toList();
      final timer = Timer.periodic(
        const Duration(milliseconds: 10),
        (_) => transport.body.add([32]),
      );
      addTearDown(timer.cancel);
      await expectLater(observation, throwsA(isA<OpenAIException>()));
      expect(transport.cancelled, 1);
      expect(transport.calls, 1);
    },
  );
  for (final body in <List<int>>[
    utf8.encode(
      'data: {"type":"agent.session.created","private":"PRIVATE"}\n\n',
    ),
    utf8.encode('data: PRIVATE-not-json\n\n'),
    <int>[100, 97, 116, 97, 58, 32, 255, 10, 10],
  ]) {
    test(
      'Malformed known event / JSON / UTF-8 fails privately: ${body.length}',
      () async {
        final transport = _BytesTransport(body);
        final client = OpenAIClient.withApiKey(
          'synthetic',
          httpClient: transport,
        );
        addTearDown(() {
          client.close();
          transport.close();
        });
        await expectLater(
          client.agents.sessions.events.stream('session').toList(),
          throwsA(
            isA<ParseException>().having(
              (e) => e.toString(),
              'private',
              isNot(contains('PRIVATE')),
            ),
          ),
        );
        expect(transport.calls, 1);
      },
    );
  }
  test(
    'Early EOF and DONE close only observer without inventing completion',
    () async {
      for (final bytes in [
        <int>[],
        utf8.encode('data: {"type":"future"}\n\ndata: [DONE]\n\n'),
      ]) {
        final transport = _BytesTransport(bytes);
        final client = OpenAIClient.withApiKey(
          'synthetic',
          httpClient: transport,
        );
        final events = await client.agents.sessions.events
            .stream('session')
            .toList();
        expect(events.length, bytes.isEmpty ? 0 : 1);
        expect(transport.calls, 1);
        expect(transport.closed, 0);
        client.close();
        transport.close();
      }
    },
  );
}

class _PendingTransport extends http.BaseClient {
  _PendingTransport({this.status = 200, this.pendingHeaders = false}) {
    body = StreamController<List<int>>(
      onCancel: () {
        cancelled++;
      },
    );
  }
  final int status;
  final bool pendingHeaders;
  late final StreamController<List<int>> body;
  final header = Completer<http.StreamedResponse>();
  final sent = Completer<void>();
  http.BaseRequest? request;
  int calls = 0;
  int cancelled = 0;
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest r) async {
    calls++;
    request = r;
    await r.finalize().drain<void>();
    sent.complete();
    if (pendingHeaders) return header.future;
    return http.StreamedResponse(
      body.stream,
      status,
      headers: {
        'content-type': status == 200
            ? 'text/event-stream'
            : 'application/json',
      },
      request: r,
    );
  }

  @override
  void close() {
    closed++;
    unawaited(body.close());
  }
}

class _BytesTransport extends http.BaseClient {
  _BytesTransport(this.bytes);
  final List<int> bytes;
  int calls = 0;
  int closed = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    calls++;
    await request.finalize().drain<void>();
    return http.StreamedResponse(Stream.value(bytes), 200, request: request);
  }

  @override
  void close() {
    closed++;
  }
}
