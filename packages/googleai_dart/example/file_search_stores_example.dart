// ignore_for_file: avoid_print
/// Demonstrates FileSearchStores for semantic retrieval (RAG).
/// See also: file_search_example.dart for the primary example.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  String? storeName;

  try {
    print('🔍 FileSearchStores Example\n');
    print('FileSearchStores enable semantic retrieval over your documents.\n');

    // 1. Create a FileSearchStore
    print('1️⃣  Creating FileSearchStore...\n');

    final store = await client.fileSearchStores.create(
      displayName: 'My Knowledge Base',
    );
    storeName = store.name;

    print('✅ FileSearchStore created!');
    print('   Name: ${store.name}');
    print('   Display Name: ${store.displayName}');
    print('   Created: ${store.createTime}');

    // 2. List FileSearchStores
    print('\n2️⃣  Listing FileSearchStores...\n');

    final listResponse = await client.fileSearchStores.list(pageSize: 10);
    final stores = listResponse.fileSearchStores ?? [];

    print('📋 Found ${stores.length} stores:');
    for (final s in stores) {
      print('   - ${s.displayName ?? s.name}');
    }

    // 3. Get FileSearchStore details
    print('\n3️⃣  Getting store details...\n');

    if (storeName != null) {
      final retrieved = await client.fileSearchStores.get(name: storeName);

      print('📄 Store Details:');
      print('   Name: ${retrieved.name}');
      print('   Display Name: ${retrieved.displayName}');
    }

    // 4. Upload document (example)
    print('\n4️⃣  Uploading document...\n');

    print('   To upload a document:');
    print('   ```dart');
    print('   final uploadResponse = await client.fileSearchStores.upload(');
    print('     parent: "$storeName",');
    print('     filePath: "/path/to/document.pdf",');
    print('     mimeType: "application/pdf",');
    print('     request: UploadToFileSearchStoreRequest(');
    print('       displayName: "My Document",');
    print('       chunkingConfig: ChunkingConfig(');
    print('         whiteSpaceConfig: WhiteSpaceConfig(');
    print('           maxTokensPerChunk: 200,');
    print('           maxOverlapTokens: 20,');
    print('         ),');
    print('       ),');
    print('     ),');
    print('   );');
    print('   ```');

    // 5. Use in generation
    print('\n5️⃣  Using FileSearch in generation...\n');

    print('   Use FileSearch tool with your store:');
    print('   ```dart');
    print('   final response = await client.models.generateContent(');
    print('     model: "gemini-3.1-flash-preview",');
    print('     request: GenerateContentRequest(');
    print('       contents: [Content.text("What does the doc say?")],');
    print('       tools: [');
    print('         Tool(');
    print('           fileSearch: FileSearch(');
    print('             fileSearchStoreNames: ["$storeName"],');
    print('             topK: 5,');
    print('           ),');
    print('         ),');
    print('       ],');
    print('     ),');
    print('   );');
    print('   ```');

    // 6. Delete FileSearchStore
    print('\n6️⃣  Deleting FileSearchStore...\n');

    if (storeName != null) {
      await client.fileSearchStores.delete(name: storeName);
      storeName = null;
      print('✅ FileSearchStore deleted!');
    }

    print('\n📝 Notes:');
    print('   - FileSearchStores provide semantic retrieval (RAG)');
    print('   - Upload documents with customizable chunking');
    print('   - Use with FileSearch tool in generation requests');
    print('   - Support metadata filters for targeted search');
    print('   - See file_search_example.dart for complete example');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Cleanup
    if (storeName != null) {
      try {
        await client.fileSearchStores.delete(name: storeName);
        print('\n🧹 Cleaned up store');
      } catch (e) {
        // Already deleted
      }
    }
    client.close();
  }
}
