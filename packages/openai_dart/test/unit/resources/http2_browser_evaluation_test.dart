// ignore_for_file: experimental_member_use

@TestOn('browser && js')
library;

import 'package:http/http.dart' as http;
import 'package:http2/client.dart';
import 'package:test/test.dart';

void main() {
  test(
    'HTTP2 candidate compiles but IO dial is unsupported in browsers',
    () async {
      final candidate = Http2Client();
      try {
        await expectLater(
          candidate
              .send(http.Request('GET', Uri.parse('https://127.0.0.1/fixture')))
              .timeout(const Duration(seconds: 1)),
          throwsA(
            isA<http.ClientException>().having(
              (error) => error.message,
              'message',
              contains('Unsupported operation'),
            ),
          ),
        );
      } finally {
        candidate.close();
      }
    },
  );
}
