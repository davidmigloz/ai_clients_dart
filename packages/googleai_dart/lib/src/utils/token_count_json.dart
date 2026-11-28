/// Parses Live protobuf int64 token counts and legacy numeric JSON.
int? liveTokenCountFromJson(Object? value) {
  if (value == null || value is int) return value as int?;
  if (value is String) {
    final parsed = int.tryParse(value, radix: 10);
    if (parsed != null &&
        BigInt.from(parsed) == BigInt.tryParse(value, radix: 10)) {
      return parsed;
    }
  }
  throw const FormatException('Invalid or unrepresentable Live token count.');
}
