// ignore_for_file: avoid_print
/// An offline signed receiver using only loopback HTTP and a synthetic secret.
/// Run: dart run example/webhooks_example.dart
library;

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // A deployed receiver can use WebhookVerifier.fromEnvironment(); it reads
  // OPENAI_WEBHOOK_SECRET without requiring OPENAI_API_KEY.
  const demoSecret = 'synthetic-example-signing-key';
  const verifier = WebhookVerifier(secret: demoSecret);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final sender = HttpClient();
  final handled =
      <String>{}; // Application-owned, in-memory demo deduplication.
  var actions = 0;

  final serving = () async {
    await for (final request in server.take(3)) {
      // Preserve original bytes: never jsonDecode/re-encode before verification.
      final bytes = await request.fold<List<int>>([], (body, part) {
        body.addAll(part);
        return body;
      });
      final headers = <String, String>{};
      var ambiguous = false;
      request.headers.forEach((name, values) {
        if (const {
              'webhook-id',
              'webhook-timestamp',
              'webhook-signature',
            }.contains(name) &&
            values.length != 1) {
          ambiguous = true;
        }
        headers[name] = values.join(',');
      });
      if (ambiguous) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        continue;
      }
      try {
        final event = verifier.unwrapBytes(bytes, headers);
        final firstDelivery = handled.add(headers['webhook-id']!);
        // Production applications persist/queue work before acknowledging. The
        // verifier itself performs no lookup, API call or workflow action.
        request.response.statusCode = HttpStatus.ok;
        await request.response.close();
        if (firstDelivery) {
          if (event case ResponseCompletedWebhookEvent()) {
            actions++;
            // This branch represents work owned by the application. Fetching a
            // response, running tools or investigating an alert is explicit.
            print('Acknowledged ${event.type}; application handled it once.');
          }
        }
      } on InvalidWebhookSignatureException {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        print('Rejected tampered delivery before JSON parsing.');
      } on FormatException {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        print('Rejected authenticated malformed event.');
      }
    }
  }();

  try {
    final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
        .toString();
    final body = utf8.encode(
      jsonEncode({
        'id': 'evt_local_demo',
        'object': 'event',
        'created_at': int.parse(timestamp),
        'type': 'response.completed',
        'data': {'id': 'resp_local_demo'},
      }),
    );
    // Only the synthetic sender signs. A real receiver never creates signatures.
    final signed = base64.encode(
      Hmac(
        sha256,
        utf8.encode(demoSecret),
      ).convert([...utf8.encode('delivery.$timestamp.'), ...body]).bytes,
    );
    final uri = Uri.parse('http://127.0.0.1:${server.port}/webhook');
    for (final payload in [body, body, utf8.encode('tampered non-JSON')]) {
      final request = await sender.postUrl(uri);
      request.headers
        ..set('webhook-id', 'delivery')
        ..set('webhook-timestamp', timestamp)
        ..set('webhook-signature', 'v1,$signed');
      request.add(payload);
      final response = await request.close();
      print('Local delivery returned ${response.statusCode}.');
      await response.drain<void>();
    }
    await serving;
    if (actions != 1) throw StateError('Expected one application action.');
  } finally {
    sender.close(force: true);
    await server.close(force: true);
  }
}
