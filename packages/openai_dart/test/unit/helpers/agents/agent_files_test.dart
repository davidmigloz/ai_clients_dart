import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

http.Response _uploaded(int index, {int bytes = 2, String? id}) =>
    http.Response(
      jsonEncode({
        'id': id ?? 'file_fixture_$index',
        'object': 'file',
        'bytes': bytes,
        'created_at': 1,
        'filename': 'private-name.bin',
        'purpose': 'user_data',
        'status': 'processed',
      }),
      200,
    );

AgentFileInputBytes _bytes(
  String destination, [
  List<int> bytes = const [1, 2],
]) => AgentFileInputBytes(
  bytes: bytes,
  filename: 'private-name.bin',
  destination: destination,
);

OpenAIClient _client(
  http.Client transport, {
  Map<String, String> headers = const {},
}) => OpenAIClient(
  config: OpenAIConfig(
    baseUrl: 'https://a.invalid/proxy/v1',
    authProvider: const ApiKeyProvider('fixture-A'),
    organization: 'org-A',
    project: 'project-A',
    defaultHeaders: headers,
    retryPolicy: const RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

void main() {
  group('portable ownership models', () {
    test('bytes detach, preserve arbitrary values and compare every field', () {
      final source = [0, 255, 128, 13, 10];
      final input = _bytes('/workspace/input.bin', source);
      source[0] = 7;
      expect(input.bytes, [0, 255, 128, 13, 10]);
      expect(() => input.bytes[0] = 9, throwsUnsupportedError);
      expect(input.copyWith(), input);
      expect(input.copyWith().hashCode, input.hashCode);
      expect(input.copyWith(bytes: [1]), isNot(input));
      expect(input.copyWith(filename: 'other.bin'), isNot(input));
      expect(input.copyWith(destination: '/workspace/other.bin'), isNot(input));
      expect(input.toString(), isNot(contains('private-name')));
      expect(input.toString(), isNot(contains('input.bin')));
      for (final invalid in <List<int>>[
        [-1],
        [256],
      ]) {
        expect(() => _bytes('/workspace/a', invalid), throwsFormatException);
      }
    });
    test('stream metadata is immutable and factory equality uses identity', () {
      Stream<List<int>> first() => Stream.value([1]);
      Stream<List<int>> other() => Stream.value([1]);
      final input =
          AgentFileInput.stream(
                open: first,
                length: 1,
                filename: 'private-name.bin',
                destination: '/workspace/input.bin',
              )
              as AgentFileInputStream;
      expect(input.copyWith(), input);
      expect(input.copyWith().hashCode, input.hashCode);
      expect(input.copyWith(open: other), isNot(input));
      expect(input.copyWith(length: 2), isNot(input));
      expect(input.copyWith(filename: 'other'), isNot(input));
      expect(input.copyWith(destination: '/workspace/other'), isNot(input));
      expect(input.toString(), isNot(contains('private-name')));
      expect(() => input.copyWith(length: -1), throwsFormatException);
    });
    test(
      'all invalid destination/filename forms fail without revealing payload',
      () {
        for (final path in [
          'relative',
          '/workspace',
          '/workspace/',
          '/workspace/a/',
          '/workspace/a//b',
          '/workspace/a/./b',
          '/workspace/a/../b',
          '/workspace/../a',
          '/workspace/a\\b',
          '/workspace/\u0000a',
          '/workspace/.codex/a',
          '/workspace/.managed-agents/a',
          '/workspace/.managed-agents-user/a',
          '/workspace/outputs',
        ]) {
          expect(
            () => _bytes(path),
            throwsA(
              isA<FormatException>().having(
                (e) => e.toString(),
                'private path',
                isNot(contains(path == '/workspace' ? 'PRIVATE' : path)),
              ),
            ),
          );
        }
        for (final name in [
          '',
          'private\nname',
          'private\rname',
          'private\u0000name',
        ]) {
          expect(
            () => AgentFileInput.bytes(
              bytes: [],
              filename: name,
              destination: '/workspace/a',
            ),
            throwsFormatException,
          );
        }
        expect(
          _bytes('/workspace/outputs/result.bin').destination,
          '/workspace/outputs/result.bin',
        );
        final unicode = '/workspace/${'🚀' * 4085}';
        expect(_bytes(unicode).destination, unicode);
      },
    );
    test(
      'prepared/partial/staged copy value contracts retain private known observations',
      () {
        final refs = [
          AgentSessionHostedEnvironmentFileConfigFileId(
            fileId: 'file_private',
            path: '/workspace/private',
          ),
        ];
        final ids = ['file_private'];
        final prepared = PreparedAgentFiles(files: refs, uploadedFileIds: ids);
        refs.clear();
        ids.clear();
        expect(prepared.files, hasLength(1));
        expect(prepared.uploadedFileIds, ['file_private']);
        expect(() => prepared.files.clear(), throwsUnsupportedError);
        expect(() => prepared.uploadedFileIds.clear(), throwsUnsupportedError);
        expect(prepared.copyWith(), prepared);
        expect(prepared.copyWith().hashCode, prepared.hashCode);
        expect(prepared.copyWith(files: []), isNot(prepared));
        expect(
          prepared.copyWith(uploadedFileIds: ['different']),
          isNot(prepared),
        );
        final cause = const AbortedException(message: 'private-failure');
        final error = AgentFilePreparationException(
          prepared: prepared,
          cause: cause,
        );
        expect(error.wasAborted, isTrue);
        expect(error.copyWith(), error);
        expect(error.copyWith().hashCode, error.hashCode);
        expect(error.copyWith(cause: null).cause, isNull);
        expect(error.copyWith(cause: null).wasAborted, isFalse);
        expect(error.copyWith(prepared: PreparedAgentFiles()), isNot(error));
        final staged = StagedAgentFile(
          uploadedFileId: 'file_private',
          file: AgentEnvironmentFile(
            environmentId: 'environment_private',
            path: '/workspace/private',
            sizeBytes: 2,
          ),
        );
        expect(staged.copyWith(), staged);
        expect(staged.copyWith().hashCode, staged.hashCode);
        expect(staged.copyWith(uploadedFileId: 'different'), isNot(staged));
        expect(
          staged.copyWith(file: staged.file.copyWith(sizeBytes: 3)),
          isNot(staged),
        );
        for (final value in [prepared, error, staged]) {
          expect(value.toString(), isNot(contains('file_private')));
          expect(value.toString(), isNot(contains('/workspace/private')));
          expect(value.toString(), isNot(contains('private-failure')));
        }
      },
    );
  });

  test(
    'public preparation uses user_data, exact bytes/order and explicit paths',
    () async {
      final sent = <http.Request>[];
      final order = <String>[];
      final sdk = _client(
        MockClient((request) async {
          sent.add(request);
          order.add('upload${sent.length}');
          return _uploaded(sent.length, bytes: _multipartFile(request).length);
        }),
      );
      final prepared = await AgentFiles(sdk).prepare([
        _bytes('/workspace/selected.bin', [0, 255, 128, 13, 10]),
        AgentFileInput.stream(
          open: () {
            order.add('source2');
            return Stream.fromIterable([
              [1],
              [2, 3],
            ]);
          },
          length: 3,
          filename: 'second.bin',
          destination: '/workspace/nested/second.bin',
        ),
      ]);
      expect(order, ['upload1', 'source2', 'upload2']);
      expect(sent.map((r) => '${r.method} ${r.url.path}'), [
        'POST /proxy/v1/files',
        'POST /proxy/v1/files',
      ]);
      for (final request in sent) {
        expect(request.headers['authorization'], 'Bearer fixture-A');
        expect(request.headers['openai-project'], 'project-A');
        expect(request.headers['openai-organization'], 'org-A');
        expect(
          latin1.decode(request.bodyBytes),
          contains('name="purpose"\r\n\r\nuser_data\r\n'),
        );
      }
      expect(_multipartFile(sent[0]), [0, 255, 128, 13, 10]);
      expect(_multipartFile(sent[1]), [1, 2, 3]);
      expect(prepared.uploadedFileIds, ['file_fixture_1', 'file_fixture_2']);
      expect(prepared.files.map((f) => f.toJson()), [
        {
          'type': 'file_id',
          'file_id': 'file_fixture_1',
          'path': '/workspace/selected.bin',
        },
        {
          'type': 'file_id',
          'file_id': 'file_fixture_2',
          'path': '/workspace/nested/second.bin',
        },
      ]);
      sdk.close();
    },
  );

  test(
    'preflight validates every conflict and budget before source reads or uploads',
    () async {
      var opens = 0;
      var sends = 0;
      final sdk = _client(
        MockClient((_) async {
          sends++;
          return _uploaded(sends);
        }),
      );
      AgentFileInput stream(String path, int length) => AgentFileInput.stream(
        open: () {
          opens++;
          return Stream.value([1]);
        },
        length: length,
        filename: 'selected',
        destination: path,
      );
      for (final paths in [
        ['/workspace/a', '/workspace/a'],
        ['/workspace/a', '/workspace/a/b'],
        ['/workspace/a/b', '/workspace/a'],
      ]) {
        await expectLater(
          AgentFiles(sdk).prepare(paths.map((p) => stream(p, 1)).toList()),
          throwsFormatException,
        );
      }
      await expectLater(
        AgentFiles(sdk).prepare([
          stream('/workspace/a', 1),
          stream('/workspace/b', 3),
        ], maxFileBytes: 2),
        throwsFormatException,
      );
      await expectLater(
        AgentFiles(sdk).prepare([], maxFileBytes: -1),
        throwsFormatException,
      );
      expect(opens, 0);
      expect(sends, 0);
      sdk.close();
    },
  );

  test(
    'shared idempotency keys reject batches while one upload retains its key',
    () async {
      for (final fromDefaults in [true, false]) {
        final sent = <http.Request>[];
        final sdk = _client(
          MockClient((r) async {
            sent.add(r);
            return _uploaded(sent.length);
          }),
          headers: fromDefaults ? {'IDEMPOTENCY-Key': 'private-key'} : {},
        );
        final headers = fromDefaults
            ? null
            : {'Idempotency-Key': 'private-key'};
        await expectLater(
          AgentFiles(sdk).prepare([
            _bytes('/workspace/a'),
            _bytes('/workspace/b'),
          ], additionalHeaders: headers),
          throwsFormatException,
        );
        expect(sent, isEmpty);
        await AgentFiles(
          sdk,
        ).prepare([_bytes('/workspace/a')], additionalHeaders: headers);
        expect(sent.single.headers['idempotency-key'], 'private-key');
        sdk.close();
      }
    },
  );

  test(
    'request lists and header maps detach, and captured resources retain tenant generation',
    () async {
      final sent = <http.Request>[];
      final firstSeen = Completer<void>();
      final release = Completer<void>();
      final sdk = _client(
        MockClient((r) async {
          sent.add(r);
          if (sent.length == 1) {
            firstSeen.complete();
            await release.future;
          }
          return _uploaded(sent.length);
        }),
      );
      final helper = AgentFiles(sdk);
      final inputs = <AgentFileInput>[
        _bytes('/workspace/a'),
        _bytes('/workspace/b'),
      ];
      final headers = {'X-Selection': 'initial'};
      final pending = helper.prepare(inputs, additionalHeaders: headers);
      inputs.clear();
      headers['X-Selection'] = 'mutated';
      await firstSeen.future;
      sdk.updateConfig(
        baseUrl: 'https://b.invalid/v1',
        authProvider: const ApiKeyProvider('fixture-B'),
        project: 'project-B',
        organization: 'org-B',
      );
      release.complete();
      await pending;
      await AgentFiles(sdk).prepare([_bytes('/workspace/c')]);
      expect(sent.map((r) => r.url.host), [
        'a.invalid',
        'a.invalid',
        'b.invalid',
      ]);
      expect(sent.map((r) => r.headers['authorization']), [
        'Bearer fixture-A',
        'Bearer fixture-A',
        'Bearer fixture-B',
      ]);
      expect(sent.take(2).map((r) => r.headers['x-selection']), [
        'initial',
        'initial',
      ]);
      sdk.close();
    },
  );

  test(
    'partial HTTP failure retains only observed uploads and performs no deletion',
    () async {
      final sent = <http.Request>[];
      final sdk = _client(
        MockClient((request) async {
          sent.add(request);
          return sent.length == 1
              ? _uploaded(1)
              : http.Response(
                  '{"error":{"message":"private-name.bin","code":"private-code"}}',
                  429,
                  headers: {'retry-after': '0.01'},
                );
        }),
      );
      try {
        await AgentFiles(sdk).prepare([
          _bytes('/workspace/a'),
          _bytes('/workspace/b'),
          _bytes('/workspace/c'),
        ]);
        fail('expected partial preparation');
      } on AgentFilePreparationException catch (error) {
        expect(error.prepared.uploadedFileIds, ['file_fixture_1']);
        expect(error.prepared.files.single.path, '/workspace/a');
        expect(error.cause, isA<RateLimitException>());
        expect(
          (error.cause! as RateLimitException).retryAfter,
          const Duration(milliseconds: 10),
        );
        expect(error.toString(), isNot(contains('file_fixture_1')));
        expect(error.cause.toString(), isNot(contains('private-name')));
      }
      expect(sent, hasLength(2));
      expect(sent.every((r) => r.method == 'POST'), isTrue);
      sdk.close();
    },
  );

  test(
    'abort releases a selected source immediately and exposes prior uploads',
    () async {
      var sends = 0;
      var cancels = 0;
      final ready = Completer<void>();
      final abort = Completer<void>();
      final source = StreamController<List<int>>(
        onListen: ready.complete,
        onCancel: () {
          cancels++;
          return Completer<void>().future;
        },
      );
      final sdk = _client(MockClient((_) async => _uploaded(++sends)));
      final pending = AgentFiles(sdk).prepare([
        _bytes('/workspace/a'),
        AgentFileInput.stream(
          open: () => source.stream,
          length: 1,
          filename: 'private-stream',
          destination: '/workspace/b',
        ),
      ], abortTrigger: abort.future);
      final assertion = expectLater(
        pending,
        throwsA(
          isA<AgentFilePreparationException>()
              .having((e) => e.prepared.uploadedFileIds, 'observed IDs', [
                'file_fixture_1',
              ])
              .having((e) => e.wasAborted, 'abort cause', isTrue),
        ),
      );
      await ready.future;
      abort.complete();
      await assertion.timeout(const Duration(seconds: 1));
      expect(cancels, 1);
      expect(sends, 1);
      source.close().ignore();
      sdk.close();
    },
  );

  test(
    'already-completed abort and empty input have zero upload effects',
    () async {
      var sends = 0;
      final sdk = _client(MockClient((_) async => _uploaded(++sends)));
      final empty = await AgentFiles(sdk).prepare([]);
      expect(empty.uploadedFileIds, isEmpty);
      await expectLater(
        AgentFiles(
          sdk,
        ).prepare([_bytes('/workspace/a')], abortTrigger: Future<void>.value()),
        throwsA(
          isA<AgentFilePreparationException>()
              .having(
                (e) => e.prepared.uploadedFileIds,
                'no observed uploads',
                isEmpty,
              )
              .having((e) => e.wasAborted, 'abort', isTrue),
        ),
      );
      expect(sends, 0);
      sdk.close();
    },
  );

  test(
    'uncertain aborted delivery never fabricates a later upload ID',
    () async {
      final transport = _AbortUploadClient();
      final sdk = _client(transport);
      final abort = Completer<void>();
      final pending = AgentFiles(sdk).prepare([
        _bytes('/workspace/a'),
        _bytes('/workspace/b'),
      ], abortTrigger: abort.future);
      final assertion = expectLater(
        pending,
        throwsA(
          isA<AgentFilePreparationException>().having(
            (e) => e.prepared.uploadedFileIds,
            'only acknowledged upload',
            ['file_fixture_1'],
          ),
        ),
      );
      await transport.secondStarted.future;
      abort.complete();
      await assertion;
      expect(transport.sends, 2);
      expect(transport.closes, 0);
      sdk.close();
      expect(transport.closes, 0);
    },
  );

  test(
    'an acknowledgment observed despite cancellation stays available for caller cleanup',
    () async {
      final abort = Completer<void>();
      var sends = 0;
      final sdk = _client(
        MockClient((_) async {
          sends++;
          if (sends == 2) abort.complete();
          return _uploaded(sends);
        }),
      );
      await expectLater(
        AgentFiles(sdk).prepare([
          _bytes('/workspace/a'),
          _bytes('/workspace/b'),
          _bytes('/workspace/c'),
        ], abortTrigger: abort.future),
        throwsA(
          isA<AgentFilePreparationException>().having(
            (e) => e.prepared.uploadedFileIds,
            'observed acknowledgments',
            ['file_fixture_1', 'file_fixture_2'],
          ),
        ),
      );
      expect(sends, 2);
      sdk.close();
    },
  );

  test(
    'bad stream lengths and source errors stop before their upload with precise partial ownership',
    () async {
      for (final mode in [
        'short',
        'long',
        'invalid-byte',
        'open-error',
        'stream-error',
      ]) {
        var sends = 0;
        final sdk = _client(MockClient((_) async => _uploaded(++sends)));
        Stream<List<int>> source() {
          if (mode == 'open-error') throw StateError('private-source-path');
          if (mode == 'stream-error')
            return Stream.error(StateError('private-source-path'));
          return Stream.value(
            mode == 'long'
                ? [1, 2, 3]
                : mode == 'invalid-byte'
                ? [256, 1]
                : [1],
          );
        }

        await expectLater(
          AgentFiles(sdk).prepare([
            _bytes('/workspace/a'),
            AgentFileInput.stream(
              open: source,
              length: 2,
              filename: 'private-source',
              destination: '/workspace/b',
            ),
          ]),
          throwsA(
            isA<AgentFilePreparationException>()
                .having((e) => e.prepared.uploadedFileIds, 'prior IDs', [
                  'file_fixture_1',
                ])
                .having(
                  (e) => e.toString(),
                  'private diagnostics',
                  isNot(contains('private-source')),
                ),
          ),
        );
        expect(sends, 1);
        sdk.close();
      }
    },
  );

  test('source chunk reuse cannot mutate already materialized bytes', () async {
    final mutable = [1, 2];
    Stream<List<int>> source() async* {
      yield mutable;
      mutable[0] = 9;
      yield mutable;
    }

    late List<int> sent;
    final sdk = _client(
      MockClient((request) async {
        sent = _multipartFile(request);
        return _uploaded(1, bytes: 4);
      }),
    );
    await AgentFiles(sdk).prepare([
      AgentFileInput.stream(
        open: source,
        length: 4,
        filename: 'selected',
        destination: '/workspace/a',
      ),
    ]);
    expect(sent, [1, 2, 9, 2]);
    sdk.close();
  });

  test(
    'mapping failure keeps a successful overlong upload identifier as observed',
    () async {
      final observed = 'f' * 257;
      final sdk = _client(MockClient((_) async => _uploaded(1, id: observed)));
      await expectLater(
        AgentFiles(sdk).prepare([_bytes('/workspace/a')]),
        throwsA(
          isA<AgentFilePreparationException>()
              .having((e) => e.prepared.uploadedFileIds, 'observed actual ID', [
                observed,
              ])
              .having((e) => e.prepared.files, 'unusable mapping', isEmpty),
        ),
      );
      sdk.close();
    },
  );

  test(
    'explicit staging uses the same tenant and keeps a separately owned upload',
    () async {
      final sent = <http.Request>[];
      const environmentId = 'environment /?🚀';
      final sdk = _client(
        MockClient((request) async {
          sent.add(request);
          if (request.url.pathSegments.contains('environments')) {
            expect(request.headers['openai-beta'], 'agents=v1');
            expect(
              request.url.pathSegments[request.url.pathSegments.length - 2],
              environmentId,
            );
            expect(jsonDecode(utf8.decode(request.bodyBytes)), {
              'type': 'file_id',
              'file_id': 'file_fixture_1',
              'path': '/workspace/input.bin',
            });
            return http.Response(
              jsonEncode(
                AgentEnvironmentFile(
                  environmentId: environmentId,
                  path: '/workspace/input.bin',
                  sizeBytes: 2,
                ).toJson(),
              ),
              201,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }
          return _uploaded(1);
        }),
      );
      final staged = await AgentFiles(
        sdk,
      ).stage(environmentId, _bytes('/workspace/input.bin'));
      expect(staged.uploadedFileId, 'file_fixture_1');
      expect(staged.file.environmentId, environmentId);
      expect(sent, hasLength(2));
      for (final request in sent) {
        expect(request.headers['authorization'], 'Bearer fixture-A');
        expect(request.headers['openai-project'], 'project-A');
      }
      sdk.close();
    },
  );

  test(
    'staging does not reuse upload idempotency from defaults, options or provider',
    () async {
      for (final mode in ['defaults', 'options', 'provider']) {
        final sent = <http.Request>[];
        final sdk = OpenAIClient(
          config: OpenAIConfig(
            baseUrl: 'https://fixture.invalid/v1',
            defaultHeaders: mode == 'defaults'
                ? {'iDeMpOtEnCy-KeY': 'upload-key'}
                : {},
            authProvider: mode == 'provider' ? _KeyProvider() : null,
            retryPolicy: const RetryPolicy(maxRetries: 0),
          ),
          httpClient: MockClient((request) async {
            sent.add(request);
            if (sent.length == 1) return _uploaded(1);
            return http.Response(
              jsonEncode(
                AgentEnvironmentFile(
                  environmentId: 'env_fixture',
                  path: '/workspace/a',
                  sizeBytes: 2,
                ).toJson(),
              ),
              201,
              headers: {'content-type': 'application/json; charset=utf-8'},
            );
          }),
        );
        await AgentFiles(sdk).stage(
          'env_fixture',
          _bytes('/workspace/a'),
          additionalHeaders: mode == 'options'
              ? {'IDEMPOTENCY-key': 'upload-key'}
              : null,
        );
        expect(sent.first.headers['idempotency-key'], 'upload-key');
        expect(sent.last.headers.containsKey('idempotency-key'), isFalse);
        sdk.close();
      }
    },
  );

  test(
    'staging scopes both HTTP abort signals and releases each on success',
    () async {
      final capture = _CaptureAbortSignals();
      final caller = Completer<void>();
      var sends = 0;
      final sdk = _client(
        MockClient((_) async {
          if (++sends == 1) return _uploaded(1);
          return http.Response(
            jsonEncode(
              AgentEnvironmentFile(
                environmentId: 'environment_fixture',
                path: '/workspace/a',
                sizeBytes: 2,
              ).toJson(),
            ),
            201,
          );
        }),
      );
      sdk.interceptorChain.interceptors.insert(0, capture);
      await AgentFiles(sdk).stage(
        'environment_fixture',
        _bytes('/workspace/a'),
        abortTrigger: caller.future,
      );
      expect(capture.signals, hasLength(2));
      expect(
        capture.signals.every((signal) => !identical(signal, caller.future)),
        isTrue,
      );
      expect(identical(capture.signals[0], capture.signals[1]), isFalse);
      await Future.wait(capture.signals.cast<Future<void>>());
      expect(caller.isCompleted, isFalse);
      sdk.close();
    },
  );

  test(
    'abort between upload and staging preserves observed IDs without a second write',
    () async {
      var sends = 0;
      final sdk = _client(MockClient((_) async => _uploaded(++sends)));
      final abort = _AbortOnSecondWatch();
      await expectLater(
        AgentFiles(sdk).stage(
          'environment_fixture',
          _bytes('/workspace/a'),
          abortTrigger: abort,
        ),
        throwsA(
          isA<AgentFilePreparationException>()
              .having((error) => error.wasAborted, 'aborted', isTrue)
              .having(
                (error) => error.prepared.uploadedFileIds,
                'known upload',
                ['file_fixture_1'],
              ),
        ),
      );
      expect(abort.watches, 2);
      expect(sends, 1);
      sdk.close();
    },
  );

  test(
    'dynamic repeated upload keys fail before the affected POST with known partial ownership',
    () async {
      var sends = 0;
      final sdk = OpenAIClient(
        config: OpenAIConfig(
          authProvider: _KeyProvider(),
          retryPolicy: const RetryPolicy(maxRetries: 0),
        ),
        httpClient: MockClient((_) async => _uploaded(++sends)),
      );
      await expectLater(
        AgentFiles(
          sdk,
        ).prepare([_bytes('/workspace/a'), _bytes('/workspace/b')]),
        throwsA(
          isA<AgentFilePreparationException>()
              .having(
                (error) => error.prepared.uploadedFileIds,
                'known first upload',
                ['file_fixture_1'],
              )
              .having(
                (error) => error.cause,
                'private final-request rejection',
                isA<ConnectionException>(),
              )
              .having(
                (error) => error.toString(),
                'private key',
                isNot(contains('upload-key')),
              ),
        ),
      );
      expect(sends, 1);
      sdk.close();
    },
  );

  test(
    'invalid staging context has no upload; staging failure preserves its known ID',
    () async {
      final sent = <http.Request>[];
      final sdk = _client(
        MockClient((request) async {
          sent.add(request);
          return sent.length == 1
              ? _uploaded(1)
              : http.Response(
                  '{"error":{"message":"private-stage-path"}}',
                  500,
                );
        }),
      );
      for (final id in ['', '.', '..', '\ud800', '\udfff']) {
        await expectLater(
          AgentFiles(sdk).stage(id, _bytes('/workspace/a')),
          throwsFormatException,
        );
      }
      expect(sent, isEmpty);
      await expectLater(
        AgentFiles(sdk).stage('environment_fixture', _bytes('/workspace/a')),
        throwsA(
          isA<AgentFilePreparationException>()
              .having(
                (e) => e.prepared.uploadedFileIds,
                'staging upload ownership',
                ['file_fixture_1'],
              )
              .having(
                (e) => e.cause,
                'typed staging failure',
                isA<InternalServerException>(),
              ),
        ),
      );
      expect(sent, hasLength(2));
      expect(sent.any((r) => r.method == 'DELETE'), isFalse);
      sdk.close();
    },
  );
}

List<int> _multipartFile(http.Request request) {
  final boundary = RegExp(
    r'boundary=([^;]+)',
  ).firstMatch(request.headers['content-type']!)!.group(1)!;
  final text = latin1.decode(request.bodyBytes);
  final file = text.indexOf('name="file"');
  final start = text.indexOf('\r\n\r\n', file) + 4;
  final end = text.indexOf('\r\n--$boundary', start);
  return latin1.encode(text.substring(start, end));
}

class _AbortUploadClient extends http.BaseClient {
  int sends = 0;
  int closes = 0;
  final secondStarted = Completer<void>();
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    await request.finalize().drain<void>();
    if (sends == 1) {
      final result = _uploaded(1);
      return http.StreamedResponse(Stream.value(result.bodyBytes), 200);
    }
    secondStarted.complete();
    if (request is http.Abortable) await request.abortTrigger;
    throw http.RequestAbortedException(request.url);
  }

  @override
  void close() {
    closes++;
  }
}

class _KeyProvider implements AuthProvider {
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer fixture-key',
    'IDEMPOTENCY-Key': 'upload-key',
  };
}

class _CaptureAbortSignals implements Interceptor {
  final signals = <Future<void>?>[];
  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    signals.add(context.abortTrigger);
    return next(context);
  }
}

class _AbortOnSecondWatch implements Future<void> {
  final _completion = Completer<void>();
  int watches = 0;
  @override
  Future<R> then<R>(FutureOr<R> Function(void) onValue, {Function? onError}) {
    if (++watches == 2) _completion.complete();
    return _completion.future.then(onValue, onError: onError);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Only then is used by this fixture.');
}
