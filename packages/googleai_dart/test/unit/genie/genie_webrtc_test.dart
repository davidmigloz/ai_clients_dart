import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _token = 'auth_tokens/rtc+fixture';
const _deadline = Duration(seconds: 3);

class _Peer implements GenieWebRtcPeer, GenieWebRtcDataChannel {
  final calls = <String>[];
  final sent = <Map<String, dynamic>>[];
  final channel = StreamController<Object>();
  final channelOpened = Completer<void>();
  String offer = 'v=0\r\ns=offline-offer\r\n';
  bool openAfterAnswer = true;
  final closed = Completer<void>();

  @override
  int? maxMessageSize = 1024;

  @override
  void addReceiveOnlyTransceiver(GenieWebRtcMediaKind kind) {
    calls.add('recvonly:${kind.name}');
  }

  @override
  GenieWebRtcDataChannel createDataChannel(String label) {
    calls.add('channel:$label');
    return this;
  }

  @override
  Future<String> createOffer() async {
    calls.add('offer');
    return offer;
  }

  @override
  Future<void> setAnswer(String sdp) async {
    calls.add('answer:$sdp');
    if (openAfterAnswer) channelOpened.complete();
  }

  @override
  Future<void> get opened => channelOpened.future;

  @override
  Stream<Object> get messages => channel.stream;

  @override
  void sendText(String message) {
    final frame = jsonDecode(message) as Map<String, dynamic>;
    sent.add(frame);
    if (frame['event_type'] == 'interaction.complete') {
      emit({
        'event_type': 'interaction.completed',
        'status': {'code': 0},
      }, binary: true);
    }
  }

  void emit(Map<String, dynamic> event, {bool binary = false}) {
    final text = jsonEncode(event);
    channel.add(binary ? utf8.encode(text) : text);
  }

  @override
  Future<void> flush() async => calls.add('flush');

  @override
  Future<void> close() async {
    calls.add('close');
    unawaited(channel.close());
    closed.complete();
  }
}

class _PendingSignaling extends http.BaseClient {
  final requestStarted = Completer<void>();
  final requestAborted = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final abortable = request as http.Abortable;
    expect(request.followRedirects, isFalse);
    requestStarted.complete();
    await abortable.abortTrigger;
    requestAborted.complete();
    throw http.RequestAbortedException(request.url);
  }
}

http.Response _answer(String sdp) =>
    http.Response(jsonEncode({'answer_sdp': sdp}), 200);

GenieResource _genie(http.Client transport, {GoogleAIConfig? config}) {
  final client = GoogleAIClient(
    config: config ?? const GoogleAIConfig(),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client.interactions.genie;
}

void main() {
  test(
    'negotiates v1beta SDP with scoped auth and uses the ordered controls',
    () async {
      final peer = _Peer();
      const answer = 'v=0\r\ns=offline-answer\r\n';
      final genie = _genie(
        MockClient((request) async {
          expect(peer.calls, [
            'recvonly:audio',
            'recvonly:video',
            'channel:events',
            'offer',
          ]);
          expect(request.method, 'POST');
          expect(request.url.pathSegments, [
            'proxy',
            'v1beta',
            'interactions',
            'int/test:webrtc',
          ]);
          expect(request.url.queryParametersAll, {
            'proxy': ['a', 'b'],
            'trace': ['on'],
          });
          expect(request.url.fragment, isEmpty);
          expect(request.headers['content-type'], 'application/json');
          expect(request.headers['accept'], 'application/json');
          expect(request.headers['x-goog-api-key'], _token);
          expect(request.headers['api-revision'], isNull);
          expect(request.headers['authorization'], isNull);
          expect(request.headers['x-proxy'], 'keep');
          expect(jsonDecode(request.body), {'offer_sdp': peer.offer});
          peer.emit({'event_type': 'interaction.connected'});
          return _answer(answer);
        }),
        config: const GoogleAIConfig(
          baseUrl:
              'https://proxy.invalid/proxy/?key=old&proxy=a&proxy=b#remove',
          apiVersion: ApiVersion.v1,
          interactionsApiVersion: ApiVersion.v1,
          authProvider: ApiKeyProvider('raw-inherited-key'),
          defaultHeaders: {
            'API-Revision': 'stale',
            'X-Goog-Api-Key': 'stale',
            'Authorization': 'stale',
            'x-proxy': 'keep',
          },
          defaultQueryParams: {'auth_token': 'stale', 'trace': 'on'},
        ),
      );
      final session = await genie.connectWebRtc(
        'int/test',
        authToken: _token,
        peer: peer,
        timeout: _deadline,
      );
      addTearDown(session.detach);
      expect(peer.calls.last, 'answer:$answer');
      expect(
        peer.sent,
        isEmpty,
      ); // Signaling already associated the interaction ID.
      expect(await session.receive().first, isA<GenieConnectedEvent>());
      expect(
        () => session.send(GenieWorldSetup(prompt: '♫' * 400)),
        throwsArgumentError,
      );
      session.sendBatch([
        const GenieWorldSetup(prompt: 'A port town'),
        const GenieUserAction(
          action: GenieAction.keyClick,
          key: GenieKey.arrowUp,
        ),
      ]);
      expect(peer.sent.single, {
        'events': [
          {
            'event_type': 'world_setup',
            'world_prompt': {'text': 'A port town'},
          },
          {
            'event_type': 'user_action',
            'action': 'key_click',
            'input': 'arrow_up',
          },
        ],
      });
      final received = session.receive().toList();
      await session.complete();
      expect(peer.sent.last, {'event_type': 'interaction.complete'});
      expect(await received, [isA<GenieTerminalEvent>()]);
      await peer.closed.future;
      expect(peer.calls.sublist(peer.calls.length - 2), ['flush', 'close']);
    },
  );

  test(
    'bounds the default SCTP message size when no limit was negotiated',
    () async {
      final peer = _Peer()..maxMessageSize = null;
      final session = await _genie(MockClient((_) async => _answer('fixture')))
          .connectWebRtc(
            'int_default',
            authToken: _token,
            peer: peer,
            timeout: _deadline,
          );
      expect(
        () => session.send(GenieWorldSetup(prompt: '森' * 22000)),
        throwsArgumentError,
      );
      expect(peer.sent, isEmpty);
      session.send(const GenieWorldSetup(prompt: 'A woodland'));
      await session.cancel();
      expect(peer.sent.last, {'event_type': 'interaction.cancel'});
      expect(peer.calls.sublist(peer.calls.length - 2), ['flush', 'close']);
    },
  );

  test(
    'closes failed peers and keeps credentials and SDP out of HTTP errors',
    () async {
      final peer = _Peer();
      final genie = _genie(
        MockClient(
          (_) async => http.Response('echo $_token ${peer.offer}', 403),
        ),
      );
      await expectLater(
        genie.connectWebRtc(
          'int_failed',
          authToken: _token,
          peer: peer,
          timeout: _deadline,
        ),
        throwsA(
          isA<GenieConnectionException>()
              .having((error) => error.httpStatus, 'status', 403)
              .having(
                (error) => error.toString(),
                'diagnostic',
                allOf(isNot(contains(_token)), isNot(contains(peer.offer))),
              )
              .having((error) => error.cause, 'cause', isNull),
        ),
      );
      await peer.closed.future;
      expect(peer.calls, [
        'recvonly:audio',
        'recvonly:video',
        'channel:events',
        'offer',
        'close',
      ]);
    },
  );

  test(
    'rejects malformed signaling answers before opening a channel',
    () async {
      final peer = _Peer();
      await expectLater(
        _genie(MockClient((_) async => _answer('  '))).connectWebRtc(
          'int_malformed',
          authToken: _token,
          peer: peer,
          timeout: _deadline,
        ),
        throwsA(
          isA<GenieConnectionException>().having(
            (error) => error.message,
            'message',
            contains('SDP answer'),
          ),
        ),
      );
      await peer.closed.future;
      expect(peer.calls, isNot(contains(startsWith('answer:'))));
    },
  );

  test('a signaling timeout interrupts HTTP and releases the peer', () async {
    final transport = _PendingSignaling();
    final peer = _Peer();
    final failure = expectLater(
      _genie(transport).connectWebRtc(
        'int_signal_timeout',
        authToken: _token,
        peer: peer,
        timeout: const Duration(milliseconds: 100),
      ),
      throwsA(
        isA<GenieConnectionException>().having(
          (error) => error.message,
          'message',
          contains('Timed out'),
        ),
      ),
    );
    await transport.requestStarted.future.timeout(_deadline);
    await failure;
    await transport.requestAborted.future.timeout(_deadline);
    await peer.closed.future.timeout(_deadline);
    expect(peer.calls, isNot(contains(startsWith('answer:'))));
  });

  test(
    'times out and releases a peer whose control channel never opens',
    () async {
      final peer = _Peer()..openAfterAnswer = false;
      await expectLater(
        _genie(MockClient((_) async => _answer('fixture'))).connectWebRtc(
          'int_timeout',
          authToken: _token,
          peer: peer,
          timeout: const Duration(milliseconds: 100),
        ),
        throwsA(
          isA<GenieConnectionException>().having(
            (error) => error.message,
            'message',
            contains('Timed out'),
          ),
        ),
      );
      await peer.closed.future;
      expect(peer.calls, contains('answer:fixture'));
    },
  );
}
