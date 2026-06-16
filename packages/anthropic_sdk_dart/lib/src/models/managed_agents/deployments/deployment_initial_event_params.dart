import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../events/send_event_params.dart'
    show
        SystemMessageEventParams,
        UserDefineOutcomeEventParams,
        UserMessageEventParams;

/// An event sent to a session immediately after it is created (create side).
///
/// Supports `user.message`, `user.define_outcome`, and `system.message`. This
/// is a narrowed view of the broader `EventParams` union: the API accepts only
/// these three event types as deployment initial events, so the variants below
/// wrap the existing param classes rather than duplicating them.
///
/// Variants:
/// - [DeploymentUserMessageEventParams] — wraps [UserMessageEventParams]
///   (type: "user.message")
/// - [DeploymentUserDefineOutcomeEventParams] — wraps
///   [UserDefineOutcomeEventParams] (type: "user.define_outcome")
/// - [DeploymentSystemMessageEventParams] — wraps [SystemMessageEventParams]
///   (type: "system.message")
/// - [UnknownDeploymentInitialEventParams] — Unrecognized type (preserves raw
///   JSON)
sealed class DeploymentInitialEventParams {
  const DeploymentInitialEventParams();

  /// Creates a [DeploymentInitialEventParams] from JSON.
  factory DeploymentInitialEventParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'user.message' => DeploymentUserMessageEventParams(
        UserMessageEventParams.fromJson(json),
      ),
      'user.define_outcome' => DeploymentUserDefineOutcomeEventParams(
        UserDefineOutcomeEventParams.fromJson(json),
      ),
      'system.message' => DeploymentSystemMessageEventParams(
        SystemMessageEventParams.fromJson(json),
      ),
      _ => UnknownDeploymentInitialEventParams(rawJson: json),
    };
  }

  /// Wraps a [UserMessageEventParams] as a deployment initial event.
  const factory DeploymentInitialEventParams.userMessage(
    UserMessageEventParams params,
  ) = DeploymentUserMessageEventParams;

  /// Wraps a [UserDefineOutcomeEventParams] as a deployment initial event.
  const factory DeploymentInitialEventParams.userDefineOutcome(
    UserDefineOutcomeEventParams params,
  ) = DeploymentUserDefineOutcomeEventParams;

  /// Wraps a [SystemMessageEventParams] as a deployment initial event.
  const factory DeploymentInitialEventParams.systemMessage(
    SystemMessageEventParams params,
  ) = DeploymentSystemMessageEventParams;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A `user.message` deployment initial event, wrapping a
/// [UserMessageEventParams].
@immutable
class DeploymentUserMessageEventParams extends DeploymentInitialEventParams {
  /// The wrapped user message params.
  final UserMessageEventParams params;

  /// Creates a [DeploymentUserMessageEventParams].
  const DeploymentUserMessageEventParams(this.params);

  @override
  Map<String, dynamic> toJson() => params.toJson();

  /// Creates a copy with replaced values.
  DeploymentUserMessageEventParams copyWith({UserMessageEventParams? params}) {
    return DeploymentUserMessageEventParams(params ?? this.params);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentUserMessageEventParams &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  String toString() => 'DeploymentUserMessageEventParams(params: $params)';
}

/// A `user.define_outcome` deployment initial event, wrapping a
/// [UserDefineOutcomeEventParams].
@immutable
class DeploymentUserDefineOutcomeEventParams
    extends DeploymentInitialEventParams {
  /// The wrapped define-outcome params.
  final UserDefineOutcomeEventParams params;

  /// Creates a [DeploymentUserDefineOutcomeEventParams].
  const DeploymentUserDefineOutcomeEventParams(this.params);

  @override
  Map<String, dynamic> toJson() => params.toJson();

  /// Creates a copy with replaced values.
  DeploymentUserDefineOutcomeEventParams copyWith({
    UserDefineOutcomeEventParams? params,
  }) {
    return DeploymentUserDefineOutcomeEventParams(params ?? this.params);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentUserDefineOutcomeEventParams &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  String toString() =>
      'DeploymentUserDefineOutcomeEventParams(params: $params)';
}

/// A `system.message` deployment initial event, wrapping a
/// [SystemMessageEventParams].
@immutable
class DeploymentSystemMessageEventParams extends DeploymentInitialEventParams {
  /// The wrapped system message params.
  final SystemMessageEventParams params;

  /// Creates a [DeploymentSystemMessageEventParams].
  const DeploymentSystemMessageEventParams(this.params);

  @override
  Map<String, dynamic> toJson() => params.toJson();

  /// Creates a copy with replaced values.
  DeploymentSystemMessageEventParams copyWith({
    SystemMessageEventParams? params,
  }) {
    return DeploymentSystemMessageEventParams(params ?? this.params);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentSystemMessageEventParams &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  String toString() => 'DeploymentSystemMessageEventParams(params: $params)';
}

/// Unrecognized deployment initial event params (preserves raw JSON).
@immutable
class UnknownDeploymentInitialEventParams extends DeploymentInitialEventParams {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownDeploymentInitialEventParams].
  const UnknownDeploymentInitialEventParams({required this.rawJson});

  /// Creates an [UnknownDeploymentInitialEventParams] from JSON.
  factory UnknownDeploymentInitialEventParams.fromJson(
    Map<String, dynamic> json,
  ) {
    return UnknownDeploymentInitialEventParams(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownDeploymentInitialEventParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownDeploymentInitialEventParams(rawJson: $rawJson)';
}
