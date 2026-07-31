import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../events/send_event_params.dart'
    show UserDefineOutcomeEventParams, UserMessageEventParams;

/// An event sent to a session immediately after it is created (create side).
///
/// Supports `user.message` and `user.define_outcome`. This is a narrowed view
/// of the broader `EventParams` union: the API accepts only these two event
/// types as session initial events, so the variants below wrap the existing
/// param classes rather than duplicating them.
///
/// Variants:
/// - [SessionUserMessageEventParams] — wraps [UserMessageEventParams]
///   (type: "user.message")
/// - [SessionUserDefineOutcomeEventParams] — wraps
///   [UserDefineOutcomeEventParams] (type: "user.define_outcome")
/// - [UnknownSessionInitialEventParams] — Unrecognized type (preserves raw
///   JSON)
sealed class SessionInitialEventParams {
  const SessionInitialEventParams();

  /// Creates a [SessionInitialEventParams] from JSON.
  factory SessionInitialEventParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'user.message' => SessionUserMessageEventParams(
        UserMessageEventParams.fromJson(json),
      ),
      'user.define_outcome' => SessionUserDefineOutcomeEventParams(
        UserDefineOutcomeEventParams.fromJson(json),
      ),
      _ => UnknownSessionInitialEventParams(rawJson: json),
    };
  }

  /// Wraps a [UserMessageEventParams] as a session initial event.
  const factory SessionInitialEventParams.userMessage(
    UserMessageEventParams params,
  ) = SessionUserMessageEventParams;

  /// Wraps a [UserDefineOutcomeEventParams] as a session initial event.
  const factory SessionInitialEventParams.userDefineOutcome(
    UserDefineOutcomeEventParams params,
  ) = SessionUserDefineOutcomeEventParams;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A `user.message` session initial event, wrapping a
/// [UserMessageEventParams].
@immutable
class SessionUserMessageEventParams extends SessionInitialEventParams {
  /// The wrapped user message params.
  final UserMessageEventParams params;

  /// Creates a [SessionUserMessageEventParams].
  const SessionUserMessageEventParams(this.params);

  @override
  Map<String, dynamic> toJson() => params.toJson();

  /// Creates a copy with replaced values.
  SessionUserMessageEventParams copyWith({UserMessageEventParams? params}) {
    return SessionUserMessageEventParams(params ?? this.params);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUserMessageEventParams &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  String toString() => 'SessionUserMessageEventParams(params: $params)';
}

/// A `user.define_outcome` session initial event, wrapping a
/// [UserDefineOutcomeEventParams].
@immutable
class SessionUserDefineOutcomeEventParams extends SessionInitialEventParams {
  /// The wrapped define-outcome params.
  final UserDefineOutcomeEventParams params;

  /// Creates a [SessionUserDefineOutcomeEventParams].
  const SessionUserDefineOutcomeEventParams(this.params);

  @override
  Map<String, dynamic> toJson() => params.toJson();

  /// Creates a copy with replaced values.
  SessionUserDefineOutcomeEventParams copyWith({
    UserDefineOutcomeEventParams? params,
  }) {
    return SessionUserDefineOutcomeEventParams(params ?? this.params);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionUserDefineOutcomeEventParams &&
          runtimeType == other.runtimeType &&
          params == other.params;

  @override
  int get hashCode => params.hashCode;

  @override
  String toString() => 'SessionUserDefineOutcomeEventParams(params: $params)';
}

/// Unrecognized session initial event params (preserves raw JSON).
@immutable
class UnknownSessionInitialEventParams extends SessionInitialEventParams {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSessionInitialEventParams].
  const UnknownSessionInitialEventParams({required this.rawJson});

  /// Creates an [UnknownSessionInitialEventParams] from JSON.
  factory UnknownSessionInitialEventParams.fromJson(Map<String, dynamic> json) {
    return UnknownSessionInitialEventParams(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSessionInitialEventParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSessionInitialEventParams(rawJson: $rawJson)';
}
