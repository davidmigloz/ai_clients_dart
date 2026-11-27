final _keyPattern = RegExp(r'^[a-z][a-z0-9_]{0,63}$');
final _valuePattern = RegExp(r'^[A-Za-z0-9._:@/-]{1,256}$');
const _maxSafeInteger = 9007199254740991;

bool _validCallContext(Map<String, Object?> values) =>
    values.length <= 16 &&
    values.entries.every(
      (entry) =>
          _keyPattern.hasMatch(entry.key) &&
          switch (entry.value) {
            bool() => true,
            final int value =>
              value >= -_maxSafeInteger && value <= _maxSafeInteger,
            final String value => _valuePattern.hasMatch(value),
            _ => false,
          },
    );

/// Decodes the cleartext technical metadata of a workflow call.
Map<String, Object>? parseWorkflowCallContext(Object? json) {
  if (json == null) return null;
  if (json is! Map<String, Object?> || !_validCallContext(json)) {
    throw const FormatException('Invalid workflow call_context');
  }
  return Map<String, Object>.unmodifiable(json);
}

/// Validates and returns a workflow call's technical metadata.
Map<String, Object> workflowCallContextToJson(Map<String, Object> values) {
  if (!_validCallContext(values)) {
    throw ArgumentError('Invalid workflow callContext');
  }
  return values;
}
