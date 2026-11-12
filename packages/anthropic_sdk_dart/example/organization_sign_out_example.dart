import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Signs out the specified Claude Enterprise member across their account.
///
/// Pass a member's user_ ID and set ANTHROPIC_ADMIN_KEY to an organization key
/// with write:members. This Enterprise beta ends active member sessions.
/// The member can sign back in afterward.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 1 || !arguments.single.startsWith('user_')) {
    throw ArgumentError('Usage: organization_sign_out_example.dart user-id');
  }
  final key = Platform.environment['ANTHROPIC_ADMIN_KEY'];
  if (key == null || key.isEmpty) {
    throw StateError('Set ANTHROPIC_ADMIN_KEY with write:members.');
  }
  final client = AnthropicClient.withApiKey(
    key,
    baseUrl: Platform.environment['ANTHROPIC_BASE_URL'],
  );
  try {
    final member = await client.organization.users.signOut(arguments.single);
    stdout.writeln('Signed out ${member.id}.');
  } on ApiException catch (error) {
    if (error.statusCode != 503) rethrow;
    stderr.writeln(
      'The server may have ended some sessions. Run the command again to finish.',
    );
    exitCode = 75;
  } finally {
    client.close();
  }
}
