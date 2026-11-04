@TestOn('vm')
library;

import 'dart:io';
import 'dart:isolate';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart_admin.dart';
import 'package:test/test.dart';

void main() {
  test(
    'environment construction never falls back to a project API key',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'admin-env-fixture-',
      );
      try {
        final script = File('${directory.path}/check.dart');
        await script.writeAsString("""
import 'dart:io';
import 'package:openai_dart/openai_dart_admin.dart';
void main() {
  try { OpenAIAdminConfig.fromEnvironment(); stdout.write('unexpected'); }
  on StateError { stdout.write('missing-admin'); }
}
""");
        final config = await Isolate.packageConfig;
        final result = await Process.run(
          Platform.resolvedExecutable,
          ['--packages=$config', script.path],
          environment: {
            'OPENAI_API_KEY': 'synthetic_project_only',
            'OPENAI_ADMIN_KEY': '',
          },
          includeParentEnvironment: false,
        );
        expect(result.exitCode, 0);
        expect(result.stdout, 'missing-admin');
      } finally {
        await directory.delete(recursive: true);
      }
    },
  );

  test('real local redirect never forwards an Admin credential', () async {
    final origin = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final target = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var originCalls = 0;
    var targetCalls = 0;
    final originSub = origin.listen((request) async {
      originCalls++;
      expect(
        request.headers.value('authorization'),
        'Bearer synthetic_admin_redirect',
      );
      request.response.statusCode = HttpStatus.temporaryRedirect;
      request.response.headers.set(
        'location',
        'http://127.0.0.1:${target.port}/private',
      );
      await request.response.close();
    });
    final targetSub = target.listen((request) async {
      targetCalls++;
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
    });
    final transport = http.Client();
    final client = OpenAIAdminClient(
      config: OpenAIAdminConfig(
        authProvider: const ApiKeyProvider('synthetic_admin_redirect'),
        baseUrl: 'http://127.0.0.1:${origin.port}/v1',
        retryPolicy: const RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    try {
      await expectLater(
        client.organization.externalKeys.list(),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 307)),
      );
      expect(originCalls, 1);
      expect(targetCalls, 0);
    } finally {
      client.close();
      transport.close();
      await originSub.cancel();
      await targetSub.cancel();
      await origin.close(force: true);
      await target.close(force: true);
    }
  });
}
