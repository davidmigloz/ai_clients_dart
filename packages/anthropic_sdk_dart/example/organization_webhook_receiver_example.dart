import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Verifies Claude webhook deliveries on a local development listener.
///
/// Set ANTHROPIC_WEBHOOK_KEY to your endpoint's signing secret. For a deployed
/// receiver, persist processed event IDs to deduplicate deliveries across restarts.
Future<void> main() async {
  final secret = Platform.environment['ANTHROPIC_WEBHOOK_KEY'];
  if (secret == null || secret.isEmpty) {
    stderr.writeln('Set ANTHROPIC_WEBHOOK_KEY.');
    exitCode = 64;
    return;
  }

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  stdout.writeln('Listening on http://localhost:8080');
  await for (final request in server) {
    if (request.method != 'POST') {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      await request.response.close();
      continue;
    }
    try {
      final rawBody = await utf8.decoder.bind(request).join();
      final headers = <String, String>{};
      request.headers.forEach((name, values) {
        headers[name] = values.join(' ');
      });
      final event = WebhookEvent.unwrap(
        rawBody,
        headers: headers,
        signingSecret: secret,
      );
      stdout.writeln('Received ${event.id}');
      request.response.statusCode = HttpStatus.noContent;
    } on FormatException {
      request.response.statusCode = HttpStatus.badRequest;
    }
    await request.response.close();
  }
}
