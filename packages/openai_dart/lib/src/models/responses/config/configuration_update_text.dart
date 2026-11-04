import 'package:meta/meta.dart';

import '../../common/json_helpers.dart';
import '../websocket/websocket_json_helpers.dart';
import 'text_config.dart';

export 'text_config.dart' show JsonSchemaFormat, PlainTextFormat, TextFormat;

/// Text output configuration that persists until a subsequent update replaces it.
///
/// A supplied configuration requires [format]. Only [PlainTextFormat] and
/// [JsonSchemaFormat] are supported; legacy JSON object mode is not accepted by
/// configuration updates. Omitting this object leaves the current setting alone;
/// use [ConfigurationUpdateText.plainText] to return to plain text.
@immutable
class ConfigurationUpdateText {
  /// The output format, with an immutable schema snapshot for JSON Schema.
  final TextFormat format;

  /// Creates an update and snapshots any schema owned by the caller.
  factory ConfigurationUpdateText({required TextFormat format}) =>
      ConfigurationUpdateText.fromJson({'format': format.toJson()});

  const ConfigurationUpdateText._(this.format);

  /// Returns to plain text output.
  const ConfigurationUpdateText.plainText() : format = const PlainTextFormat();

  /// Parses an update, rejecting omitted/null formats and unsupported JSON mode.
  /// Optional JSON Schema `strict: null` is normalized to omission.
  factory ConfigurationUpdateText.fromJson(
    Map<String, dynamic> json, {
    String context = 'ConfigurationUpdateText',
  }) {
    final value = snapshotResponsesJson(json, context);
    final format = requireJsonObject(value['format'], '$context.format');
    final type = requireJsonString(format['type'], '$context.format.type');
    if (type == 'text') return const ConfigurationUpdateText.plainText();
    if (type != 'json_schema') {
      throw FormatException(
        '$context.format.type: expected text or json_schema',
      );
    }
    final strict = format['strict'] == null
        ? null
        : optionalJsonBool(format, 'strict', '$context.format');
    return ConfigurationUpdateText._(
      JsonSchemaFormat(
        name: requireJsonString(format['name'], '$context.format.name'),
        description: optionalJsonString(
          format,
          'description',
          '$context.format',
        ),
        schema: freezeJsonObject(
          requireJsonObject(format['schema'], '$context.format.schema'),
        ),
        strict: strict,
      ),
    );
  }

  /// Converts to API JSON. Local parser metadata is never serialized.
  Map<String, dynamic> toJson() => {'format': format.toJson()};

  /// Copies the update and snapshots a replacement schema.
  ConfigurationUpdateText copyWith({TextFormat? format}) =>
      format == null ? this : ConfigurationUpdateText(format: format);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigurationUpdateText && format == other.format;

  @override
  int get hashCode => format.hashCode;

  @override
  String toString() =>
      'ConfigurationUpdateText(format: ${format is JsonSchemaFormat ? 'json_schema' : 'text'})';
}
