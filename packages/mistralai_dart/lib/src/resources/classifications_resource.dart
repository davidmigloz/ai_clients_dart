import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/classifications/chat_classification_request.dart';
import '../models/classifications/classification_request.dart';
import '../models/classifications/classification_response.dart';
import 'base_resource.dart';

/// Resource for the Classifications API.
///
/// Provides content classification capabilities for text and chat messages.
///
/// Example usage:
/// ```dart
/// final response = await client.classifications.create(
///   request: ClassificationRequest.single(
///     input: 'Some text to classify',
///   ),
/// );
/// print('Flagged: ${response.flagged}');
/// ```
class ClassificationsResource extends ResourceBase {
  /// Creates a [ClassificationsResource].
  ClassificationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Classifies text content.
  ///
  /// Returns a [ClassificationResponse] with results for each input.
  Future<ClassificationResponse> create({
    required ClassificationRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/classifiers');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ClassificationResponse.fromJson(responseBody);
  }

  /// Classifies chat messages.
  ///
  /// Returns a [ClassificationResponse] with results for the conversation.
  Future<ClassificationResponse> createChat({
    required ChatClassificationRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/chat/classifiers');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ClassificationResponse.fromJson(responseBody);
  }
}
