import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_file_wire_fixtures.dart';

Map<String, dynamic> wire(String n) =>
    jsonDecode(
          jsonEncode(
            agentFileWireFixtures.singleWhere((f) => f.schema == n).full,
          ),
        )
        as Map<String, dynamic>;
void main() {
  test(
    'file copy config preserves byte and absolute workspace constraints',
    () {
      final maximum = base64Encode(List<int>.filled(5 * 1024 * 1024, 0));
      final valid = AgentSessionHostedEnvironmentFileConfigInline(
        data: maximum,
        path: '/workspace/a',
      );
      expect(valid.toJson()['data'], maximum);
      final oversize = base64Encode(List<int>.filled(5 * 1024 * 1024 + 1, 0));
      expect(oversize.length, maximum.length);
      expect(() => valid.copyWith(data: oversize), throwsFormatException);
      for (final data in [
        'PRIVATE',
        'QQ',
        'Q===',
        'data:application/octet-stream;base64,QQ==',
        '_w==',
      ]) {
        expect(
          () => AgentSessionHostedEnvironmentFileConfig.inline(
            data: data,
            path: '/workspace/a',
          ),
          throwsFormatException,
        );
      }
      for (final path in [
        'PRIVATE',
        '/workspace',
        '/workspace/../../PRIVATE',
        '/workspace/PRIVATE\u0000',
        '/elsewhere/a',
      ]) {
        expect(
          () => AgentSessionHostedEnvironmentFileConfig.fileId(
            fileId: 'file',
            path: path,
          ),
          throwsFormatException,
        );
      }
      expect(
        AgentSessionHostedEnvironmentFileConfig.inline(
          data: '',
          path: '/workspace/empty',
        ).toJson()['data'],
        '',
      );
    },
  );
  test('new received list constructors detach nested metadata and lists', () {
    final nested = <String, dynamic>{
      'private': <Object?>['PRIVATE', null],
    };
    final f = AgentEnvironmentFile(
      environmentId: 'e',
      path: '/workspace/a',
      sizeBytes: 0,
      rawJson: {'future': nested},
    );
    final files = <AgentEnvironmentFile>[f];
    final page = AgentEnvironmentFileList(
      data: files,
      next: null,
      hasMore: false,
      object: AgentEnvironmentFilePageObject.page,
    );
    final expected = page.toJson();
    files.clear();
    (nested['private'] as List)[0] = 'changed';
    expect(page.toJson(), expected);
    expect(page.data.single.toJson()['future'], {
      'private': ['PRIVATE', null],
    });
    expect(page.data.clear, throwsUnsupportedError);
    expect(page.toString(), isNot(contains('PRIVATE')));
    expect(page.copyWith(), page);
    expect(page.copyWith().hashCode, page.hashCode);
  });

  test('EnvironmentFileListResource.data: canonical maximum rejection', () {
    final body = wire('EnvironmentFileListResource');
    body['data'] = List<Object?>.filled(
      2001,
      (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
    );
    expect(
      () => agentFileWireFixtures
          .singleWhere((f) => f.schema == 'EnvironmentFileListResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test(
    'HostedEnvironmentFileParamFileId.file_id: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamFileId');
      body['file_id'] = '🚀' * 257;
      expect(
        () => agentFileWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamFileId')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileParamFileId.path: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamFileId');
      body['path'] = '🚀' * 4097;
      expect(
        () => agentFileWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamFileId')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileParamInline.data: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamInline');
      body['data'] = 'A' * 6990512;
      expect(
        () => agentFileWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamInline')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileParamInline.path: canonical maximum rejection',
    () {
      final body = wire('HostedEnvironmentFileParamInline');
      body['path'] = '🚀' * 4097;
      expect(
        () => agentFileWireFixtures
            .singleWhere((f) => f.schema == 'HostedEnvironmentFileParamInline')
            .parse(body),
        throwsFormatException,
      );
    },
  );
  test('SessionArtifactListResource.data: canonical maximum rejection', () {
    final body = wire('SessionArtifactListResource');
    body['data'] = List<Object?>.filled(
      2001,
      (body['data'] as List).isEmpty ? '' : (body['data'] as List).first,
    );
    expect(
      () => agentFileWireFixtures
          .singleWhere((f) => f.schema == 'SessionArtifactListResource')
          .parse(body),
      throwsFormatException,
    );
  });
  test('AgentEnvironmentFile.sizeBytes: parse rejects double.nan', () {
    final body = wire('EnvironmentFileResource');
    final original = AgentEnvironmentFile.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentEnvironmentFile.fromJson({...body, 'size_bytes': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentFile.sizeBytes: copy rejects double.nan', () {
    final body = wire('EnvironmentFileResource');
    final original = AgentEnvironmentFile.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(sizeBytes: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentFile.sizeBytes: construct rejects double.nan', () {
    final body = wire('EnvironmentFileResource');
    final original = AgentEnvironmentFile.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentEnvironmentFile(
        environmentId: original.environmentId,
        path: original.path,
        sizeBytes: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentFile.sizeBytes: parse rejects double.infinity', () {
    final body = wire('EnvironmentFileResource');
    final original = AgentEnvironmentFile.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentEnvironmentFile.fromJson({...body, 'size_bytes': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentFile.sizeBytes: copy rejects double.infinity', () {
    final body = wire('EnvironmentFileResource');
    final original = AgentEnvironmentFile.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(sizeBytes: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentEnvironmentFile.sizeBytes: construct rejects double.infinity', () {
    final body = wire('EnvironmentFileResource');
    final original = AgentEnvironmentFile.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentEnvironmentFile(
        environmentId: original.environmentId,
        path: original.path,
        sizeBytes: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentEnvironmentFile.sizeBytes: parse rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentFileResource');
      final original = AgentEnvironmentFile.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentEnvironmentFile.fromJson({...body, 'size_bytes': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentFile.sizeBytes: copy rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentFileResource');
      final original = AgentEnvironmentFile.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentEnvironmentFile.sizeBytes: construct rejects double.negativeInfinity',
    () {
      final body = wire('EnvironmentFileResource');
      final original = AgentEnvironmentFile.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentEnvironmentFile(
          environmentId: original.environmentId,
          path: original.path,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionArtifact.createdAt: parse rejects double.nan', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionArtifact.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.createdAt: copy rejects double.nan', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.createdAt: construct rejects double.nan', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionArtifact(
        id: original.id,
        sessionId: original.sessionId,
        environmentId: original.environmentId,
        turnId: original.turnId,
        path: original.path,
        sizeBytes: original.sizeBytes,
        createdAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.createdAt: parse rejects double.infinity', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionArtifact.fromJson({...body, 'created_at': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.createdAt: copy rejects double.infinity', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(createdAt: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.createdAt: construct rejects double.infinity', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionArtifact(
        id: original.id,
        sessionId: original.sessionId,
        environmentId: original.environmentId,
        turnId: original.turnId,
        path: original.path,
        sizeBytes: original.sizeBytes,
        createdAt: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionArtifact.createdAt: parse rejects double.negativeInfinity',
    () {
      final body = wire('SessionArtifactResource');
      final original = AgentSessionArtifact.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionArtifact.fromJson({...body, 'created_at': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionArtifact.createdAt: copy rejects double.negativeInfinity',
    () {
      final body = wire('SessionArtifactResource');
      final original = AgentSessionArtifact.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(createdAt: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionArtifact.createdAt: construct rejects double.negativeInfinity',
    () {
      final body = wire('SessionArtifactResource');
      final original = AgentSessionArtifact.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionArtifact(
          id: original.id,
          sessionId: original.sessionId,
          environmentId: original.environmentId,
          turnId: original.turnId,
          path: original.path,
          sizeBytes: original.sizeBytes,
          createdAt: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('AgentSessionArtifact.sizeBytes: parse rejects double.nan', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionArtifact.fromJson({...body, 'size_bytes': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.sizeBytes: copy rejects double.nan', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => original.copyWith(sizeBytes: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.sizeBytes: construct rejects double.nan', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.nan;
    expect(
      () => AgentSessionArtifact(
        id: original.id,
        sessionId: original.sessionId,
        environmentId: original.environmentId,
        turnId: original.turnId,
        path: original.path,
        createdAt: original.createdAt,
        sizeBytes: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.sizeBytes: parse rejects double.infinity', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionArtifact.fromJson({...body, 'size_bytes': bad}),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.sizeBytes: copy rejects double.infinity', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => original.copyWith(sizeBytes: bad),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test('AgentSessionArtifact.sizeBytes: construct rejects double.infinity', () {
    final body = wire('SessionArtifactResource');
    final original = AgentSessionArtifact.fromJson(body);
    expect(original.toJson(), body);
    const dynamic bad = double.infinity;
    expect(
      () => AgentSessionArtifact(
        id: original.id,
        sessionId: original.sessionId,
        environmentId: original.environmentId,
        turnId: original.turnId,
        path: original.path,
        createdAt: original.createdAt,
        sizeBytes: bad,
      ),
      throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
    );
  });
  test(
    'AgentSessionArtifact.sizeBytes: parse rejects double.negativeInfinity',
    () {
      final body = wire('SessionArtifactResource');
      final original = AgentSessionArtifact.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionArtifact.fromJson({...body, 'size_bytes': bad}),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionArtifact.sizeBytes: copy rejects double.negativeInfinity',
    () {
      final body = wire('SessionArtifactResource');
      final original = AgentSessionArtifact.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => original.copyWith(sizeBytes: bad),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test(
    'AgentSessionArtifact.sizeBytes: construct rejects double.negativeInfinity',
    () {
      final body = wire('SessionArtifactResource');
      final original = AgentSessionArtifact.fromJson(body);
      expect(original.toJson(), body);
      const dynamic bad = double.negativeInfinity;
      expect(
        () => AgentSessionArtifact(
          id: original.id,
          sessionId: original.sessionId,
          environmentId: original.environmentId,
          turnId: original.turnId,
          path: original.path,
          createdAt: original.createdAt,
          sizeBytes: bad,
        ),
        throwsA(anyOf(isA<FormatException>(), isA<TypeError>())),
      );
    },
  );
  test('EnvironmentFilePageObjectResource: page', () {
    final v = AgentEnvironmentFilePageObject.fromJson('page');
    expect(v.toJson(), 'page');
  });
  test('HostedEnvironmentFileParam: known file_id source variant', () {
    final body =
        jsonDecode(
              r'''{"file_id": "file_synthetic", "path": "/workspace/PRIVATE-file-caf\u00e9\ud83d\ude80.bin", "type": "file_id"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedEnvironmentFileConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedEnvironmentFileConfig.fromJson({
        ...body,
        'type': 'file_id',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test('HostedEnvironmentFileParam: known inline source variant', () {
    final body =
        jsonDecode(
              r'''{"data": "AP+AAA0KQUJD", "path": "/workspace/PRIVATE-file-caf\u00e9\ud83d\ude80.bin", "type": "inline"}''',
            )
            as Map<String, dynamic>;
    final value = AgentSessionHostedEnvironmentFileConfig.fromJson(body);
    expect(value.toJson(), body);
    expect(
      () => AgentSessionHostedEnvironmentFileConfig.fromJson({
        ...body,
        'type': 'inline',
        'PRIVATE-required': null,
      }),
      throwsFormatException,
    );
  });
  test(
    'HostedEnvironmentFileParam: unknown privately owned received fallback',
    () {
      final value = AgentSessionHostedEnvironmentFileConfig.fromJson(const {
        'type': 'future',
        'opaque': 'PRIVATE',
      });
      expect(value.toJson(), {'type': 'future', 'opaque': 'PRIVATE'});
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(value.validate, throwsFormatException);
    },
  );
  test('ListOrderParam: asc', () {
    final v = AgentListOrder.fromJson('asc');
    expect(v.toJson(), 'asc');
  });
  test('ListOrderParam: desc', () {
    final v = AgentListOrder.fromJson('desc');
    expect(v.toJson(), 'desc');
  });
}
