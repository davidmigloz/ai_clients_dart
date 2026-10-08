import 'audio_json_helpers.dart';

/// Copies a typed optional collection without retaining caller ownership.
List<T>? immutableFileAudioList<T>(List<T>? values) =>
    values == null ? null : List<T>.unmodifiable(values);

/// Describes private fields without rendering caller or provider content.
String fileAudioPresence(Object? value) =>
    value == null ? 'null' : '[REDACTED]';

/// Summarizes collection presence without rendering private elements.
String fileAudioListSummary(List<Object?>? value) =>
    value == null ? 'null' : '${value.length} items';

/// Reads a finite number without narrowing REST numeric byte elements.
num requireFileAudioNum(Object? value, String context) {
  if (value is! num || !value.isFinite) {
    throw FormatException('$context: expected a finite number');
  }
  return value;
}

/// Normalizes numeric sentinel-copy arguments without unchecked double casts.
double? copyFileAudioNumber(Object? value, String context) =>
    value == null ? null : requireAudioNumber(value, context);

/// Enforces the published temperature range without revealing its value.
void validateFileAudioTemperature(double? value, String context) {
  if (value != null && (!value.isFinite || value < 0 || value > 1)) {
    throw FormatException(
      '$context: expected a finite number between zero and one',
    );
  }
}

/// Validates reference syntax; service-side audio duration remains authoritative.
void validateFileAudioDataUrl(String value) {
  try {
    // UriData accepts Base64 and percent-encoded content. Reject malformed
    // percent sequences before URI normalization can silently repair them.
    if (RegExp(r'%(?![0-9a-fA-F]{2})').hasMatch(value)) {
      throw const FormatException('Malformed percent encoding');
    }
    UriData.parse(value).contentAsBytes();
  } on FormatException {
    throw const FormatException(
      'TranscriptionRequest.knownSpeakerReferences: expected a valid data URL',
    );
  }
}

/// Reads a known string with a contextual value-safe error.
String requireFileAudioString(Object? value, String context) {
  if (value is! String) throw FormatException('$context: expected a string');
  return value;
}

/// Reads an object without unchecked casts or private error details.
Map<String, dynamic> requireFileAudioMap(Object? value, String context) {
  if (value is! Map<String, dynamic>) {
    throw FormatException('$context: expected an object');
  }
  return value;
}

/// Reads a typed collection, including indexed known-field diagnostics.
List<T> requireFileAudioList<T>(
  Object? value,
  String context,
  T Function(Object?, String) parse,
) {
  if (value is! List<dynamic>) {
    throw FormatException('$context: expected an array');
  }
  return List<T>.unmodifiable([
    for (var index = 0; index < value.length; index++)
      parse(value[index], '$context[$index]'),
  ]);
}

/// Optional schema-nonnull fields distinguish absence from malformed null.
T? optionalFileAudio<T>(
  Map<String, dynamic> json,
  String key,
  String context,
  T Function(Object?, String) parse,
) => json.containsKey(key) ? parse(json[key], '$context.$key') : null;

/// Validates a fixed discriminator without rendering a received value.
void requireFileAudioType(
  Map<String, dynamic> json,
  String key,
  String expected,
  String context,
) {
  if (requireFileAudioString(json[key], '$context.$key') != expected) {
    throw FormatException('$context.$key: unexpected discriminator');
  }
}

/// Removes stale child metadata on an explicit fresh copy replacement.
Map<String, dynamic> copyFileAudioRaw(
  Map<String, dynamic> current,
  Map<String, dynamic>? replacement,
  Set<String> replaced,
) =>
    replacement ??
    {
      for (final entry in current.entries)
        if (!replaced.contains(entry.key)) entry.key: entry.value,
    };

/// Overlays nested child metadata with parent extras winning and typed fields fixed.
Map<String, dynamic> mergeFileAudioChild(
  Object? parent,
  Map<String, dynamic> child,
  Set<String> known,
) {
  final value = mergeAudioModelJson(parent, known, child);
  // Token usage includes a second schema-known object. Overlay that object's
  // future members at the same priority while typed counts/absence still win.
  final details = child['input_token_details'];
  if (known.contains('input_token_details') &&
      details is Map<String, dynamic>) {
    value['input_token_details'] = mergeAudioModelJson(
      parent is Map<String, dynamic> ? parent['input_token_details'] : null,
      const {'audio_tokens', 'text_tokens'},
      details,
    );
  }
  return value;
}

/// Uses the actual received union branch when prioritizing parent future fields.
Set<String> fileAudioUsageFields(Map<String, dynamic> value) =>
    switch (value['type']) {
      'tokens' => const {
        'type',
        'input_tokens',
        'output_tokens',
        'total_tokens',
        'input_token_details',
      },
      'duration' => const {'type', 'seconds'},
      _ => const {'type'},
    };

/// Applies the same overlay to a typed list of child objects.
List<Map<String, dynamic>> mergeFileAudioChildren(
  Object? parent,
  List<Map<String, dynamic>> children,
  Set<String> known,
) => [
  for (var index = 0; index < children.length; index++)
    mergeFileAudioChild(
      parent is List<dynamic> && index < parent.length ? parent[index] : null,
      children[index],
      known,
    ),
];

/// Uses canonical known fields and preserves immutable finite future extras.
Map<String, dynamic> fileAudioJson(
  Map<String, dynamic> raw,
  Set<String> known,
  Map<String, dynamic> fields,
  String context,
) {
  final value = mergeAudioJson(raw, known, fields);
  snapshotAudioJson(value, context, knownKeys: known);
  return value;
}
