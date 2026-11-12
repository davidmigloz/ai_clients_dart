/// Encodes one opaque API identifier before interpolating it into a route.
String encodePathSegment(String value, String parameter) {
  // Some intermediaries strip semicolon parameters before routing.
  final segment = value.split(';').first;
  if (segment.isEmpty || segment == '.' || segment == '..') {
    throw ArgumentError('Expected a nonempty path identifier', parameter);
  }
  final encoded = Uri.encodeComponent(value);
  if (Uri.decodeComponent(encoded) != value) {
    throw ArgumentError('Expected a valid Unicode path identifier', parameter);
  }
  return encoded;
}
