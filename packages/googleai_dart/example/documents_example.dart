// ignore_for_file: avoid_print
/// Demonstrates document management within corpora.
library;

import 'package:googleai_dart/googleai_dart.dart';

void main() async {
  // Note: Documents API is only available with Google AI (not Vertex AI)
  final client = GoogleAIClient(
    config: const GoogleAIConfig(authProvider: ApiKeyProvider('YOUR_API_KEY')),
  );

  String? corpusName;
  String? documentName;

  try {
    print('📄 Documents API Example\n');
    print('Documents are stored within corpora for semantic retrieval.\n');

    // First, create a corpus to hold documents
    print('🔧 Setup: Creating corpus...\n');

    final corpus = await client.corpora.create(
      corpus: const Corpus(displayName: 'Documents Example Corpus'),
    );
    corpusName = corpus.name;

    print('   Corpus created: $corpusName\n');

    // Get documents resource for this corpus
    if (corpusName != null) {
      final documents = client.corpora.documents(corpus: corpusName);

      // 1. Create a document
      print('1️⃣  Creating document...\n');

      final document = await documents.create(
        document: const Document(displayName: 'Research Paper'),
      );
      documentName = document.name;

      print('✅ Document created!');
      print('   Name: ${document.name}');
      print('   Display Name: ${document.displayName}');
      print('   Created: ${document.createTime}');
      print('   Updated: ${document.updateTime}');

      // 2. List documents
      print('\n2️⃣  Listing documents...\n');

      final listResponse = await documents.list(pageSize: 10);
      final docs = listResponse.documents ?? [];

      print('📋 Found ${docs.length} documents:');
      for (final doc in docs) {
        print('   - ${doc.displayName ?? doc.name}');
      }

      // 3. Get document details
      print('\n3️⃣  Getting document details...\n');

      if (documentName != null) {
        final retrieved = await documents.get(name: documentName);

        print('📄 Document Details:');
        print('   Name: ${retrieved.name}');
        print('   Display Name: ${retrieved.displayName}');
        print('   Created: ${retrieved.createTime}');
        print('   Updated: ${retrieved.updateTime}');

        // 4. Update document
        print('\n4️⃣  Updating document...\n');

        final updated = await documents.update(
          name: documentName,
          document: const Document(displayName: 'Updated Research Paper'),
          updateMask: 'displayName',
        );

        print('✅ Document updated!');
        print('   New Display Name: ${updated.displayName}');

        // 5. Delete document
        print('\n5️⃣  Deleting document...\n');

        await documents.delete(name: documentName);
        documentName = null;

        print('✅ Document deleted!');
      }
    }

    print('\n📝 Notes:');
    print('   - Documents belong to corpora');
    print(
      '   - Documents API is only available with Google AI (not Vertex AI)',
    );
    print('   - Vertex AI uses RAG stores for document management');
    print('   - A corpus can contain multiple documents');
    print('   - Use updateMask to specify which fields to update');
  } catch (e) {
    print('❌ Error: $e');
  } finally {
    // Cleanup
    if (documentName != null && corpusName != null) {
      try {
        final documents = client.corpora.documents(corpus: corpusName);
        await documents.delete(name: documentName);
        print('\n🧹 Cleaned up document');
      } catch (e) {
        // Document might already be deleted
      }
    }
    if (corpusName != null) {
      try {
        await client.corpora.delete(name: corpusName, force: true);
        print('🧹 Cleaned up corpus');
      } catch (e) {
        print('\n⚠️  Failed to clean up corpus: $e');
      }
    }
    client.close();
  }
}
