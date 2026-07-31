import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/content_provenance_checks/content_provenance_checks.dart';
import 'base_resource.dart';

/// Resource for content provenance checks.
///
/// Detects OpenAI C2PA/SynthID provenance signals in an uploaded image or
/// audio file.
///
/// Access this resource through [OpenAIClient.contentProvenanceChecks].
class ContentProvenanceChecksResource extends ResourceBase {
  /// Creates a [ContentProvenanceChecksResource].
  ContentProvenanceChecksResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/content_provenance_checks';

  /// Checks a file for OpenAI content provenance signals.
  ///
  /// ## Parameters
  ///
  /// - [bytes] - The file content as bytes.
  /// - [filename] - The filename to associate with the upload.
  ///
  /// ## Returns
  ///
  /// A [ContentProvenanceCheck] describing the detected provenance signals.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final check = await client.contentProvenanceChecks.create(
  ///   bytes: File('image.png').readAsBytesSync(),
  ///   filename: 'image.png',
  /// );
  ///
  /// for (final result in check.results) {
  ///   print('${result.type}: ${result.toJson()}');
  /// }
  /// ```
  Future<ContentProvenanceCheck> create({
    required List<int> bytes,
    required String filename,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final httpRequest = http.MultipartRequest('POST', url)
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: filename),
      )
      ..headers.addAll(requestBuilder.buildMultipartHeaders());
    final response = await interceptorChain.execute(httpRequest);
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ContentProvenanceCheck.fromJson(json);
  }
}
