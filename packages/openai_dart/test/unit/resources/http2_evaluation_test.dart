// ignore_for_file: experimental_member_use

@TestOn('vm')
@Timeout(Duration(seconds: 20))
library;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http2/client.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

import '../fixtures/http2/loopback_peer.dart';

void main() {
  late LoopbackPeer peer;
  final clients = <http.Client>[];
  setUp(() async {
    peer = await LoopbackPeer.start();
  });
  tearDown(() async {
    // Destroy local sockets before graceful candidate close to bound failed cases.
    await peer.close();
    for (final client in clients) {
      client.close();
    }
    clients.clear();
  });
  Http2Client candidate({int maxStreams = 100}) {
    final client = peer.http2(maxStreams: maxStreams);
    clients.add(client);
    return client;
  }

  test(
    'public JSON negotiates h2 and OpenAI close preserves borrowed client',
    () async {
      final transport = candidate();
      final api = peer.openai(transport);
      final result = await api.responses.create(fixtureRequest());
      expect(result.id, 'resp_fixture');
      api.close();
      expect(
        (await transport.get(Uri.parse('${peer.baseUrl}/probe'))).statusCode,
        200,
      );
      final stats = await peer.command('stats');
      expect(stats['connections'], 1);
      expect(stats['h2Sessions'], 1);
      expect(
        requestRecords(stats).every((r) => r['protocol'] == '2.0'),
        isTrue,
      );
    },
  );

  for (final mode in ['json-hold', 'body-hold']) {
    test(
      'candidate public JSON ignores native abort $mode (known blocker)',
      () async {
        final transport = candidate();
        final probed = _HeadersProbe(transport);
        final api = peer.openai(probed, mode: mode);
        final abort = Completer<void>();
        var settled = false;
        final future = api.responses
            .create(fixtureRequest(), abortTrigger: abort.future)
            .whenComplete(() {
              settled = true;
            });
        await _records(peer, (records) => records.isNotEmpty);
        if (mode == 'body-hold') {
          await probed.headers.future.timeout(const Duration(seconds: 2));
        } else {
          expect(probed.headers.isCompleted, isFalse);
        }
        abort.complete();
        await Future<void>.delayed(const Duration(milliseconds: 100));
        expect(settled, isFalse);
        expect(
          requestRecords(await peer.command('stats')).single['reset'],
          isFalse,
        );
        await peer.command('release');
        expect((await future).id, 'resp_fixture');
        api.close();
      },
    );
  }

  test(
    'already completed abort trigger is ignored by candidate public JSON',
    () async {
      final api = peer.openai(candidate());
      expect(
        (await api.responses.create(
          fixtureRequest(),
          abortTrigger: Future<void>.value(),
        )).id,
        'resp_fixture',
      );
      expect((await peer.command('stats'))['requests'], 1);
      api.close();
    },
  );

  for (final mode in ['json-hold', 'body-hold']) {
    test('HTTP1 baseline aborts pending public JSON $mode', () async {
      final transport = peer.http1();
      clients.add(transport);
      final probe = _HeadersProbe(transport);
      final api = peer.openai(probe, mode: mode);
      final abort = Completer<void>();
      final check = expectLater(
        api.responses.create(fixtureRequest(), abortTrigger: abort.future),
        throwsA(isA<AbortedException>()),
      );
      await _records(peer, (records) => records.isNotEmpty);
      if (mode == 'body-hold') {
        await probe.headers.future;
      }
      abort.complete();
      await check.timeout(const Duration(seconds: 2));
      api.close();
    });
  }
  test(
    'Responses SSE abort closes dedicated client but does not release h2 stream',
    () async {
      final shared = candidate();
      final dedicated = candidate();
      final api = peer.openai(
        shared,
        mode: 'sse-hold',
        streamFactory: () => dedicated,
      );
      final abort = Completer<void>();
      final first = Completer<void>();
      final done = Completer<void>();
      final events = <ResponseStreamEvent>[];
      final subscription = api.responses
          .createStream(fixtureRequest(), abortTrigger: abort.future)
          .listen(
            (event) {
              events.add(event);
              if (!first.isCompleted) first.complete();
            },
            onDone: done.complete,
            onError: done.completeError,
          );
      await first.future;
      abort.complete();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(done.isCompleted, isFalse);
      expect(
        requestRecords(await peer.command('stats')).single['reset'],
        isFalse,
      );
      await peer.command('release');
      await done.future;
      expect(
        events,
        hasLength(2),
      ); // Data still delivered after requested abortion.
      await subscription.cancel();
      await dedicated.closed.timeout(const Duration(seconds: 2));
      expect(
        (await shared.get(Uri.parse('${peer.baseUrl}/probe'))).statusCode,
        200,
      );
      api.close();
    },
  );

  test(
    'public SSE subscription cancel resets only its stream; shared request survives',
    () async {
      final transport = candidate();
      final api = peer.openai(transport, mode: 'sse-hold');
      final first = Completer<void>();
      final subscription = api.responses.createStream(fixtureRequest()).listen((
        _,
      ) {
        if (!first.isCompleted) first.complete();
      });
      await first.future;
      var canceled = false;
      final cancel = subscription.cancel().then((_) {
        canceled = true;
      });
      await cancel.timeout(const Duration(seconds: 2));
      expect(canceled, isTrue);
      await _records(peer, (records) => records.first['reset'] == true);
      final normal = peer.openai(transport);
      expect(
        (await normal.responses.create(fixtureRequest())).id,
        'resp_fixture',
      );
      expect((await peer.command('stats'))['connections'], 1);
      await peer.command('release');
      await cancel.timeout(const Duration(seconds: 2));
      api.close();
      normal.close();
    },
  );

  test(
    'raw subscription cancel promptly resets only one shared h2 stream',
    () async {
      final transport = candidate();
      final response = await transport.send(
        http.Request('GET', Uri.parse('${peer.baseUrl}/probe'))
          ..headers['x-fixture-mode'] = 'sse-hold',
      );
      final first = Completer<void>();
      final subscription = response.stream.listen((_) {
        if (!first.isCompleted) first.complete();
      });
      await first.future;
      await subscription.cancel();
      final api = peer.openai(transport);
      expect((await api.responses.create(fixtureRequest())).id, 'resp_fixture');
      final stats = await _records(
        peer,
        (records) => records.first['reset'] == true,
      );
      expect(stats['connections'], 1);
      api.close();
    },
  );

  test(
    'graceful close waits for active public SSE, rejects new requests',
    () async {
      final transport = candidate();
      final api = peer.openai(transport, mode: 'sse-hold');
      final first = Completer<void>();
      final stream = api.responses.createStream(fixtureRequest()).listen((_) {
        if (!first.isCompleted) first.complete();
      });
      await first.future;
      var closed = false;
      transport.close();
      unawaited(
        transport.closed.then((_) {
          closed = true;
        }),
      );
      await expectLater(
        transport.get(Uri.parse('${peer.baseUrl}/probe')),
        throwsA(isA<http.ClientException>()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(closed, isFalse);
      await peer.command('release');
      await transport.closed.timeout(const Duration(seconds: 2));
      await stream.cancel();
      api.close();
    },
  );

  test(
    'server GOAWAY preserves accepted SSE and next public JSON reconnects',
    () async {
      final transport = candidate();
      final api = peer.openai(transport, mode: 'sse-hold');
      final first = Completer<void>();
      final done = Completer<void>();
      final subscription = api.responses
          .createStream(fixtureRequest())
          .listen(
            (_) {
              if (!first.isCompleted) first.complete();
            },
            onDone: done.complete,
            onError: done.completeError,
          );
      await first.future;
      await peer.command('goaway');
      await peer.command('release');
      await done.future;
      final normal = peer.openai(transport);
      expect(
        (await normal.responses.create(fixtureRequest())).id,
        'resp_fixture',
      );
      expect(
        (await peer.command('stats'))['h2Sessions'],
        greaterThanOrEqualTo(2),
      );
      await subscription.cancel();
      api.close();
      normal.close();
    },
  );

  test(
    'configured stream cap opens another connection rather than queueing',
    () async {
      final transport = candidate(maxStreams: 2);
      final api = peer.openai(transport, mode: 'body-hold');
      final futures = [
        for (var i = 0; i < 5; i++) api.responses.create(fixtureRequest()),
      ];
      final stats = await _records(peer, (records) => records.length == 5);
      expect(stats['h2Sessions'], 3);
      await peer.command('release');
      await Future.wait(futures);
      api.close();
    },
  );

  test(
    'server advertised two-stream limit causes three connections for five public reads',
    () async {
      await peer.close();
      peer = await LoopbackPeer.start(streamLimit: 2);
      final transport = candidate();
      final api = peer.openai(transport, mode: 'body-hold');
      final reads = [
        for (var i = 0; i < 5; i++) api.responses.create(fixtureRequest()),
      ];
      final stats = await _records(peer, (records) => records.length == 5);
      expect(stats['h2Sessions'], 3);
      await peer.command('release');
      await Future.wait(reads);
      api.close();
    },
  );

  test(
    'Responses SSE abort before headers leaves request active until peer release',
    () async {
      final transport = candidate();
      final dedicated = candidate();
      final api = peer.openai(
        transport,
        mode: 'sse-before',
        streamFactory: () => dedicated,
      );
      final abort = Completer<void>();
      final done = Completer<void>();
      var events = 0;
      final subscription = api.responses
          .createStream(fixtureRequest(), abortTrigger: abort.future)
          .listen(
            (_) {
              events++;
            },
            onDone: done.complete,
            onError: done.completeError,
          );
      await _records(peer, (records) => records.isNotEmpty);
      abort.complete();
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(events, 0);
      expect(done.isCompleted, isFalse);
      expect(
        requestRecords(await peer.command('stats')).single['reset'],
        isFalse,
      );
      await peer.command('release');
      await done.future;
      expect(events, 1);
      await subscription.cancel();
      await dedicated.closed;
      api.close();
    },
  );

  test(
    'public multipart upload and adapter streamed body are fully buffered',
    () async {
      final transport = candidate();
      final api = peer.openai(transport);
      final file = await api.files.upload(
        bytes: Uint8List(1024 * 1024),
        filename: 'fixture.bin',
        purpose: FilePurpose.assistants,
      );
      expect(file.bytes, greaterThan(1024 * 1024));
      final request = http.StreamedRequest(
        'POST',
        Uri.parse('${peer.baseUrl}/files'),
      );
      final sent = transport.send(request);
      request.sink.add(Uint8List(65536));
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(
        (await peer.command('stats'))['requests'],
        1,
      ); // No partial second upload.
      request.sink.add(Uint8List(65536));
      await request.sink.close();
      final response = await sent;
      await response.stream.drain<void>();
      expect(
        requestRecords(await peer.command('stats')).last['bodyBytes'],
        131072,
      );
      api.close();
    },
  );

  test(
    'paused candidate response admits bounded 4MiB before consumer resumes',
    () async {
      final transport = candidate();
      final request = http.Request('GET', Uri.parse('${peer.baseUrl}/download'))
        ..headers['x-fixture-mode'] = 'download';
      final response = await transport.send(request);
      final done = Completer<void>();
      var bytes = 0;
      final subscription = response.stream.listen(
        (chunk) {
          bytes += chunk.length;
        },
        onDone: done.complete,
        onError: done.completeError,
      )..pause();
      final stats = await _records(
        peer,
        (records) => records.single['finished'] == true,
      );
      expect(requestRecords(stats).single['sentBytes'], 4 * 1024 * 1024);
      expect(bytes, 0);
      subscription.resume();
      await done.future;
      expect(bytes, 4 * 1024 * 1024);
      await subscription.cancel();
    },
  );

  for (final kind in ['plain', 'http1']) {
    test(
      'public client rejects $kind endpoint rather than falling back',
      () async {
        final url = kind == 'plain'
            ? 'http://127.0.0.1:${peer.ready['plainPort']}/v1'
            : 'https://127.0.0.1:${peer.ready['http1Port']}/v1';
        final api = peer.openai(candidate(), url: url);
        await expectLater(
          api.responses.create(fixtureRequest()),
          throwsA(isA<http.ClientException>()),
        );
        api.close();
      },
    );
  }

  test('redirect and gzip behavior differs from IO baseline', () async {
    final h2 = candidate();
    final h1 = peer.http1();
    clients.add(h1);
    for (final mode in ['redirect', 'gzip']) {
      final requestUrl = Uri.parse('${peer.baseUrl}/probe');
      final direct = await h2.get(
        requestUrl,
        headers: {'x-fixture-mode': mode},
      );
      final baseline = await h1.get(
        requestUrl,
        headers: {'x-fixture-mode': mode},
      );
      if (mode == 'redirect') {
        expect(direct.statusCode, 302);
        expect(baseline.statusCode, 200);
      } else {
        expect(direct.bodyBytes.take(2), [31, 139]);
        expect(baseline.body, contains('resp_fixture'));
      }
    }
  });

  test(
    'reusing public SSE h2 connection reproduces local interoperability failure',
    () async {
      final transport = candidate();
      final api = peer.openai(transport, mode: 'sse');
      expect(
        await api.responses.createStream(fixtureRequest()).toList(),
        hasLength(10),
      );
      await peer.command('stats');
      await expectLater(
        api.responses.createStream(fixtureRequest()).toList(),
        throwsA(isA<http.ClientException>()),
      );
      api.close();
    },
  );

  test(
    'reusable HTTP1 baseline completes consecutive public SSE requests',
    () async {
      final transport = peer.http1();
      clients.add(transport);
      final api = peer.openai(transport, mode: 'sse');
      for (var i = 0; i < 2; i++) {
        expect(
          await api.responses.createStream(fixtureRequest()).toList(),
          hasLength(10),
        );
      }
      expect((await peer.command('stats'))['connections'], 1);
      api.close();
    },
  );

  test(
    'Node reference client completes eight SSE requests on one h2 connection',
    () async {
      final stats = await peer.command('reference-sse');
      expect(stats['reference'], {'successful': 8, 'events': 80});
      expect(stats['h2Sessions'], 1);
    },
  );

  test(
    'IO explicit proxy hook is absent from the candidate direct dial',
    () async {
      var proxyCalls = 0;
      final io = HttpClient(context: peer.context)
        ..findProxy = (_) {
          proxyCalls++;
          return 'PROXY 127.0.0.1:1';
        };
      final baseline = IOClient(io);
      clients.add(baseline);
      await expectLater(
        baseline.get(Uri.parse('${peer.baseUrl}/probe')),
        throwsA(isA<http.ClientException>()),
      );
      expect(proxyCalls, 1);
      expect(
        (await candidate().get(Uri.parse('${peer.baseUrl}/probe'))).statusCode,
        200,
      );
      expect(proxyCalls, 1);
    },
  );
}

Future<Map<String, dynamic>> _records(
  LoopbackPeer peer,
  bool Function(List<Map<String, dynamic>>) predicate,
) async {
  final deadline = DateTime.now().add(const Duration(seconds: 3));
  while (DateTime.now().isBefore(deadline)) {
    final snapshot = await peer.command('stats');
    if (predicate(requestRecords(snapshot))) return snapshot;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  throw StateError('Bounded peer observation timed out');
}

class _HeadersProbe extends http.BaseClient {
  _HeadersProbe(this.inner);
  final http.Client inner;
  final headers = Completer<void>();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await inner.send(request);
    if (!headers.isCompleted) headers.complete();
    return response;
  }

  @override
  void close() => inner.close();
}
