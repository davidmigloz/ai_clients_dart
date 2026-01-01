// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating OCR (Optical Character Recognition) with the Mistral AI API.
///
/// This example shows how to:
/// - Extract text from documents and images
/// - Process specific pages
/// - Handle images in documents
/// - Get structured output with markdown
///
/// Supported formats:
/// - PDF documents
/// - Images (PNG, JPEG, etc.)
/// - Other document formats
void main() {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Example 1: Process document from URL ---
    print('=== OCR from URL ===\n');

    print('Example: Processing a PDF from URL\n');
    print(r'''
final response = await client.ocr.process(
  request: OcrRequest.fromUrl(
    url: 'https://example.com/document.pdf',
  ),
);

// Get all text
print('Extracted text:');
print(response.text);

// Or process page by page
for (final page in response.pages) {
  print('Page ${page.index}:');
  print(page.markdown);
}
''');

    // --- Example 2: Process document from file ---
    print('=== OCR from Uploaded File ===\n');

    print('Example: Processing a previously uploaded file\n');
    print(r'''
// First upload the file
final file = await client.files.upload(
  file: File('document.pdf'),
  purpose: FilePurpose.ocr,
);

// Then process with OCR
final response = await client.ocr.process(
  request: OcrRequest.fromFile(
    fileId: file.id,
  ),
);

print('Pages processed: ${response.pages.length}');
''');

    // --- Example 3: Process specific pages ---
    print('=== OCR Specific Pages ===\n');

    print('Example: Processing only certain pages\n');
    print(r'''
final response = await client.ocr.process(
  request: OcrRequest.fromUrl(
    url: 'https://example.com/long-document.pdf',
    pages: [0, 1, 4], // Only process pages 1, 2, and 5 (0-indexed)
  ),
);

print('Processed ${response.pages.length} pages');
for (final page in response.pages) {
  print('Page ${page.index + 1}: ${page.markdown.length} characters');
}
''');

    // --- Example 4: Include image data ---
    print('=== OCR with Image Extraction ===\n');

    print('Example: Getting images from the document\n');
    print(r'''
final response = await client.ocr.process(
  request: OcrRequest.fromUrl(
    url: 'https://example.com/document-with-images.pdf',
    includeImageBase64: true, // Include base64-encoded images
  ),
);

for (final page in response.pages) {
  print('Page ${page.index}: ${page.images.length} images');
  for (final image in page.images) {
    print('  - Image ${image.id}');
    if (image.boundingBox != null) {
      print('    Bounding box: ${image.boundingBox}');
    }
    if (image.imageBase64 != null) {
      print('    Base64 data: ${image.imageBase64!.length} chars');
    }
  }
}
''');

    // --- Example 5: Process base64-encoded document ---
    print('=== OCR from Base64 Data ===\n');

    print('Example: Processing a base64-encoded document\n');
    print(r'''
import 'dart:convert';
import 'dart:io';

// Read and encode file
final bytes = await File('document.pdf').readAsBytes();
final base64Data = base64Encode(bytes);

final response = await client.ocr.process(
  request: OcrRequest.fromBase64(
    data: base64Data,
    mimeType: 'application/pdf',
  ),
);

print('Extracted text: ${response.text}');
''');

    // --- Example 6: Complete workflow ---
    print('=== Complete OCR Workflow ===\n');

    print(r'''
Complete workflow for processing a document:

// 1. Process the document
final response = await client.ocr.process(
  request: OcrRequest.fromUrl(
    url: 'https://example.com/report.pdf',
  ),
);

// 2. Check processing stats
print('Total pages in document: ${response.totalPages}');
print('Pages processed: ${response.processedPages}');

// 3. Get usage info
if (response.usage != null) {
  print('Tokens used: ${response.usage!.totalTokens}');
}

// 4. Process the extracted text
final fullText = response.text;

// Or get specific page content
final firstPageText = response.getPageText(0);
if (firstPageText != null) {
  print('First page content:');
  print(firstPageText);
}

// 5. Work with markdown output
for (final page in response.pages) {
  // The markdown preserves formatting:
  // - Headers (#, ##, ###)
  // - Lists (-, *)
  // - Tables (| ... |)
  // - Bold/italic formatting
  print('Page ${page.index}:');
  print(page.markdown);
  print('---');
}
''');

    // --- Example 7: Process image ---
    print('=== OCR on Images ===\n');

    print('Example: Extract text from an image\n');
    print(r'''
// OCR works on images too
final response = await client.ocr.process(
  request: OcrRequest.fromUrl(
    url: 'https://example.com/scanned-document.png',
  ),
);

// Images typically have a single "page"
if (response.pages.isNotEmpty) {
  print('Extracted text from image:');
  print(response.pages.first.markdown);
}
''');

    // --- Example 8: Error handling ---
    print('=== Error Handling ===\n');

    print(r'''
try {
  final response = await client.ocr.process(
    request: OcrRequest.fromUrl(
      url: 'https://example.com/document.pdf',
    ),
  );
  print('Success: ${response.pages.length} pages processed');
} on MistralAuthException {
  print('Authentication failed - check your API key');
} on MistralRateLimitException catch (e) {
  print('Rate limited - retry after ${e.retryAfter}');
} on MistralValidationException catch (e) {
  print('Invalid request: ${e.message}');
} on MistralException catch (e) {
  print('API error: ${e.message}');
}
''');
  } finally {
    client.close();
  }
}
