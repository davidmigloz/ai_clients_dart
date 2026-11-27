import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative start admin scim sync request.
@immutable
class StartAdminScimSyncRequest {
  /// Creates a [StartAdminScimSyncRequest].
  const StartAdminScimSyncRequest({this.dryRun, this.syncConfig});

  /// Preview all synchronization changes without applying them.
  final bool? dryRun;

  /// Categories to synchronize. Required when dry_run is false; ignored for dry runs.
  final AdminScimSyncConfig? syncConfig;

  /// Parses a [StartAdminScimSyncRequest] from JSON.
  factory StartAdminScimSyncRequest.fromJson(Map<String, dynamic> json) {
    return StartAdminScimSyncRequest(
      dryRun: json['dry_run'] == null ? null : json['dry_run'] as bool,
      syncConfig: json['sync_config'] == null
          ? null
          : AdminScimSyncConfig.fromJson(
              json['sync_config'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'dry_run': ?dryRun,
    if (syncConfig != null) 'sync_config': syncConfig!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  StartAdminScimSyncRequest copyWith({
    Object? dryRun = unsetCopyWithValue,
    Object? syncConfig = unsetCopyWithValue,
  }) => StartAdminScimSyncRequest(
    dryRun: dryRun == unsetCopyWithValue ? this.dryRun : dryRun as bool?,
    syncConfig: syncConfig == unsetCopyWithValue
        ? this.syncConfig
        : syncConfig as AdminScimSyncConfig?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StartAdminScimSyncRequest &&
          runtimeType == other.runtimeType &&
          dryRun == other.dryRun &&
          syncConfig == other.syncConfig;

  @override
  int get hashCode => Object.hashAll([dryRun, syncConfig]);

  @override
  String toString() =>
      'StartAdminScimSyncRequest('
      'dryRun: $dryRun, '
      'syncConfig: $syncConfig)';
}

/// Administrative scim sync started.
@immutable
class AdminScimSyncStarted {
  /// Creates a [AdminScimSyncStarted].
  const AdminScimSyncStarted({required this.runId});

  /// Unique identifier of the created SCIM synchronization run.
  final String runId;

  /// Parses a [AdminScimSyncStarted] from JSON.
  factory AdminScimSyncStarted.fromJson(Map<String, dynamic> json) {
    if (json['run_id'] == null) {
      throw const FormatException('AdminScimSyncStarted: missing run_id');
    }
    return AdminScimSyncStarted(runId: json['run_id'] as String);
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'run_id': runId};

  /// Creates a copy with the given fields replaced.
  AdminScimSyncStarted copyWith({String? runId}) =>
      AdminScimSyncStarted(runId: runId ?? this.runId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimSyncStarted &&
          runtimeType == other.runtimeType &&
          runId == other.runId;

  @override
  int get hashCode => Object.hashAll([runId]);

  @override
  String toString() =>
      'AdminScimSyncStarted('
      'runId: $runId)';
}

/// Administrative scim sync run.
@immutable
class AdminScimSyncRun {
  /// Creates a [AdminScimSyncRun].
  const AdminScimSyncRun({
    required this.createdAt,
    required this.dryRun,
    required this.errorMessage,
    required this.finishedAt,
    required this.runId,
    required this.startedAt,
    required this.status,
    required this.summary,
    required this.syncConfig,
  });

  /// Time at which the synchronization run was created.
  final String createdAt;

  /// Whether the run only previewed changes.
  final bool dryRun;

  /// Failure detail when the synchronization run could not complete.
  final String? errorMessage;

  /// Time at which processing finished, if it has finished.
  final String? finishedAt;

  /// Unique identifier of the SCIM synchronization run.
  final String runId;

  /// Time at which processing started, if it has started.
  final String? startedAt;

  /// Current lifecycle status of the synchronization run.
  final AdminScimRunStatus status;

  /// Preview or result summary, available after the synchronization plan is built.
  final AdminScimSyncSummary? summary;

  /// Categories selected for this synchronization run.
  final AdminScimSyncConfig? syncConfig;

  /// Parses a [AdminScimSyncRun] from JSON.
  factory AdminScimSyncRun.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('AdminScimSyncRun: missing created_at');
    }
    if (json['dry_run'] == null) {
      throw const FormatException('AdminScimSyncRun: missing dry_run');
    }
    if (!json.containsKey('error_message')) {
      throw const FormatException('AdminScimSyncRun: missing error_message');
    }
    if (!json.containsKey('finished_at')) {
      throw const FormatException('AdminScimSyncRun: missing finished_at');
    }
    if (json['run_id'] == null) {
      throw const FormatException('AdminScimSyncRun: missing run_id');
    }
    if (!json.containsKey('started_at')) {
      throw const FormatException('AdminScimSyncRun: missing started_at');
    }
    if (json['status'] == null) {
      throw const FormatException('AdminScimSyncRun: missing status');
    }
    if (!json.containsKey('summary')) {
      throw const FormatException('AdminScimSyncRun: missing summary');
    }
    if (!json.containsKey('sync_config')) {
      throw const FormatException('AdminScimSyncRun: missing sync_config');
    }
    return AdminScimSyncRun(
      createdAt: json['created_at'] as String,
      dryRun: json['dry_run'] as bool,
      errorMessage: json['error_message'] == null
          ? null
          : json['error_message'] as String,
      finishedAt: json['finished_at'] == null
          ? null
          : json['finished_at'] as String,
      runId: json['run_id'] as String,
      startedAt: json['started_at'] == null
          ? null
          : json['started_at'] as String,
      status: AdminScimRunStatus.fromJson(json['status'] as String),
      summary: json['summary'] == null
          ? null
          : AdminScimSyncSummary.fromJson(
              json['summary'] as Map<String, dynamic>,
            ),
      syncConfig: json['sync_config'] == null
          ? null
          : AdminScimSyncConfig.fromJson(
              json['sync_config'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'dry_run': dryRun,
    'error_message': errorMessage,
    'finished_at': finishedAt,
    'run_id': runId,
    'started_at': startedAt,
    'status': status.toJson(),
    'summary': summary?.toJson(),
    'sync_config': syncConfig?.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminScimSyncRun copyWith({
    String? createdAt,
    bool? dryRun,
    Object? errorMessage = unsetCopyWithValue,
    Object? finishedAt = unsetCopyWithValue,
    String? runId,
    Object? startedAt = unsetCopyWithValue,
    AdminScimRunStatus? status,
    Object? summary = unsetCopyWithValue,
    Object? syncConfig = unsetCopyWithValue,
  }) => AdminScimSyncRun(
    createdAt: createdAt ?? this.createdAt,
    dryRun: dryRun ?? this.dryRun,
    errorMessage: errorMessage == unsetCopyWithValue
        ? this.errorMessage
        : errorMessage as String?,
    finishedAt: finishedAt == unsetCopyWithValue
        ? this.finishedAt
        : finishedAt as String?,
    runId: runId ?? this.runId,
    startedAt: startedAt == unsetCopyWithValue
        ? this.startedAt
        : startedAt as String?,
    status: status ?? this.status,
    summary: summary == unsetCopyWithValue
        ? this.summary
        : summary as AdminScimSyncSummary?,
    syncConfig: syncConfig == unsetCopyWithValue
        ? this.syncConfig
        : syncConfig as AdminScimSyncConfig?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimSyncRun &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          dryRun == other.dryRun &&
          errorMessage == other.errorMessage &&
          finishedAt == other.finishedAt &&
          runId == other.runId &&
          startedAt == other.startedAt &&
          status == other.status &&
          summary == other.summary &&
          syncConfig == other.syncConfig;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    dryRun,
    errorMessage,
    finishedAt,
    runId,
    startedAt,
    status,
    summary,
    syncConfig,
  ]);

  @override
  String toString() =>
      'AdminScimSyncRun('
      'createdAt: $createdAt, '
      'dryRun: $dryRun, '
      'errorMessage: $errorMessage, '
      'finishedAt: $finishedAt, '
      'runId: $runId, '
      'startedAt: $startedAt, '
      'status: $status, '
      'summary: $summary, '
      'syncConfig: $syncConfig)';
}

/// Administrative scim sync active run.
@immutable
class AdminScimSyncActiveRun {
  /// Creates a [AdminScimSyncActiveRun].
  const AdminScimSyncActiveRun({required this.runId, required this.status});

  /// Unique identifier of the already active SCIM synchronization run.
  final String runId;

  /// Current lifecycle status of the active synchronization run.
  final AdminScimRunStatus status;

  /// Parses a [AdminScimSyncActiveRun] from JSON.
  factory AdminScimSyncActiveRun.fromJson(Map<String, dynamic> json) {
    if (json['run_id'] == null) {
      throw const FormatException('AdminScimSyncActiveRun: missing run_id');
    }
    if (json['status'] == null) {
      throw const FormatException('AdminScimSyncActiveRun: missing status');
    }
    return AdminScimSyncActiveRun(
      runId: json['run_id'] as String,
      status: AdminScimRunStatus.fromJson(json['status'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'run_id': runId, 'status': status.toJson()};

  /// Creates a copy with the given fields replaced.
  AdminScimSyncActiveRun copyWith({
    String? runId,
    AdminScimRunStatus? status,
  }) => AdminScimSyncActiveRun(
    runId: runId ?? this.runId,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimSyncActiveRun &&
          runtimeType == other.runtimeType &&
          runId == other.runId &&
          status == other.status;

  @override
  int get hashCode => Object.hashAll([runId, status]);

  @override
  String toString() =>
      'AdminScimSyncActiveRun('
      'runId: $runId, '
      'status: $status)';
}

/// Administrative scim sync config.
@immutable
class AdminScimSyncConfig {
  /// Creates a [AdminScimSyncConfig].
  const AdminScimSyncConfig({
    this.deleteMissingGroups,
    this.deprovisionUsers,
    required this.syncGroups,
    required this.syncMemberships,
    required this.syncUsers,
  });

  /// Delete Organization groups that are absent from the SCIM provider.
  final bool? deleteMissingGroups;

  /// Remove Organization users that are inactive or absent from the SCIM provider.
  final bool? deprovisionUsers;

  /// Synchronize group metadata from the SCIM provider.
  final bool syncGroups;

  /// Synchronize additions and removals of users in SCIM groups.
  final bool syncMemberships;

  /// Add users found in the SCIM provider to the Organization.
  final bool syncUsers;

  /// Parses a [AdminScimSyncConfig] from JSON.
  factory AdminScimSyncConfig.fromJson(Map<String, dynamic> json) {
    if (json['sync_groups'] == null) {
      throw const FormatException('AdminScimSyncConfig: missing sync_groups');
    }
    if (json['sync_memberships'] == null) {
      throw const FormatException(
        'AdminScimSyncConfig: missing sync_memberships',
      );
    }
    if (json['sync_users'] == null) {
      throw const FormatException('AdminScimSyncConfig: missing sync_users');
    }
    return AdminScimSyncConfig(
      deleteMissingGroups: json['delete_missing_groups'] == null
          ? null
          : json['delete_missing_groups'] as bool,
      deprovisionUsers: json['deprovision_users'] == null
          ? null
          : json['deprovision_users'] as bool,
      syncGroups: json['sync_groups'] as bool,
      syncMemberships: json['sync_memberships'] as bool,
      syncUsers: json['sync_users'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'delete_missing_groups': ?deleteMissingGroups,
    'deprovision_users': ?deprovisionUsers,
    'sync_groups': syncGroups,
    'sync_memberships': syncMemberships,
    'sync_users': syncUsers,
  };

  /// Creates a copy with the given fields replaced.
  AdminScimSyncConfig copyWith({
    Object? deleteMissingGroups = unsetCopyWithValue,
    Object? deprovisionUsers = unsetCopyWithValue,
    bool? syncGroups,
    bool? syncMemberships,
    bool? syncUsers,
  }) => AdminScimSyncConfig(
    deleteMissingGroups: deleteMissingGroups == unsetCopyWithValue
        ? this.deleteMissingGroups
        : deleteMissingGroups as bool?,
    deprovisionUsers: deprovisionUsers == unsetCopyWithValue
        ? this.deprovisionUsers
        : deprovisionUsers as bool?,
    syncGroups: syncGroups ?? this.syncGroups,
    syncMemberships: syncMemberships ?? this.syncMemberships,
    syncUsers: syncUsers ?? this.syncUsers,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimSyncConfig &&
          runtimeType == other.runtimeType &&
          deleteMissingGroups == other.deleteMissingGroups &&
          deprovisionUsers == other.deprovisionUsers &&
          syncGroups == other.syncGroups &&
          syncMemberships == other.syncMemberships &&
          syncUsers == other.syncUsers;

  @override
  int get hashCode => Object.hashAll([
    deleteMissingGroups,
    deprovisionUsers,
    syncGroups,
    syncMemberships,
    syncUsers,
  ]);

  @override
  String toString() =>
      'AdminScimSyncConfig('
      'deleteMissingGroups: $deleteMissingGroups, '
      'deprovisionUsers: $deprovisionUsers, '
      'syncGroups: $syncGroups, '
      'syncMemberships: $syncMemberships, '
      'syncUsers: $syncUsers)';
}

/// Values for AdminScimRunStatus.
enum AdminScimRunStatus {
  /// Represents PENDING.
  pending('PENDING'),

  /// Represents RUNNING.
  running('RUNNING'),

  /// Represents SUCCESS.
  success('SUCCESS'),

  /// Represents SKIPPED.
  skipped('SKIPPED'),

  /// Represents FAILED.
  failed('FAILED'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const AdminScimRunStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static AdminScimRunStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Administrative scim sync summary.
@immutable
class AdminScimSyncSummary {
  /// Creates a [AdminScimSyncSummary].
  const AdminScimSyncSummary({
    required this.groups,
    required this.memberships,
    required this.users,
  });

  /// The groups field.
  final AdminScimGroupSummary groups;

  /// The memberships field.
  final List<AdminScimMembershipAction> memberships;

  /// The users field.
  final AdminScimUserSummary users;

  /// Parses a [AdminScimSyncSummary] from JSON.
  factory AdminScimSyncSummary.fromJson(Map<String, dynamic> json) {
    if (json['groups'] == null) {
      throw const FormatException('AdminScimSyncSummary: missing groups');
    }
    if (json['memberships'] == null) {
      throw const FormatException('AdminScimSyncSummary: missing memberships');
    }
    if (json['users'] == null) {
      throw const FormatException('AdminScimSyncSummary: missing users');
    }
    return AdminScimSyncSummary(
      groups: AdminScimGroupSummary.fromJson(
        json['groups'] as Map<String, dynamic>,
      ),
      memberships: (json['memberships'] as List)
          .map(
            (item) => AdminScimMembershipAction.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      users: AdminScimUserSummary.fromJson(
        json['users'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'groups': groups.toJson(),
    'memberships': memberships.map((item) => item.toJson()).toList(),
    'users': users.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  AdminScimSyncSummary copyWith({
    AdminScimGroupSummary? groups,
    List<AdminScimMembershipAction>? memberships,
    AdminScimUserSummary? users,
  }) => AdminScimSyncSummary(
    groups: groups ?? this.groups,
    memberships: memberships ?? this.memberships,
    users: users ?? this.users,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimSyncSummary &&
          runtimeType == other.runtimeType &&
          groups == other.groups &&
          valuesDeepEqual(memberships, other.memberships) &&
          users == other.users;

  @override
  int get hashCode =>
      Object.hashAll([groups, valueDeepHashCode(memberships), users]);

  @override
  String toString() =>
      'AdminScimSyncSummary('
      'groups: $groups, '
      'memberships: ${memberships.length}, '
      'users: $users)';
}

/// Administrative scim group summary.
@immutable
class AdminScimGroupSummary {
  /// Creates a [AdminScimGroupSummary].
  const AdminScimGroupSummary({
    required this.create,
    required this.delete,
    required this.update,
  });

  /// The create field.
  final List<AdminScimGroupAction> create;

  /// The delete field.
  final List<AdminScimGroupAction> delete;

  /// The update field.
  final List<AdminScimGroupUpdateAction> update;

  /// Parses a [AdminScimGroupSummary] from JSON.
  factory AdminScimGroupSummary.fromJson(Map<String, dynamic> json) {
    if (json['create'] == null) {
      throw const FormatException('AdminScimGroupSummary: missing create');
    }
    if (json['delete'] == null) {
      throw const FormatException('AdminScimGroupSummary: missing delete');
    }
    if (json['update'] == null) {
      throw const FormatException('AdminScimGroupSummary: missing update');
    }
    return AdminScimGroupSummary(
      create: (json['create'] as List)
          .map(
            (item) =>
                AdminScimGroupAction.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      delete: (json['delete'] as List)
          .map(
            (item) =>
                AdminScimGroupAction.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      update: (json['update'] as List)
          .map(
            (item) => AdminScimGroupUpdateAction.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'create': create.map((item) => item.toJson()).toList(),
    'delete': delete.map((item) => item.toJson()).toList(),
    'update': update.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AdminScimGroupSummary copyWith({
    List<AdminScimGroupAction>? create,
    List<AdminScimGroupAction>? delete,
    List<AdminScimGroupUpdateAction>? update,
  }) => AdminScimGroupSummary(
    create: create ?? this.create,
    delete: delete ?? this.delete,
    update: update ?? this.update,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimGroupSummary &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(create, other.create) &&
          valuesDeepEqual(delete, other.delete) &&
          valuesDeepEqual(update, other.update);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(create),
    valueDeepHashCode(delete),
    valueDeepHashCode(update),
  ]);

  @override
  String toString() =>
      'AdminScimGroupSummary('
      'create: ${create.length}, '
      'delete: ${delete.length}, '
      'update: ${update.length})';
}

/// Administrative scim membership action.
@immutable
class AdminScimMembershipAction {
  /// Creates a [AdminScimMembershipAction].
  const AdminScimMembershipAction({
    required this.group,
    required this.usersAdded,
    required this.usersRemoved,
  });

  /// The group field.
  final AdminScimGroupReference group;

  /// The users_added field.
  final List<AdminScimUserReference> usersAdded;

  /// The users_removed field.
  final List<AdminScimUserReference> usersRemoved;

  /// Parses a [AdminScimMembershipAction] from JSON.
  factory AdminScimMembershipAction.fromJson(Map<String, dynamic> json) {
    if (json['group'] == null) {
      throw const FormatException('AdminScimMembershipAction: missing group');
    }
    if (json['users_added'] == null) {
      throw const FormatException(
        'AdminScimMembershipAction: missing users_added',
      );
    }
    if (json['users_removed'] == null) {
      throw const FormatException(
        'AdminScimMembershipAction: missing users_removed',
      );
    }
    return AdminScimMembershipAction(
      group: AdminScimGroupReference.fromJson(
        json['group'] as Map<String, dynamic>,
      ),
      usersAdded: (json['users_added'] as List)
          .map(
            (item) =>
                AdminScimUserReference.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      usersRemoved: (json['users_removed'] as List)
          .map(
            (item) =>
                AdminScimUserReference.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'group': group.toJson(),
    'users_added': usersAdded.map((item) => item.toJson()).toList(),
    'users_removed': usersRemoved.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AdminScimMembershipAction copyWith({
    AdminScimGroupReference? group,
    List<AdminScimUserReference>? usersAdded,
    List<AdminScimUserReference>? usersRemoved,
  }) => AdminScimMembershipAction(
    group: group ?? this.group,
    usersAdded: usersAdded ?? this.usersAdded,
    usersRemoved: usersRemoved ?? this.usersRemoved,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimMembershipAction &&
          runtimeType == other.runtimeType &&
          group == other.group &&
          valuesDeepEqual(usersAdded, other.usersAdded) &&
          valuesDeepEqual(usersRemoved, other.usersRemoved);

  @override
  int get hashCode => Object.hashAll([
    group,
    valueDeepHashCode(usersAdded),
    valueDeepHashCode(usersRemoved),
  ]);

  @override
  String toString() =>
      'AdminScimMembershipAction('
      'group: $group, '
      'usersAdded: ${usersAdded.length}, '
      'usersRemoved: ${usersRemoved.length})';
}

/// Administrative scim user summary.
@immutable
class AdminScimUserSummary {
  /// Creates a [AdminScimUserSummary].
  const AdminScimUserSummary({
    required this.deprovision,
    required this.provision,
  });

  /// The deprovision field.
  final List<AdminScimUserAction> deprovision;

  /// The provision field.
  final List<AdminScimUserAction> provision;

  /// Parses a [AdminScimUserSummary] from JSON.
  factory AdminScimUserSummary.fromJson(Map<String, dynamic> json) {
    if (json['deprovision'] == null) {
      throw const FormatException('AdminScimUserSummary: missing deprovision');
    }
    if (json['provision'] == null) {
      throw const FormatException('AdminScimUserSummary: missing provision');
    }
    return AdminScimUserSummary(
      deprovision: (json['deprovision'] as List)
          .map(
            (item) =>
                AdminScimUserAction.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      provision: (json['provision'] as List)
          .map(
            (item) =>
                AdminScimUserAction.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'deprovision': deprovision.map((item) => item.toJson()).toList(),
    'provision': provision.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  AdminScimUserSummary copyWith({
    List<AdminScimUserAction>? deprovision,
    List<AdminScimUserAction>? provision,
  }) => AdminScimUserSummary(
    deprovision: deprovision ?? this.deprovision,
    provision: provision ?? this.provision,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimUserSummary &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(deprovision, other.deprovision) &&
          valuesDeepEqual(provision, other.provision);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(deprovision),
    valueDeepHashCode(provision),
  ]);

  @override
  String toString() =>
      'AdminScimUserSummary('
      'deprovision: ${deprovision.length}, '
      'provision: ${provision.length})';
}

/// Administrative scim group action.
@immutable
class AdminScimGroupAction {
  /// Creates a [AdminScimGroupAction].
  const AdminScimGroupAction({required this.group});

  /// The group field.
  final AdminScimGroupReference group;

  /// Parses a [AdminScimGroupAction] from JSON.
  factory AdminScimGroupAction.fromJson(Map<String, dynamic> json) {
    if (json['group'] == null) {
      throw const FormatException('AdminScimGroupAction: missing group');
    }
    return AdminScimGroupAction(
      group: AdminScimGroupReference.fromJson(
        json['group'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'group': group.toJson()};

  /// Creates a copy with the given fields replaced.
  AdminScimGroupAction copyWith({AdminScimGroupReference? group}) =>
      AdminScimGroupAction(group: group ?? this.group);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimGroupAction &&
          runtimeType == other.runtimeType &&
          group == other.group;

  @override
  int get hashCode => Object.hashAll([group]);

  @override
  String toString() =>
      'AdminScimGroupAction('
      'group: $group)';
}

/// Administrative scim group update action.
@immutable
class AdminScimGroupUpdateAction {
  /// Creates a [AdminScimGroupUpdateAction].
  const AdminScimGroupUpdateAction({
    required this.group,
    required this.previousGroupName,
  });

  /// The group field.
  final AdminScimGroupReference group;

  /// The previous_groupName field.
  final String previousGroupName;

  /// Parses a [AdminScimGroupUpdateAction] from JSON.
  factory AdminScimGroupUpdateAction.fromJson(Map<String, dynamic> json) {
    if (json['group'] == null) {
      throw const FormatException('AdminScimGroupUpdateAction: missing group');
    }
    if (json['previous_groupName'] == null) {
      throw const FormatException(
        'AdminScimGroupUpdateAction: missing previous_groupName',
      );
    }
    return AdminScimGroupUpdateAction(
      group: AdminScimGroupReference.fromJson(
        json['group'] as Map<String, dynamic>,
      ),
      previousGroupName: json['previous_groupName'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'group': group.toJson(),
    'previous_groupName': previousGroupName,
  };

  /// Creates a copy with the given fields replaced.
  AdminScimGroupUpdateAction copyWith({
    AdminScimGroupReference? group,
    String? previousGroupName,
  }) => AdminScimGroupUpdateAction(
    group: group ?? this.group,
    previousGroupName: previousGroupName ?? this.previousGroupName,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimGroupUpdateAction &&
          runtimeType == other.runtimeType &&
          group == other.group &&
          previousGroupName == other.previousGroupName;

  @override
  int get hashCode => Object.hashAll([group, previousGroupName]);

  @override
  String toString() =>
      'AdminScimGroupUpdateAction('
      'group: $group, '
      'previousGroupName: $previousGroupName)';
}

/// Administrative scim group reference.
@immutable
class AdminScimGroupReference {
  /// Creates a [AdminScimGroupReference].
  const AdminScimGroupReference({required this.groupName, required this.uuid});

  /// The groupName field.
  final String groupName;

  /// The uuid field.
  final String uuid;

  /// Parses a [AdminScimGroupReference] from JSON.
  factory AdminScimGroupReference.fromJson(Map<String, dynamic> json) {
    if (json['groupName'] == null) {
      throw const FormatException('AdminScimGroupReference: missing groupName');
    }
    if (json['uuid'] == null) {
      throw const FormatException('AdminScimGroupReference: missing uuid');
    }
    return AdminScimGroupReference(
      groupName: json['groupName'] as String,
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'groupName': groupName, 'uuid': uuid};

  /// Creates a copy with the given fields replaced.
  AdminScimGroupReference copyWith({String? groupName, String? uuid}) =>
      AdminScimGroupReference(
        groupName: groupName ?? this.groupName,
        uuid: uuid ?? this.uuid,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimGroupReference &&
          runtimeType == other.runtimeType &&
          groupName == other.groupName &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([groupName, uuid]);

  @override
  String toString() =>
      'AdminScimGroupReference('
      'groupName: $groupName, '
      'uuid: $uuid)';
}

/// Administrative scim user reference.
@immutable
class AdminScimUserReference {
  /// Creates a [AdminScimUserReference].
  const AdminScimUserReference({this.userName, required this.uuid});

  /// The userName field.
  final String? userName;

  /// The uuid field.
  final String uuid;

  /// Parses a [AdminScimUserReference] from JSON.
  factory AdminScimUserReference.fromJson(Map<String, dynamic> json) {
    if (json['uuid'] == null) {
      throw const FormatException('AdminScimUserReference: missing uuid');
    }
    return AdminScimUserReference(
      userName: json['userName'] == null ? null : json['userName'] as String,
      uuid: json['uuid'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'userName': ?userName, 'uuid': uuid};

  /// Creates a copy with the given fields replaced.
  AdminScimUserReference copyWith({
    Object? userName = unsetCopyWithValue,
    String? uuid,
  }) => AdminScimUserReference(
    userName: userName == unsetCopyWithValue
        ? this.userName
        : userName as String?,
    uuid: uuid ?? this.uuid,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimUserReference &&
          runtimeType == other.runtimeType &&
          userName == other.userName &&
          uuid == other.uuid;

  @override
  int get hashCode => Object.hashAll([userName, uuid]);

  @override
  String toString() =>
      'AdminScimUserReference('
      'userName: $userName, '
      'uuid: $uuid)';
}

/// Administrative scim user action.
@immutable
class AdminScimUserAction {
  /// Creates a [AdminScimUserAction].
  const AdminScimUserAction({required this.user});

  /// The user field.
  final AdminScimUserReference user;

  /// Parses a [AdminScimUserAction] from JSON.
  factory AdminScimUserAction.fromJson(Map<String, dynamic> json) {
    if (json['user'] == null) {
      throw const FormatException('AdminScimUserAction: missing user');
    }
    return AdminScimUserAction(
      user: AdminScimUserReference.fromJson(
        json['user'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'user': user.toJson()};

  /// Creates a copy with the given fields replaced.
  AdminScimUserAction copyWith({AdminScimUserReference? user}) =>
      AdminScimUserAction(user: user ?? this.user);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdminScimUserAction &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => Object.hashAll([user]);

  @override
  String toString() =>
      'AdminScimUserAction('
      'user: $user)';
}
