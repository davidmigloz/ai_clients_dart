/// Reads a required property from a server response with field context.
T requiredOrganizationField<T>(
  Map<String, dynamic> json,
  String key,
  String model, {
  String? legacyKey,
}) {
  final responseKey = json.containsKey(key) ? key : legacyKey ?? key;
  final value = json[responseKey];
  if (json.containsKey(responseKey) && value is T) return value;
  throw FormatException('$model: missing or invalid "$key"');
}

/// Validates the wire discriminator of a known Admin response.
void checkOrganizationType(Map<String, dynamic> json, String type) {
  if (json['type'] != type) {
    throw FormatException('Expected Admin response type "$type"');
  }
}
