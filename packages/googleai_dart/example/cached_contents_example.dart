// ignore_for_file: avoid_print
/// Demonstrates cached contents (context caching) API.
/// See also: caching_example.dart for the primary caching example.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  String? cachedContentName;

  try {
    print('💾 Cached Contents Example\n');
    print('Context caching saves frequently used content for reuse,');
    print('reducing latency and costs.\n');

    // 1. Create cached content
    print('1️⃣  Creating cached content...\n');

    final cached = await client.cachedContents.create(
      cachedContent: const CachedContent(
        model: 'models/gemini-3-flash-preview',
        displayName: 'Math Expert Cache',
        systemInstruction: Content(
          parts: [TextPart('You are an expert mathematician.')],
        ),
        ttl: '3600s', // Cache for 1 hour
      ),
    );
    cachedContentName = cached.name;

    print('✅ Cached content created!');
    print('   Name: ${cached.name}');
    print('   Display Name: ${cached.displayName}');
    print('   Model: ${cached.model}');
    print('   TTL: ${cached.ttl}');
    print('   Expire Time: ${cached.expireTime}');
    print('   Usage: ${cached.usageMetadata}');

    // 2. List cached contents
    print('\n2️⃣  Listing cached contents...\n');

    final listResponse = await client.cachedContents.list(pageSize: 10);

    print('📋 Found ${listResponse.cachedContents.length} cached contents:');
    for (final c in listResponse.cachedContents) {
      print('   - ${c.displayName ?? c.name}');
      print('     Expires: ${c.expireTime}');
    }

    // 3. Get cached content details
    print('\n3️⃣  Getting cached content details...\n');

    if (cachedContentName != null) {
      final retrieved = await client.cachedContents.get(
        name: cachedContentName,
      );

      print('📄 Cached Content Details:');
      print('   Name: ${retrieved.name}');
      print('   Display Name: ${retrieved.displayName}');
      print('   Created: ${retrieved.createTime}');
      print('   Updated: ${retrieved.updateTime}');
      print('   Expires: ${retrieved.expireTime}');

      // 4. Update TTL
      print('\n4️⃣  Updating cache TTL...\n');

      final updated = await client.cachedContents.update(
        name: cachedContentName,
        cachedContent: const CachedContent(
          model: 'models/gemini-3-flash-preview',
          ttl: '7200s', // Extend to 2 hours
        ),
        updateMask: 'ttl',
      );

      print('✅ Cache TTL updated!');
      print('   New Expire Time: ${updated.expireTime}');
    }

    // 5. Use cached content in generation
    print('\n5️⃣  Using cached content...\n');

    print('   Use cached content in requests to save tokens:');
    print('   ```dart');
    print('   final response = await client.models.generateContent(');
    print('     model: "gemini-3-flash-preview",');
    print('     request: GenerateContentRequest(');
    print('       cachedContent: "$cachedContentName",');
    print(
      '       contents: [Content.text("Explain the Pythagorean theorem")],',
    );
    print('     ),');
    print('   );');
    print('   ```');

    // 6. Delete cached content
    print('\n6️⃣  Deleting cached content...\n');

    if (cachedContentName != null) {
      await client.cachedContents.delete(name: cachedContentName);
      cachedContentName = null;
      print('✅ Cached content deleted!');
    }

    print('\n📝 Notes:');
    print('   - Caching reduces latency for repeated contexts');
    print('   - Saves costs by reusing cached tokens');
    print('   - TTL controls how long cache is valid');
    print('   - Use updateMask to update specific fields');
    print('   - See caching_example.dart for more examples');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Cleanup
    if (cachedContentName != null) {
      try {
        await client.cachedContents.delete(name: cachedContentName);
        print('\n🧹 Cleaned up cached content');
      } catch (e) {
        // Already deleted
      }
    }
    client.close();
  }
}
