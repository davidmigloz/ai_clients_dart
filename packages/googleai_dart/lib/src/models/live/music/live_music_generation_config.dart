/// Musical scale used for Live Music generation.
extension type const LiveMusicScale(String value) {
  /// Uses the model default.
  static const unspecified = LiveMusicScale('SCALE_UNSPECIFIED');

  /// C major or A minor.
  static const cMajorAMinor = LiveMusicScale('C_MAJOR_A_MINOR');

  /// D-flat major or B-flat minor.
  static const dFlatMajorBFlatMinor = LiveMusicScale(
    'D_FLAT_MAJOR_B_FLAT_MINOR',
  );

  /// D major or B minor.
  static const dMajorBMinor = LiveMusicScale('D_MAJOR_B_MINOR');

  /// E-flat major or C minor.
  static const eFlatMajorCMinor = LiveMusicScale('E_FLAT_MAJOR_C_MINOR');

  /// E major or D-flat minor.
  static const eMajorDFlatMinor = LiveMusicScale('E_MAJOR_D_FLAT_MINOR');

  /// F major or D minor.
  static const fMajorDMinor = LiveMusicScale('F_MAJOR_D_MINOR');

  /// G-flat major or E-flat minor.
  static const gFlatMajorEFlatMinor = LiveMusicScale(
    'G_FLAT_MAJOR_E_FLAT_MINOR',
  );

  /// G major or E minor.
  static const gMajorEMinor = LiveMusicScale('G_MAJOR_E_MINOR');

  /// A-flat major or F minor.
  static const aFlatMajorFMinor = LiveMusicScale('A_FLAT_MAJOR_F_MINOR');

  /// A major or G-flat minor.
  static const aMajorGFlatMinor = LiveMusicScale('A_MAJOR_G_FLAT_MINOR');

  /// B-flat major or G minor.
  static const bFlatMajorGMinor = LiveMusicScale('B_FLAT_MAJOR_G_MINOR');

  /// B major or A-flat minor.
  static const bMajorAFlatMinor = LiveMusicScale('B_MAJOR_A_FLAT_MINOR');
}

/// How the model steers a prompt when generating music.
extension type const LiveMusicGenerationMode(String value) {
  /// Uses the model default.
  static const unspecified = LiveMusicGenerationMode(
    'MUSIC_GENERATION_MODE_UNSPECIFIED',
  );

  /// Prioritizes music quality.
  static const quality = LiveMusicGenerationMode('QUALITY');

  /// Prioritizes variety.
  static const diversity = LiveMusicGenerationMode('DIVERSITY');

  /// Favors music likely to contain vocals.
  static const vocalization = LiveMusicGenerationMode('VOCALIZATION');
}

/// An input prompt and its relative contribution to Live Music generation.
class LiveMusicWeightedPrompt {
  /// The prompt text.
  final String text;

  /// Relative prompt weight. The service normalizes the weights in a batch.
  final double weight;

  /// Creates a weighted prompt.
  const LiveMusicWeightedPrompt({required this.text, required this.weight});

  /// Parses a weighted prompt from its wire representation.
  factory LiveMusicWeightedPrompt.fromJson(Map<String, dynamic> json) {
    final text = json['text'];
    final weight = json['weight'];
    if (text is! String || weight is! num) {
      throw const FormatException('A music prompt requires text and weight.');
    }
    return LiveMusicWeightedPrompt(text: text, weight: weight.toDouble());
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'text': text, 'weight': weight};
}

/// Configuration for Lyria RealTime.
///
/// Each configuration message replaces the previous settings. Omitted fields
/// use the service defaults. Reset the session context after changing tempo or
/// scale to apply those changes.
class LiveMusicGenerationConfig {
  /// Sampling temperature, from 0 to 3.
  final double? temperature;

  /// Number of candidate tokens to sample from, from 1 to 1000.
  final int? topK;

  /// Optional seed used during generation.
  final int? seed;

  /// How closely generation follows prompts, from 0 to 6.
  final double? guidance;

  /// Beats per minute, from 60 to 200.
  final int? bpm;

  /// Density of sounds, from 0 to 1.
  final double? density;

  /// Brightness of the audio, from 0 to 1.
  final double? brightness;

  /// Musical scale.
  final LiveMusicScale? scale;

  /// Whether to suppress bass.
  final bool? muteBass;

  /// Whether to suppress drums.
  final bool? muteDrums;

  /// Whether to generate only bass and drums.
  final bool? onlyBassAndDrums;

  /// How to steer the prompt for music generation.
  final LiveMusicGenerationMode? musicGenerationMode;

  /// Creates a music configuration.
  const LiveMusicGenerationConfig({
    this.temperature,
    this.topK,
    this.seed,
    this.guidance,
    this.bpm,
    this.density,
    this.brightness,
    this.scale,
    this.muteBass,
    this.muteDrums,
    this.onlyBassAndDrums,
    this.musicGenerationMode,
  });

  /// Reads the music configuration from JSON.
  factory LiveMusicGenerationConfig.fromJson(Map<String, dynamic> json) {
    final scale = json['scale'] as String?;
    final mode = json['musicGenerationMode'] as String?;
    return LiveMusicGenerationConfig(
      temperature: (json['temperature'] as num?)?.toDouble(),
      topK: json['topK'] as int?,
      seed: json['seed'] as int?,
      guidance: (json['guidance'] as num?)?.toDouble(),
      bpm: json['bpm'] as int?,
      density: (json['density'] as num?)?.toDouble(),
      brightness: (json['brightness'] as num?)?.toDouble(),
      scale: scale == null ? null : LiveMusicScale(scale),
      muteBass: json['muteBass'] as bool?,
      muteDrums: json['muteDrums'] as bool?,
      onlyBassAndDrums: json['onlyBassAndDrums'] as bool?,
      musicGenerationMode: mode == null ? null : LiveMusicGenerationMode(mode),
    );
  }

  /// Converts fields supplied by the caller to JSON.
  Map<String, dynamic> toJson() => {
    'temperature': ?temperature,
    'topK': ?topK,
    'seed': ?seed,
    'guidance': ?guidance,
    'bpm': ?bpm,
    'density': ?density,
    'brightness': ?brightness,
    'scale': ?scale?.value,
    'muteBass': ?muteBass,
    'muteDrums': ?muteDrums,
    'onlyBassAndDrums': ?onlyBassAndDrums,
    'musicGenerationMode': ?musicGenerationMode?.value,
  };
}
