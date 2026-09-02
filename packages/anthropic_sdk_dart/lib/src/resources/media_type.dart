import 'package:http/http.dart' as http;

/// Parses [mimeType] into an [http.MediaType] for use as a multipart part's
/// content type.
///
/// Falls back to `application/octet-stream` when [mimeType] doesn't parse as
/// a valid media type (e.g. it's missing a `/` or is otherwise malformed).
http.MediaType parseMediaTypeOrOctetStream(String mimeType) {
  try {
    return http.MediaType.parse(mimeType);
  } on FormatException {
    return http.MediaType('application', 'octet-stream');
  }
}
