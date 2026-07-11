/// Harm categories that can be blocked.
enum HarmCategory {
  /// Unspecified harm category.
  unspecified,

  /// Hate speech and content.
  hateSpeech,

  /// Sexually explicit content.
  sexuallyExplicit,

  /// Harassment content.
  harassment,

  /// Dangerous content.
  dangerousContent,

  /// Civic integrity.
  civicIntegrity,

  /// Prompts attempting to bypass or subvert the model's safety guidelines
  /// (jailbreak attempts).
  jailbreak,

  /// Legacy PaLM category: negative or harmful comments targeting identity
  /// and/or protected attribute.
  derogatory,

  /// Legacy PaLM category: content that is rude, disrespectful, or profane.
  toxicity,

  /// Legacy PaLM category: describes scenarios depicting violence against an
  /// individual or group, or general descriptions of gore.
  violence,

  /// Legacy PaLM category: contains references to sexual acts or other lewd
  /// content.
  sexual,

  /// Legacy PaLM category: promotes unchecked medical advice.
  medical,

  /// Legacy PaLM category: dangerous content that promotes, facilitates, or
  /// encourages harmful acts.
  dangerous,
}

/// Converts string to HarmCategory enum.
HarmCategory harmCategoryFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'HARM_CATEGORY_HATE_SPEECH' => HarmCategory.hateSpeech,
    'HARM_CATEGORY_SEXUALLY_EXPLICIT' => HarmCategory.sexuallyExplicit,
    'HARM_CATEGORY_HARASSMENT' => HarmCategory.harassment,
    'HARM_CATEGORY_DANGEROUS_CONTENT' => HarmCategory.dangerousContent,
    'HARM_CATEGORY_CIVIC_INTEGRITY' => HarmCategory.civicIntegrity,
    'HARM_CATEGORY_JAILBREAK' => HarmCategory.jailbreak,
    'HARM_CATEGORY_DEROGATORY' => HarmCategory.derogatory,
    'HARM_CATEGORY_TOXICITY' => HarmCategory.toxicity,
    'HARM_CATEGORY_VIOLENCE' => HarmCategory.violence,
    'HARM_CATEGORY_SEXUAL' => HarmCategory.sexual,
    'HARM_CATEGORY_MEDICAL' => HarmCategory.medical,
    'HARM_CATEGORY_DANGEROUS' => HarmCategory.dangerous,
    _ => HarmCategory.unspecified,
  };
}

/// Converts HarmCategory enum to string.
String harmCategoryToString(HarmCategory category) {
  return switch (category) {
    HarmCategory.hateSpeech => 'HARM_CATEGORY_HATE_SPEECH',
    HarmCategory.sexuallyExplicit => 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
    HarmCategory.harassment => 'HARM_CATEGORY_HARASSMENT',
    HarmCategory.dangerousContent => 'HARM_CATEGORY_DANGEROUS_CONTENT',
    HarmCategory.civicIntegrity => 'HARM_CATEGORY_CIVIC_INTEGRITY',
    HarmCategory.jailbreak => 'HARM_CATEGORY_JAILBREAK',
    HarmCategory.derogatory => 'HARM_CATEGORY_DEROGATORY',
    HarmCategory.toxicity => 'HARM_CATEGORY_TOXICITY',
    HarmCategory.violence => 'HARM_CATEGORY_VIOLENCE',
    HarmCategory.sexual => 'HARM_CATEGORY_SEXUAL',
    HarmCategory.medical => 'HARM_CATEGORY_MEDICAL',
    HarmCategory.dangerous => 'HARM_CATEGORY_DANGEROUS',
    HarmCategory.unspecified => 'HARM_CATEGORY_UNSPECIFIED',
  };
}
