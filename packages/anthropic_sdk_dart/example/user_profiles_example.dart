// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// User Profiles example (Beta).
///
/// User profiles let a platform register end-users with Anthropic, track
/// per-user trust-grant status for feature areas that require enrollment
/// (e.g., `cyber`), and generate short-lived enrollment URLs to send to
/// the end user.
///
/// Requires the `user-profiles-2026-03-24` beta header, which the
/// [UserProfilesResource] sets automatically.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // 1. Create a user profile.
    print('=== Create ===');
    final profile = await client.userProfiles.create(
      const CreateUserProfileRequest(
        externalId: 'user_12345',
        metadata: {'tier': 'pro', 'region': 'eu'},
      ),
    );
    print('Created ${profile.id} (external_id: ${profile.externalId})');

    // 2. Send a message scoped to this user.
    print('\n=== Send message with user_profile_id ===');
    final reply = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-opus-4-7',
        maxTokens: 256,
        userProfileId: profile.id,
        messages: [InputMessage.user('Hello!')],
      ),
    );
    print('Model replied: ${reply.content.first.runtimeType}');

    // 3. List user profiles (paginated).
    print('\n=== List ===');
    final page = await client.userProfiles.list(
      limit: 10,
      order: UserProfileListOrder.desc,
    );
    print('Returned ${page.data.length} profile(s); nextPage=${page.nextPage}');

    // 4. Retrieve the profile and inspect trust grants.
    print('\n=== Retrieve ===');
    final fetched = await client.userProfiles.retrieve(profile.id);
    for (final entry in fetched.trustGrants.entries) {
      print('  ${entry.key} → ${entry.value.status.toJson()}');
    }
    if (fetched.trustGrants.isEmpty) {
      print('  (no trust grants)');
    }

    // 5. Update metadata. Empty-string values remove a key server-side.
    print('\n=== Update ===');
    final updated = await client.userProfiles.update(
      profile.id,
      const UpdateUserProfileRequest(
        metadata: {'tier': 'enterprise', 'region': ''},
      ),
    );
    print('Updated metadata: ${updated.metadata}');

    // 6. Generate an enrollment URL to send to the end user.
    print('\n=== Enrollment URL ===');
    final enrollment = await client.userProfiles.createEnrollmentUrl(
      profile.id,
    );
    print('Enrollment URL expires at ${enrollment.expiresAt}:');
    print('  ${enrollment.url}');
  } finally {
    client.close();
  }
}
