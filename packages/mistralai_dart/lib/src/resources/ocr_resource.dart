import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ocr/ocr_request.dart';
import '../models/ocr/ocr_response.dart';
import 'base_resource.dart';

/// Resource for the OCR API.
///
/// Provides optical character recognition (OCR) for extracting text from
/// documents and images. Supports PDFs, images, and various document formats.
///
/// Example usage:
/// ```dart
/// // Extract text from a PDF URL
/// final response = await client.ocr.process(
///   request: OcrRequest.fromUrl(
///     url: 'https://example.com/document.pdf',
///   ),
/// );
///
/// print('Extracted text:');
/// for (final page in response.pages) {
///   print('Page ${page.index}: ${page.markdown}');
/// }
///
/// // Or get all text at once
/// print(response.text);
/// ```
class OcrResource extends ResourceBase {
  /// Creates an [OcrResource].
  OcrResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Processes a document with OCR.
  ///
  /// The [request] contains the document to process and OCR settings.
  ///
  /// Returns an [OcrResponse] containing the extracted text from each page.
  ///
  /// Supported document types:
  /// - PDFs
  /// - Images (PNG, JPEG, etc.)
  /// - Other document formats
  ///
  /// Example:
  /// ```dart
  /// // From URL
  /// final response = await client.ocr.process(
  ///   request: OcrRequest.fromUrl(
  ///     url: 'https://example.com/document.pdf',
  ///   ),
  /// );
  ///
  /// // From file ID (previously uploaded)
  /// final response = await client.ocr.process(
  ///   request: OcrRequest.fromFile(
  ///     fileId: 'file-abc123',
  ///   ),
  /// );
  ///
  /// // From base64 data
  /// final response = await client.ocr.process(
  ///   request: OcrRequest.fromBase64(
  ///     data: base64EncodedPdf,
  ///     mimeType: 'application/pdf',
  ///   ),
  /// );
  /// ```
  Future<OcrResponse> process({required OcrRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/ocr');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return OcrResponse.fromJson(responseBody);
  }
}
