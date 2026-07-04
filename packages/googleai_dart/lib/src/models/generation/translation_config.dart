import '../copy_with_sentinel.dart';

/// Configuration for translation.
class TranslationConfig {
  /// The BCP-47 language code to translate the response into.
  final String targetLanguageCode;

  /// Whether to echo the target language back in the response.
  final bool? echoTargetLanguage;

  /// Creates a [TranslationConfig].
  const TranslationConfig({
    required this.targetLanguageCode,
    this.echoTargetLanguage,
  });

  /// Creates a [TranslationConfig] from JSON.
  factory TranslationConfig.fromJson(Map<String, dynamic> json) =>
      TranslationConfig(
        targetLanguageCode: json['targetLanguageCode'] as String,
        echoTargetLanguage: json['echoTargetLanguage'] as bool?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'targetLanguageCode': targetLanguageCode,
    if (echoTargetLanguage != null) 'echoTargetLanguage': echoTargetLanguage,
  };

  /// Creates a copy with replaced values.
  TranslationConfig copyWith({
    String? targetLanguageCode,
    Object? echoTargetLanguage = unsetCopyWithValue,
  }) {
    return TranslationConfig(
      targetLanguageCode: targetLanguageCode ?? this.targetLanguageCode,
      echoTargetLanguage: echoTargetLanguage == unsetCopyWithValue
          ? this.echoTargetLanguage
          : echoTargetLanguage as bool?,
    );
  }

  @override
  String toString() =>
      'TranslationConfig('
      'targetLanguageCode: $targetLanguageCode, '
      'echoTargetLanguage: $echoTargetLanguage)';
}
