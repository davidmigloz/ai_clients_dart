@Tags(['integration'])
library;

import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

/// Integration tests for the Health API.
///
/// These tests require a running ChromaDB server.
/// Run with: dart test --tags=integration
void main() {
  late ChromaClient client;

  setUpAll(() {
    client = ChromaClient.local();
  });

  tearDownAll(() {
    client.close();
  });

  group('HealthResource', () {
    test('heartbeat returns server nanosecond timestamp', () async {
      final response = await client.health.heartbeat();

      expect(response.nanosecondHeartbeat, isNotNull);
      expect(response.nanosecondHeartbeat, greaterThan(0));
    });

    test('version returns server version', () async {
      final response = await client.health.version();

      expect(response.version, isNotNull);
      expect(response.version, isNotEmpty);
    });

    test('preFlightChecks returns server capabilities', () async {
      final response = await client.health.preFlightChecks();

      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
    });

    test('healthcheck returns server health info', () async {
      final response = await client.health.healthcheck();

      expect(response, isNotNull);
      expect(response, isA<Map<String, dynamic>>());
    });
  });
}
