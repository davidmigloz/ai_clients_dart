@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart_agent_files_io.dart';
import 'package:test/test.dart';

const _private = 'PRIVATE_IO_SELECTION';

Matcher _privateFailure() => isA<AgentFileSystemException>().having(
  (e) => e.toString(),
  'private diagnostics',
  isNot(contains(_private)),
);

Future<List<int>> _bytes(AgentFileInputStream input) async => [
  await for (final chunk in input.open()) ...chunk,
];

const _hosted = '/workspace/outputs/$_private.bin';

final class _ArtifactsTransport extends http.BaseClient {
  _ArtifactsTransport({this.body}) : bytes = const [0, 255, 128, 0];
  final List<int> bytes;
  final Stream<List<int>> Function()? body;
  final requests = <http.BaseRequest>[];
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (request.url.path.endsWith('/content')) {
      return http.StreamedResponse(
        body?.call() ?? Stream.value(bytes),
        200,
        headers: {'content-type': 'application/octet-stream'},
        request: request,
      );
    }
    return http.StreamedResponse(
      Stream.value(
        utf8.encode(
          jsonEncode({
            'object': 'list',
            'data': [
              {
                'id': 'artifact_$_private',
                'object': 'agent.session.artifact',
                'created_at': 1,
                'environment_id': 'environment_$_private',
                'path': _hosted,
                'session_id': 'session_$_private',
                'turn_id': 'turn_$_private',
                'size_bytes': bytes.length,
              },
            ],
            'first_id': 'artifact_$_private',
            'last_id': 'artifact_$_private',
            'has_more': false,
          }),
        ),
      ),
      200,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

AgentResultArtifacts _artifacts(_ArtifactsTransport transport) {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('synthetic-io-fixture'),
      retryPolicy: RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  addTearDown(client.close);
  return AgentResultArtifacts.forTurn(
    resource: client.agents.sessions.artifacts,
    sessionId: 'session_$_private',
    turnId: 'turn_$_private',
  );
}

void main() {
  late Directory root;
  late AgentFileSystem system;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('agent-files-$_private-');
    system = await AgentFileSystem.open(root);
  });
  tearDown(() async {
    if (root.existsSync()) await root.delete(recursive: true);
  });

  test(
    'selects exact binary bytes, filename, hosted destination and size',
    () async {
      await Directory('${root.path}/nested').create();
      final bytes = [0, 255, 128, 10, 13, 0];
      await File('${root.path}/nested/$_private.bin').writeAsBytes(bytes);
      final selected = await system.selectFile(
        'nested/$_private.bin',
        destination: '/workspace/selected.bin',
      );
      expect(selected.filename, '$_private.bin');
      expect(selected.destination, '/workspace/selected.bin');
      expect(selected.length, bytes.length);
      expect(await _bytes(selected), bytes);
      expect(system.toString(), isNot(contains(_private)));
      expect(selected.toString(), isNot(contains(_private)));
    },
  );

  test('zero-length regular source remains an empty binary stream', () async {
    await File('${root.path}/empty').create();
    final selected = await system.selectFile(
      'empty',
      destination: '/workspace/empty',
    );
    expect(selected.length, 0);
    expect(await _bytes(selected), isEmpty);
  });

  test('system aliases above the explicit root are resolved', () async {
    // The platform temporary-directory spelling may already contain an alias.
    final canonical = await root.resolveSymbolicLinks();
    await File('$canonical/input').writeAsBytes([1, 2]);
    final selected = await system.selectFile(
      'input',
      destination: '/workspace/input',
    );
    expect(await _bytes(selected), [1, 2]);
  });

  for (final path in [
    '',
    '../$_private',
    './input',
    '/absolute',
    'a//b',
    r'a\b',
    'C:drive-relative',
    'nested/C:drive-relative',
    'file:stream',
    r'directory/file:stream:$DATA',
    'input/..',
    'input\u0000',
  ]) {
    test(
      'rejects invalid relative source ${path.codeUnits} privately',
      () async {
        await expectLater(
          system.selectFile(path, destination: '/workspace/input'),
          throwsA(_privateFailure()),
        );
      },
    );
  }

  test('rejects a missing or non-directory root without creation', () async {
    final missing = Directory('${root.path}/missing');
    await expectLater(
      AgentFileSystem.open(missing),
      throwsA(_privateFailure()),
    );
    expect(missing.existsSync(), isFalse);
    final file = await File('${root.path}/file').create();
    await expectLater(
      AgentFileSystem.open(Directory(file.path)),
      throwsA(_privateFailure()),
    );
  });

  test('rejects source directories and missing parents', () async {
    await Directory('${root.path}/directory').create();
    for (final path in ['directory', 'missing', 'missing/file']) {
      await expectLater(
        system.selectFile(path, destination: '/workspace/input'),
        throwsA(_privateFailure()),
      );
    }
  });

  test('rejects root, source and parent symlinks', () async {
    final target = await File('${root.path}/target').writeAsBytes([1]);
    final directory = await Directory('${root.path}/directory').create();
    await Link('${root.path}/source-link').create(target.path);
    await Link('${root.path}/parent-link').create(directory.path);
    await Link('${root.path}/root-link').create(root.path);
    await expectLater(
      AgentFileSystem.open(Directory('${root.path}/root-link')),
      throwsA(_privateFailure()),
    );
    await expectLater(
      AgentFileSystem.open(Directory('${root.path}/root-link/')),
      throwsA(_privateFailure()),
    );
    for (final path in ['source-link', 'parent-link/file']) {
      await expectLater(
        system.selectFile(path, destination: '/workspace/input'),
        throwsA(_privateFailure()),
      );
    }
  });

  test('rejects dangling source links without following them', () async {
    await Link('${root.path}/dangling').create('${root.path}/missing');
    await expectLater(
      system.selectFile('dangling', destination: '/workspace/input'),
      throwsA(_privateFailure()),
    );
  });

  test('rejects size changes before lazy source opening', () async {
    final file = await File('${root.path}/source').writeAsBytes([1, 2]);
    final selected = await system.selectFile(
      'source',
      destination: '/workspace/input',
    );
    await file.writeAsBytes([1, 2, 3]);
    await expectLater(_bytes(selected), throwsA(_privateFailure()));
  });

  test('rejects source truncation before lazy opening', () async {
    final file = await File('${root.path}/source').writeAsBytes([1, 2]);
    final selected = await system.selectFile(
      'source',
      destination: '/workspace/input',
    );
    await file.writeAsBytes([1]);
    await expectLater(_bytes(selected), throwsA(_privateFailure()));
  });

  test(
    'rejects same-size metadata changes before lazy source opening',
    () async {
      final file = await File('${root.path}/source').writeAsBytes([1, 2]);
      await file.setLastModified(DateTime.utc(2020));
      final selected = await system.selectFile(
        'source',
        destination: '/workspace/input',
      );
      await file.writeAsBytes([3, 4]);
      await file.setLastModified(DateTime.utc(2021));
      await expectLater(_bytes(selected), throwsA(_privateFailure()));
    },
  );

  test('rejects ordinary source replacement before opening', () async {
    final file = await File('${root.path}/source').writeAsBytes([1, 2]);
    final selected = await system.selectFile(
      'source',
      destination: '/workspace/input',
    );
    await file.rename('${root.path}/original');
    await File(file.path).writeAsBytes([3, 4, 5]);
    await expectLater(_bytes(selected), throwsA(_privateFailure()));
    expect(await File('${root.path}/original').readAsBytes(), [1, 2]);
  });

  test('rejects a selected source replaced by a symlink', () async {
    final file = await File('${root.path}/source').writeAsBytes([1, 2]);
    final selected = await system.selectFile(
      'source',
      destination: '/workspace/input',
    );
    await file.delete();
    final target = await File('${root.path}/other').writeAsBytes([3, 4]);
    await Link(file.path).create(target.path);
    await expectLater(_bytes(selected), throwsA(_privateFailure()));
  });

  for (final mutation in ['growth', 'truncation', 'replacement']) {
    test('detects source $mutation during a held-handle transfer', () async {
      final file = await File(
        '${root.path}/source',
      ).writeAsBytes(List.filled(131072, 7));
      final selected = await system.selectFile(
        'source',
        destination: '/workspace/input',
      );
      var changed = false;
      await expectLater(() async {
        await for (final chunk in selected.open()) {
          expect(chunk, isNotEmpty);
          if (!changed) {
            changed = true;
            if (mutation == 'growth') {
              await file.writeAsBytes([9], mode: FileMode.append);
            } else if (mutation == 'truncation') {
              await file.writeAsBytes([9]);
            } else {
              await file.rename('${root.path}/original');
              await File(file.path).writeAsBytes([9]);
            }
          }
        }
      }(), throwsA(_privateFailure()));
    });
  }

  test(
    'source cancellation settles and releases its selected handle',
    () async {
      final file = await File(
        '${root.path}/source',
      ).writeAsBytes(List.filled(131072, 7));
      final selected = await system.selectFile(
        'source',
        destination: '/workspace/input',
      );
      await for (final _ in selected.open()) {
        break;
      }
      await file.rename('${root.path}/renamed');
      expect(await File('${root.path}/renamed').length(), 131072);
    },
  );

  test('explicit native cause is retained but never printed', () {
    final cause = FileSystemException(_private, root.path);
    final error = AgentFileSystemException(
      operation: _private,
      path: root.path,
      cause: cause,
    );
    expect(error.path, root.path);
    expect(error.cause, same(cause));
    expect(error.toString(), isNot(contains(_private)));
  });

  test(
    'downloads exact bytes only to the explicit new local destination',
    () async {
      final transport = _ArtifactsTransport();
      final selected = await system.downloadFile(
        _artifacts(transport),
        path: _hosted,
        destination: 'chosen.bin',
      );
      expect(selected.path, _hosted);
      expect(
        await File('${root.path}/chosen.bin').readAsBytes(),
        transport.bytes,
      );
      expect(File('${root.path}/$_private.bin').existsSync(), isFalse);
      expect(transport.requests.length, 2);
      await File('${root.path}/chosen.bin').rename('${root.path}/renamed.bin');
    },
  );

  test('download snapshots per-call headers before local awaits', () async {
    final transport = _ArtifactsTransport();
    final headers = {'X-Caller': 'original'};
    final future = system.downloadFile(
      _artifacts(transport),
      path: _hosted,
      destination: 'chosen.bin',
      additionalHeaders: headers,
    );
    headers['X-Caller'] = 'mutated';
    await future;
    expect(
      transport.requests.map((request) => request.headers['X-Caller']),
      everyElement('original'),
    );
  });

  for (final kind in ['file', 'directory', 'link', 'dangling link']) {
    test(
      'existing destination $kind rejects unchanged before any HTTP call',
      () async {
        final local = '${root.path}/existing';
        final original = [9, 8, 7];
        if (kind == 'file') {
          await File(local).writeAsBytes(original);
        } else if (kind == 'directory') {
          await Directory(local).create();
        } else {
          final target = '${root.path}/target';
          if (kind == 'link') await File(target).writeAsBytes(original);
          await Link(local).create(target);
        }
        final transport = _ArtifactsTransport();
        await expectLater(
          system.downloadFile(
            _artifacts(transport),
            path: _hosted,
            destination: 'existing',
          ),
          throwsA(_privateFailure()),
        );
        expect(transport.requests, isEmpty);
        if (kind == 'file') expect(await File(local).readAsBytes(), original);
        if (kind == 'link') {
          expect(await File('${root.path}/target').readAsBytes(), original);
        }
        expect(
          FileSystemEntity.typeSync(local, followLinks: false),
          isNot(FileSystemEntityType.notFound),
        );
      },
    );
  }

  for (final destination in [
    'missing/output',
    'parent-link/output',
    '../escape',
    'nested/file:stream',
    r'nested/file:stream:$DATA',
  ]) {
    test(
      'invalid output parent or relative selection rejects privately: $destination',
      () async {
        final directory = await Directory(
          '${root.path}/target-directory',
        ).create();
        await Link('${root.path}/parent-link').create(directory.path);
        final transport = _ArtifactsTransport();
        await expectLater(
          system.downloadFile(
            _artifacts(transport),
            path: _hosted,
            destination: destination,
          ),
          throwsA(_privateFailure()),
        );
        expect(transport.requests, isEmpty);
        expect(File('${directory.path}/output').existsSync(), isFalse);
      },
    );
  }

  test(
    'download preserves source failure and leaves partial output caller-owned',
    () async {
      final transport = _ArtifactsTransport(
        body: () async* {
          yield [0, 255];
          throw StateError(_private);
        },
      );
      await expectLater(
        system.downloadFile(
          _artifacts(transport),
          path: _hosted,
          destination: 'partial',
        ),
        throwsA(
          isA<OpenAIException>().having(
            (e) => e.toString(),
            'private failure',
            isNot(contains(_private)),
          ),
        ),
      );
      final file = File('${root.path}/partial');
      expect(await file.readAsBytes(), [0, 255]);
      await file.rename('${root.path}/partial-renamed');
    },
  );

  test(
    'abort closes local handle while idle remote source releases later',
    () async {
      final abort = Completer<void>();
      final waiting = Completer<void>();
      final release = Completer<void>();
      addTearDown(() {
        if (!release.isCompleted) release.complete();
      });
      final transport = _ArtifactsTransport(
        body: () async* {
          yield [0, 255];
          waiting.complete();
          await release.future;
        },
      );
      final download = system.downloadFile(
        _artifacts(transport),
        path: _hosted,
        destination: 'partial',
        abortTrigger: abort.future,
      );
      final outcome = expectLater(
        download.timeout(const Duration(seconds: 5)),
        throwsA(isA<AbortedException>()),
      );
      await waiting.future;
      abort.complete();
      await outcome;
      expect(await File('${root.path}/partial').readAsBytes(), [0, 255]);
      await File('${root.path}/partial').rename('${root.path}/partial-renamed');
    },
  );

  test(
    'replacement output is retained and never deleted after sink failure',
    () async {
      final local = File('${root.path}/chosen');
      final transport = _ArtifactsTransport(
        body: () async* {
          await local.rename('${root.path}/created-original');
          await File(local.path).writeAsBytes([9, 8, 7]);
          yield [0, 255];
        },
      );
      await expectLater(
        system.downloadFile(
          _artifacts(transport),
          path: _hosted,
          destination: 'chosen',
        ),
        throwsA(
          isA<ConnectionException>()
              .having(
                (e) => e.cause,
                'local sink cause',
                isA<AgentFileSystemException>(),
              )
              .having(
                (e) => e.toString(),
                'private failure',
                isNot(contains(_private)),
              ),
        ),
      );
      expect(await local.readAsBytes(), [9, 8, 7]);
      expect(
        await File('${root.path}/created-original').readAsBytes(),
        isEmpty,
      );
    },
  );
}
