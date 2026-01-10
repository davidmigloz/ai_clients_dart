// ignore_for_file: avoid_print
/// Health and status check example.
///
/// Demonstrates how to check server health, version,
/// and perform diagnostic operations.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // --- Heartbeat ---
    // Quick check that the server is responding
    print('=== Heartbeat ===\n');
    final heartbeat = await client.health.heartbeat();
    print('Server heartbeat: ${heartbeat.nanosecondHeartbeat} ns');

    // --- Version ---
    // Get the ChromaDB server version
    print('\n=== Version ===\n');
    final version = await client.health.version();
    print('ChromaDB version: ${version.version}');

    // --- Health Check ---
    // Full health check of the server
    print('\n=== Health Check ===\n');
    final health = await client.health.healthcheck();
    print('Health status: $health');

    // --- Pre-flight Checks ---
    // Verify server configuration and readiness
    print('\n=== Pre-flight Checks ===\n');
    final preflight = await client.health.preFlightChecks();
    print('Pre-flight checks: $preflight');

    // --- Reset (Development Only) ---
    // Reset the database - WARNING: this deletes all data!
    // Only works if the server is configured to allow resets
    print('\n=== Reset (if enabled) ===\n');
    try {
      final reset = await client.health.reset();
      print('Reset result: $reset');
    } on ChromaException catch (e) {
      print('Reset not available: ${e.message}');
    }

    print('\nAll health checks completed successfully!');
  } on TimeoutException catch (e) {
    print('Server not responding: ${e.message}');
  } on ChromaException catch (e) {
    print('Error: ${e.message}');
  } finally {
    client.close();
  }
}
