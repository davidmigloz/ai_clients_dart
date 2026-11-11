/// Reads a required property from a server response with field context.
T requiredOrganizationField<T>(
  Map<String, dynamic> json,
  String key,
  String model,
) {
  final value = json[key];
  if (json.containsKey(key) && value is T) return value;
  throw FormatException('$model: missing or invalid "$key"');
}

/// Validates the wire discriminator of a known Admin response.
void checkOrganizationType(Map<String, dynamic> json, String type) {
  if (json['type'] != type) {
    throw FormatException('Expected Admin response type "$type"');
  }
}
