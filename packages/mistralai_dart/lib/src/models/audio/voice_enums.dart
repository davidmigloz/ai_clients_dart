/// The provenance of a voice.
enum VoiceType {
  /// A voice supplied by Mistral.
  preset('preset'),

  /// A voice created in a workspace.
  custom('custom'),

  /// A value introduced by a newer API version.
  unknown('unknown');

  const VoiceType(this.value);

  /// The API wire value.
  final String value;

  /// Converts a wire value to a voice type.
  static VoiceType? fromJson(String? value) => switch (value) {
    'preset' => preset,
    'custom' => custom,
    null => null,
    _ => unknown,
  };
}

/// Gender filters supported by voice search.
enum VoiceGender {
  /// Female.
  female('female'),

  /// Male.
  male('male'),

  /// Neutral.
  neutral('neutral'),

  /// A value introduced by a newer API version.
  unknown('unknown');

  const VoiceGender(this.value);

  /// The API wire value.
  final String value;

  /// Converts a wire value to a voice gender.
  static VoiceGender? fromJson(String? value) => switch (value) {
    'female' => female,
    'male' => male,
    'neutral' => neutral,
    null => null,
    _ => unknown,
  };
}

/// The voice cloning technology.
enum VoiceKind {
  /// Instant voice cloning.
  ivc('ivc'),

  /// Professional voice cloning.
  pvc('pvc'),

  /// A value introduced by a newer API version.
  unknown('unknown');

  const VoiceKind(this.value);

  /// The API wire value.
  final String value;

  /// Converts a wire value to a voice kind.
  static VoiceKind? fromJson(String? value) => switch (value) {
    'ivc' => ivc,
    'pvc' => pvc,
    null => null,
    _ => unknown,
  };
}
