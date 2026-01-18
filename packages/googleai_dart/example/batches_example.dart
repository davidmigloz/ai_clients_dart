// ignore_for_file: avoid_print
/// Demonstrates batch operations API.
/// See also: batch_example.dart for the primary batch example.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  try {
    print('📦 Batches Resource Example\n');
    print('Batches allow processing multiple requests asynchronously.\n');

    // 1. List batches
    print('1️⃣  Listing batches...\n');

    final listResponse = await client.batches.list(pageSize: 10);
    final operations = listResponse.operations ?? [];

    if (operations.isEmpty) {
      print('   No batch operations found.');
      print('\n   To create a batch, use:');
      print('   ```dart');
      print('   final batch = await client.models.batchGenerateContent(');
      print('     model: "gemini-3-flash-preview",');
      print('     batch: GenerateContentBatch(');
      print('       displayName: "My Batch",');
      print('       inputConfig: InputConfig(');
      print('         requests: InlinedRequests(');
      print('           requests: [/* ... */],');
      print('         ),');
      print('       ),');
      print('     ),');
      print('   );');
      print('   ```');
    } else {
      print('   Found ${operations.length} batch operations:\n');

      for (final op in operations) {
        print('   📋 ${op.name}');
        print('      Done: ${op.done}');
        print('');
      }
    }

    // 2. Get batch details
    print('2️⃣  Getting batch details...\n');

    print('   To get details of a specific batch:');
    print('   ```dart');
    print('   final batch = await client.batches.getGenerateContentBatch(');
    print('     name: "batches/batch-id",');
    print('   );');
    print(r'   print("State: ${batch.state}");');
    print(r'   print("Progress: ${batch.stats}");');
    print('   ```');

    // 3. Cancel batch
    print('\n3️⃣  Canceling a batch...\n');

    print('   To cancel a running batch:');
    print('   ```dart');
    print('   await client.batches.cancel(name: "batches/batch-id");');
    print('   print("Batch canceled");');
    print('   ```');

    // 4. Delete batch
    print('\n4️⃣  Deleting a batch...\n');

    print('   To delete a completed batch:');
    print('   ```dart');
    print('   await client.batches.delete(name: "batches/batch-id");');
    print('   print("Batch deleted");');
    print('   ```');

    print('\n📝 Notes:');
    print('   - Batches process requests asynchronously');
    print('   - Use for large-scale processing jobs');
    print('   - Monitor operation.done for completion status');
    print('   - Results are available when batch completes');
    print('   - See batch_example.dart for complete batch creation example');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    client.close();
  }
}
