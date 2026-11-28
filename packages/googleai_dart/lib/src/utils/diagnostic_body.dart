import 'dart:convert';

import 'package:http/http.dart' as http;

/// Reads response text for diagnostics without throwing on malformed bytes.
///
/// The operation still receives the original bytes for its own decoder.
String readDiagnosticBody(http.Response response) {
  try {
    return response.body;
  } on FormatException {
    return utf8.decode(response.bodyBytes, allowMalformed: true);
  }
}
