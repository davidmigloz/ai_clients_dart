// ignore_for_file: avoid_print
/// Demonstrates generated files management for video outputs.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  try {
    print('🎬 Generated Files Example\n');
    print('Generated files contain outputs from generation operations,');
    print('such as videos from Veo or other media generation models.\n');

    // Note: Generated files are created by long-running prediction operations
    // such as video generation with Veo models.

    print('1️⃣  Creating generated files...\n');

    print('   Generated files are created when using video generation:');
    print('   ```dart');
    print('   final operation = await client.models.predictLongRunning(');
    print('     model: "veo-3.1-lite-generate-preview",');
    print('     instances: [');
    print('       {"prompt": "A cat playing piano"},');
    print('     ],');
    print('   );');
    print('');
    print('   // Poll for completion');
    print('   while (operation.done != true) {');
    print('     await Future.delayed(Duration(seconds: 10));');
    print('     // Check operation status...');
    print('   }');
    print('');
    print('   // Access generated videos in the response');
    print('   final response = operation.response;');
    print('   ```');

    print('\n2️⃣  Accessing generated files...\n');

    print('   Generated files can be accessed from the operation response:');
    print('   ```dart');
    print('   if (operation.done == true && operation.response != null) {');
    print(
      '     final videoResponse = operation.response!.generateVideoResponse;',
    );
    print('     if (videoResponse?.generatedSamples != null) {');
    print('       for (final media in videoResponse!.generatedSamples!) {');
    print('         if (media.video?.uri != null) {');
    print(r'           print("Video URI: ${media.video!.uri}");');
    print('         }');
    print('       }');
    print('     }');
    print('   }');
    print('   ```');

    print('\n3️⃣  Checking for RAI filtering...\n');

    print('   Some generated content may be filtered:');
    print('   ```dart');
    print('   if (videoResponse?.raiMediaFilteredCount != null) {');
    print(
      r'     print("Filtered: ${videoResponse!.raiMediaFilteredCount} videos");',
    );
    print(r'     print("Reasons: ${videoResponse.raiMediaFilteredReasons}");');
    print('   }');
    print('   ```');

    print('\n📝 Notes:');
    print(
      '   - Generated files are created by video/media generation operations',
    );
    print('   - Files are available for download via their URI');
    print('   - Files have an expiration time and will be auto-deleted');
    print('   - Use long-running operations to track generation progress');
    print('   - See prediction_example.dart for video generation examples');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
