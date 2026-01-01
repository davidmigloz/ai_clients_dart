// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Document processing example (PDF analysis).
///
/// This example demonstrates:
/// - Processing PDF documents with base64 encoding
/// - Extracting text from PDFs
/// - Analyzing document content
/// - Multi-page document handling
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Analyze a PDF document
    print('=== PDF Document Analysis ===');
    const pdfPath = 'example/sample_document.pdf';
    final pdfFile = File(pdfPath);

    if (pdfFile.existsSync()) {
      final pdfBytes = await pdfFile.readAsBytes();
      final base64Pdf = base64Encode(pdfBytes);

      final response = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 4096,
          messages: [
            InputMessage.userBlocks([
              InputContentBlock.document(
                DocumentSource.base64Pdf(base64Pdf),
                title: 'Sample Document',
              ),
              InputContentBlock.text(
                'Please analyze this document and provide:\n'
                '1. A summary of the main content\n'
                '2. Key points or findings\n'
                '3. Any notable sections or headings',
              ),
            ]),
          ],
        ),
      );

      print('Analysis:');
      print(response.text);
    } else {
      print('No PDF file found at $pdfPath');
      print('To test PDF processing:');
      print('1. Place a PDF file at $pdfPath');
      print('2. Run this example again');
    }

    // Example 2: Extract structured data from a document
    print('\n=== Structured Data Extraction ===');
    print('(Simulated - requires actual PDF file)');
    print('''
To extract structured data from a document, you would use:

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 4096,
    messages: [
      InputMessage.userBlocks([
        InputContentBlock.document(
          DocumentSource.base64Pdf(base64EncodedPdf),
        ),
        InputContentBlock.text(
          'Extract the following data as JSON:
          - Document title
          - Author (if present)
          - Date (if present)
          - Main topics covered
          - Key statistics or figures',
        ),
      ]),
    ],
  ),
);
''');

    // Example 3: Compare multiple documents
    print('\n=== Multi-Document Comparison ===');
    print('(Simulated - requires actual PDF files)');
    print('''
To compare multiple documents:

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 8192,
    messages: [
      InputMessage.userBlocks([
        InputContentBlock.document(
          DocumentSource.base64Pdf(base64Document1),
          title: 'Document 1',
        ),
        InputContentBlock.document(
          DocumentSource.base64Pdf(base64Document2),
          title: 'Document 2',
        ),
        InputContentBlock.text(
          'Compare these two documents and highlight:
          1. Similarities
          2. Differences
          3. Any contradictions',
        ),
      ]),
    ],
  ),
);
''');

    // Example 4: Q&A over document
    print('\n=== Document Q&A ===');
    print('(Simulated - requires actual PDF file)');
    print('''
To ask questions about a document:

// First message with document
final messages = [
  InputMessage.userBlocks([
    InputContentBlock.document(
      DocumentSource.base64Pdf(base64Document),
      title: 'Reference Document',
    ),
    InputContentBlock.text('I have attached a document for reference.'),
  ]),
  InputMessage.assistant('I have reviewed the document. What questions do you have?'),
  InputMessage.user('What are the main conclusions?'),
];

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 2048,
    messages: messages,
  ),
);
''');
  } finally {
    client.close();
  }
}
