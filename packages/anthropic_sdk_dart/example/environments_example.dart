// ignore_for_file: avoid_print

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Creates, updates and archives a Claude Managed Agents cloud environment.
///
/// Uses ANTHROPIC_API_KEY and the workspace that owns the key.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final environments = client.environments;
    final environment = await environments.create(
      const CreateEnvironmentParams(
        name: 'Restricted environment example',
        config: CloudEnvironmentConfigParams(
          networking: LimitedEnvironmentNetworkParams(
            allowedHosts: ['example.com'],
          ),
        ),
      ),
    );
    try {
      final updated = await environments.update(
        environment.id,
        const UpdateEnvironmentParams(
          description: 'A cloud environment with a limited network policy',
        ),
      );
      print('Environment: ${updated.id}');
    } finally {
      await environments.archive(environment.id);
    }
  } finally {
    client.close();
  }
}
