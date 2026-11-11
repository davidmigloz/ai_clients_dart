// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Set ANTHROPIC_API_KEY to a key for the organization that owns the profiles.
/// Pass an existing uprof_ ID to inspect it, or omit the argument to list
/// restricted and banned profiles.
Future<void> main(List<String> args) async {
  final client = AnthropicClient.fromEnvironment();
  final profiles = client.userProfiles.current;

  try {
    if (args.isNotEmpty) {
      final profile = await profiles.retrieve(args.first);
      print('${profile.id}: ${profile.enforcementStatusValue ?? 'unreported'}');
      return;
    }

    String? cursor;
    do {
      final page = await profiles.list(
        page: cursor,
        enforcementStatuses: const [
          UserProfileEnforcementStatus.restricted,
          UserProfileEnforcementStatus.banned,
        ],
      );
      for (final profile in page.data) {
        print(
          '${profile.id}: ${profile.enforcementStatusValue ?? 'unreported'}',
        );
      }
      cursor = page.nextPage;
    } while (cursor != null);
  } finally {
    client.close();
  }
}
