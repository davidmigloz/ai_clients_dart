import 'dart:convert';
import 'dart:io';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

import '../../resources/webhook_verifier_vectors.dart';

/// Child-process probe. Its parent supplies an isolated synthetic environment.
/// No inherited credentials are read and no network request is allowed.
void main(List<String> arguments) {
  final mode = arguments.single;
  final vector = verifierVectors['dotsId']!;
  final headers = <String, String>{
    'webhook-id': vector['id']! as String,
    'webhook-timestamp': vector['timestamp']! as String,
    'webhook-signature': 'v1,${vector['signature']}',
  };
  const tolerance = Duration(days: 36500);
  final report = <String, Object?>{'constructed': false, 'httpRequests': 0};
  OpenAIClient? client;
  var httpRequests = 0;
  final transport = MockClient((request) {
    httpRequests++;
    throw StateError('Unexpected HTTP request in environment fixture.');
  });
  try {
    if (mode == 'standalone') {
      final verifier = WebhookVerifier.fromEnvironment();
      report['constructed'] = true;
      verifier.verifySignature(
        vector['body']! as String,
        headers,
        tolerance: tolerance,
      );
    } else {
      final OpenAIConfig config;
      if (mode == 'config') {
        config = OpenAIConfig.fromEnvironment();
      } else if (mode == 'client') {
        client = OpenAIClient.fromEnvironment(httpClient: transport);
        config = client.config;
      } else {
        throw ArgumentError('Unknown environment fixture mode.');
      }
      report['constructed'] = true;
      report['webhookSecretAbsent'] = config.webhookSecret == null;
      report['webhookSecretMatches'] = config.webhookSecret == 'whsec_eA==';
      report['apiKeyMatches'] =
          config.authProvider!.getHeaders()['Authorization'] ==
          'Bearer sk-synthetic-environment';
      if (client != null) {
        client.close();
        // First resource access after close remains local.
        client.webhooks.verifySignature(
          vector['body']! as String,
          headers,
          tolerance: tolerance,
        );
      } else {
        WebhookVerifier(secret: config.webhookSecret).verifySignature(
          vector['body']! as String,
          headers,
          tolerance: tolerance,
        );
      }
    }
    report['verified'] = true;
  } on StateError catch (error) {
    report['error'] = 'StateError';
    report['diagnostic'] = error.toString();
  } on ArgumentError catch (error) {
    report['error'] = 'ArgumentError';
    report['invalidValueAbsent'] = error.invalidValue == null;
    report['diagnostic'] = error.toString();
  } finally {
    client?.close();
    transport.close();
  }
  report['httpRequests'] = httpRequests;
  stdout.writeln(jsonEncode(report));
}
