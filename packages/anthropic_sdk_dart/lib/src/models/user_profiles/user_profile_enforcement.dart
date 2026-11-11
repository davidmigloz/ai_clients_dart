import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// The overall enforcement status of a user profile.
enum UserProfileEnforcementStatus {
  /// Anthropic has no active restriction or ban for the profile.
  unrestricted('unrestricted'),

  /// The profile has a pending enforcement decision.
  pending('pending'),

  /// Anthropic has restricted the profile.
  restricted('restricted'),

  /// Anthropic has banned the profile.
  banned('banned'),

  /// An unrecognized status. The profile retains the original wire value.
  unknown('unknown');

  const UserProfileEnforcementStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value, falling back to [unknown].
  static UserProfileEnforcementStatus fromJson(String value) => values
      .firstWhere((status) => status.value == value, orElse: () => unknown);
}

/// An enforcement action applied by Anthropic.
///
/// Known restrictions and bans use [UserProfilePolicyEnforcementAction].
/// Other action types are retained by [UnknownUserProfileEnforcementAction].
sealed class UserProfileEnforcementAction {
  const UserProfileEnforcementAction();

  /// The wire discriminator.
  String get type;

  /// Parses an enforcement action.
  factory UserProfileEnforcementAction.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'restriction' ||
        'ban' => UserProfilePolicyEnforcementAction.fromJson(json),
        _ => UnknownUserProfileEnforcementAction(raw: json),
      };

  /// Converts this action to JSON.
  Map<String, dynamic> toJson();
}

/// An Anthropic restriction or ban.
///
/// Reason and next-step values are kept as wire strings so newer values
/// can be read and round-tripped.
@immutable
class UserProfilePolicyEnforcementAction extends UserProfileEnforcementAction {
  @override
  final String type;

  /// The enforcement action ID.
  final String id;

  /// Why Anthropic opened the action.
  final String reason;

  /// Next step for the entity, such as `verify`. May be null.
  final String? action;

  /// When Anthropic opened the action.
  final DateTime openedAt;

  /// When the action expires, if it has a set expiration.
  final DateTime? expiresAt;

  const UserProfilePolicyEnforcementAction._({
    required this.type,
    required this.id,
    required this.reason,
    required this.openedAt,
    this.action,
    this.expiresAt,
  });

  /// Creates a restriction record.
  const UserProfilePolicyEnforcementAction.restriction({
    required String id,
    required String reason,
    required DateTime openedAt,
    String? action,
    DateTime? expiresAt,
  }) : this._(
         type: 'restriction',
         id: id,
         reason: reason,
         openedAt: openedAt,
         action: action,
         expiresAt: expiresAt,
       );

  /// Creates a ban record.
  const UserProfilePolicyEnforcementAction.ban({
    required String id,
    required String reason,
    required DateTime openedAt,
    String? action,
    DateTime? expiresAt,
  }) : this._(
         type: 'ban',
         id: id,
         reason: reason,
         openedAt: openedAt,
         action: action,
         expiresAt: expiresAt,
       );

  /// Parses a known restriction or ban.
  factory UserProfilePolicyEnforcementAction.fromJson(
    Map<String, dynamic> json,
  ) {
    final type = json['type'];
    if (type != 'restriction' && type != 'ban') {
      throw FormatException('Expected a restriction or ban, got $type');
    }
    final expiresAt = json['expires_at'] as String?;
    return UserProfilePolicyEnforcementAction._(
      type: type as String,
      id: json['id'] as String,
      reason: json['reason'] as String,
      action: json['action'] as String?,
      openedAt: DateTime.parse(json['opened_at'] as String),
      expiresAt: expiresAt == null ? null : DateTime.parse(expiresAt),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'reason': reason,
    'action': action,
    'opened_at': openedAt.toUtc().toIso8601String(),
    'expires_at': expiresAt?.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  UserProfilePolicyEnforcementAction copyWith({
    String? id,
    String? reason,
    DateTime? openedAt,
    Object? action = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
  }) => UserProfilePolicyEnforcementAction._(
    type: type,
    id: id ?? this.id,
    reason: reason ?? this.reason,
    openedAt: openedAt ?? this.openedAt,
    action: action == unsetCopyWithValue ? this.action : action as String?,
    expiresAt: expiresAt == unsetCopyWithValue
        ? this.expiresAt
        : expiresAt as DateTime?,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfilePolicyEnforcementAction &&
      type == other.type &&
      id == other.id &&
      reason == other.reason &&
      openedAt == other.openedAt &&
      action == other.action &&
      expiresAt == other.expiresAt;

  @override
  int get hashCode =>
      Object.hash(type, id, reason, openedAt, action, expiresAt);

  @override
  String toString() =>
      'UserProfilePolicyEnforcementAction(type: $type, id: $id, reason: $reason, '
      'openedAt: $openedAt, action: $action, expiresAt: $expiresAt)';
}

/// A future enforcement action whose payload is preserved.
@immutable
class UnknownUserProfileEnforcementAction extends UserProfileEnforcementAction {
  /// The raw action payload.
  final Map<String, dynamic> raw;

  /// Creates an unknown enforcement action from its JSON fields.
  UnknownUserProfileEnforcementAction({required Map<String, dynamic> raw})
    : raw = deepUnmodifiableMap(raw);

  @override
  String get type => raw['type'] is String ? raw['type'] as String : 'unknown';

  @override
  Map<String, dynamic> toJson() => Map<String, dynamic>.from(raw);

  /// Creates a copy with a replacement raw payload.
  UnknownUserProfileEnforcementAction copyWith({Map<String, dynamic>? raw}) =>
      UnknownUserProfileEnforcementAction(raw: raw ?? this.raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownUserProfileEnforcementAction &&
      mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);

  @override
  String toString() =>
      'UnknownUserProfileEnforcementAction(type: $type, raw: ${raw.length} entries)';
}
