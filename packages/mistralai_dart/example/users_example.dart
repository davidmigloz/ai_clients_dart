// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Users API (Beta).
///
/// This example shows how to:
/// - Retrieve the identity of the currently authenticated user
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  final client = MistralClient.fromEnvironment();

  try {
    await currentUserExample(client);
  } finally {
    client.close();
  }
}

/// Demonstrates retrieving the current user's identity.
Future<void> currentUserExample(MistralClient client) async {
  print('=== Current User Example ===\n');

  final identity = await client.users.me();

  print('Signed in as: ${identity.email ?? identity.id}');
  print('  ID: ${identity.id}');
  print('  Name: ${identity.firstName} ${identity.lastName}');
  if (identity.organization != null) {
    print('  Organization: ${identity.organization!.name}');
  }
  if (identity.workspace != null) {
    print('  Workspace: ${identity.workspace!.name}');
  }
  if (identity.apiKey != null) {
    print('  API key: ${identity.apiKey!.name}');
  }
}
