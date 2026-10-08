import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

import '../fixtures/responses_websocket_events.dart';

const _request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Local fixture'),
);

void main() {
  group('public Responses WebSocket connect', () {
    for (final scheme in ['http', 'https', 'ws', 'wss']) {
      test(
        '$scheme preserves path, repeated query and header precedence',
        () async {
          final socket = _Socket();
          final client = OpenAIClient(
            config: OpenAIConfig(
              baseUrl: '$scheme://example.invalid/proxy/v1/?k=a&k=b&mode=test',
              authProvider: const OrganizationApiKeyProvider(
                apiKey: 'auth-fixture',
                organization: 'auth-org',
                project: 'auth-project',
              ),
              defaultHeaders: const {
                'AUTHORIZATION': 'default',
                'OPENAI-ORGANIZATION': 'default-org',
                'OpenAI-Project': 'default-project',
                'OpenAI-Version': 'default-version',
                'X-Local': 'default-local',
              },
              organization: 'config-org',
              project: 'config-project',
              apiVersion: 'config-version',
            ),
          );
          try {
            final connection = await client.responses.connect(
              beta: true,
              additionalHeaders: const {
                'Authorization': 'request-auth',
                'openai-organization': 'request-org',
                'OPENAI-PROJECT': 'request-project',
                'openai-version': 'request-version',
                'OPENAI-BETA': 'cannot-override',
              },
              connector: (uri, {headers}) async {
                expect(
                  uri.scheme,
                  scheme == 'http' || scheme == 'ws' ? 'ws' : 'wss',
                );
                expect(uri.path, '/proxy/v1/responses');
                expect(uri.queryParametersAll, {
                  'k': ['a', 'b'],
                  'mode': ['test'],
                });
                expect(headers, {
                  'authorization': 'request-auth',
                  'openai-organization': 'request-org',
                  'openai-project': 'request-project',
                  'openai-version': 'request-version',
                  'openai-beta': 'responses_multi_agent=v1',
                  'x-local': 'default-local',
                });
                return socket;
              },
            );
            await connection.close();
            await connection.done;
          } finally {
            client.close();
          }
        },
      );
    }

    test(
      'auth and config override defaults without automatic headers',
      () async {
        final socket = _Socket();
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: OrganizationApiKeyProvider(
              apiKey: 'fixture',
              organization: 'auth-org',
              project: 'auth-project',
            ),
            defaultHeaders: {
              'AUTHORIZATION': 'default',
              'OpenAI-Version': 'old',
            },
            organization: 'config-org',
            apiVersion: 'config-version',
          ),
        );
        try {
          final connection = await client.responses.connect(
            connector: (uri, {headers}) async {
              expect(headers, {
                'authorization': 'Bearer fixture',
                'openai-organization': 'config-org',
                'openai-project': 'auth-project',
                'openai-version': 'config-version',
              });
              expect(uri.queryParameters, isEmpty);
              return socket;
            },
          );
          await connection.close();
        } finally {
          client.close();
        }
      },
    );

    test(
      'explicit headerless proxy configuration remains headerless',
      () async {
        final client = OpenAIClient(
          config: const OpenAIConfig(baseUrl: 'https://proxy.invalid/v1'),
        );
        final socket = _Socket();
        try {
          final connection = await client.responses.connect(
            connector: (uri, {headers}) async {
              expect(uri.toString(), 'wss://proxy.invalid/v1/responses');
              expect(headers, isEmpty);
              return socket;
            },
          );
          await connection.close();
        } finally {
          client.close();
        }
      },
    );

    test('closed client rejects synchronously before dialing', () {
      final client = OpenAIClient()..close();
      var dials = 0;
      expect(
        () => client.responses.connect(
          connector: (uri, {headers}) async {
            dials++;
            return _Socket();
          },
        ),
        throwsStateError,
      );
      expect(dials, 0);
    });

    for (final timeout in [Duration.zero, const Duration(milliseconds: -1)]) {
      test('invalid timeout $timeout rejects before dialing', () {
        final client = OpenAIClient();
        var dials = 0;
        try {
          expect(
            () => client.responses.connect(
              connectionTimeout: timeout,
              connector: (uri, {headers}) async {
                dials++;
                return _Socket();
              },
            ),
            throwsArgumentError,
          );
          expect(dials, 0);
        } finally {
          client.close();
        }
      });
    }

    for (final limit in [0, -1]) {
      test('invalid buffer limit $limit rejects before dialing', () {
        final client = OpenAIClient();
        var dials = 0;
        try {
          expect(
            () => client.responses.connect(
              maxBufferedEvents: limit,
              connector: (uri, {headers}) async {
                dials++;
                return _Socket();
              },
            ),
            throwsArgumentError,
          );
          expect(dials, 0);
        } finally {
          client.close();
        }
      });
    }

    for (final url in [
      'ftp://host/private?api_key=secret',
      '/relative',
      'https://host/v1#fragment',
    ]) {
      test(
        'invalid URL rejects safely before dialing: ${Uri.parse(url).scheme}',
        () async {
          final client = OpenAIClient(config: OpenAIConfig(baseUrl: url));
          var dials = 0;
          try {
            await expectLater(
              client.responses.connect(
                connector: (uri, {headers}) async {
                  dials++;
                  return _Socket();
                },
              ),
              throwsA(
                isA<ArgumentError>().having(
                  (e) => e.toString(),
                  'safe',
                  isNot(contains('secret')),
                ),
              ),
            );
            expect(dials, 0);
          } finally {
            client.close();
          }
        },
      );
    }

    for (final synchronous in [true, false]) {
      test('connector failure is redacted (sync=$synchronous)', () async {
        final client = OpenAIClient(
          config: const OpenAIConfig(
            baseUrl: 'https://user:password@host/v1?api_key=secret',
            authProvider: ApiKeyProvider('credential'),
          ),
        );
        try {
          await expectLater(
            client.responses.connect(
              connector: (uri, {headers}) {
                final failure = StateError(
                  'secret password credential $uri $headers',
                );
                if (synchronous) throw failure;
                return Future<ws.WebSocket>.error(failure);
              },
            ),
            throwsA(
              isA<ConnectionException>().having(
                (e) => e.toString(),
                'redacted',
                allOf(
                  contains('handshake failed'),
                  isNot(contains('secret')),
                  isNot(contains('password')),
                  isNot(contains('credential')),
                ),
              ),
            ),
          );
        } finally {
          client.close();
        }
      });
    }

    for (final closeFails in [false, true]) {
      test(
        'timeout disposes late successful socket (closeFails=$closeFails)',
        () async {
          final opening = Completer<ws.WebSocket>();
          final socket = _Socket(closeFails: closeFails);
          final client = OpenAIClient(
            config: const OpenAIConfig(
              connectTimeout: Duration(milliseconds: 5),
            ),
          );
          try {
            await expectLater(
              client.responses.connect(
                connector: (uri, {headers}) => opening.future,
              ),
              throwsA(
                isA<ConnectionException>().having(
                  (e) => e.message,
                  'timeout',
                  contains('timed out'),
                ),
              ),
            );
            opening.complete(socket);
            await _pump();
            expect(socket.closeCalls, 1);
          } finally {
            client.close();
          }
        },
      );
    }

    test('timeout consumes a late failed handshake', () async {
      final opening = Completer<ws.WebSocket>();
      final client = OpenAIClient();
      try {
        await expectLater(
          client.responses.connect(
            connectionTimeout: const Duration(milliseconds: 5),
            connector: (uri, {headers}) => opening.future,
          ),
          throwsA(isA<ConnectionException>()),
        );
        opening.completeError(StateError('late credential-bearing failure'));
        await _pump();
      } finally {
        client.close();
      }
    });

    test('client closure during handshake disposes late socket', () async {
      final opening = Completer<ws.WebSocket>();
      final socket = _Socket();
      final client = OpenAIClient();
      final connecting = client.responses.connect(
        connector: (uri, {headers}) => opening.future,
      );
      final rejected = expectLater(connecting, throwsStateError);
      client.close();
      opening.complete(socket);
      await rejected;
      expect(socket.closeCalls, 1);
    });

    test(
      'opened connection remains caller-owned after client closure',
      () async {
        final socket = _Socket();
        final client = OpenAIClient();
        final connection = await client.responses.connect(
          connector: (uri, {headers}) async => socket,
        );
        client.close();
        expect(socket.closeCalls, 0);
        connection.create(_request);
        expect(socket.sent, hasLength(1));
        await connection.close();
        expect(socket.closeCalls, 1);
      },
    );

    test(
      'native upgraded server receives exact endpoint and headers',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final received = Completer<Map<String, dynamic>>();
        final peer = Completer<WebSocket>();
        final subscription = server.listen((request) async {
          received.complete({
            'path': request.uri.path,
            'query': request.uri.queryParametersAll,
            'auth': request.headers.value('authorization'),
            'org': request.headers.value('openai-organization'),
            'project': request.headers.value('openai-project'),
            'version': request.headers.value('openai-version'),
            'beta': request.headers.value('openai-beta'),
            'content': request.headers.value('content-type'),
            'trace': request.headers.value('x-request-id'),
          });
          peer.complete(await WebSocketTransformer.upgrade(request));
        });
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'http://127.0.0.1:${server.port}/proxy/v1/?k=a&k=b',
            authProvider: const ApiKeyProvider('local-fixture'),
            organization: 'local-org',
            project: 'local-project',
            apiVersion: 'local-version',
          ),
        );
        ResponsesConnection? connection;
        try {
          connection = await client.responses.connect(beta: true);
          expect(await received.future, {
            'path': '/proxy/v1/responses',
            'query': {
              'k': ['a', 'b'],
            },
            'auth': 'Bearer local-fixture',
            'org': 'local-org',
            'project': 'local-project',
            'version': 'local-version',
            'beta': 'responses_multi_agent=v1',
            'content': null,
            'trace': null,
          });
          final nativePeer = await peer.future;
          final frames = nativePeer
              .map((frame) => jsonDecode(frame as String))
              .first;
          connection.create(_request, streamId: 'planner', generate: false);
          expect(await frames, {
            'type': 'response.create',
            'model': 'gpt-6-sol',
            'input': 'Local fixture',
            'stream_id': 'planner',
            'generate': false,
          });
          await connection.close(1000, 'local cleanup');
          await connection.done;
        } finally {
          if (connection != null) await connection.close();
          client.close();
          if (peer.isCompleted) await (await peer.future).close();
          await subscription.cancel();
          await server.close(force: true);
        }
      },
    );

    test('native timed-out handshake closes a late upgraded socket', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final accepted = Completer<void>();
      final upgrade = Completer<void>();
      final peer = Completer<WebSocket>();
      final peerClosed = Completer<void>();
      final subscription = server.listen((request) async {
        accepted.complete();
        await upgrade.future;
        final socket = await WebSocketTransformer.upgrade(request);
        peer.complete(socket);
        socket.listen((_) {}, onDone: peerClosed.complete);
      });
      final client = OpenAIClient(
        config: OpenAIConfig(baseUrl: 'http://127.0.0.1:${server.port}/v1'),
      );
      try {
        final connecting = client.responses.connect(
          connectionTimeout: const Duration(milliseconds: 100),
        );
        final rejected = expectLater(
          connecting,
          throwsA(
            isA<ConnectionException>().having(
              (e) => e.message,
              'timeout',
              contains('timed out'),
            ),
          ),
        );
        await accepted.future.timeout(const Duration(seconds: 2));
        await rejected;
        upgrade.complete();
        final socket = await peer.future.timeout(const Duration(seconds: 2));
        await peerClosed.future.timeout(const Duration(seconds: 2));
        expect(socket.closeCode, 1000);
      } finally {
        if (!upgrade.isCompleted) upgrade.complete();
        client.close();
        if (peer.isCompleted) await (await peer.future).close();
        await subscription.cancel();
        await server.close(force: true);
      }
    });

    test('native handshake failure is safe and identifiable', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final subscription = server.listen((request) async {
        request.response.statusCode = 401;
        request.response.write('private fixture error');
        await request.response.close();
      });
      final client = OpenAIClient(
        config: OpenAIConfig(
          baseUrl: 'http://127.0.0.1:${server.port}/v1?api_key=secret',
        ),
      );
      try {
        await expectLater(
          client.responses.connect(),
          throwsA(
            isA<ConnectionException>().having(
              (e) => e.toString(),
              'redaction',
              allOf(
                isNot(contains('secret')),
                isNot(contains('private fixture')),
              ),
            ),
          ),
        );
      } finally {
        client.close();
        await subscription.cancel();
        await server.close(force: true);
      }
    });
  });

  group('public Responses persistent messages', () {
    for (final beta in [false, true]) {
      test(
        'required nullable annotation traverses GA/beta WebSocket (beta=$beta)',
        () async {
          final socket = _Socket();
          final client = OpenAIClient();
          final connection = await client.responses.connect(
            beta: beta,
            connector: (uri, {headers}) async => socket,
          );
          final next = connection.events.first;
          final raw = <String, dynamic>{
            'type': 'response.output_text.annotation.added',
            'stream_id': 'lane',
            'sequence_number': 1,
            'item_id': 'msg_fixture',
            'output_index': 0,
            'content_index': 0,
            'annotation_index': 0,
            'annotation': null,
            if (beta) 'agent': {'agent_name': 'local-fixture'},
          };
          try {
            socket.frame(raw);
            final event = await next as ResponsesStreamEvent;
            expect(
              event.event,
              isA<OutputTextAnnotationAddedEvent>().having(
                (e) => e.annotation,
                'nullable annotation',
                isNull,
              ),
            );
            expect(event.toJson(), raw);
            expect(connection.isClosed, isFalse);
          } finally {
            await connection.close();
            client.close();
          }
        },
      );
    }

    test(
      'create preserves supported REST settings and WS-only metadata',
      () async {
        final socket = _Socket();
        final client = OpenAIClient();
        final requestJson = <String, dynamic>{
          'model': 'gpt-6-sol',
          'input': 'fixture',
          'stream': true,
          'background': false,
          'store': false,
          'previous_response_id': 'resp_parent',
          'stream_options': {'include_obfuscation': false},
          'access_programs': {'cyber': 'standard'},
          'tools': [
            {'type': 'tool_search', 'execution': 'client'},
          ],
          'parallel_tool_calls': false,
          'max_output_tokens': 42,
          'metadata': {'local': 'fixture'},
          'instructions': 'Local instruction',
          'context_management': [
            {'type': 'compaction', 'compact_threshold': 200000},
          ],
        };
        final request = CreateResponseRequest.fromJson(requestJson);
        final connection = await client.responses.connect(
          connector: (uri, {headers}) async => socket,
        );
        try {
          connection.create(request, streamId: 'planner', generate: false);
          final expected = {...requestJson}
            ..remove('stream')
            ..remove('background')
            ..addAll({
              'type': 'response.create',
              'stream_id': 'planner',
              'generate': false,
            });
          expect(jsonDecode(socket.sent.single), expected);
          expect(request.toJson(), requestJson);
          expect(request.toJson(), isNot(contains('stream_id')));
          expect(request.toJson(), isNot(contains('generate')));
          connection.create(
            _request.copyWith(previousResponseId: 'resp_warmup'),
            streamId: 'planner',
          );
          expect(jsonDecode(socket.sent.last), {
            'model': 'gpt-6-sol',
            'input': 'Local fixture',
            'previous_response_id': 'resp_warmup',
            'type': 'response.create',
            'stream_id': 'planner',
          });
        } finally {
          await connection.close();
          client.close();
        }
      },
    );

    for (final lane in ['', 'bad lane', 'é', 'a/b', 'a\n', 'a' * 257]) {
      test(
        'invalid request lane fails without a write (${lane.length} chars)',
        () async {
          final socket = _Socket();
          final client = OpenAIClient();
          final connection = await client.responses.connect(
            connector: (uri, {headers}) async => socket,
          );
          try {
            expect(
              () => connection.create(_request, streamId: lane),
              throwsFormatException,
            );
            expect(socket.sent, isEmpty);
          } finally {
            await connection.close();
            client.close();
          }
        },
      );
    }

    test('background true fails without a write', () async {
      final socket = _Socket();
      final client = OpenAIClient();
      final connection = await client.responses.connect(
        connector: (uri, {headers}) async => socket,
      );
      try {
        expect(
          () => connection.create(_request.copyWith(background: true)),
          throwsFormatException,
        );
        expect(socket.sent, isEmpty);
      } finally {
        await connection.close();
        client.close();
      }
    });

    test(
      'lane errors and terminal events leave other lanes and socket usable',
      () async {
        final socket = _Socket();
        final client = OpenAIClient();
        final connection = await client.responses.connect(
          connector: (uri, {headers}) async => socket,
        );
        final messages = <ResponsesServerEvent>[];
        final subscription = connection.events.listen(messages.add);
        final frames = <Map<String, dynamic>>[
          {
            'type': 'response.compaction.compacting',
            'sequence_number': 1,
            'output_index': 0,
            'item_id': 'cmp_1',
            'stream_id': 'planner',
          },
          {
            'type': 'error',
            'status': 400,
            'stream_id': 'planner',
            'error': {
              'type': 'invalid_request_error',
              'code': 'previous_response_not_found',
              'message': 'Local fixture',
              'param': 'previous_response_id',
            },
          },
          {
            'type': 'response.completed',
            'sequence_number': 2,
            'stream_id': 'research',
            'response': _response('resp_research'),
          },
          {
            'type': 'response.completed',
            'sequence_number': 3,
            'response': _response('resp_default'),
          },
          {
            'type': 'response.completed',
            'sequence_number': 4,
            'stream_id': 'planner',
            'response': _response('resp_planner'),
          },
          {
            'type': 'response.future_fixture',
            'stream_id': 'provider future lane',
            'payload': {
              'items': [1, null],
            },
          },
        ];
        try {
          connection
            ..create(_request, streamId: 'planner')
            ..create(_request, streamId: 'research')
            ..create(_request);
          frames.forEach(socket.frame);
          await _pump();
          expect(messages.map((m) => m.toJson()).toList(), frames);
          expect(messages.map((m) => m.streamId), [
            'planner',
            'planner',
            'research',
            null,
            'planner',
            'provider future lane',
          ]);
          expect(
            messages[0],
            isA<ResponsesStreamEvent>().having(
              (m) => m.event,
              'shared compaction',
              isA<ResponseCompactionCompactingEvent>(),
            ),
          );
          expect(messages[1], isA<ResponsesErrorEvent>());
          expect(connection.isClosed, isFalse);
          connection.create(
            _request.copyWith(previousResponseId: 'resp_planner'),
            streamId: 'planner',
          );
          expect(socket.sent, hasLength(4));
          expect(
            (jsonDecode(socket.sent.last) as Map)['previous_response_id'],
            'resp_planner',
          );
          await subscription.cancel();
          expect(socket.closeCalls, 0);
        } finally {
          await connection.close();
          client.close();
        }
      },
    );

    test(
      'all ordinary canonical events traverse the exported socket codec',
      () async {
        final socket = _Socket();
        final client = OpenAIClient();
        final connection = await client.responses.connect(
          connector: (uri, {headers}) async => socket,
        );
        final messages = <ResponsesServerEvent>[];
        final subscription = connection.events.listen(messages.add);
        final fixtures = responsesWebSocketEventFixtures();
        try {
          expect(fixtures, hasLength(58));
          for (var i = 0; i < fixtures.length; i++) {
            socket.frame({
              ...fixtures[i],
              if (i.isEven) 'stream_id': 'lane_${i % 4}',
            });
          }
          await _pump();
          expect(messages, hasLength(58));
          for (var i = 0; i < fixtures.length; i++) {
            final envelope = messages[i] as ResponsesStreamEvent;
            expect(
              envelope.event,
              isNot(isA<UnknownEvent>()),
              reason: '${fixtures[i]['type']}',
            );
            expect(envelope.type, fixtures[i]['type']);
            expect(envelope.streamId, i.isEven ? 'lane_${i % 4}' : null);
            expect(envelope.toJson(), {
              ...fixtures[i],
              if (i.isEven) 'stream_id': 'lane_${i % 4}',
            });
          }
          expect(connection.isClosed, isFalse);
        } finally {
          await subscription.cancel();
          await connection.close();
          client.close();
        }
      },
    );

    for (final type in [
      'response.steer.accepted',
      'response.steer.pending',
      'response.steer.failed',
      'response.inject.created',
      'response.inject.failed',
      'future.provider_event',
    ]) {
      test('future/dependent frame retains complete raw JSON: $type', () async {
        final socket = _Socket();
        final client = OpenAIClient();
        final connection = await client.responses.connect(
          beta: true,
          connector: (uri, {headers}) async => socket,
        );
        final next = connection.events.first;
        final raw = <String, dynamic>{
          'type': type,
          'stream_id': 'lane',
          if (type.startsWith('response.steer.')) 'sequence_number': 2,
          if (type.startsWith('response.steer.'))
            'steer': {
              'id': 'steer_saved',
              'previous_response_id': 'resp_parent',
              if (type == 'response.steer.failed')
                'input': {'original_rejected': true},
            },
          if (type == 'response.steer.pending')
            'reason': 'future_provider_reason',
          if (type == 'response.steer.pending')
            'required_input': [
              {
                'type': 'function_call_output',
                'call_id': 'call_saved',
                'name': 'get_status',
              },
            ],
          if (type == 'response.steer.failed')
            'error': {
              'type': 'invalid_request_error',
              'code': 'future_provider_code',
              'message': 'private failure',
            },
          'future': {
            'items': [
              null,
              {'private': 'fixture'},
            ],
          },
        };
        try {
          socket.frame(raw);
          final message = await next;
          switch (type) {
            case 'response.steer.accepted':
              expect(message, isA<ResponsesSteerAcceptedEvent>());
            case 'response.steer.pending':
              expect(message, isA<ResponsesSteerPendingEvent>());
            case 'response.steer.failed':
              expect(message, isA<ResponsesSteerFailedEvent>());
          }
          expect(message.toJson(), raw);
          expect(message.streamId, 'lane');
          expect(connection.isClosed, isFalse);
        } finally {
          await connection.close();
          client.close();
        }
      });
    }

    for (final codeState in ['absent', 'null', 'value']) {
      for (final paramState in ['absent', 'null', 'value']) {
        test(
          'full beta WS error retains code=$codeState param=$paramState',
          () async {
            final socket = _Socket();
            final client = OpenAIClient();
            final connection = await client.responses.connect(
              beta: true,
              connector: (uri, {headers}) async => socket,
            );
            final next = connection.events.first;
            final raw = <String, dynamic>{
              'type': 'error',
              'status': 403,
              'sequence_number': 7,
              'stream_id': 'provider future lane é',
              'agent': null,
              'error': {
                'type': 'future_provider_error',
                'message': 'private fixture message',
                if (codeState != 'absent')
                  'code': codeState == 'null' ? null : 'future_code',
                if (paramState != 'absent')
                  'param': paramState == 'null' ? null : 'input',
                'headers': {'x-private': 'private fixture header'},
                'misalignment': {
                  'detailed_explanation': 'private fixture explanation',
                  'error_type': 'future_classification',
                  'review_target': 'opaque:fixture',
                  'steer': {
                    'message': 'private fixture continuation',
                    'future': {
                      'keep': [1, null],
                    },
                  },
                  'future': {
                    'keep': [true],
                  },
                },
                'future': {
                  'keep': [false],
                },
              },
              'future': {
                'keep': [null],
              },
            };
            try {
              socket.frame(raw);
              final message = await next as ResponsesErrorEvent;
              expect(message.toJson(), raw);
              expect(
                message.error.code,
                codeState == 'value' ? 'future_code' : null,
              );
              expect(
                message.error.param,
                paramState == 'value' ? 'input' : null,
              );
              expect(message.toString(), isNot(contains('private fixture')));
              expect(message.toString(), isNot(contains('opaque:fixture')));
              expect(connection.isClosed, isFalse);
            } finally {
              await connection.close();
              client.close();
            }
          },
        );
      }
    }

    test('guide connection-limit error retains omitted param', () async {
      final socket = _Socket();
      final client = OpenAIClient();
      final connection = await client.responses.connect(
        connector: (uri, {headers}) async => socket,
      );
      final next = connection.events.first;
      final raw = <String, dynamic>{
        'type': 'error',
        'status': 400,
        'error': {
          'type': 'invalid_request_error',
          'code': 'websocket_connection_limit_reached',
          'message':
              'Responses websocket connection limit reached (60 minutes). Create a new websocket connection to continue.',
        },
      };
      try {
        socket.frame(raw);
        final message = await next;
        expect(message, isA<ResponsesErrorEvent>());
        expect(message.toJson(), raw);
        expect(connection.isClosed, isFalse);
      } finally {
        await connection.close();
        client.close();
      }
    });
  });
}

Future<void> _pump() => Future<void>.delayed(const Duration(milliseconds: 10));

Map<String, dynamic> _response(String id) => {
  'id': id,
  'object': 'response',
  'created_at': 1,
  'status': 'completed',
  'model': 'gpt-6-sol',
  'output': <dynamic>[],
  'access_programs': null,
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <dynamic>[],
  'parallel_tool_calls': false,
  'metadata': <String, dynamic>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
};

class _Socket implements ws.WebSocket {
  final bool closeFails;
  final StreamController<ws.WebSocketEvent> controller = StreamController();
  final List<String> sent = [];
  int closeCalls = 0;
  _Socket({this.closeFails = false});

  void frame(Map<String, dynamic> frame) =>
      controller.add(ws.TextDataReceived(jsonEncode(frame)));
  @override
  Stream<ws.WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) => sent.add(text);
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('No binary sends.');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    if (!controller.isClosed) {
      controller.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
      unawaited(controller.close());
    }
    if (closeFails) throw StateError('Local close fixture');
  }
}
