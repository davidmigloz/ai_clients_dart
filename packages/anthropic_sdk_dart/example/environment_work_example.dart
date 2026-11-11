// ignore_for_file: avoid_print

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Polls once and demonstrates the lease lifecycle in a test environment.
///
/// Set ANTHROPIC_ENVIRONMENT_ID and ANTHROPIC_ENVIRONMENT_KEY for a dedicated
/// self-hosted test environment. This sample claims and stops the work item
/// it receives if it acquires the lease. A production worker runs the assigned session between those
/// operations.
Future<void> main() async {
  final id = Platform.environment['ANTHROPIC_ENVIRONMENT_ID'];
  final key = Platform.environment['ANTHROPIC_ENVIRONMENT_KEY'];
  if (id == null || key == null) {
    throw StateError(
      'Set ANTHROPIC_ENVIRONMENT_ID and ANTHROPIC_ENVIRONMENT_KEY',
    );
  }

  final client = AnthropicClient();
  try {
    final queue = client.environments.work(id, bearerToken: key);
    final item = await queue.poll(
      blockMs: 100,
      workerId: 'dart-example-worker',
    );
    if (item == null) {
      print('No work available.');
      return;
    }
    final worker = client.environments.work(
      id,
      bearerToken: item.credentials?.sessionsToken ?? key,
    );
    var ownsLease = false;
    try {
      await worker.ack(item.id);
      final lease = await worker.heartbeat(
        item.id,
        expectedLastHeartbeat: EnvironmentWorkResource.noHeartbeat,
      );
      ownsLease = lease.leaseExtended;
      print('Work item ${item.id}, lease extended: $ownsLease');
    } on EnvironmentHeartbeatConflictException {
      print('Another worker may hold the lease for ${item.id}.');
    } finally {
      if (ownsLease) await worker.stop(item.id);
    }
  } finally {
    client.close();
  }
}
