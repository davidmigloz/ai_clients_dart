@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  test(
    'actual socket failure does not replay upload and preserves private caller context',
    () async {
      const original = SocketException('PRIVATE socket failure');
      final transport = _SocketFailureTransport(original);
      final hierarchy = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      final oldRootLevel = Logger.root.level;
      final oldClientLevel = Logger('OpenAIClient').level;
      Logger.root.level = Level.ALL;
      final records = <LogRecord>[];
      final subscription = Logger.root.onRecord.listen(records.add);
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/PRIVATE-proxy/v1',
          authProvider: ApiKeyProvider('PRIVATE-credential'),
          defaultHeaders: {'x-private-header': 'PRIVATE-header'},
          retryPolicy: RetryPolicy(
            maxRetries: 3,
            initialDelay: Duration(milliseconds: 1),
            maxDelay: Duration(milliseconds: 5),
            jitter: 0,
          ),
          logLevel: Level.FINEST,
        ),
        httpClient: transport,
      );
      try {
        final request = CustomVoiceCreateRequest(
          name: 'PRIVATE name',
          audioSample: Uint8List.fromList(utf8.encode('PRIVATE sample')),
          filename: 'PRIVATE-sample.wav',
          consent: 'PRIVATE consent',
          audioSampleContentType: 'audio/wav',
        );
        try {
          await client.audio.voices.create(request);
          fail('Expected typed connection failure');
        } on ConnectionException catch (error) {
          expect(error.cause, same(original));
          expect(
            error.url,
            'https://fixture.invalid/PRIVATE-proxy/v1/audio/voices',
          );
          expect(error.toString(), isNot(contains('PRIVATE')));
        }
        expect(transport.sends, 1);
        expect(transport.request!.method, 'POST');
        expect(transport.body, isNotEmpty);
        expect(transport.closes, 0);
        expect(
          records
              .map(
                (record) =>
                    '${record.message} ${record.error} ${record.stackTrace}',
              )
              .join('\n'),
          isNot(contains('PRIVATE')),
        );
      } finally {
        client.close();
        await subscription.cancel();
        Logger.root.level = oldRootLevel;
        Logger('OpenAIClient').level = oldClientLevel;
        hierarchicalLoggingEnabled = hierarchy;
      }
      expect(transport.closes, 0);
    },
  );
}

class _SocketFailureTransport extends http.BaseClient {
  _SocketFailureTransport(this.failure);
  final SocketException failure;
  http.BaseRequest? request;
  List<int>? body;
  int sends = 0;
  int closes = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest value) async {
    sends++;
    request = value;
    body = await value.finalize().toBytes();
    throw failure;
  }

  @override
  void close() => closes++;
}
