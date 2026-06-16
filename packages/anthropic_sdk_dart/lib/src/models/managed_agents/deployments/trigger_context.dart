import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/equality_helpers.dart';

/// Describes what triggered a deployment run, with trigger-specific metadata.
///
/// Discriminated union.
///
/// Variants:
/// - [ScheduleTriggerContext] — Fired by the cron schedule (type: "schedule")
/// - [ManualTriggerContext] — Started manually (type: "manual")
/// - [UnknownTriggerContext] — Unrecognized type (preserves raw JSON)
sealed class TriggerContext {
  const TriggerContext();

  /// Creates a [TriggerContext] from JSON.
  factory TriggerContext.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'schedule' => ScheduleTriggerContext.fromJson(json),
      'manual' => ManualTriggerContext.fromJson(json),
      _ => UnknownTriggerContext.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The run was fired by the deployment's cron schedule.
@immutable
class ScheduleTriggerContext extends TriggerContext {
  /// The type discriminator. Always `schedule`.
  final String type;

  /// The UTC instant at which the cron expression matched in the configured
  /// timezone, before jitter is applied.
  ///
  /// At most one run is recorded per (deployment_id, scheduled_at) pair.
  final BetaTimestamp scheduledAt;

  /// Creates a [ScheduleTriggerContext].
  const ScheduleTriggerContext({
    this.type = 'schedule',
    required this.scheduledAt,
  });

  /// Creates a [ScheduleTriggerContext] from JSON.
  factory ScheduleTriggerContext.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'schedule';
    if (type != 'schedule') {
      throw FormatException(
        'ScheduleTriggerContext: expected type "schedule", got "$type"',
      );
    }
    return ScheduleTriggerContext(
      type: type,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'scheduled_at': scheduledAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  ScheduleTriggerContext copyWith({String? type, BetaTimestamp? scheduledAt}) {
    return ScheduleTriggerContext(
      type: type ?? this.type,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduleTriggerContext &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          scheduledAt == other.scheduledAt;

  @override
  int get hashCode => Object.hash(type, scheduledAt);

  @override
  String toString() =>
      'ScheduleTriggerContext(type: $type, scheduledAt: $scheduledAt)';
}

/// The run was started manually by creating a session directly against the
/// deployment.
@immutable
class ManualTriggerContext extends TriggerContext {
  /// The type discriminator. Always `manual`.
  final String type;

  /// Creates a [ManualTriggerContext].
  const ManualTriggerContext({this.type = 'manual'});

  /// Creates a [ManualTriggerContext] from JSON.
  factory ManualTriggerContext.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'manual';
    if (type != 'manual') {
      throw FormatException(
        'ManualTriggerContext: expected type "manual", got "$type"',
      );
    }
    return ManualTriggerContext(type: type);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  /// Creates a copy with replaced values.
  ManualTriggerContext copyWith({String? type}) {
    return ManualTriggerContext(type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManualTriggerContext &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ManualTriggerContext(type: $type)';
}

/// Unrecognized trigger context type (preserves raw JSON).
@immutable
class UnknownTriggerContext extends TriggerContext {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownTriggerContext].
  const UnknownTriggerContext({required this.rawJson});

  /// Creates an [UnknownTriggerContext] from JSON.
  factory UnknownTriggerContext.fromJson(Map<String, dynamic> json) {
    return UnknownTriggerContext(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownTriggerContext &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownTriggerContext(rawJson: $rawJson)';
}
