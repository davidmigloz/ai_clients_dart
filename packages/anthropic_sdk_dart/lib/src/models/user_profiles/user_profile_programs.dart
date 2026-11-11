import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Access status for a program tier or feature.
@immutable
class UserProfileProgramAccess {
  /// The wire access status, normally active or inactive.
  final String status;

  /// Creates a [UserProfileProgramAccess].
  const UserProfileProgramAccess({required this.status});

  /// Parses a [UserProfileProgramAccess] from JSON.
  factory UserProfileProgramAccess.fromJson(Map<String, dynamic> json) {
    return UserProfileProgramAccess(status: json['status'] as String);
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {'status': status};

  /// Creates a copy with replaced values.
  UserProfileProgramAccess copyWith({String? status}) =>
      UserProfileProgramAccess(status: status ?? this.status);

  @override
  bool operator ==(Object other) =>
      other is UserProfileProgramAccess && status == other.status;

  @override
  int get hashCode => Object.hashAll([status]);

  @override
  String toString() =>
      'UserProfileProgramAccess('
      'status: $status)';
}

/// Requirements associated with the cyber program.
@immutable
class UserProfileCyberRequirements {
  /// Whether data retention is required.
  final bool dataRetention;

  /// Whether human review is required.
  final bool humanReview;

  /// Creates a [UserProfileCyberRequirements].
  const UserProfileCyberRequirements({
    required this.dataRetention,
    required this.humanReview,
  });

  /// Parses a [UserProfileCyberRequirements] from JSON.
  factory UserProfileCyberRequirements.fromJson(Map<String, dynamic> json) {
    return UserProfileCyberRequirements(
      dataRetention: json['data_retention'] as bool,
      humanReview: json['human_review'] as bool,
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'data_retention': dataRetention,
    'human_review': humanReview,
  };

  /// Creates a copy with replaced values.
  UserProfileCyberRequirements copyWith({
    bool? dataRetention,
    bool? humanReview,
  }) => UserProfileCyberRequirements(
    dataRetention: dataRetention ?? this.dataRetention,
    humanReview: humanReview ?? this.humanReview,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfileCyberRequirements &&
      dataRetention == other.dataRetention &&
      humanReview == other.humanReview;

  @override
  int get hashCode => Object.hashAll([dataRetention, humanReview]);

  @override
  String toString() =>
      'UserProfileCyberRequirements('
      'dataRetention: $dataRetention, '
      'humanReview: $humanReview)';
}

/// The profile’s standing in the cyber program.
@immutable
class UserProfileCyberProgram {
  /// The wire program status, normally active, pending or rejected.
  final String status;

  /// Access state keyed by tier name.
  final Map<String, UserProfileProgramAccess> tiers;

  /// Any requirements reported for this profile.
  final UserProfileCyberRequirements? requirements;

  /// Creates a [UserProfileCyberProgram].
  const UserProfileCyberProgram({
    required this.status,
    required this.tiers,
    this.requirements,
  });

  /// Parses a [UserProfileCyberProgram] from JSON.
  factory UserProfileCyberProgram.fromJson(Map<String, dynamic> json) {
    final requirementsJson = json['requirements'] as Map<String, dynamic>?;
    return UserProfileCyberProgram(
      status: json['status'] as String,
      tiers: Map.unmodifiable(
        (json['tiers'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            UserProfileProgramAccess.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
      requirements: requirementsJson == null
          ? null
          : UserProfileCyberRequirements.fromJson(requirementsJson),
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'status': status,
    'tiers': tiers.map((key, value) => MapEntry(key, value.toJson())),
    'requirements': requirements?.toJson(),
  };

  /// Creates a copy with replaced values.
  UserProfileCyberProgram copyWith({
    String? status,
    Map<String, UserProfileProgramAccess>? tiers,
    Object? requirements = unsetCopyWithValue,
  }) => UserProfileCyberProgram(
    status: status ?? this.status,
    tiers: tiers ?? this.tiers,
    requirements: requirements == unsetCopyWithValue
        ? this.requirements
        : requirements as UserProfileCyberRequirements?,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfileCyberProgram &&
      status == other.status &&
      mapsEqual(tiers, other.tiers) &&
      requirements == other.requirements;

  @override
  int get hashCode => Object.hashAll([status, mapHash(tiers), requirements]);

  @override
  String toString() =>
      'UserProfileCyberProgram('
      'status: $status, '
      'tiers: ${tiers.length} entries, '
      'requirements: $requirements)';
}

/// The profile’s standing in the enterprise feature suite.
@immutable
class UserProfileEfsProgram {
  /// The wire program status, normally active, pending or rejected.
  final String status;

  /// Access state keyed by feature name.
  final Map<String, UserProfileProgramAccess> features;

  /// Creates a [UserProfileEfsProgram].
  const UserProfileEfsProgram({required this.status, required this.features});

  /// Parses a [UserProfileEfsProgram] from JSON.
  factory UserProfileEfsProgram.fromJson(Map<String, dynamic> json) {
    return UserProfileEfsProgram(
      status: json['status'] as String,
      features: Map.unmodifiable(
        (json['features'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(
            key,
            UserProfileProgramAccess.fromJson(value as Map<String, dynamic>),
          ),
        ),
      ),
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'status': status,
    'features': features.map((key, value) => MapEntry(key, value.toJson())),
  };

  /// Creates a copy with replaced values.
  UserProfileEfsProgram copyWith({
    String? status,
    Map<String, UserProfileProgramAccess>? features,
  }) => UserProfileEfsProgram(
    status: status ?? this.status,
    features: features ?? this.features,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfileEfsProgram &&
      status == other.status &&
      mapsEqual(features, other.features);

  @override
  int get hashCode => Object.hashAll([status, mapHash(features)]);

  @override
  String toString() =>
      'UserProfileEfsProgram('
      'status: $status, '
      'features: ${features.length} entries)';
}

/// The programs Anthropic reports for a user profile.
@immutable
class UserProfilePrograms {
  /// The cyber program, when reported.
  final UserProfileCyberProgram? cyber;

  /// The enterprise feature suite, when reported.
  final UserProfileEfsProgram? efs;

  /// Creates a [UserProfilePrograms].
  const UserProfilePrograms({this.cyber, this.efs});

  /// Parses a [UserProfilePrograms] from JSON.
  factory UserProfilePrograms.fromJson(Map<String, dynamic> json) {
    final cyberJson = json['cyber'] as Map<String, dynamic>?;
    final efsJson = json['efs'] as Map<String, dynamic>?;
    return UserProfilePrograms(
      cyber: cyberJson == null
          ? null
          : UserProfileCyberProgram.fromJson(cyberJson),
      efs: efsJson == null ? null : UserProfileEfsProgram.fromJson(efsJson),
    );
  }

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'cyber': cyber?.toJson(),
    'efs': efs?.toJson(),
  };

  /// Creates a copy with replaced values.
  UserProfilePrograms copyWith({
    Object? cyber = unsetCopyWithValue,
    Object? efs = unsetCopyWithValue,
  }) => UserProfilePrograms(
    cyber: cyber == unsetCopyWithValue
        ? this.cyber
        : cyber as UserProfileCyberProgram?,
    efs: efs == unsetCopyWithValue ? this.efs : efs as UserProfileEfsProgram?,
  );

  @override
  bool operator ==(Object other) =>
      other is UserProfilePrograms && cyber == other.cyber && efs == other.efs;

  @override
  int get hashCode => Object.hashAll([cyber, efs]);

  @override
  String toString() =>
      'UserProfilePrograms('
      'cyber: $cyber, '
      'efs: $efs)';
}
