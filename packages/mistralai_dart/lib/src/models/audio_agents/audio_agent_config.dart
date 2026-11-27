import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'audio_agent_tools.dart';

/// The AudioAgentConfigurationRequest wire payload.
@immutable
class AudioAgentConfiguration {
  /// Creates a [AudioAgentConfiguration].
  const AudioAgentConfiguration({
    this.instructions,
    this.llm,
    this.stt,
    this.tools,
    this.tts,
    this.turn,
    this.welcomeMessage,
  });

  /// The instructions field.
  final String? instructions;

  /// The llm field.
  final AudioLlmConfig? llm;

  /// The stt field.
  final AudioSttConfig? stt;

  /// The tools field.
  final List<VoiceAgentTool>? tools;

  /// The tts field.
  final AudioTtsConfig? tts;

  /// The turn field.
  final AudioTurnConfig? turn;

  /// The welcome_message field.
  final String? welcomeMessage;

  /// Parses a [AudioAgentConfiguration] from JSON.
  factory AudioAgentConfiguration.fromJson(Map<String, dynamic> json) {
    return AudioAgentConfiguration(
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      llm: json['llm'] == null
          ? null
          : AudioLlmConfig.fromJson(json['llm'] as Map<String, dynamic>),
      stt: json['stt'] == null
          ? null
          : AudioSttConfig.fromJson(json['stt'] as Map<String, dynamic>),
      tools: json['tools'] == null
          ? null
          : (json['tools'] as List)
                .map(
                  (item) =>
                      VoiceAgentTool.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      tts: json['tts'] == null
          ? null
          : AudioTtsConfig.fromJson(json['tts'] as Map<String, dynamic>),
      turn: json['turn'] == null
          ? null
          : AudioTurnConfig.fromJson(json['turn'] as Map<String, dynamic>),
      welcomeMessage: json['welcome_message'] == null
          ? null
          : json['welcome_message'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'instructions': ?instructions,
    if (llm != null) 'llm': llm!.toJson(),
    if (stt != null) 'stt': stt!.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
    if (tts != null) 'tts': tts!.toJson(),
    if (turn != null) 'turn': turn!.toJson(),
    'welcome_message': ?welcomeMessage,
  };

  /// Creates a copy with the given fields replaced.
  AudioAgentConfiguration copyWith({
    Object? instructions = unsetCopyWithValue,
    Object? llm = unsetCopyWithValue,
    Object? stt = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? tts = unsetCopyWithValue,
    Object? turn = unsetCopyWithValue,
    Object? welcomeMessage = unsetCopyWithValue,
  }) => AudioAgentConfiguration(
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    llm: llm == unsetCopyWithValue ? this.llm : llm as AudioLlmConfig?,
    stt: stt == unsetCopyWithValue ? this.stt : stt as AudioSttConfig?,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List?)?.cast<VoiceAgentTool>(),
    tts: tts == unsetCopyWithValue ? this.tts : tts as AudioTtsConfig?,
    turn: turn == unsetCopyWithValue ? this.turn : turn as AudioTurnConfig?,
    welcomeMessage: welcomeMessage == unsetCopyWithValue
        ? this.welcomeMessage
        : welcomeMessage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAgentConfiguration &&
          runtimeType == other.runtimeType &&
          instructions == other.instructions &&
          llm == other.llm &&
          stt == other.stt &&
          valuesDeepEqual(tools, other.tools) &&
          tts == other.tts &&
          turn == other.turn &&
          welcomeMessage == other.welcomeMessage;

  @override
  int get hashCode => Object.hashAll([
    instructions,
    llm,
    stt,
    valueDeepHashCode(tools),
    tts,
    turn,
    welcomeMessage,
  ]);

  @override
  String toString() =>
      'AudioAgentConfiguration('
      'instructions: $instructions, '
      'llm: $llm, '
      'stt: $stt, '
      'tools: ${tools?.length}, '
      'tts: $tts, '
      'turn: $turn, '
      'welcomeMessage: $welcomeMessage)';
}

/// The AudioAgentConfigurationResponseConfig wire payload.
@immutable
class AudioAgentConfigurationSnapshot {
  /// Creates a [AudioAgentConfigurationSnapshot].
  const AudioAgentConfigurationSnapshot({
    this.instructions,
    required this.llm,
    required this.stt,
    this.tools,
    required this.tts,
    required this.turn,
    this.welcomeMessage,
  });

  /// The instructions field.
  final String? instructions;

  /// The llm field.
  final AudioLlmConfig llm;

  /// The stt field.
  final AudioSttConfig stt;

  /// The tools field.
  final List<VoiceAgentTool>? tools;

  /// The tts field.
  final AudioTtsConfig tts;

  /// The turn field.
  final AudioTurnConfig turn;

  /// The welcome_message field.
  final String? welcomeMessage;

  /// Parses a [AudioAgentConfigurationSnapshot] from JSON.
  factory AudioAgentConfigurationSnapshot.fromJson(Map<String, dynamic> json) {
    if (json['llm'] == null) {
      throw const FormatException(
        'AudioAgentConfigurationSnapshot: missing llm',
      );
    }
    if (json['stt'] == null) {
      throw const FormatException(
        'AudioAgentConfigurationSnapshot: missing stt',
      );
    }
    if (json['tts'] == null) {
      throw const FormatException(
        'AudioAgentConfigurationSnapshot: missing tts',
      );
    }
    if (json['turn'] == null) {
      throw const FormatException(
        'AudioAgentConfigurationSnapshot: missing turn',
      );
    }
    return AudioAgentConfigurationSnapshot(
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
      llm: AudioLlmConfig.fromJson(json['llm'] as Map<String, dynamic>),
      stt: AudioSttConfig.fromJson(json['stt'] as Map<String, dynamic>),
      tools: json['tools'] == null
          ? null
          : (json['tools'] as List)
                .map(
                  (item) =>
                      VoiceAgentTool.fromJson(item as Map<String, dynamic>),
                )
                .toList(),
      tts: AudioTtsConfig.fromJson(json['tts'] as Map<String, dynamic>),
      turn: AudioTurnConfig.fromJson(json['turn'] as Map<String, dynamic>),
      welcomeMessage: json['welcome_message'] == null
          ? null
          : json['welcome_message'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'instructions': ?instructions,
    'llm': llm.toJson(),
    'stt': stt.toJson(),
    if (tools != null) 'tools': tools!.map((item) => item.toJson()).toList(),
    'tts': tts.toJson(),
    'turn': turn.toJson(),
    'welcome_message': ?welcomeMessage,
  };

  /// Creates a copy with the given fields replaced.
  AudioAgentConfigurationSnapshot copyWith({
    Object? instructions = unsetCopyWithValue,
    AudioLlmConfig? llm,
    AudioSttConfig? stt,
    Object? tools = unsetCopyWithValue,
    AudioTtsConfig? tts,
    AudioTurnConfig? turn,
    Object? welcomeMessage = unsetCopyWithValue,
  }) => AudioAgentConfigurationSnapshot(
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
    llm: llm ?? this.llm,
    stt: stt ?? this.stt,
    tools: tools == unsetCopyWithValue
        ? this.tools
        : (tools as List?)?.cast<VoiceAgentTool>(),
    tts: tts ?? this.tts,
    turn: turn ?? this.turn,
    welcomeMessage: welcomeMessage == unsetCopyWithValue
        ? this.welcomeMessage
        : welcomeMessage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAgentConfigurationSnapshot &&
          runtimeType == other.runtimeType &&
          instructions == other.instructions &&
          llm == other.llm &&
          stt == other.stt &&
          valuesDeepEqual(tools, other.tools) &&
          tts == other.tts &&
          turn == other.turn &&
          welcomeMessage == other.welcomeMessage;

  @override
  int get hashCode => Object.hashAll([
    instructions,
    llm,
    stt,
    valueDeepHashCode(tools),
    tts,
    turn,
    welcomeMessage,
  ]);

  @override
  String toString() =>
      'AudioAgentConfigurationSnapshot('
      'instructions: $instructions, '
      'llm: $llm, '
      'stt: $stt, '
      'tools: ${tools?.length}, '
      'tts: $tts, '
      'turn: $turn, '
      'welcomeMessage: $welcomeMessage)';
}

/// The AudioLLMConfig wire payload.
@immutable
class AudioLlmConfig {
  /// Creates a [AudioLlmConfig].
  const AudioLlmConfig({this.model});

  /// The model field.
  final String? model;

  /// Parses a [AudioLlmConfig] from JSON.
  factory AudioLlmConfig.fromJson(Map<String, dynamic> json) {
    return AudioLlmConfig(
      model: json['model'] == null ? null : json['model'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'model': ?model};

  /// Creates a copy with the given fields replaced.
  AudioLlmConfig copyWith({Object? model = unsetCopyWithValue}) =>
      AudioLlmConfig(
        model: model == unsetCopyWithValue ? this.model : model as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioLlmConfig &&
          runtimeType == other.runtimeType &&
          model == other.model;

  @override
  int get hashCode => Object.hashAll([model]);

  @override
  String toString() =>
      'AudioLlmConfig('
      'model: $model)';
}

/// The AudioSTTConfig wire payload.
@immutable
class AudioSttConfig {
  /// Creates a [AudioSttConfig].
  const AudioSttConfig({
    this.contextBias,
    this.language,
    this.model,
    this.targetStreamingDelayMs,
    this.turnDetection,
  });

  /// The context_bias field.
  final List<String>? contextBias;

  /// The language field.
  final String? language;

  /// The model field.
  final String? model;

  /// The target_streaming_delay_ms field.
  final int? targetStreamingDelayMs;

  /// The turn_detection field.
  final AudioTurnDetectionConfig? turnDetection;

  /// Parses a [AudioSttConfig] from JSON.
  factory AudioSttConfig.fromJson(Map<String, dynamic> json) {
    return AudioSttConfig(
      contextBias: json['context_bias'] == null
          ? null
          : (json['context_bias'] as List)
                .map((item) => item as String)
                .toList(),
      language: json['language'] == null ? null : json['language'] as String,
      model: json['model'] == null ? null : json['model'] as String,
      targetStreamingDelayMs: json['target_streaming_delay_ms'] == null
          ? null
          : json['target_streaming_delay_ms'] as int,
      turnDetection: json['turn_detection'] == null
          ? null
          : AudioTurnDetectionConfig.fromJson(
              json['turn_detection'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'context_bias': ?contextBias,
    'language': ?language,
    'model': ?model,
    'target_streaming_delay_ms': ?targetStreamingDelayMs,
    if (turnDetection != null) 'turn_detection': turnDetection!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AudioSttConfig copyWith({
    Object? contextBias = unsetCopyWithValue,
    Object? language = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? targetStreamingDelayMs = unsetCopyWithValue,
    Object? turnDetection = unsetCopyWithValue,
  }) => AudioSttConfig(
    contextBias: contextBias == unsetCopyWithValue
        ? this.contextBias
        : (contextBias as List?)?.cast<String>(),
    language: language == unsetCopyWithValue
        ? this.language
        : language as String?,
    model: model == unsetCopyWithValue ? this.model : model as String?,
    targetStreamingDelayMs: targetStreamingDelayMs == unsetCopyWithValue
        ? this.targetStreamingDelayMs
        : targetStreamingDelayMs as int?,
    turnDetection: turnDetection == unsetCopyWithValue
        ? this.turnDetection
        : turnDetection as AudioTurnDetectionConfig?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioSttConfig &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(contextBias, other.contextBias) &&
          language == other.language &&
          model == other.model &&
          targetStreamingDelayMs == other.targetStreamingDelayMs &&
          turnDetection == other.turnDetection;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(contextBias),
    language,
    model,
    targetStreamingDelayMs,
    turnDetection,
  ]);

  @override
  String toString() =>
      'AudioSttConfig('
      'contextBias: ${contextBias?.length}, '
      'language: $language, '
      'model: $model, '
      'targetStreamingDelayMs: $targetStreamingDelayMs, '
      'turnDetection: $turnDetection)';
}

/// The AudioTTSConfig wire payload.
@immutable
class AudioTtsConfig {
  /// Creates a [AudioTtsConfig].
  const AudioTtsConfig({this.expressiveness, this.model, this.voiceId});

  /// The expressiveness field.
  final double? expressiveness;

  /// The model field.
  final String? model;

  /// The voice_id field.
  final String? voiceId;

  /// Parses a [AudioTtsConfig] from JSON.
  factory AudioTtsConfig.fromJson(Map<String, dynamic> json) {
    return AudioTtsConfig(
      expressiveness: json['expressiveness'] == null
          ? null
          : (json['expressiveness'] as num).toDouble(),
      model: json['model'] == null ? null : json['model'] as String,
      voiceId: json['voice_id'] == null ? null : json['voice_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'expressiveness': ?expressiveness,
    'model': ?model,
    'voice_id': ?voiceId,
  };

  /// Creates a copy with the given fields replaced.
  AudioTtsConfig copyWith({
    Object? expressiveness = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? voiceId = unsetCopyWithValue,
  }) => AudioTtsConfig(
    expressiveness: expressiveness == unsetCopyWithValue
        ? this.expressiveness
        : (expressiveness as num?)?.toDouble(),
    model: model == unsetCopyWithValue ? this.model : model as String?,
    voiceId: voiceId == unsetCopyWithValue ? this.voiceId : voiceId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTtsConfig &&
          runtimeType == other.runtimeType &&
          expressiveness == other.expressiveness &&
          model == other.model &&
          voiceId == other.voiceId;

  @override
  int get hashCode => Object.hashAll([expressiveness, model, voiceId]);

  @override
  String toString() =>
      'AudioTtsConfig('
      'expressiveness: $expressiveness, '
      'model: $model, '
      'voiceId: $voiceId)';
}

/// The AudioTurnConfig wire payload.
@immutable
class AudioTurnConfig {
  /// Creates a [AudioTurnConfig].
  const AudioTurnConfig({this.allowInterruptions, this.inactivity});

  /// The allow_interruptions field.
  final bool? allowInterruptions;

  /// The inactivity field.
  final AudioInactivityConfig? inactivity;

  /// Parses a [AudioTurnConfig] from JSON.
  factory AudioTurnConfig.fromJson(Map<String, dynamic> json) {
    return AudioTurnConfig(
      allowInterruptions: json['allow_interruptions'] == null
          ? null
          : json['allow_interruptions'] as bool,
      inactivity: json['inactivity'] == null
          ? null
          : AudioInactivityConfig.fromJson(
              json['inactivity'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'allow_interruptions': ?allowInterruptions,
    if (inactivity != null) 'inactivity': inactivity!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AudioTurnConfig copyWith({
    Object? allowInterruptions = unsetCopyWithValue,
    Object? inactivity = unsetCopyWithValue,
  }) => AudioTurnConfig(
    allowInterruptions: allowInterruptions == unsetCopyWithValue
        ? this.allowInterruptions
        : allowInterruptions as bool?,
    inactivity: inactivity == unsetCopyWithValue
        ? this.inactivity
        : inactivity as AudioInactivityConfig?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTurnConfig &&
          runtimeType == other.runtimeType &&
          allowInterruptions == other.allowInterruptions &&
          inactivity == other.inactivity;

  @override
  int get hashCode => Object.hashAll([allowInterruptions, inactivity]);

  @override
  String toString() =>
      'AudioTurnConfig('
      'allowInterruptions: $allowInterruptions, '
      'inactivity: $inactivity)';
}

/// The AudioTurnDetectionConfig wire payload.
@immutable
class AudioTurnDetectionConfig {
  /// Creates a [AudioTurnDetectionConfig].
  const AudioTurnDetectionConfig({
    this.eagerEndThreshold,
    this.endThreshold,
    this.endTimeoutMs,
    this.minSilenceMs,
    this.startThreshold,
  });

  /// The eager_end_threshold field.
  final double? eagerEndThreshold;

  /// The end_threshold field.
  final double? endThreshold;

  /// The end_timeout_ms field.
  final int? endTimeoutMs;

  /// The min_silence_ms field.
  final int? minSilenceMs;

  /// The start_threshold field.
  final double? startThreshold;

  /// Parses a [AudioTurnDetectionConfig] from JSON.
  factory AudioTurnDetectionConfig.fromJson(Map<String, dynamic> json) {
    return AudioTurnDetectionConfig(
      eagerEndThreshold: json['eager_end_threshold'] == null
          ? null
          : (json['eager_end_threshold'] as num).toDouble(),
      endThreshold: json['end_threshold'] == null
          ? null
          : (json['end_threshold'] as num).toDouble(),
      endTimeoutMs: json['end_timeout_ms'] == null
          ? null
          : json['end_timeout_ms'] as int,
      minSilenceMs: json['min_silence_ms'] == null
          ? null
          : json['min_silence_ms'] as int,
      startThreshold: json['start_threshold'] == null
          ? null
          : (json['start_threshold'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'eager_end_threshold': ?eagerEndThreshold,
    'end_threshold': ?endThreshold,
    'end_timeout_ms': ?endTimeoutMs,
    'min_silence_ms': ?minSilenceMs,
    'start_threshold': ?startThreshold,
  };

  /// Creates a copy with the given fields replaced.
  AudioTurnDetectionConfig copyWith({
    Object? eagerEndThreshold = unsetCopyWithValue,
    Object? endThreshold = unsetCopyWithValue,
    Object? endTimeoutMs = unsetCopyWithValue,
    Object? minSilenceMs = unsetCopyWithValue,
    Object? startThreshold = unsetCopyWithValue,
  }) => AudioTurnDetectionConfig(
    eagerEndThreshold: eagerEndThreshold == unsetCopyWithValue
        ? this.eagerEndThreshold
        : (eagerEndThreshold as num?)?.toDouble(),
    endThreshold: endThreshold == unsetCopyWithValue
        ? this.endThreshold
        : (endThreshold as num?)?.toDouble(),
    endTimeoutMs: endTimeoutMs == unsetCopyWithValue
        ? this.endTimeoutMs
        : endTimeoutMs as int?,
    minSilenceMs: minSilenceMs == unsetCopyWithValue
        ? this.minSilenceMs
        : minSilenceMs as int?,
    startThreshold: startThreshold == unsetCopyWithValue
        ? this.startThreshold
        : (startThreshold as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioTurnDetectionConfig &&
          runtimeType == other.runtimeType &&
          eagerEndThreshold == other.eagerEndThreshold &&
          endThreshold == other.endThreshold &&
          endTimeoutMs == other.endTimeoutMs &&
          minSilenceMs == other.minSilenceMs &&
          startThreshold == other.startThreshold;

  @override
  int get hashCode => Object.hashAll([
    eagerEndThreshold,
    endThreshold,
    endTimeoutMs,
    minSilenceMs,
    startThreshold,
  ]);

  @override
  String toString() =>
      'AudioTurnDetectionConfig('
      'eagerEndThreshold: $eagerEndThreshold, '
      'endThreshold: $endThreshold, '
      'endTimeoutMs: $endTimeoutMs, '
      'minSilenceMs: $minSilenceMs, '
      'startThreshold: $startThreshold)';
}

/// The AudioInactivityConfig wire payload.
@immutable
class AudioInactivityConfig {
  /// Creates a [AudioInactivityConfig].
  const AudioInactivityConfig({
    required this.maxReminders,
    this.messages,
    required this.timeoutMs,
  });

  /// The max_reminders field.
  final int maxReminders;

  /// The messages field.
  final List<String>? messages;

  /// The timeout_ms field.
  final int timeoutMs;

  /// Parses a [AudioInactivityConfig] from JSON.
  factory AudioInactivityConfig.fromJson(Map<String, dynamic> json) {
    if (json['max_reminders'] == null) {
      throw const FormatException(
        'AudioInactivityConfig: missing max_reminders',
      );
    }
    if (json['timeout_ms'] == null) {
      throw const FormatException('AudioInactivityConfig: missing timeout_ms');
    }
    return AudioInactivityConfig(
      maxReminders: json['max_reminders'] as int,
      messages: json['messages'] == null
          ? null
          : (json['messages'] as List).map((item) => item as String).toList(),
      timeoutMs: json['timeout_ms'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'max_reminders': maxReminders,
    'messages': ?messages,
    'timeout_ms': timeoutMs,
  };

  /// Creates a copy with the given fields replaced.
  AudioInactivityConfig copyWith({
    int? maxReminders,
    Object? messages = unsetCopyWithValue,
    int? timeoutMs,
  }) => AudioInactivityConfig(
    maxReminders: maxReminders ?? this.maxReminders,
    messages: messages == unsetCopyWithValue
        ? this.messages
        : (messages as List?)?.cast<String>(),
    timeoutMs: timeoutMs ?? this.timeoutMs,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioInactivityConfig &&
          runtimeType == other.runtimeType &&
          maxReminders == other.maxReminders &&
          valuesDeepEqual(messages, other.messages) &&
          timeoutMs == other.timeoutMs;

  @override
  int get hashCode =>
      Object.hashAll([maxReminders, valueDeepHashCode(messages), timeoutMs]);

  @override
  String toString() =>
      'AudioInactivityConfig('
      'maxReminders: $maxReminders, '
      'messages: ${messages?.length}, '
      'timeoutMs: $timeoutMs)';
}
