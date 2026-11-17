import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

import 'webhook_verifier_vectors.dart';

const _identifier = 'stable-pseudonym';
const _credential = 'synthetic-mcp-credential';
const _sessionId = 'live_fixture';

LiveMCPTool _mcp() => LiveMCPTool(
  serverLabel: 'Handbook',
  serverUrl: 'https://server.example/mcp',
  serverDescription: 'Company handbook lookup',
  authorization: _credential,
  headers: const {'X-Fixture': 'private-value'},
  allowedTools: LiveMCPAllowedTools.names(const ['lookup']),
  requireApproval: LiveMCPApprovalFilter(
    always: LiveMCPToolFilter(toolNames: const ['lookup'], readOnly: true),
  ),
  allowedCallers: const [
    LiveCallableToolAllowedCaller.direct,
    LiveCallableToolAllowedCaller.programmatic,
  ],
  deferLoading: false,
  rawJson: const {
    'future': {'value': 1},
  },
);

LiveResponsesDelegationParam _delegation(LiveMCPTool tool) =>
    LiveResponsesDelegationParam(
      responses: LiveResponsesDelegationSettingsInputParam(
        model: 'gpt-6.2-sol',
        tools: [tool],
        toolChoice: LiveMCPToolChoice(serverLabel: 'Handbook', name: 'lookup'),
      ),
    );

Map<String, dynamic> _session(LiveMCPTool tool) => {
  'id': _sessionId,
  'model': 'gpt-live-1',
  'expires_at': 10,
  'status': 'active',
  'safety_identifier': _identifier,
  'delegation': _delegation(tool).toJson(),
};

void main() {
  test('new Live voice constants keep their exact wire spelling', () {
    const voices = [
      LiveVoice.calandria,
      LiveVoice.compas,
      LiveVoice.destello,
      LiveVoice.halo,
      LiveVoice.hornero,
      LiveVoice.luciernaga,
      LiveVoice.pearl,
    ];
    expect(voices.map((voice) => voice.toJson()), [
      'calandria',
      'compas',
      'destello',
      'halo',
      'hornero',
      'luciernaga',
      'pearl',
    ]);
    for (final voice in voices) {
      expect(LiveVoice.fromJson(voice.toJson()), voice);
    }
  });

  test('MCP lists, filters and approval choices preserve exact wire shape', () {
    final tool = _mcp();
    final json = tool.toJson();

    expect(json['allowed_tools'], ['lookup']);
    expect(json['allowed_callers'], ['direct', 'programmatic']);
    expect(json['require_approval'], {
      'always': {
        'tool_names': ['lookup'],
        'read_only': true,
      },
    });
    final restored = LiveTool.fromJson(json) as LiveMCPTool;
    expect(restored, tool);
    expect(restored.hashCode, tool.hashCode);
    expect(restored.headers, {'X-Fixture': 'private-value'});
    expect(restored.toString(), isNot(contains(_credential)));
    expect(
      () => restored.headers!['mutated'] = 'value',
      throwsUnsupportedError,
    );

    final updated = tool.copyWith(
      allowedTools: LiveMCPToolFilter(readOnly: true),
      requireApproval: LiveMCPApproval.always,
    );
    expect(updated.toJson()['allowed_tools'], {'read_only': true});
    expect(updated.toJson()['require_approval'], 'always');
    expect(
      LiveMCPTool.fromJson(const {
        'type': 'mcp',
        'authorization': null,
        'allowed_tools': null,
        'require_approval': {'never': null},
      }).toJson(),
      {
        'type': 'mcp',
        'authorization': null,
        'allowed_tools': null,
        'require_approval': {'never': null},
      },
    );
    for (final invalid in [
      {'server_label': 'x space'},
      {'server_url': '/relative'},
      {'tunnel_id': 'fixture'},
      {'allowed_callers': <String>[]},
      {
        'allowed_callers': ['other'],
      },
      {
        'headers': {'X-Fake': 2},
      },
      {'require_approval': 'auto'},
    ]) {
      expect(
        () => LiveMCPTool.fromJson({'type': 'mcp', ...invalid}),
        throwsFormatException,
      );
    }
  });

  test('copying a Live MCP tool can retain, rotate, or remove credentials', () {
    final tool = _mcp();
    final kept = tool.copyWith();
    expect(kept.authorization, _credential);
    expect(kept.headers, tool.headers);

    final rotated = tool.copyWith(
      authorization: 'replacement-credential',
      headers: const {'X-Fresh': 'replacement-metadata'},
    );
    expect(rotated.toJson()['authorization'], 'replacement-credential');
    expect(rotated.toJson()['headers'], {'X-Fresh': 'replacement-metadata'});

    final cleared = tool.copyWith(authorization: null, headers: null);
    expect(cleared.authorization, isNull);
    expect(cleared.headers, isNull);
    expect(cleared.toJson(), isNot(contains('authorization')));
    expect(cleared.toJson(), isNot(contains('headers')));
    expect(tool.authorization, _credential);
  });

  test('Live HTTP sends startup ID and credentials only on requests', () async {
    final expected = _mcp();
    final session = _session(expected);
    final requests = <http.Request>[];
    final client = OpenAIClient(
      httpClient: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/accept')) {
          return http.Response('', 200);
        }
        return http.Response(
          jsonEncode({
            'session': session,
            'transport': {'type': 'sip'},
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
    );
    addTearDown(client.close);
    final created = await client.live.sessions.create(
      LiveSessionCreateRequest(
        session: LiveMediaSessionCreateParams(
          model: 'gpt-live-1',
          safetyIdentifier: _identifier,
          delegation: _delegation(expected),
        ),
        transport: LiveSIPTransport(
          destination: '+14155550123',
          trunk: LiveSIPTrunk(
            providerUrl: 'sips:sip.example.org:5061',
            auth: LiveSIPTrunkAuth(username: 'fixture', password: 'fixture'),
            callerNumber: '+14155550100',
          ),
        ),
      ),
    );
    await client.live.sessions.accept(
      _sessionId,
      LiveCallAcceptRequest(
        session: LiveCallAcceptSession(
          model: 'gpt-live-1',
          safetyIdentifier: _identifier,
          delegation: _delegation(expected),
        ),
      ),
    );

    expect(requests.map((request) => request.url.path), [
      '/v1/live/sessions',
      '/v1/live/sessions/live_fixture/accept',
    ]);
    for (final request in requests) {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final sent = body['session'] as Map<String, dynamic>;
      expect(sent['safety_identifier'], _identifier);
      final delegation = sent['delegation'] as Map<String, dynamic>;
      expect(delegation, _delegation(expected).toJson());
    }
    expect(created.session.id, _sessionId);
    expect(created.transport.type, 'sip');
    for (final json in [
      created.rawJson,
      created.session.rawJson,
      created.toJson(),
    ]) {
      expect(jsonEncode(json), isNot(contains(_credential)));
      expect(jsonEncode(json), isNot(contains('X-Fixture')));
      expect(jsonEncode(json), contains('Handbook'));
    }
  });

  test(
    'WebSocket startup and update send secrets, received snapshots omit them',
    () async {
      final socket = _Socket();
      final client = OpenAIClient(
        httpClient: MockClient(
          (_) async => throw StateError('No REST expected'),
        ),
      );
      addTearDown(client.close);
      final connection = await client.live.connect(
        connector: (uri, {headers}) async => socket,
      );
      addTearDown(connection.close);
      final events = <LiveServerEvent>[];
      final subscription = connection.events.listen(events.add);
      addTearDown(subscription.cancel);
      final tool = _mcp();
      final started = connection.start(
        LiveSessionStartEvent(
          session: LiveSessionCreateParams(
            model: 'gpt-live-1',
            safetyIdentifier: _identifier,
            delegation: _delegation(tool),
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(socket.writes.first['type'], 'session.start');
      expect(jsonEncode(socket.writes.first), contains(_identifier));
      expect(jsonEncode(socket.writes.first), contains(_credential));

      final reflected = _session(tool);
      socket.emit({
        'type': 'session.started',
        'event_id': 'started',
        'session': reflected,
      });
      await started;

      connection.send(
        LiveSessionUpdateParam(
          session: LiveSessionUpdateParams(
            delegation: LiveResponsesDelegationUpdateParam(
              responses: LiveResponsesDelegationSettingsUpdateInputParam(
                toolChoice: LiveMCPToolChoice(serverLabel: 'Handbook'),
                tools: [tool.copyWith(requireApproval: LiveMCPApproval.always)],
              ),
            ),
          ),
        ),
      );
      expect(socket.writes.last['type'], 'session.update');
      expect(jsonEncode(socket.writes.last), contains(_credential));
      expect(
        jsonEncode(socket.writes.last),
        isNot(contains('safety_identifier')),
      );
      socket.emit({
        'type': 'session.updated',
        'event_id': 'updated',
        'session': reflected,
      });
      await Future<void>.delayed(Duration.zero);

      final session = connection.currentSession!;
      expect(session.safetyIdentifier, _identifier);
      final delegation = session.delegation! as LiveResponsesDelegationParam;
      final received = delegation.responses.tools!.single as LiveMCPTool;
      expect(received.serverLabel, 'Handbook');
      expect(received.allowedTools, tool.allowedTools);
      expect(received.authorization, isNull);
      expect(received.headers, isNull);
      expect(received.rawJson['future'], {'value': 1});
      final updated = events.whereType<LiveSessionUpdated>().single;
      for (final json in [
        updated.rawJson,
        updated.toJson(),
        session.rawJson,
        session.toJson(),
        received.rawJson,
      ]) {
        expect(jsonEncode(json), isNot(contains(_credential)));
        expect(jsonEncode(json), isNot(contains('X-Fixture')));
      }
      expect(jsonEncode(reflected), contains(_credential));
    },
  );

  test('safety IDs distinguish omission and null and stay startup-only', () {
    final base = LiveSessionCreateParams(model: 'gpt-live-1');
    expect(base.toJson(), isNot(contains('safety_identifier')));
    final cleared = base.copyWith(safetyIdentifier: null);
    expect(cleared.hasSafetyIdentifier, isTrue);
    expect(cleared.toJson()['safety_identifier'], isNull);
    expect(
      cleared.copyWith(clearSafetyIdentifier: true).toJson(),
      isNot(contains('safety_identifier')),
    );
    expect(
      () => base.copyWith(safetyIdentifier: 'x' * 129),
      throwsFormatException,
    );
    expect(
      () => LiveSessionUpdateParams.fromJson(const {
        'safety_identifier': _identifier,
      }),
      throwsFormatException,
    );
    expect(
      () => LiveForkSessionConfigParam.fromJson(const {
        'safety_identifier': _identifier,
      }),
      throwsFormatException,
    );
    expect(
      base.copyWith(safetyIdentifier: _identifier).toString(),
      isNot(contains(_identifier)),
    );
  });

  test(
    'only Live Decisions function namespaces gain a 128-character limit',
    () {
      final message = {
        'type': 'function_call',
        'name': 'lookup',
        'call_id': 'call_fixture',
        'arguments': '{}',
        'namespace': 'x' * 128,
      };
      final call = LiveDecisionFunctionCallParam.fromJson(message);
      expect(call.toJson(), message);
      final stored = {...message, 'id': 'item_fixture'};
      expect(
        LiveDecisionStoredInputItemParam.fromJson(stored).toJson(),
        stored,
      );
      expect(() => call.copyWith(namespace: 'x' * 129), throwsFormatException);
      expect(
        () => LiveDecisionCustomToolCallParam.fromJson({
          'type': 'custom_tool_call',
          'name': 'lookup',
          'call_id': 'call_fixture',
          'input': '{}',
          'namespace': 'x' * 65,
        }),
        throwsFormatException,
      );
    },
  );

  test('subscribes to and verifies the connected WebRTC webhook', () async {
    const eventType = WebhookEventType.liveTransportConnected;
    final client = OpenAIClient(
      config: const OpenAIConfig(webhookSecret: officialWebhookTestSecret),
      httpClient: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['event_types'], ['live.transport.connected']);
        return http.Response(
          jsonEncode({
            ...body,
            'id': 'endpoint_fixture',
            'object': 'webhook_endpoint',
            'created_at': 1,
            'signing_secret_hint': null,
            'signing_secret': 'fixture-returned-once',
          }),
          200,
        );
      }),
    );
    addTearDown(client.close);
    final endpoint = await client.webhooks.create(
      WebhookEndpointCreateRequest(
        name: 'Live observer',
        url: 'https://receiver.example/live',
        eventTypes: const [eventType],
      ),
    );
    expect(endpoint.eventTypes, [eventType.value]);
    expect(WebhookEndpointTestRequest(eventType: eventType).toJson(), {
      'event_type': eventType.value,
    });

    final wire = {
      'id': 'evt_fixture',
      'object': 'event',
      'created_at': 1,
      'type': eventType.value,
      'data': {'type': 'webrtc', 'session_id': _sessionId},
    };
    final bytes = utf8.encode(jsonEncode(wire));
    final event =
        client.webhooks.unwrapBytes(bytes, _signed(bytes))
            as LiveTransportConnectedWebhookEvent;
    expect(event.data.sessionId, _sessionId);
    expect(event.data.type, 'webrtc');
    expect(event.toJson(), wire);
    expect(event.copyWith(), event);
    expect(event.copyWith().hashCode, event.hashCode);
    expect(
      () => WebhookEvent.fromJson({...wire}..remove('object')),
      throwsFormatException,
    );
    expect(
      () => WebhookEvent.fromJson({
        ...wire,
        'data': const {'type': 'sip', 'session_id': _sessionId},
      }),
      throwsFormatException,
    );

    final incoming = WebhookEvent.fromJson({
      ...wire,
      'type': 'live.transport.incoming',
      'data': const {
        'type': 'sip',
        'session_id': _sessionId,
        'sip_headers': <Object>[],
      },
    });
    expect(incoming, isA<LiveTransportIncomingWebhookEvent>());
  });
}

Map<String, String> _signed(List<int> bytes) {
  final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final signed = [...utf8.encode('delivery.$timestamp.'), ...bytes];
  final signature = Hmac(
    sha256,
    base64Decode(officialWebhookKeyBase64),
  ).convert(signed).bytes;
  return {
    'webhook-id': 'delivery',
    'webhook-timestamp': '$timestamp',
    'webhook-signature': 'v1,${base64Encode(signature)}',
  };
}

class _Socket implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  final List<Map<String, dynamic>> writes = [];

  void emit(Map<String, dynamic> json) =>
      _events.add(TextDataReceived(jsonEncode(json)));

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => '';

  @override
  void sendText(String text) =>
      writes.add(jsonDecode(text) as Map<String, dynamic>);

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('JSON fixture');

  @override
  Future<void> close([int? code, String? reason]) async {
    unawaited(_events.close());
  }
}
