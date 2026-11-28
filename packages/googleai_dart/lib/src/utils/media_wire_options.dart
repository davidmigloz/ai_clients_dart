/// Reads a recognized media option and retains unfamiliar values for replay.
T? decodeMediaOption<T>(
  Map<String, dynamic> json,
  String key,
  Map<String, dynamic> additionalProperties,
  T Function(Object value) decode,
) {
  if (!json.containsKey(key)) return null;
  final value = json[key];
  if (value != null) {
    try {
      return decode(value);
    } on TypeError {
      // Preserve newer wire shapes in the same raw form older clients used.
    }
  }
  additionalProperties[key] = value;
  return null;
}

/// Collects extra keys and explicit nulls while reading typed fields.
Map<String, dynamic> mediaExtensions(
  Map<String, dynamic> json,
  Set<String> keys,
) => {
  for (final entry in json.entries)
    if (!keys.contains(entry.key) || entry.value == null)
      entry.key: entry.value,
};
