// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Libraries API (Beta).
///
/// Libraries provide document storage for RAG (Retrieval-Augmented Generation).
/// Documents in libraries can be accessed by agents through the document_library
/// tool for context-aware responses.
///
/// This example shows how to:
/// - Create and manage libraries
/// - Add documents to libraries
/// - Retrieve document content
/// - Use libraries with agents
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  // Initialize client
  final client = MistralClient();

  try {
    // Example: Basic library operations
    await libraryManagementExample(client);

    // Example: Document operations
    await documentOperationsExample(client);

    // Example: Using libraries with agents
    await libraryWithAgentExample(client);
  } finally {
    client.close();
  }
}

/// Demonstrates basic library CRUD operations.
Future<void> libraryManagementExample(MistralClient client) async {
  print('=== Library Management Example ===\n');

  // Create a new library
  print('Creating a new library...');
  final library = await client.libraries.create(
    name: 'Product Documentation',
    description: 'Technical docs and user guides for our product',
  );

  print('Created library:');
  print('  ID: ${library.id}');
  print('  Name: ${library.name}');
  print('  Description: ${library.description}');
  print('  Documents: ${library.nbDocuments ?? 0}');
  print('');

  // List all libraries
  print('Listing all libraries...');
  final libraries = await client.libraries.list(page: 0, pageSize: 10);

  print('Found ${libraries.total ?? libraries.length} libraries:');
  for (final lib in libraries.data) {
    print('  - ${lib.name} (${lib.id})');
    if (lib.hasDocuments) {
      print('    Documents: ${lib.nbDocuments}');
    }
  }
  print('');

  // Retrieve a specific library
  print('Retrieving library details...');
  final retrieved = await client.libraries.retrieve(libraryId: library.id);
  print('Retrieved: ${retrieved.name}');
  print('');

  // Update the library
  print('Updating library...');
  final updated = await client.libraries.update(
    libraryId: library.id,
    name: 'Product Documentation v2',
    description: 'Updated documentation library',
  );
  print('Updated name: ${updated.name}');
  print('Updated description: ${updated.description}');
  print('');

  // Delete the library (cleanup)
  print('Deleting library...');
  await client.libraries.delete(libraryId: library.id);
  print('Library deleted successfully');
  print('');
}

/// Demonstrates document operations within a library.
Future<void> documentOperationsExample(MistralClient client) async {
  print('=== Document Operations Example ===\n');

  // First, create a library
  final library = await client.libraries.create(
    name: 'Docs Library',
    description: 'For document operations demo',
  );
  print('Created library: ${library.id}');

  try {
    // Note: To add documents, you first need to upload a file
    // using the Files API, then add it to the library.
    //
    // Example workflow:
    // 1. Upload file: final file = await client.files.upload(...)
    // 2. Add to library: await client.libraries.documents.create(
    //      libraryId: library.id,
    //      fileId: file.id,
    //    )

    // For this example, we'll demonstrate the API structure:
    print('');
    print('Document workflow:');
    print('1. Upload a file using client.files.upload()');
    print('2. Add file to library using client.libraries.documents.create()');
    print('3. Wait for processing (check status with retrieve())');
    print('4. Access content with client.libraries.documents.getContent()');
    print('');

    // List documents in the library (will be empty for new library)
    print('Listing documents...');
    final documents = await client.libraries.documents.list(
      libraryId: library.id,
      page: 0,
      pageSize: 10,
    );

    if (documents.isEmpty) {
      print('No documents in library yet');
    } else {
      print('Documents in library:');
      for (final doc in documents.data) {
        print('  - ${doc.name} (${doc.status.value})');
        if (doc.isCompleted) {
          print('    Pages: ${doc.numberOfPages}');
          print('    Size: ${doc.size} bytes');
        } else if (doc.isProcessing) {
          print('    Status: Processing...');
        }
      }
    }
    print('');
  } finally {
    // Cleanup
    await client.libraries.delete(libraryId: library.id);
    print('Cleaned up library');
  }
}

/// Demonstrates using a library with an agent.
Future<void> libraryWithAgentExample(MistralClient client) async {
  print('=== Library with Agent Example ===\n');

  // Create a library with documents (in practice)
  final library = await client.libraries.create(
    name: 'Knowledge Base',
    description: 'Company knowledge base for AI assistant',
  );

  try {
    print('Created knowledge base library: ${library.id}');
    print('');

    // To use the library with an agent, you would:
    // 1. Add documents to the library
    // 2. Create an agent with the document_library tool
    // 3. The agent can then query the library for relevant context
    //
    // Example agent creation with document library tool:
    //
    // final agent = await client.agents.create(
    //   request: CreateAgentRequest(
    //     model: 'mistral-large-latest',
    //     name: 'Knowledge Assistant',
    //     instructions: 'You are a helpful assistant...',
    //     tools: [
    //       Tool.documentLibrary(
    //         libraryIds: [library.id],
    //       ),
    //     ],
    //   ),
    // );

    print('Agent with document library tool:');
    print('');
    print('  const agent = CreateAgentRequest(');
    print('    model: "mistral-large-latest",');
    print('    name: "Knowledge Assistant",');
    print('    tools: [');
    print('      Tool.documentLibrary(');
    print('        libraryIds: ["${library.id}"],');
    print('      ),');
    print('    ],');
    print('  );');
    print('');
    print('The agent will automatically search the library for relevant');
    print('context when answering user questions.');
    print('');
  } finally {
    // Cleanup
    await client.libraries.delete(libraryId: library.id);
    print('Cleaned up library');
  }
}

/// Polls a document until processing is complete.
Future<LibraryDocument> waitForDocumentProcessing(
  MistralClient client,
  String libraryId,
  String documentId, {
  Duration timeout = const Duration(minutes: 5),
  Duration interval = const Duration(seconds: 5),
}) async {
  final startTime = DateTime.now();

  while (true) {
    final document = await client.libraries.documents.retrieve(
      libraryId: libraryId,
      documentId: documentId,
    );

    if (document.isCompleted) {
      return document;
    }

    if (document.status == LibraryDocumentStatus.failed) {
      throw Exception('Document processing failed');
    }

    if (DateTime.now().difference(startTime) > timeout) {
      throw Exception('Timeout waiting for document processing');
    }

    await Future<void>.delayed(interval);
    print('  Still processing...');
  }
}

/// Example showing full document workflow (requires actual file).
Future<void> fullDocumentWorkflowExample(MistralClient client) async {
  print('=== Full Document Workflow Example ===\n');

  // This example shows the complete workflow for adding
  // and using documents in a library.

  // 1. Create library
  final library = await client.libraries.create(
    name: 'API Documentation',
    description: 'REST API reference documentation',
  );
  print('Created library: ${library.id}');

  try {
    // 2. Upload a file (requires actual file path)
    // final file = await client.files.upload(
    //   filePath: 'docs/api-reference.pdf',
    //   purpose: FilePurpose.libraries,
    // );
    // print('Uploaded file: ${file.id}');

    // 3. Add file to library
    // final document = await client.libraries.documents.create(
    //   libraryId: library.id,
    //   fileId: file.id,
    //   documentName: 'API Reference',
    // );
    // print('Added document: ${document.id}');

    // 4. Wait for processing
    // final processed = await waitForDocumentProcessing(
    //   client,
    //   library.id,
    //   document.id,
    // );
    // print('Document processed: ${processed.numberOfPages} pages');

    // 5. Get extracted content
    // final content = await client.libraries.documents.getContent(
    //   libraryId: library.id,
    //   documentId: document.id,
    // );
    // print('Extracted ${content.text.length} characters');

    // 6. Use with agent for RAG
    // final response = await client.chat.create(
    //   request: ChatCompletionRequest(
    //     model: 'mistral-large-latest',
    //     messages: [
    //       ChatMessage.user('What endpoints are available in the API?'),
    //     ],
    //     tools: [
    //       Tool.documentLibrary(libraryIds: [library.id]),
    //     ],
    //   ),
    // );
    // print('Agent response: ${response.choices.first.message.content}');

    print('(Workflow demonstrated - requires actual file upload)');
  } finally {
    await client.libraries.delete(libraryId: library.id);
    print('Cleaned up library');
  }
}
