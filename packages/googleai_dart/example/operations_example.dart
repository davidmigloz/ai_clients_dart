// ignore_for_file: avoid_print
/// Demonstrates long-running operations management.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  try {
    print('⚙️  Operations API Example\n');
    print('Operations track the progress of long-running tasks like:');
    print('- Model tuning');
    print('- Video generation');
    print('- Batch processing');
    print('- Async embedding jobs\n');

    // 1. List operations for tuned models
    print('1️⃣  Listing operations for tuned models...\n');

    // First, list tuned models to get a parent
    final tunedModels = await client.tunedModels.list(pageSize: 5);

    if (tunedModels.tunedModels.isEmpty) {
      print('   No tuned models found.');
      print('   Operations are created when tuning models or running batch jobs.');
    } else {
      final firstModel = tunedModels.tunedModels.first;
      print('   Found tuned model: ${firstModel.name}');

      if (firstModel.name != null) {
        final opsResponse = await client.tunedModels
            .operations(tunedModel: firstModel.name!)
            .list(pageSize: 10);

        if (opsResponse.operations.isEmpty) {
          print('   No operations found for this model.');
        } else {
          print('   Found ${opsResponse.operations.length} operations:\n');
          for (final op in opsResponse.operations) {
            print('   📋 ${op.name}');
            print('      Done: ${op.done}');
            if (op.metadata != null) {
              print('      Metadata: ${op.metadata}');
            }
            if (op.error != null) {
              print('      Error: ${op.error!.message}');
            }
            print('');
          }
        }
      }
    }

    // 2. Get specific operation status
    print('2️⃣  Getting operation status...\n');

    print('   To get status of a specific operation:');
    print('   ```dart');
    print('   final operation = await client.tunedModels');
    print('       .operations(tunedModel: "my-model-id")');
    print('       .get(name: "operations/abc123");');
    print('');
    print(r'   print("Done: ${operation.done}");');
    print('');
    print('   if (operation.done && operation.response != null) {');
    print(r'     print("Result: ${operation.response}");');
    print('   }');
    print('   ```');

    // 3. Polling for completion
    print('\n3️⃣  Polling for operation completion...\n');

    print('   Example: Poll until operation completes');
    print('   ```dart');
    print('   var operation = await client.tunedModels');
    print('       .operations(tunedModel: "my-model-id")');
    print('       .get(name: operationName);');
    print('');
    print('   while (operation.done != true) {');
    print('     await Future.delayed(Duration(seconds: 10));');
    print('     operation = await client.tunedModels');
    print('         .operations(tunedModel: "my-model-id")');
    print('         .get(name: operationName);');
    print(r'     print("Progress: ${operation.metadata}");');
    print('   }');
    print('');
    print('   if (operation.error != null) {');
    print(r'     print("Error: ${operation.error!.message}");');
    print('   } else {');
    print(r'     print("Success: ${operation.response}");');
    print('   }');
    print('   ```');

    // 4. Operations from other contexts
    print('\n4️⃣  Other operation contexts...\n');

    print('   Operations are available in various contexts:');
    print('');
    print('   // Tuned model operations');
    print('   client.tunedModels.operations(tunedModel: "my-model-id")');
    print('');
    print('   // File search store operations');
    print('   client.fileSearchStores.getOperation(name: "operations/...")');
    print('');
    print('   // Batch operations');
    print('   client.batches.getGenerateContentBatch(name: "batches/...")');

    print('\n📝 Notes:');
    print('   - Operations track long-running asynchronous tasks');
    print('   - Check operation.done to see if completed');
    print('   - operation.response contains the result on success');
    print('   - operation.error contains error details on failure');
    print('   - operation.metadata contains progress information');
    print('   - Use polling with reasonable intervals to check status');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
