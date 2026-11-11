import 'package:meta/meta.dart';

/// An action offered to the entity that a user profile represents.
enum UserProfileAction {
  /// Enrolls the end user in an Anthropic program.
  enrollEndUser('enroll_end_user');

  const UserProfileAction(this.type);

  /// The action’s wire discriminator.
  final String type;

  /// Encodes the action object.
  Map<String, dynamic> toJson() => {'type': type};
}

/// A short-lived URL for a user profile action.
@immutable
class UserProfileActionUrl {
  /// The wire discriminator.
  String get type => 'user_profile_action_url';

  /// The URL to send to the person taking the action.
  final String url;

  /// When the URL expires.
  final DateTime expiresAt;

  /// Creates a [UserProfileActionUrl].
  const UserProfileActionUrl({required this.url, required this.expiresAt});

  /// Parses a [UserProfileActionUrl] from JSON.
  factory UserProfileActionUrl.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'user_profile_action_url') {
      throw FormatException(
        'Expected user_profile_action_url, got ${json["type"]}',
      );
    }
    return UserProfileActionUrl(
      url: json['url'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'url': url,
    'expires_at': expiresAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  UserProfileActionUrl copyWith({String? url, DateTime? expiresAt}) =>
      UserProfileActionUrl(
        url: url ?? this.url,
        expiresAt: expiresAt ?? this.expiresAt,
      );

  @override
  bool operator ==(Object other) =>
      other is UserProfileActionUrl &&
      url == other.url &&
      expiresAt == other.expiresAt;

  @override
  int get hashCode => Object.hashAll([url, expiresAt]);

  @override
  String toString() =>
      'UserProfileActionUrl('
      'url: [redacted], '
      'expiresAt: $expiresAt)';
}

/// Confirmation of a deleted user profile.
@immutable
class DeletedUserProfile {
  /// The wire discriminator.
  String get type => 'user_profile_deleted';

  /// The ID of the deleted user profile.
  final String id;

  /// Creates a [DeletedUserProfile].
  const DeletedUserProfile({required this.id});

  /// Parses a [DeletedUserProfile] from JSON.
  factory DeletedUserProfile.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'user_profile_deleted') {
      throw FormatException(
        'Expected user_profile_deleted, got ${json["type"]}',
      );
    }
    return DeletedUserProfile(id: json['id'] as String);
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Creates a copy with replaced values.
  DeletedUserProfile copyWith({String? id}) =>
      DeletedUserProfile(id: id ?? this.id);

  @override
  bool operator ==(Object other) =>
      other is DeletedUserProfile && id == other.id;

  @override
  int get hashCode => Object.hashAll([id]);

  @override
  String toString() =>
      'DeletedUserProfile('
      'id: $id)';
}
