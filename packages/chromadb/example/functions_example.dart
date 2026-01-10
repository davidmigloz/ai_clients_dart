/// Example demonstrating serverless function operations.
///
/// Serverless functions allow you to attach processing pipelines
/// to collections that automatically transform records.
///
/// Note: Functions require ChromaDB Cloud or Enterprise.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // Create or get a collection
    final collection = await client.getOrCreateCollection(name: 'my-documents');

    // Attach a function to process records
    // This function will process records from 'my-documents'
    // and output results to 'processed-documents'
    final attachResponse = await collection.attachFunction(
      name: 'my-processor',
      functionId: 'embed_processor',
      outputCollection: 'processed-documents',
      params: {'model': 'text-embedding-ada-002'},
    );

    // ignore: avoid_print
    print('Function attached: ${attachResponse.attachedFunction.name}');
    // ignore: avoid_print
    print('Newly created: ${attachResponse.created}');

    // Get details of an attached function
    final details = await collection.getFunction(name: 'my-processor');
    // ignore: avoid_print
    print('Function name: ${details.attachedFunction.functionName}');
    // ignore: avoid_print
    print('Input collection: ${details.attachedFunction.inputCollectionId}');
    // ignore: avoid_print
    print('Output collection: ${details.attachedFunction.outputCollection}');

    // Detach the function when no longer needed
    // Set deleteOutput: true to also delete the output collection
    final detachResponse = await collection.detachFunction(
      name: 'my-processor',
      deleteOutput: false,
    );
    // ignore: avoid_print
    print('Detach successful: ${detachResponse.success}');

    // You can also use the low-level FunctionsResource directly
    final functions = client.functions(collection.id);
    await functions.attach(
      name: 'direct-processor',
      functionId: 'summarizer',
      outputCollection: 'summaries',
    );
    await functions.detach(name: 'direct-processor');
  } on NotFoundException catch (e) {
    // ignore: avoid_print
    print('Function or collection not found: ${e.message}');
  } on ChromaException catch (e) {
    // ignore: avoid_print
    print('ChromaDB error: ${e.message}');
  } finally {
    client.close();
  }
}
