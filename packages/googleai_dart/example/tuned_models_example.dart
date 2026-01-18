// ignore_for_file: avoid_print
/// Demonstrates tuned models management.
/// See also: tuned_model_generation_example.dart for generation examples.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  try {
    print('🎯 Tuned Models Example\n');
    print('Tuned models are custom models trained on your data.\n');

    // 1. List tuned models
    print('1️⃣  Listing tuned models...\n');

    final listResponse = await client.tunedModels.list(pageSize: 10);

    if (listResponse.tunedModels.isEmpty) {
      print('   No tuned models found.');
      print('\n   Tuned models are created via the API or AI Studio.');
      print('   See: https://ai.google.dev/tutorials/tuning_quickstart');
    } else {
      print('📋 Found ${listResponse.tunedModels.length} tuned models:\n');

      for (final model in listResponse.tunedModels) {
        print('   🎯 ${model.displayName ?? model.name}');
        print('      Name: ${model.name}');
        print('      State: ${model.state}');
        print('      Base Model: ${model.baseModel}');
        print('');
      }

      // 2. Get tuned model details
      final firstModel = listResponse.tunedModels.first;

      if (firstModel.name != null) {
        print('2️⃣  Getting tuned model details...\n');

        final model = await client.tunedModels.get(name: firstModel.name!);

        print('📄 Model Details:');
        print('   Name: ${model.name}');
        print('   Display Name: ${model.displayName}');
        print('   State: ${model.state}');
        print('   Base Model: ${model.baseModel}');
        print('   Created: ${model.createTime}');
        print('   Updated: ${model.updateTime}');

        if (model.tuningTask != null) {
          print('   Tuning Task:');
          print('      Start Time: ${model.tuningTask!.startTime}');
          print('      Complete Time: ${model.tuningTask!.completeTime}');
        }

        // 3. List operations for tuning progress
        print('\n3️⃣  Listing operations...\n');

        final opsResponse =
            await client.tunedModels.operations(tunedModel: firstModel.name!).list();

        if (opsResponse.operations.isEmpty) {
          print('   No operations found for this model.');
        } else {
          print('   Operations:');
          for (final op in opsResponse.operations) {
            print('      - ${op.name}');
            print('        Done: ${op.done}');
          }
        }
      }
    }

    // 4. Generate with tuned model
    print('\n4️⃣  Generating with tuned model...\n');

    print('   To use a tuned model for generation:');
    print('   ```dart');
    print('   final response = await client.tunedModels.generateContent(');
    print('     tunedModel: "my-model-abc123",');
    print('     request: GenerateContentRequest(');
    print('       contents: [Content.text("Your prompt here")],');
    print('     ),');
    print('   );');
    print('   print(response.text);');
    print('   ```');

    // 5. Stream with tuned model
    print('\n5️⃣  Streaming with tuned model...\n');

    print('   To stream responses:');
    print('   ```dart');
    print('   await for (final chunk in client.tunedModels.streamGenerateContent(');
    print('     tunedModel: "my-model-abc123",');
    print('     request: request,');
    print('   )) {');
    print('     print(chunk.text);');
    print('   }');
    print('   ```');

    print('\n📝 Notes:');
    print('   - Tuned models are created via training on your data');
    print('   - Check model.state for training status');
    print('   - Use operations to monitor training progress');
    print('   - Permissions control access to tuned models');
    print('   - See tuned_model_generation_example.dart for generation examples');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
