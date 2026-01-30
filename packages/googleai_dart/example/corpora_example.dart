// ignore_for_file: avoid_print
/// Demonstrates corpus management for semantic retrieval.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  // Note: Corpora API is only available with Google AI (not Vertex AI)
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  String? createdCorpusName;

  try {
    print('📚 Corpora API Example\n');
    print('Corpora are collections of documents for semantic retrieval.\n');

    // 1. Create a corpus
    print('1️⃣  Creating corpus...\n');

    final corpus = await client.corpora.create(
      corpus: const Corpus(displayName: 'My Knowledge Base'),
    );

    createdCorpusName = corpus.name;

    print('✅ Corpus created!');
    print('   Name: ${corpus.name}');
    print('   Display Name: ${corpus.displayName}');
    print('   Created: ${corpus.createTime}');
    print('   Updated: ${corpus.updateTime}');

    // 2. List corpora
    print('\n2️⃣  Listing corpora...\n');

    final listResponse = await client.corpora.list(pageSize: 10);
    final corpora = listResponse.corpora ?? [];

    print('📋 Found ${corpora.length} corpora:');
    for (final c in corpora) {
      print('   - ${c.displayName ?? c.name}');
      print('     Name: ${c.name}');
    }

    if (listResponse.nextPageToken != null) {
      print('\n   More corpora available (use nextPageToken for pagination)');
    }

    // 3. Get corpus details
    print('\n3️⃣  Getting corpus details...\n');

    if (createdCorpusName != null) {
      final retrieved = await client.corpora.get(name: createdCorpusName);

      print('📄 Corpus Details:');
      print('   Name: ${retrieved.name}');
      print('   Display Name: ${retrieved.displayName}');
      print('   Created: ${retrieved.createTime}');
      print('   Updated: ${retrieved.updateTime}');
    }

    // 4. Access documents (sub-resource)
    print('\n4️⃣  Accessing documents sub-resource...\n');

    print('   To manage documents within this corpus:');
    print('   ```dart');
    print(
      '   final docs = client.corpora.documents(corpus: "$createdCorpusName");',
    );
    print('   final docList = await docs.list();');
    print('   ```');
    print('   See documents_example.dart for full document operations.');

    // 5. Access permissions (sub-resource)
    print('\n5️⃣  Accessing permissions sub-resource...\n');

    print('   To manage permissions for this corpus:');
    print('   ```dart');
    print(
      '   final perms = client.corpora.permissions(parent: "$createdCorpusName");',
    );
    print('   final permList = await perms.list();');
    print('   ```');
    print('   See permissions_example.dart for full permission operations.');

    // 6. Delete corpus
    print('\n6️⃣  Deleting corpus...\n');

    if (createdCorpusName != null) {
      await client.corpora.delete(name: createdCorpusName);
      createdCorpusName = null;
      print('✅ Corpus deleted!');
    }

    print('\n📝 Notes:');
    print('   - A project can create up to 10 corpora');
    print('   - Corpora API is only available with Google AI (not Vertex AI)');
    print('   - Vertex AI uses RAG stores for semantic retrieval');
    print('   - Use force: true to delete corpus with documents');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Cleanup
    if (createdCorpusName != null) {
      try {
        await client.corpora.delete(name: createdCorpusName, force: true);
        print('\n🧹 Cleaned up corpus');
      } catch (e) {
        print('\n⚠️  Failed to clean up corpus: $e');
      }
    }
    client.close();
  }
}
