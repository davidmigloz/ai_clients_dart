import '../models/beta/config/output_config.dart';

/// Reads the canonical output configuration and the legacy beta format alias.
OutputConfig? parseMessageOutputConfig(Map<String, dynamic> json) {
  final configJson = json['output_config'] as Map<String, dynamic>?;
  final legacyFormat = json['output_format'] as Map<String, dynamic>?;
  if (legacyFormat == null) {
    return configJson == null ? null : OutputConfig.fromJson(configJson);
  }
  if (configJson?['format'] != null) {
    throw const FormatException(
      'Use only output_config.format. output_format is deprecated.',
    );
  }
  return OutputConfig.fromJson({...?configJson, 'format': legacyFormat});
}
