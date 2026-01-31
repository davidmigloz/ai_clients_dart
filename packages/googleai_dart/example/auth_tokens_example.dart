// ignore_for_file: avoid_print
/// Demonstrates ephemeral token creation for client-side authentication.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  // Server-side: Create ephemeral tokens using your API key
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  try {
    print('🔐 Ephemeral Token Example\n');
    print('Ephemeral tokens allow secure, short-lived authentication');
    print('for client-side applications without exposing your API key.\n');

    // Create an ephemeral token
    print('1️⃣  Creating ephemeral token...\n');

    final token = await client.authTokens.create(
      authToken: AuthToken(
        // Token expiration time (when messages using this token expire)
        expireTime: DateTime.now().add(const Duration(minutes: 30)),
        // Window to start new sessions with this token
        newSessionExpireTime: DateTime.now().add(const Duration(seconds: 60)),
        // Number of times the token can be used (null = unlimited)
        uses: 1,
      ),
    );

    print('✅ Token created successfully!');
    print('   Token: ${token.name}');
    print('   Expires: ${token.expireTime}');
    print('   New session expire time: ${token.newSessionExpireTime}');
    print('   Uses: ${token.uses}');

    // Example: Create token with pre-configured setup
    print('\n2️⃣  Creating token with pre-configured setup...\n');

    print('   You can also include a BidiGenerateContentSetup:');
    print('   ```dart');
    print('   final tokenWithSetup = await client.authTokens.create(');
    print('     authToken: AuthToken(');
    print('       expireTime: DateTime.now().add(Duration(minutes: 15)),');
    print('       uses: 1,');
    print('       bidiGenerateContentSetup: BidiGenerateContentSetup(');
    print('         model: "models/gemini-2.0-flash-live-001",');
    print('       ),');
    print('     ),');
    print('   );');
    print('   ```');

    // Client-side usage example (code demonstration)
    print('\n💡 Client-side Usage:');
    print('   ```dart');
    print('   // On mobile/web client - no API key needed!');
    print('   final liveClient = LiveClient(');
    print('     config: GoogleAIConfig.googleAI(');
    print('       authProvider: NoAuthProvider(),');
    print('     ),');
    print('   );');
    print('');
    print('   final session = await liveClient.connect(');
    print('     model: "gemini-2.0-flash-live-001",');
    print('     accessToken: "${token.name}", // Token from server');
    print('   );');
    print('   ```');

    print('\n📝 Notes:');
    print(
      '   - Ephemeral tokens are only available with Google AI (not Vertex AI)',
    );
    print('   - Currently only compatible with the Live API');
    print('   - Create tokens server-side and pass to client applications');
    print('   - Use short expiration times for security');
    print('   - Set uses: 1 for single-use tokens');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
