import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _agentId = 'd92ef2f2-3c66-4fc5-a2ef-7f0ab7e08932';
const _sessionId = 'e4a2ce6d-f8d1-42ac-a19b-a417a028793d';
const _credentials = VoiceAgentRoomCredentials(
  sessionId: _sessionId,
  serverUrl: 'wss://voice.example.test',
  participantToken: 'short-lived-fixture',
);
const Map<String, Object> _wireFunction = {
  'type': 'function',
  'function': {
    'name': 'lookup',
    'parameters': {'type': 'object'},
    'strict': true,
  },
  'timeout_ms': 1200,
  'filler': {'type': 'static', 'text': 'Looking it up'},
};
const Map<String, Object> _configuration = {
  'llm': {'model': 'mistral-small-latest'},
  'stt': {'language': 'en', 'target_streaming_delay_ms': 240},
  'tts': {'voice_id': 'voice_fixture'},
  'turn': {'allow_interruptions': false},
  'tools': [_wireFunction],
};
const Map<String, Object> _agent = {
  'id': _agentId,
  'owner_id': 'workspace',
  'created_at': '2026-11-27T18:00:01.123456Z',
  'updated_at': '2026-11-27T19:12:00+01:00',
  'configuration': _configuration,
  'version': 2,
  'name': 'Assistant',
};
const Map<String, Object> _active = {
  'id': _sessionId,
  'status': 'active',
  'num_participants': 2,
  'created_at': '2026-11-27T18:14:00Z',
};

void main() {
  test('all seven agent operations match the pinned REST contract', () async {
    const agentPath = '/v1/audio/agents/$_agentId';
    const token = 'next+/= ?:&';
    var call = 0;
    final client = MistralClient.withApiKey(
      'workspace-fixture',
      httpClient: MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer workspace-fixture');
        expect(request.headers['accept'], 'application/json');
        switch (call++) {
          case 0:
            _expectRequest(request, 'POST', '/v1/audio/agents');
            expect(jsonDecode(request.body), {
              'name': 'Assistant',
              'configuration': _configuration,
            });
            return _response(_agent);
          case 1:
            _expectRequest(request, 'GET', '/v1/audio/agents', {
              'page_size': '2',
              'page_token': token,
              'search': 'Help & Sales',
            });
            return _response({
              'data': [_agent],
              'next_page_token': token,
            });
          case 2:
            _expectRequest(request, 'GET', agentPath, {'version': '1'});
            return _response({..._agent, 'version': 1});
          case 3:
            _expectRequest(request, 'PUT', agentPath);
            expect(jsonDecode(request.body), {
              'name': 'Assistant',
              'configuration': _configuration,
              'description': 'Updated',
            });
            return _response({..._agent, 'version': 3});
          case 4:
            _expectRequest(request, 'GET', '$agentPath/versions', {
              'page_size': '2',
              'page_token': token,
            });
            return _response({
              'data': [_agent],
              'next_page_token': token,
            });
          case 5:
            _expectRequest(request, 'GET', '$agentPath/sessions', {
              'page_size': '3',
              'page_token': token,
            });
            return _response({
              'data': [
                {
                  'id': _sessionId,
                  'agent_id': _agentId,
                  'duration': 19,
                  'bridge_metadata': {
                    'type': 'amazon_connect',
                    'context_id': 'contact',
                    'called_number': '+12025550100',
                  },
                },
              ],
              'next_page_token': token,
            });
          case 6:
            _expectRequest(request, 'DELETE', agentPath);
            return http.Response('', 204);
          default:
            throw StateError('Unexpected request.');
        }
      }),
    );
    addTearDown(client.close);
    final settings = AudioAgentConfiguration.fromJson(_configuration);
    final agents = client.audio.agents;
    final agent = await agents.create(
      request: CreateAudioAgentRequest(
        name: 'Assistant',
        configuration: settings,
      ),
    );
    expect(agent.id, _agentId);
    expect(agent.createdAt.microsecond, 456);
    expect(agent.updatedAt, DateTime.utc(2026, 11, 27, 18, 12));
    expect(agent.configuration?.tts.voiceId, 'voice_fixture');
    expect(
      agent.configuration?.tools?.single,
      isA<VoiceAgentFunctionTool>()
          .having((tool) => tool.function.strict, 'strict', true)
          .having((tool) => tool.filler, 'filler', isA<StaticToolFiller>()),
    );

    final page = await agents.list(
      pageSize: 2,
      pageToken: token,
      search: 'Help & Sales',
    );
    expect(page.data.single, agent);
    expect(page.nextPageToken, token);
    expect((await agents.get(agentId: _agentId, version: 1)).version, 1);
    expect(
      (await agents.update(
        agentId: _agentId,
        request: UpdateAudioAgentRequest(
          name: 'Assistant',
          description: 'Updated',
          configuration: settings,
        ),
      )).version,
      3,
    );
    expect(
      (await agents.listVersions(
        agentId: _agentId,
        pageSize: 2,
        pageToken: token,
      )).data.single,
      agent,
    );
    final sessions = await agents.listSessions(
      agentId: _agentId,
      pageSize: 3,
      pageToken: token,
    );
    expect(sessions.nextPageToken, token);
    expect(sessions.data.single.id, _sessionId);
    expect(sessions.data.single.bridgeMetadata?.contextId, 'contact');
    await agents.delete(agentId: _agentId);
    expect(call, 7);
  });

  test(
    'all four session operations decode credentials, transcripts and updates',
    () async {
      const path = '/v1/audio/sessions/$_sessionId';
      var call = 0;
      final client = MistralClient.withApiKey(
        'workspace-fixture',
        httpClient: MockClient((request) async {
          switch (call++) {
            case 0:
              _expectRequest(request, 'POST', '/v1/audio/sessions');
              expect(jsonDecode(request.body), {
                'agent_id': _agentId,
                'agent_version': 2,
                'tools': [
                  {
                    'type': 'transfer_call',
                    'destinations': [
                      {
                        'id': 'desk',
                        'condition': 'User asks for the help desk',
                        'destination': {
                          'type': 'sip',
                          'uri': 'sip:desk@example.test',
                        },
                      },
                    ],
                  },
                  {'type': 'hang_up'},
                ],
              });
              return _response({
                ..._credentials.toJson(),
                'created_at': '2026-11-27T18:14:00Z',
                'expires_at': '2026-11-27T18:19:00Z',
                'function_tools': [_wireFunction],
              });
            case 1:
              _expectRequest(request, 'GET', path);
              return _response({
                ..._active,
                'phone_call': {
                  'phone_number_id': 'phone-fixture',
                  'phone_number': {
                    'id': 'phone-fixture',
                    'identifier': '+12025550100',
                  },
                },
                'transcripts': [
                  {
                    'role': 'user',
                    'content': 'Hello',
                    'timestamp': '2026-11-27T18:15:00Z',
                    'latency': {'transcription_delay_ms': 22.5},
                  },
                  {
                    'role': 'assistant',
                    'content': 'Hi',
                    'timestamp': '2026-11-27T18:15:01Z',
                    'latency': {'llm_ttft_ms': 34},
                    'tool_calls': [
                      {'id': 'fn1', 'name': 'lookup', 'arguments': '{}'},
                    ],
                  },
                  {
                    'role': 'tool',
                    'name': 'lookup',
                    'tool_call_id': 'fn1',
                    'status': 'success',
                    'timestamp': '2026-11-27T18:15:02Z',
                    'result': {'found': true},
                  },
                ],
              });
            case 2:
              _expectRequest(request, 'PATCH', path);
              expect(jsonDecode(request.body), {
                'instructions': null,
                'tools': <Object>[],
                'turn': {'allow_interruptions': false},
              });
              return _response(_active);
            case 3:
              _expectRequest(request, 'DELETE', path);
              return http.Response('', 204);
            default:
              throw StateError('Unexpected request.');
          }
        }),
      );
      addTearDown(client.close);
      final sessions = client.audio.sessions;
      final credentials = await sessions.create(
        request: const CreateAudioSessionRequest(
          agentId: _agentId,
          agentVersion: 2,
          tools: [
            TransferCallTool(
              destinations: [
                TransferTarget(
                  id: 'desk',
                  condition: 'User asks for the help desk',
                  destination: SipDestination(uri: 'sip:desk@example.test'),
                ),
              ],
            ),
            HangUpTool(),
          ],
        ),
      );
      expect(credentials.functionTools?.single.function.name, 'lookup');
      expect(credentials.expiresAt, DateTime.utc(2026, 11, 27, 18, 19));
      final handoff = VoiceAgentRoomCredentials.fromSession(credentials);
      expect(handoff.toJson(), _credentials.toJson());
      expect(
        handoff.toString(),
        isNot(contains(_credentials.participantToken)),
      );
      expect(
        credentials.toString(),
        isNot(contains(_credentials.participantToken)),
      );

      final session = await sessions.get(sessionId: credentials.id);
      expect(session.status, AudioSessionStatus.active);
      expect(session.numParticipants, 2);
      expect(session.phoneCall?.phoneNumber?.identifier, '+12025550100');
      final transcript = session.transcripts!;
      expect(transcript.map((turn) => turn.role), [
        'user',
        'assistant',
        'tool',
      ]);
      expect(
        (transcript[0] as AudioUserTranscriptTurn).latency.transcriptionDelayMs,
        22.5,
      );
      expect(
        (transcript[1] as AudioAssistantTranscriptTurn).toolCalls?.single.id,
        'fn1',
      );
      expect((transcript[2] as AudioToolTranscriptTurn).result, {
        'found': true,
      });

      final update = UpdateAudioSessionRequest.fromJson(const {
        'instructions': null,
        'tools': <Object>[],
        'turn': {'allow_interruptions': false},
      }).copyWith(tools: const <VoiceAgentTool>[]);
      expect(const UpdateAudioSessionRequest().toJson(), isEmpty);
      expect(
        (await sessions.update(
          sessionId: credentials.id,
          request: update,
        )).status,
        AudioSessionStatus.active,
      );
      await sessions.close(sessionId: credentials.id);
      expect(call, 4);
    },
  );

  test(
    'room events filter the topic and participant and release both sides',
    () async {
      final transport = _Transport();
      var backends = 0;
      final connection = await VoiceAgentConnection.connect(
        credentials: _credentials,
        transport: transport,
        closeSession: (id) async {
          expect(id, _sessionId);
          expect(transport.disconnections, 1);
          backends++;
        },
      );
      final events = connection.events.toList();
      transport
        ..emit(_transcript, senderIsAgent: false)
        ..emit(_transcript, topic: 'unrelated')
        ..emit(_transcript)
        ..emit({
          'type': 'agent.state.changed',
          'old_state': 'listening',
          'state': 'thinking',
          'ts': 1.5,
        })
        ..emit({
          'type': 'tool_call.started',
          'id': 'fn1',
          'name': 'lookup',
          'ts': 2,
        })
        ..emit({
          'type': 'tool_call.ended',
          'id': 'fn1',
          'name': 'lookup',
          'ts': 2.5,
          'arguments': '{}',
          'status': 'done',
          'result': 'ok',
        })
        ..emit({
          'type': 'future.event',
          'opaque': [1, 2],
        })
        ..emit({
          'type': 'error',
          'source': 'transport',
          'code': 'peer_failed',
          'message': 'Connection failed',
          'fatal': true,
        });
      final frames = await events;
      expect(frames.map((event) => event.type), [
        'transcription.segment',
        'agent.state.changed',
        'tool_call.started',
        'tool_call.ended',
        'future.event',
        'error',
      ]);
      expect((frames.first as VoiceAgentTranscriptEvent).isFinal, isTrue);
      expect(
        (frames[1] as VoiceAgentStateChangedEvent).state,
        VoiceAgentState.thinking,
      );
      expect((frames[4] as UnknownVoiceAgentEvent).raw['opaque'], [1, 2]);
      await connection.done;
      await connection.close();
      expect(transport.disconnections, 1);
      expect(transport.unregistered, isTrue);
      expect(backends, 1);
    },
  );

  test(
    'room RPCs decode arguments and install confirmed tool handlers',
    () async {
      final transport = _Transport();
      final connection = await VoiceAgentConnection.connect(
        credentials: _credentials,
        transport: transport,
        closeSession: (_) async {},
        functions: {
          'lookup': (args) => {'query': args['q']},
          'failure': (_) => throw StateError('private value'),
        },
      );
      addTearDown(connection.close);

      expect(
        await transport.invoke('{"name":"lookup","arguments":{"q":7}}'),
        '{"query":7}',
      );
      expect(
        await transport.invoke(r'{"name":"lookup","arguments":"{\"q\":8}"}'),
        '{"query":8}',
      );
      await expectLater(
        transport.invoke('{"name":"lookup"}', senderIsAgent: false),
        throwsA(_rpcCode(2400)),
      );
      await expectLater(
        transport.invoke('{"name":"lookup","arguments":[]}'),
        throwsA(_rpcCode(2400)),
      );
      await expectLater(
        transport.invoke('{"name":"missing"}'),
        throwsA(_rpcCode(2404)),
      );
      await expectLater(
        transport.invoke('{"name":"failure"}'),
        throwsA(
          _rpcCode(1).having(
            (e) => e.toString(),
            'redacted',
            isNot(contains('private value')),
          ),
        ),
      );
      final ack = await connection.update(
        request: const VoiceAgentRoomUpdate(
          instructions: 'New instructions',
          turn: AudioTurnConfig(allowInterruptions: false),
        ),
        functions: {'lookup': (_) => 'updated', 'unconfirmed': (_) => 'wrong'},
      );
      expect(ack.type, 'session.updated');
      expect(ack.session.tools?.single, isA<VoiceAgentFunctionTool>());
      expect(await transport.invoke('{"name":"lookup"}'), 'updated');
      await expectLater(
        transport.invoke('{"name":"unconfirmed"}'),
        throwsA(_rpcCode(2404)),
      );
    },
  );

  test(
    'peer disconnect stops the backend even if room teardown fails',
    () async {
      final transport = _Transport(failDisconnect: true);
      final closed = <String>[];
      final connection = await VoiceAgentConnection.connect(
        credentials: _credentials,
        transport: transport,
        closeSession: (id) async => closed.add(id),
      );
      final events = connection.events.toList();
      transport.endPackets();
      await connection.done;
      expect(await events, isEmpty);
      expect(closed, [_sessionId]);
      expect(transport.unregistered, isTrue);
      await expectLater(
        connection.close(),
        throwsA(isA<VoiceAgentConnectionException>()),
      );
      expect(transport.disconnections, 1);
    },
  );

  test(
    'failed join redacts credentials and still closes the backend session',
    () async {
      final transport = _Transport(failJoin: true);
      final stopped = <String>[];
      await expectLater(
        VoiceAgentConnection.connect(
          credentials: _credentials,
          transport: transport,
          closeSession: (id) async => stopped.add(id),
        ),
        throwsA(
          isA<VoiceAgentConnectionException>().having(
            (error) => error.toString(),
            'redacted',
            isNot(contains(_credentials.participantToken)),
          ),
        ),
      );
      expect(transport.disconnections, 1);
      expect(stopped, [_sessionId]);
    },
  );
}

const Map<String, Object> _transcript = {
  'type': 'transcription.segment',
  'id': 'turn1',
  'role': 'assistant',
  'final': true,
  'content': 'Hello',
  'ts': 1.25,
};

void _expectRequest(
  http.Request request,
  String method,
  String path, [
  Map<String, String> query = const {},
]) {
  expect(request.method, method);
  expect(request.url.path, path);
  expect(request.url.queryParameters, query);
}

http.Response _response(Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);

TypeMatcher<VoiceAgentRpcError> _rpcCode(int code) =>
    isA<VoiceAgentRpcError>().having((error) => error.code, 'code', code);

final class _Transport implements VoiceAgentRoomTransport {
  _Transport({this.failJoin = false, this.failDisconnect = false});

  final _packets = StreamController<VoiceAgentRoomPacket>();
  final bool failJoin;
  final bool failDisconnect;
  late VoiceAgentRpcHandler _handler;
  int disconnections = 0;
  bool unregistered = false;

  @override
  Stream<VoiceAgentRoomPacket> get packets => _packets.stream;

  @override
  Future<void> connect(VoiceAgentRoomCredentials credentials) async {
    expect(credentials.toJson(), _credentials.toJson());
    if (failJoin) throw StateError('Rejected ${credentials.participantToken}');
  }

  void emit(
    Map<String, dynamic> event, {
    String topic = VoiceAgentConnection.eventsTopic,
    bool senderIsAgent = true,
  }) => _packets.add(
    VoiceAgentRoomPacket(
      topic: topic,
      bytes: utf8.encode(jsonEncode(event)),
      senderIsAgent: senderIsAgent,
    ),
  );

  @override
  void Function() registerRpcMethod(
    String method,
    VoiceAgentRpcHandler handler,
  ) {
    expect(method, 'mistral.function_tool');
    _handler = handler;
    return () => unregistered = true;
  }

  Future<String> invoke(String payload, {bool senderIsAgent = true}) =>
      _handler(
        VoiceAgentRpcInvocation(payload: payload, senderIsAgent: senderIsAgent),
      );

  @override
  Future<String> performAgentRpc(
    String method, {
    required String payload,
    required Duration timeout,
  }) async {
    expect(method, 'mistral.session_update');
    expect(timeout, const Duration(seconds: 5));
    expect(jsonDecode(payload), {
      'instructions': 'New instructions',
      'turn': {'allow_interruptions': false},
    });
    return jsonEncode({
      'type': 'session.updated',
      'ts': 3,
      'session': _configuration,
    });
  }

  void endPackets() => unawaited(_packets.close());

  @override
  Future<void> disconnect() async {
    disconnections++;
    endPackets();
    if (failDisconnect) throw StateError('Fixture teardown failure');
  }
}
