import '../../copy_with_sentinel.dart';
import '../enums/activity_handling.dart';
import '../enums/turn_coverage.dart';
import 'automatic_activity_detection.dart';

/// Configuration for real-time input handling.
///
/// Controls voice activity detection, interruption behavior, and turn coverage.
class RealtimeInputConfig {
  /// Automatic voice activity detection configuration.
  final AutomaticActivityDetection? automaticActivityDetection;

  /// How user activity affects model output.
  final ActivityHandling? activityHandling;

  /// How much input is included in a turn.
  final TurnCoverage? turnCoverage;

  /// Whether to include timestamps on supported interim transcripts.
  final bool? interimTranscriptTimestampEnabled;

  /// Creates a [RealtimeInputConfig].
  const RealtimeInputConfig({
    this.automaticActivityDetection,
    this.activityHandling,
    this.turnCoverage,
    this.interimTranscriptTimestampEnabled,
  });

  /// Creates a configuration with automatic VAD and interruption enabled.
  factory RealtimeInputConfig.withVAD({
    int? silenceDurationMs,
    ActivityHandling activityHandling =
        ActivityHandling.startOfActivityInterrupts,
    bool? interimTranscriptTimestampEnabled,
  }) {
    return RealtimeInputConfig(
      automaticActivityDetection: AutomaticActivityDetection.enabled(
        silenceDurationMs: silenceDurationMs,
      ),
      activityHandling: activityHandling,
      interimTranscriptTimestampEnabled: interimTranscriptTimestampEnabled,
    );
  }

  /// Creates a configuration for manual VAD mode.
  factory RealtimeInputConfig.manual({
    ActivityHandling activityHandling = ActivityHandling.noInterruption,
    bool? interimTranscriptTimestampEnabled,
  }) {
    return RealtimeInputConfig(
      automaticActivityDetection: AutomaticActivityDetection.manual(),
      activityHandling: activityHandling,
      interimTranscriptTimestampEnabled: interimTranscriptTimestampEnabled,
    );
  }

  /// Creates from JSON.
  factory RealtimeInputConfig.fromJson(Map<String, dynamic> json) {
    return RealtimeInputConfig(
      automaticActivityDetection: json['automaticActivityDetection'] != null
          ? AutomaticActivityDetection.fromJson(
              json['automaticActivityDetection'] as Map<String, dynamic>,
            )
          : null,
      activityHandling: json['activityHandling'] != null
          ? ActivityHandling.fromJson(json['activityHandling'] as String)
          : null,
      turnCoverage: json['turnCoverage'] != null
          ? TurnCoverage.fromJson(json['turnCoverage'] as String)
          : null,
      interimTranscriptTimestampEnabled:
          json['interimTranscriptTimestampEnabled'] as bool?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (automaticActivityDetection != null)
      'automaticActivityDetection': automaticActivityDetection!.toJson(),
    if (activityHandling != null)
      'activityHandling': activityHandling!.toJson(),
    if (turnCoverage != null) 'turnCoverage': turnCoverage!.toJson(),
    if (interimTranscriptTimestampEnabled != null)
      'interimTranscriptTimestampEnabled': interimTranscriptTimestampEnabled,
  };

  /// Creates a copy with the given fields replaced.
  RealtimeInputConfig copyWith({
    AutomaticActivityDetection? automaticActivityDetection,
    ActivityHandling? activityHandling,
    TurnCoverage? turnCoverage,
    Object? interimTranscriptTimestampEnabled = unsetCopyWithValue,
  }) {
    return RealtimeInputConfig(
      automaticActivityDetection:
          automaticActivityDetection ?? this.automaticActivityDetection,
      activityHandling: activityHandling ?? this.activityHandling,
      turnCoverage: turnCoverage ?? this.turnCoverage,
      interimTranscriptTimestampEnabled:
          interimTranscriptTimestampEnabled == unsetCopyWithValue
          ? this.interimTranscriptTimestampEnabled
          : interimTranscriptTimestampEnabled as bool?,
    );
  }

  @override
  String toString() =>
      'RealtimeInputConfig(activityHandling: $activityHandling, '
      'turnCoverage: $turnCoverage, interimTranscriptTimestampEnabled: '
      '$interimTranscriptTimestampEnabled)';
}
