import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// An actor that performed an action within the Managed Agents API.
///
/// Variants:
/// - [SessionActor] — A managed agent session (type: `session_actor`)
/// - [ApiActor] — An API key (type: `api_actor`)
/// - [UserActor] — An end user (type: `user_actor`)
/// - [UnknownManagedAgentActor] — Unrecognized actor type (preserves raw JSON)
sealed class ManagedAgentActor {
  const ManagedAgentActor();

  /// Creates a [ManagedAgentActor] from JSON.
  factory ManagedAgentActor.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'session_actor' => SessionActor.fromJson(json),
      'api_actor' => ApiActor.fromJson(json),
      'user_actor' => UserActor.fromJson(json),
      _ => UnknownManagedAgentActor.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A session actor — a managed agent session that performed the action.
@immutable
class SessionActor extends ManagedAgentActor {
  /// The type discriminator. Always `session_actor`.
  final String type;

  /// The session ID.
  final String sessionId;

  /// Creates a [SessionActor].
  const SessionActor({this.type = 'session_actor', required this.sessionId});

  /// Creates a [SessionActor] from JSON.
  factory SessionActor.fromJson(Map<String, dynamic> json) {
    return SessionActor(
      type: json['type'] as String? ?? 'session_actor',
      sessionId: json['session_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'session_id': sessionId};

  /// Creates a copy with replaced values.
  SessionActor copyWith({String? type, String? sessionId}) {
    return SessionActor(
      type: type ?? this.type,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionActor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          sessionId == other.sessionId;

  @override
  int get hashCode => Object.hash(type, sessionId);

  @override
  String toString() => 'SessionActor(type: $type, sessionId: $sessionId)';
}

/// An API actor — an API key that performed the action.
@immutable
class ApiActor extends ManagedAgentActor {
  /// The type discriminator. Always `api_actor`.
  final String type;

  /// The API key ID.
  final String apiKeyId;

  /// Creates an [ApiActor].
  const ApiActor({this.type = 'api_actor', required this.apiKeyId});

  /// Creates an [ApiActor] from JSON.
  factory ApiActor.fromJson(Map<String, dynamic> json) {
    return ApiActor(
      type: json['type'] as String? ?? 'api_actor',
      apiKeyId: json['api_key_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'api_key_id': apiKeyId};

  /// Creates a copy with replaced values.
  ApiActor copyWith({String? type, String? apiKeyId}) {
    return ApiActor(
      type: type ?? this.type,
      apiKeyId: apiKeyId ?? this.apiKeyId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiActor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          apiKeyId == other.apiKeyId;

  @override
  int get hashCode => Object.hash(type, apiKeyId);

  @override
  String toString() => 'ApiActor(type: $type, apiKeyId: $apiKeyId)';
}

/// A user actor — an end user that performed the action.
@immutable
class UserActor extends ManagedAgentActor {
  /// The type discriminator. Always `user_actor`.
  final String type;

  /// The user ID.
  final String userId;

  /// Creates a [UserActor].
  const UserActor({this.type = 'user_actor', required this.userId});

  /// Creates a [UserActor] from JSON.
  factory UserActor.fromJson(Map<String, dynamic> json) {
    return UserActor(
      type: json['type'] as String? ?? 'user_actor',
      userId: json['user_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'user_id': userId};

  /// Creates a copy with replaced values.
  UserActor copyWith({String? type, String? userId}) {
    return UserActor(type: type ?? this.type, userId: userId ?? this.userId);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserActor &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          userId == other.userId;

  @override
  int get hashCode => Object.hash(type, userId);

  @override
  String toString() => 'UserActor(type: $type, userId: $userId)';
}

/// Unrecognized [ManagedAgentActor] type — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownManagedAgentActor extends ManagedAgentActor {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownManagedAgentActor].
  const UnknownManagedAgentActor({required this.rawJson});

  /// Creates an [UnknownManagedAgentActor] from JSON.
  factory UnknownManagedAgentActor.fromJson(Map<String, dynamic> json) {
    return UnknownManagedAgentActor(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownManagedAgentActor &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownManagedAgentActor(rawJson: $rawJson)';
}
