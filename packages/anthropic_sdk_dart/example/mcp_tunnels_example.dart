// ignore_for_file: avoid_print

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Creates and archives a test tunnel in a workspace with preview access.
///
/// Set ANTHROPIC_TUNNEL_WIF_TOKEN. ANTHROPIC_WORKSPACE_ID may select the same
/// workspace as the token. Optionally pass a CA certificate path in PEM format.
Future<void> main(List<String> arguments) async {
  final token = Platform.environment['ANTHROPIC_TUNNEL_WIF_TOKEN'];
  final workspace = Platform.environment['ANTHROPIC_WORKSPACE_ID'];
  if (token == null || token.isEmpty) {
    throw StateError('Set ANTHROPIC_TUNNEL_WIF_TOKEN.');
  }

  final client = AnthropicClient(
    config: AnthropicConfig(workspaceId: workspace),
  );
  try {
    final tunnels = client.tunnels.withToken(token);
    final tunnel = await tunnels.create(displayName: 'Dart tunnel example');
    try {
      final credential = await tunnels.revealToken(tunnel.id);
      print('Tunnel: ${tunnel.id}, proxy token ID: ${credential.id}');
      if (arguments.isNotEmpty) {
        final certificates = tunnels.certificates(tunnel.id);
        final certificate = await certificates.create(
          caCertificatePem: await File(arguments.single).readAsString(),
        );
        print('Certificate fingerprint: ${certificate.fingerprint}');
        await certificates.archive(certificate.id);
      }
    } finally {
      await tunnels.archive(tunnel.id);
    }
  } finally {
    client.close();
  }
}
