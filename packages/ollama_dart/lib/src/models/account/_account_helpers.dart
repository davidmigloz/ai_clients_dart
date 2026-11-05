// Internal JSON validation helpers for account reporting models.
// ignore_for_file: public_member_api_docs

Map<String, dynamic> accountObject(Object? value, String context) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$context must be a JSON object');
  }
  return value;
}

String accountString(Object? value, String context) {
  if (value is! String) throw FormatException('$context must be a string');
  return value;
}

int accountInt(Object? value, String context) {
  if (value is! int) throw FormatException('$context must be an integer');
  return value;
}

double accountDouble(Object? value, String context) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$context must be a finite number');
  }
  return value.toDouble();
}

bool accountBool(Object? value, String context) {
  if (value is! bool) throw FormatException('$context must be a boolean');
  return value;
}

DateTime accountDateTime(Object? value, String context) {
  final text = accountString(value, context);
  final parsed = DateTime.tryParse(text);
  if (parsed == null) throw FormatException('$context must be a date-time');
  return parsed.toUtc();
}

List<T> accountList<T>(
  Object? value,
  String context,
  T Function(Map<String, dynamic>) fromJson,
) {
  if (value is! List<Object?>) {
    throw FormatException('$context must be an array');
  }
  return [
    for (var i = 0; i < value.length; i++)
      fromJson(accountObject(value[i], '$context[$i]')),
  ];
}

Object? accountFreezeJson(Object? value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.unmodifiable({
      for (final entry in value.entries)
        entry.key: accountFreezeJson(entry.value),
    });
  }
  if (value is List<Object?>) {
    return List<Object?>.unmodifiable(value.map(accountFreezeJson));
  }
  if (value == null ||
      value is String ||
      value is bool ||
      value is num && value.isFinite) {
    return value;
  }
  throw const FormatException('Account data must contain only JSON values');
}
