import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import 'deployment_paused_reason_error.dart';

// ============================================================================
// DeploymentPausedReason — sealed
// ============================================================================

/// Why a deployment is paused.
///
/// Non-null exactly when `status` is `paused`.
///
/// Variants:
/// - [ManualDeploymentPausedReason] — the caller invoked the pause endpoint
///   (type: "manual")
/// - [ErrorDeploymentPausedReason] — a failed run's error auto-paused the
///   deployment (type: "error")
/// - [UnrecognizedDeploymentPausedReason] — unrecognized type (preserves raw
///   JSON)
sealed class DeploymentPausedReason {
  const DeploymentPausedReason();

  /// Creates a [DeploymentPausedReason] from JSON.
  factory DeploymentPausedReason.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'manual' => ManualDeploymentPausedReason.fromJson(json),
      'error' => ErrorDeploymentPausedReason.fromJson(json),
      _ => UnrecognizedDeploymentPausedReason.fromJson(json),
    };
  }

  /// The type discriminator.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The caller invoked the pause endpoint on the deployment.
@immutable
class ManualDeploymentPausedReason extends DeploymentPausedReason {
  /// Creates a [ManualDeploymentPausedReason].
  const ManualDeploymentPausedReason();

  /// Creates a [ManualDeploymentPausedReason] from JSON.
  factory ManualDeploymentPausedReason.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'manual') {
      throw FormatException(
        'ManualDeploymentPausedReason: expected type "manual", got "$type"',
      );
    }
    return const ManualDeploymentPausedReason();
  }

  /// The type discriminator. Always `manual`.
  @override
  String get type => 'manual';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManualDeploymentPausedReason && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ManualDeploymentPausedReason(type: $type)';
}

/// A scheduled fire recorded a failed run whose error auto-pauses the
/// deployment.
@immutable
class ErrorDeploymentPausedReason extends DeploymentPausedReason {
  /// Creates an [ErrorDeploymentPausedReason].
  const ErrorDeploymentPausedReason({required this.error});

  /// Creates an [ErrorDeploymentPausedReason] from JSON.
  factory ErrorDeploymentPausedReason.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type != 'error') {
      throw FormatException(
        'ErrorDeploymentPausedReason: expected type "error", got "$type"',
      );
    }
    return ErrorDeploymentPausedReason(
      error: DeploymentPausedReasonError.fromJson(
        json['error'] as Map<String, dynamic>,
      ),
    );
  }

  /// The type discriminator. Always `error`.
  @override
  String get type => 'error';

  /// The failed run's error.
  final DeploymentPausedReasonError error;

  @override
  Map<String, dynamic> toJson() => {'type': type, 'error': error.toJson()};

  /// Creates a copy with replaced values.
  ErrorDeploymentPausedReason copyWith({DeploymentPausedReasonError? error}) =>
      ErrorDeploymentPausedReason(error: error ?? this.error);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorDeploymentPausedReason &&
          runtimeType == other.runtimeType &&
          error == other.error;

  @override
  int get hashCode => error.hashCode;

  @override
  String toString() =>
      'ErrorDeploymentPausedReason(type: $type, error: $error)';
}

/// Unrecognized deployment-paused-reason type (preserves raw JSON for forward
/// compatibility).
///
/// Returned by [DeploymentPausedReason.fromJson] when the `type` discriminator
/// does not match any known variant.
@immutable
class UnrecognizedDeploymentPausedReason extends DeploymentPausedReason {
  /// Creates an [UnrecognizedDeploymentPausedReason].
  const UnrecognizedDeploymentPausedReason({required this.rawJson});

  /// Creates an [UnrecognizedDeploymentPausedReason] from JSON.
  factory UnrecognizedDeploymentPausedReason.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnrecognizedDeploymentPausedReason(rawJson: json);
  }

  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// The type discriminator, read from the raw JSON if present.
  @override
  String get type => rawJson['type'] as String? ?? 'unrecognized';

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnrecognizedDeploymentPausedReason &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnrecognizedDeploymentPausedReason(rawJson: $rawJson)';
}
