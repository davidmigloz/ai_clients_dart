import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'user_profile_access_type.dart';
import 'user_profile_enforcement.dart';
import 'user_profile_external_user_details.dart';
import 'user_profile_programs.dart';

/// A user profile returned by the generally available User Profiles API.
@immutable
class CurrentUserProfile {
  /// The wire discriminator.
  String get type => 'user_profile';

  /// The unique profile ID, prefixed with uprof_.
  final String id;

  /// The entity’s name, when supplied by the platform.
  final String? name;

  /// The original wire value for the access type.
  final String accessTypeValue;

  /// Details the platform supplied about the end customer.
  final UserProfileExternalUserDetails externalUserDetails;

  /// The wire status. May be null on responses that omit enforcement details.
  final String? enforcementStatusValue;

  /// Enforcement actions, when reported by the server.
  final List<UserProfileEnforcementAction>? enforcementActions;

  /// The end customer’s program status.
  final UserProfilePrograms programs;

  /// Metadata set by the platform.
  final Map<String, String> metadata;

  /// When the profile was created.
  final DateTime createdAt;

  /// When the profile was last updated.
  final DateTime updatedAt;

  /// Creates a [CurrentUserProfile].
  const CurrentUserProfile({
    required this.id,
    this.name,
    required this.accessTypeValue,
    required this.externalUserDetails,
    this.enforcementStatusValue,
    this.enforcementActions,
    required this.programs,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Parses a [CurrentUserProfile] from JSON.
  factory CurrentUserProfile.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'user_profile') {
      throw FormatException('Expected user_profile, got ${json["type"]}');
    }
    final actionsJson = json['enforcement_actions'] as List<dynamic>?;
    return CurrentUserProfile(
      id: json['id'] as String,
      name: json['name'] as String?,
      accessTypeValue: json['access_type'] as String,
      externalUserDetails: UserProfileExternalUserDetails.fromJson(
        json['external_user_details'] as Map<String, dynamic>,
      ),
      enforcementStatusValue: json['enforcement_status'] as String?,
      enforcementActions: actionsJson == null
          ? null
          : List.unmodifiable(
              actionsJson.map(
                (value) => UserProfileEnforcementAction.fromJson(
                  value as Map<String, dynamic>,
                ),
              ),
            ),
      programs: UserProfilePrograms.fromJson(
        json['programs'] as Map<String, dynamic>,
      ),
      metadata: Map.unmodifiable(
        (json['metadata'] as Map<String, dynamic>).cast<String, String>(),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    'access_type': accessTypeValue,
    'external_user_details': externalUserDetails.toJson(),
    if (enforcementStatusValue != null)
      'enforcement_status': enforcementStatusValue,
    if (enforcementActions != null)
      'enforcement_actions': enforcementActions!
          .map((action) => action.toJson())
          .toList(),
    'programs': programs.toJson(),
    'metadata': metadata,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  CurrentUserProfile copyWith({
    String? id,
    Object? name = unsetCopyWithValue,
    String? accessTypeValue,
    UserProfileExternalUserDetails? externalUserDetails,
    Object? enforcementStatusValue = unsetCopyWithValue,
    Object? enforcementActions = unsetCopyWithValue,
    UserProfilePrograms? programs,
    Map<String, String>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CurrentUserProfile(
    id: id ?? this.id,
    name: name == unsetCopyWithValue ? this.name : name as String?,
    accessTypeValue: accessTypeValue ?? this.accessTypeValue,
    externalUserDetails: externalUserDetails ?? this.externalUserDetails,
    enforcementStatusValue: enforcementStatusValue == unsetCopyWithValue
        ? this.enforcementStatusValue
        : enforcementStatusValue as String?,
    enforcementActions: enforcementActions == unsetCopyWithValue
        ? this.enforcementActions
        : enforcementActions as List<UserProfileEnforcementAction>?,
    programs: programs ?? this.programs,
    metadata: metadata ?? this.metadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is CurrentUserProfile &&
      id == other.id &&
      name == other.name &&
      accessTypeValue == other.accessTypeValue &&
      externalUserDetails == other.externalUserDetails &&
      enforcementStatusValue == other.enforcementStatusValue &&
      listsEqual(enforcementActions, other.enforcementActions) &&
      programs == other.programs &&
      mapsEqual(metadata, other.metadata) &&
      createdAt == other.createdAt &&
      updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    accessTypeValue,
    externalUserDetails,
    enforcementStatusValue,
    listHash(enforcementActions),
    programs,
    mapHash(metadata),
    createdAt,
    updatedAt,
  ]);

  @override
  String toString() =>
      'CurrentUserProfile('
      'id: $id, '
      'name: ${name == null ? null : "[redacted]"}, '
      'accessTypeValue: $accessTypeValue, '
      'externalUserDetails: [redacted], '
      'enforcementStatusValue: $enforcementStatusValue, '
      'enforcementActions: ${enforcementActions?.length}, '
      'programs: $programs, '
      'metadata: ${metadata.length} entries, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';

  /// How the platform uses the API on behalf of this profile.
  UserProfileAccessType get accessType =>
      UserProfileAccessType.fromJson(accessTypeValue);

  /// The enforcement status, or null when the server did not report one.
  UserProfileEnforcementStatus? get enforcementStatus {
    final value = enforcementStatusValue;
    return value == null ? null : UserProfileEnforcementStatus.fromJson(value);
  }
}

/// A cursor-paginated page of generally available user profiles.
@immutable
class CurrentUserProfilePage {
  /// The profiles returned on this page.
  final List<CurrentUserProfile> data;

  /// The next page cursor, or null after the final page.
  final String? nextPage;

  /// Creates a [CurrentUserProfilePage].
  const CurrentUserProfilePage({required this.data, this.nextPage});

  /// Parses a [CurrentUserProfilePage] from JSON.
  factory CurrentUserProfilePage.fromJson(Map<String, dynamic> json) {
    return CurrentUserProfilePage(
      data: List.unmodifiable(
        (json['data'] as List<dynamic>).map(
          (value) => CurrentUserProfile.fromJson(value as Map<String, dynamic>),
        ),
      ),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((profile) => profile.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  CurrentUserProfilePage copyWith({
    List<CurrentUserProfile>? data,
    Object? nextPage = unsetCopyWithValue,
  }) => CurrentUserProfilePage(
    data: data ?? this.data,
    nextPage: nextPage == unsetCopyWithValue
        ? this.nextPage
        : nextPage as String?,
  );

  @override
  bool operator ==(Object other) =>
      other is CurrentUserProfilePage &&
      listsEqual(data, other.data) &&
      nextPage == other.nextPage;

  @override
  int get hashCode => Object.hashAll([listHash(data), nextPage]);

  @override
  String toString() =>
      'CurrentUserProfilePage('
      'data: ${data.length} entries, '
      'nextPage: $nextPage)';
}
