import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Administrative vibe code organization usage.
@immutable
class VibeCodeOrganizationUsage {
  /// Creates a [VibeCodeOrganizationUsage].
  const VibeCodeOrganizationUsage({
    required this.endTime,
    required this.nextEditActiveUsers,
    required this.nextEditModifiedLoc,
    required this.nextEditSuggestions,
    required this.startTime,
  });

  /// End of the queried window, as a Unix timestamp in seconds.
  final int endTime;

  /// The next_edit_active_users field.
  final List<VibeNextEditActiveUsersStat> nextEditActiveUsers;

  /// The next_edit_modified_loc field.
  final List<VibeNextEditModifiedLinesStat> nextEditModifiedLoc;

  /// The next_edit_suggestions field.
  final List<VibeNextEditSuggestionStat> nextEditSuggestions;

  /// Start of the queried window, as a Unix timestamp in seconds.
  final int startTime;

  /// Parses a [VibeCodeOrganizationUsage] from JSON.
  factory VibeCodeOrganizationUsage.fromJson(Map<String, dynamic> json) {
    if (json['end_time'] == null) {
      throw const FormatException(
        'VibeCodeOrganizationUsage: missing end_time',
      );
    }
    if (json['next_edit_active_users'] == null) {
      throw const FormatException(
        'VibeCodeOrganizationUsage: missing next_edit_active_users',
      );
    }
    if (json['next_edit_modified_loc'] == null) {
      throw const FormatException(
        'VibeCodeOrganizationUsage: missing next_edit_modified_loc',
      );
    }
    if (json['next_edit_suggestions'] == null) {
      throw const FormatException(
        'VibeCodeOrganizationUsage: missing next_edit_suggestions',
      );
    }
    if (json['start_time'] == null) {
      throw const FormatException(
        'VibeCodeOrganizationUsage: missing start_time',
      );
    }
    return VibeCodeOrganizationUsage(
      endTime: json['end_time'] as int,
      nextEditActiveUsers: (json['next_edit_active_users'] as List)
          .map(
            (item) => VibeNextEditActiveUsersStat.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      nextEditModifiedLoc: (json['next_edit_modified_loc'] as List)
          .map(
            (item) => VibeNextEditModifiedLinesStat.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      nextEditSuggestions: (json['next_edit_suggestions'] as List)
          .map(
            (item) => VibeNextEditSuggestionStat.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      startTime: json['start_time'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'end_time': endTime,
    'next_edit_active_users': nextEditActiveUsers
        .map((item) => item.toJson())
        .toList(),
    'next_edit_modified_loc': nextEditModifiedLoc
        .map((item) => item.toJson())
        .toList(),
    'next_edit_suggestions': nextEditSuggestions
        .map((item) => item.toJson())
        .toList(),
    'start_time': startTime,
  };

  /// Creates a copy with the given fields replaced.
  VibeCodeOrganizationUsage copyWith({
    int? endTime,
    List<VibeNextEditActiveUsersStat>? nextEditActiveUsers,
    List<VibeNextEditModifiedLinesStat>? nextEditModifiedLoc,
    List<VibeNextEditSuggestionStat>? nextEditSuggestions,
    int? startTime,
  }) => VibeCodeOrganizationUsage(
    endTime: endTime ?? this.endTime,
    nextEditActiveUsers: nextEditActiveUsers ?? this.nextEditActiveUsers,
    nextEditModifiedLoc: nextEditModifiedLoc ?? this.nextEditModifiedLoc,
    nextEditSuggestions: nextEditSuggestions ?? this.nextEditSuggestions,
    startTime: startTime ?? this.startTime,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeCodeOrganizationUsage &&
          runtimeType == other.runtimeType &&
          endTime == other.endTime &&
          valuesDeepEqual(nextEditActiveUsers, other.nextEditActiveUsers) &&
          valuesDeepEqual(nextEditModifiedLoc, other.nextEditModifiedLoc) &&
          valuesDeepEqual(nextEditSuggestions, other.nextEditSuggestions) &&
          startTime == other.startTime;

  @override
  int get hashCode => Object.hashAll([
    endTime,
    valueDeepHashCode(nextEditActiveUsers),
    valueDeepHashCode(nextEditModifiedLoc),
    valueDeepHashCode(nextEditSuggestions),
    startTime,
  ]);

  @override
  String toString() =>
      'VibeCodeOrganizationUsage('
      'endTime: $endTime, '
      'nextEditActiveUsers: ${nextEditActiveUsers.length}, '
      'nextEditModifiedLoc: ${nextEditModifiedLoc.length}, '
      'nextEditSuggestions: ${nextEditSuggestions.length}, '
      'startTime: $startTime)';
}

/// Administrative vibe code workspace usage.
@immutable
class VibeCodeWorkspaceUsage {
  /// Creates a [VibeCodeWorkspaceUsage].
  const VibeCodeWorkspaceUsage({
    required this.activeUsers,
    required this.consumedTokens,
    required this.endTime,
    required this.sessionDurations,
    required this.sessions,
    required this.startTime,
    required this.toolCalls,
    required this.toolCallsByName,
    required this.userPrompts,
  });

  /// The active_users field.
  final List<VibeActiveUsersStat> activeUsers;

  /// The consumed_tokens field.
  final List<VibeConsumedTokensStat> consumedTokens;

  /// End of the queried window, as a Unix timestamp in seconds.
  final int endTime;

  /// The session_durations field.
  final List<VibeSessionDurationStat> sessionDurations;

  /// The sessions field.
  final List<VibeSessionStat> sessions;

  /// Start of the queried window, as a Unix timestamp in seconds.
  final int startTime;

  /// The tool_calls field.
  final List<VibeToolCallsStat> toolCalls;

  /// The tool_calls_by_name field.
  final List<VibeToolCallsByNameStat> toolCallsByName;

  /// The user_prompts field.
  final List<VibeUserPromptsStat> userPrompts;

  /// Parses a [VibeCodeWorkspaceUsage] from JSON.
  factory VibeCodeWorkspaceUsage.fromJson(Map<String, dynamic> json) {
    if (json['active_users'] == null) {
      throw const FormatException(
        'VibeCodeWorkspaceUsage: missing active_users',
      );
    }
    if (json['consumed_tokens'] == null) {
      throw const FormatException(
        'VibeCodeWorkspaceUsage: missing consumed_tokens',
      );
    }
    if (json['end_time'] == null) {
      throw const FormatException('VibeCodeWorkspaceUsage: missing end_time');
    }
    if (json['session_durations'] == null) {
      throw const FormatException(
        'VibeCodeWorkspaceUsage: missing session_durations',
      );
    }
    if (json['sessions'] == null) {
      throw const FormatException('VibeCodeWorkspaceUsage: missing sessions');
    }
    if (json['start_time'] == null) {
      throw const FormatException('VibeCodeWorkspaceUsage: missing start_time');
    }
    if (json['tool_calls'] == null) {
      throw const FormatException('VibeCodeWorkspaceUsage: missing tool_calls');
    }
    if (json['tool_calls_by_name'] == null) {
      throw const FormatException(
        'VibeCodeWorkspaceUsage: missing tool_calls_by_name',
      );
    }
    if (json['user_prompts'] == null) {
      throw const FormatException(
        'VibeCodeWorkspaceUsage: missing user_prompts',
      );
    }
    return VibeCodeWorkspaceUsage(
      activeUsers: (json['active_users'] as List)
          .map(
            (item) =>
                VibeActiveUsersStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      consumedTokens: (json['consumed_tokens'] as List)
          .map(
            (item) =>
                VibeConsumedTokensStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      endTime: json['end_time'] as int,
      sessionDurations: (json['session_durations'] as List)
          .map(
            (item) =>
                VibeSessionDurationStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      sessions: (json['sessions'] as List)
          .map((item) => VibeSessionStat.fromJson(item as Map<String, dynamic>))
          .toList(),
      startTime: json['start_time'] as int,
      toolCalls: (json['tool_calls'] as List)
          .map(
            (item) => VibeToolCallsStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      toolCallsByName: (json['tool_calls_by_name'] as List)
          .map(
            (item) =>
                VibeToolCallsByNameStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      userPrompts: (json['user_prompts'] as List)
          .map(
            (item) =>
                VibeUserPromptsStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'active_users': activeUsers.map((item) => item.toJson()).toList(),
    'consumed_tokens': consumedTokens.map((item) => item.toJson()).toList(),
    'end_time': endTime,
    'session_durations': sessionDurations.map((item) => item.toJson()).toList(),
    'sessions': sessions.map((item) => item.toJson()).toList(),
    'start_time': startTime,
    'tool_calls': toolCalls.map((item) => item.toJson()).toList(),
    'tool_calls_by_name': toolCallsByName.map((item) => item.toJson()).toList(),
    'user_prompts': userPrompts.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  VibeCodeWorkspaceUsage copyWith({
    List<VibeActiveUsersStat>? activeUsers,
    List<VibeConsumedTokensStat>? consumedTokens,
    int? endTime,
    List<VibeSessionDurationStat>? sessionDurations,
    List<VibeSessionStat>? sessions,
    int? startTime,
    List<VibeToolCallsStat>? toolCalls,
    List<VibeToolCallsByNameStat>? toolCallsByName,
    List<VibeUserPromptsStat>? userPrompts,
  }) => VibeCodeWorkspaceUsage(
    activeUsers: activeUsers ?? this.activeUsers,
    consumedTokens: consumedTokens ?? this.consumedTokens,
    endTime: endTime ?? this.endTime,
    sessionDurations: sessionDurations ?? this.sessionDurations,
    sessions: sessions ?? this.sessions,
    startTime: startTime ?? this.startTime,
    toolCalls: toolCalls ?? this.toolCalls,
    toolCallsByName: toolCallsByName ?? this.toolCallsByName,
    userPrompts: userPrompts ?? this.userPrompts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeCodeWorkspaceUsage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(activeUsers, other.activeUsers) &&
          valuesDeepEqual(consumedTokens, other.consumedTokens) &&
          endTime == other.endTime &&
          valuesDeepEqual(sessionDurations, other.sessionDurations) &&
          valuesDeepEqual(sessions, other.sessions) &&
          startTime == other.startTime &&
          valuesDeepEqual(toolCalls, other.toolCalls) &&
          valuesDeepEqual(toolCallsByName, other.toolCallsByName) &&
          valuesDeepEqual(userPrompts, other.userPrompts);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(activeUsers),
    valueDeepHashCode(consumedTokens),
    endTime,
    valueDeepHashCode(sessionDurations),
    valueDeepHashCode(sessions),
    startTime,
    valueDeepHashCode(toolCalls),
    valueDeepHashCode(toolCallsByName),
    valueDeepHashCode(userPrompts),
  ]);

  @override
  String toString() =>
      'VibeCodeWorkspaceUsage('
      'activeUsers: ${activeUsers.length}, '
      'consumedTokens: ${consumedTokens.length}, '
      'endTime: $endTime, '
      'sessionDurations: ${sessionDurations.length}, '
      'sessions: ${sessions.length}, '
      'startTime: $startTime, '
      'toolCalls: ${toolCalls.length}, '
      'toolCallsByName: ${toolCallsByName.length}, '
      'userPrompts: ${userPrompts.length})';
}

/// Administrative vibe work agent usage.
@immutable
class VibeWorkAgentUsage {
  /// Creates a [VibeWorkAgentUsage].
  const VibeWorkAgentUsage({
    required this.data,
    required this.endTime,
    required this.startTime,
  });

  /// The data field.
  final List<VibeWorkByAgentStat> data;

  /// End of the queried window, as a Unix timestamp in seconds.
  final int endTime;

  /// Start of the queried window, as a Unix timestamp in seconds.
  final int startTime;

  /// Parses a [VibeWorkAgentUsage] from JSON.
  factory VibeWorkAgentUsage.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('VibeWorkAgentUsage: missing data');
    }
    if (json['end_time'] == null) {
      throw const FormatException('VibeWorkAgentUsage: missing end_time');
    }
    if (json['start_time'] == null) {
      throw const FormatException('VibeWorkAgentUsage: missing start_time');
    }
    return VibeWorkAgentUsage(
      data: (json['data'] as List)
          .map(
            (item) =>
                VibeWorkByAgentStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      endTime: json['end_time'] as int,
      startTime: json['start_time'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'end_time': endTime,
    'start_time': startTime,
  };

  /// Creates a copy with the given fields replaced.
  VibeWorkAgentUsage copyWith({
    List<VibeWorkByAgentStat>? data,
    int? endTime,
    int? startTime,
  }) => VibeWorkAgentUsage(
    data: data ?? this.data,
    endTime: endTime ?? this.endTime,
    startTime: startTime ?? this.startTime,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeWorkAgentUsage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          endTime == other.endTime &&
          startTime == other.startTime;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(data), endTime, startTime]);

  @override
  String toString() =>
      'VibeWorkAgentUsage('
      'data: ${data.length}, '
      'endTime: $endTime, '
      'startTime: $startTime)';
}

/// Administrative vibe work time usage.
@immutable
class VibeWorkTimeUsage {
  /// Creates a [VibeWorkTimeUsage].
  const VibeWorkTimeUsage({
    required this.data,
    required this.endTime,
    required this.startTime,
  });

  /// The data field.
  final List<VibeWorkByTimeStat> data;

  /// End of the queried window, as a Unix timestamp in seconds.
  final int endTime;

  /// Start of the queried window, as a Unix timestamp in seconds.
  final int startTime;

  /// Parses a [VibeWorkTimeUsage] from JSON.
  factory VibeWorkTimeUsage.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('VibeWorkTimeUsage: missing data');
    }
    if (json['end_time'] == null) {
      throw const FormatException('VibeWorkTimeUsage: missing end_time');
    }
    if (json['start_time'] == null) {
      throw const FormatException('VibeWorkTimeUsage: missing start_time');
    }
    return VibeWorkTimeUsage(
      data: (json['data'] as List)
          .map(
            (item) => VibeWorkByTimeStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      endTime: json['end_time'] as int,
      startTime: json['start_time'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'end_time': endTime,
    'start_time': startTime,
  };

  /// Creates a copy with the given fields replaced.
  VibeWorkTimeUsage copyWith({
    List<VibeWorkByTimeStat>? data,
    int? endTime,
    int? startTime,
  }) => VibeWorkTimeUsage(
    data: data ?? this.data,
    endTime: endTime ?? this.endTime,
    startTime: startTime ?? this.startTime,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeWorkTimeUsage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          endTime == other.endTime &&
          startTime == other.startTime;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(data), endTime, startTime]);

  @override
  String toString() =>
      'VibeWorkTimeUsage('
      'data: ${data.length}, '
      'endTime: $endTime, '
      'startTime: $startTime)';
}

/// Administrative vibe work user usage.
@immutable
class VibeWorkUserUsage {
  /// Creates a [VibeWorkUserUsage].
  const VibeWorkUserUsage({
    required this.data,
    required this.endTime,
    required this.startTime,
  });

  /// The data field.
  final List<VibeWorkByUserStat> data;

  /// End of the queried window, as a Unix timestamp in seconds.
  final int endTime;

  /// Start of the queried window, as a Unix timestamp in seconds.
  final int startTime;

  /// Parses a [VibeWorkUserUsage] from JSON.
  factory VibeWorkUserUsage.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('VibeWorkUserUsage: missing data');
    }
    if (json['end_time'] == null) {
      throw const FormatException('VibeWorkUserUsage: missing end_time');
    }
    if (json['start_time'] == null) {
      throw const FormatException('VibeWorkUserUsage: missing start_time');
    }
    return VibeWorkUserUsage(
      data: (json['data'] as List)
          .map(
            (item) => VibeWorkByUserStat.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      endTime: json['end_time'] as int,
      startTime: json['start_time'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'end_time': endTime,
    'start_time': startTime,
  };

  /// Creates a copy with the given fields replaced.
  VibeWorkUserUsage copyWith({
    List<VibeWorkByUserStat>? data,
    int? endTime,
    int? startTime,
  }) => VibeWorkUserUsage(
    data: data ?? this.data,
    endTime: endTime ?? this.endTime,
    startTime: startTime ?? this.startTime,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeWorkUserUsage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          endTime == other.endTime &&
          startTime == other.startTime;

  @override
  int get hashCode =>
      Object.hashAll([valueDeepHashCode(data), endTime, startTime]);

  @override
  String toString() =>
      'VibeWorkUserUsage('
      'data: ${data.length}, '
      'endTime: $endTime, '
      'startTime: $startTime)';
}

/// Administrative vibe next edit active users stat.
@immutable
class VibeNextEditActiveUsersStat {
  /// Creates a [VibeNextEditActiveUsersStat].
  const VibeNextEditActiveUsersStat({
    required this.day,
    required this.nbActiveUsers,
  });

  /// The day field.
  final String day;

  /// The nb_active_users field.
  final int nbActiveUsers;

  /// Parses a [VibeNextEditActiveUsersStat] from JSON.
  factory VibeNextEditActiveUsersStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeNextEditActiveUsersStat: missing day');
    }
    if (json['nb_active_users'] == null) {
      throw const FormatException(
        'VibeNextEditActiveUsersStat: missing nb_active_users',
      );
    }
    return VibeNextEditActiveUsersStat(
      day: json['day'] as String,
      nbActiveUsers: json['nb_active_users'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'nb_active_users': nbActiveUsers,
  };

  /// Creates a copy with the given fields replaced.
  VibeNextEditActiveUsersStat copyWith({String? day, int? nbActiveUsers}) =>
      VibeNextEditActiveUsersStat(
        day: day ?? this.day,
        nbActiveUsers: nbActiveUsers ?? this.nbActiveUsers,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeNextEditActiveUsersStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          nbActiveUsers == other.nbActiveUsers;

  @override
  int get hashCode => Object.hashAll([day, nbActiveUsers]);

  @override
  String toString() =>
      'VibeNextEditActiveUsersStat('
      'day: $day, '
      'nbActiveUsers: $nbActiveUsers)';
}

/// Administrative vibe next edit modified lines stat.
@immutable
class VibeNextEditModifiedLinesStat {
  /// Creates a [VibeNextEditModifiedLinesStat].
  const VibeNextEditModifiedLinesStat({
    required this.day,
    required this.linesDeleted,
    required this.linesInserted,
    required this.linesTotal,
    required this.linesUnchanged,
  });

  /// The day field.
  final String day;

  /// The lines_deleted field.
  final int linesDeleted;

  /// The lines_inserted field.
  final int linesInserted;

  /// The lines_total field.
  final int linesTotal;

  /// The lines_unchanged field.
  final int linesUnchanged;

  /// Parses a [VibeNextEditModifiedLinesStat] from JSON.
  factory VibeNextEditModifiedLinesStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeNextEditModifiedLinesStat: missing day');
    }
    if (json['lines_deleted'] == null) {
      throw const FormatException(
        'VibeNextEditModifiedLinesStat: missing lines_deleted',
      );
    }
    if (json['lines_inserted'] == null) {
      throw const FormatException(
        'VibeNextEditModifiedLinesStat: missing lines_inserted',
      );
    }
    if (json['lines_total'] == null) {
      throw const FormatException(
        'VibeNextEditModifiedLinesStat: missing lines_total',
      );
    }
    if (json['lines_unchanged'] == null) {
      throw const FormatException(
        'VibeNextEditModifiedLinesStat: missing lines_unchanged',
      );
    }
    return VibeNextEditModifiedLinesStat(
      day: json['day'] as String,
      linesDeleted: json['lines_deleted'] as int,
      linesInserted: json['lines_inserted'] as int,
      linesTotal: json['lines_total'] as int,
      linesUnchanged: json['lines_unchanged'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'lines_deleted': linesDeleted,
    'lines_inserted': linesInserted,
    'lines_total': linesTotal,
    'lines_unchanged': linesUnchanged,
  };

  /// Creates a copy with the given fields replaced.
  VibeNextEditModifiedLinesStat copyWith({
    String? day,
    int? linesDeleted,
    int? linesInserted,
    int? linesTotal,
    int? linesUnchanged,
  }) => VibeNextEditModifiedLinesStat(
    day: day ?? this.day,
    linesDeleted: linesDeleted ?? this.linesDeleted,
    linesInserted: linesInserted ?? this.linesInserted,
    linesTotal: linesTotal ?? this.linesTotal,
    linesUnchanged: linesUnchanged ?? this.linesUnchanged,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeNextEditModifiedLinesStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          linesDeleted == other.linesDeleted &&
          linesInserted == other.linesInserted &&
          linesTotal == other.linesTotal &&
          linesUnchanged == other.linesUnchanged;

  @override
  int get hashCode => Object.hashAll([
    day,
    linesDeleted,
    linesInserted,
    linesTotal,
    linesUnchanged,
  ]);

  @override
  String toString() =>
      'VibeNextEditModifiedLinesStat('
      'day: $day, '
      'linesDeleted: $linesDeleted, '
      'linesInserted: $linesInserted, '
      'linesTotal: $linesTotal, '
      'linesUnchanged: $linesUnchanged)';
}

/// Administrative vibe next edit suggestion stat.
@immutable
class VibeNextEditSuggestionStat {
  /// Creates a [VibeNextEditSuggestionStat].
  const VibeNextEditSuggestionStat({
    required this.day,
    required this.forceGeneratedFalse,
    required this.forceGeneratedTrue,
    required this.outcomeAborted,
    required this.outcomeAccepted,
    required this.outcomeDismissed,
    required this.outcomeRejected,
    required this.outcomeTimeout,
    required this.surfaceGhostText,
    required this.surfaceWidget,
    required this.totalSuggestions,
  });

  /// The day field.
  final String day;

  /// The force_generated_false field.
  final int forceGeneratedFalse;

  /// The force_generated_true field.
  final int forceGeneratedTrue;

  /// The outcome_aborted field.
  final int outcomeAborted;

  /// The outcome_accepted field.
  final int outcomeAccepted;

  /// The outcome_dismissed field.
  final int outcomeDismissed;

  /// The outcome_rejected field.
  final int outcomeRejected;

  /// The outcome_timeout field.
  final int outcomeTimeout;

  /// The surface_ghost_text field.
  final int surfaceGhostText;

  /// The surface_widget field.
  final int surfaceWidget;

  /// The total_suggestions field.
  final int totalSuggestions;

  /// Parses a [VibeNextEditSuggestionStat] from JSON.
  factory VibeNextEditSuggestionStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeNextEditSuggestionStat: missing day');
    }
    if (json['force_generated_false'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing force_generated_false',
      );
    }
    if (json['force_generated_true'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing force_generated_true',
      );
    }
    if (json['outcome_aborted'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing outcome_aborted',
      );
    }
    if (json['outcome_accepted'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing outcome_accepted',
      );
    }
    if (json['outcome_dismissed'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing outcome_dismissed',
      );
    }
    if (json['outcome_rejected'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing outcome_rejected',
      );
    }
    if (json['outcome_timeout'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing outcome_timeout',
      );
    }
    if (json['surface_ghost_text'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing surface_ghost_text',
      );
    }
    if (json['surface_widget'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing surface_widget',
      );
    }
    if (json['total_suggestions'] == null) {
      throw const FormatException(
        'VibeNextEditSuggestionStat: missing total_suggestions',
      );
    }
    return VibeNextEditSuggestionStat(
      day: json['day'] as String,
      forceGeneratedFalse: json['force_generated_false'] as int,
      forceGeneratedTrue: json['force_generated_true'] as int,
      outcomeAborted: json['outcome_aborted'] as int,
      outcomeAccepted: json['outcome_accepted'] as int,
      outcomeDismissed: json['outcome_dismissed'] as int,
      outcomeRejected: json['outcome_rejected'] as int,
      outcomeTimeout: json['outcome_timeout'] as int,
      surfaceGhostText: json['surface_ghost_text'] as int,
      surfaceWidget: json['surface_widget'] as int,
      totalSuggestions: json['total_suggestions'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'force_generated_false': forceGeneratedFalse,
    'force_generated_true': forceGeneratedTrue,
    'outcome_aborted': outcomeAborted,
    'outcome_accepted': outcomeAccepted,
    'outcome_dismissed': outcomeDismissed,
    'outcome_rejected': outcomeRejected,
    'outcome_timeout': outcomeTimeout,
    'surface_ghost_text': surfaceGhostText,
    'surface_widget': surfaceWidget,
    'total_suggestions': totalSuggestions,
  };

  /// Creates a copy with the given fields replaced.
  VibeNextEditSuggestionStat copyWith({
    String? day,
    int? forceGeneratedFalse,
    int? forceGeneratedTrue,
    int? outcomeAborted,
    int? outcomeAccepted,
    int? outcomeDismissed,
    int? outcomeRejected,
    int? outcomeTimeout,
    int? surfaceGhostText,
    int? surfaceWidget,
    int? totalSuggestions,
  }) => VibeNextEditSuggestionStat(
    day: day ?? this.day,
    forceGeneratedFalse: forceGeneratedFalse ?? this.forceGeneratedFalse,
    forceGeneratedTrue: forceGeneratedTrue ?? this.forceGeneratedTrue,
    outcomeAborted: outcomeAborted ?? this.outcomeAborted,
    outcomeAccepted: outcomeAccepted ?? this.outcomeAccepted,
    outcomeDismissed: outcomeDismissed ?? this.outcomeDismissed,
    outcomeRejected: outcomeRejected ?? this.outcomeRejected,
    outcomeTimeout: outcomeTimeout ?? this.outcomeTimeout,
    surfaceGhostText: surfaceGhostText ?? this.surfaceGhostText,
    surfaceWidget: surfaceWidget ?? this.surfaceWidget,
    totalSuggestions: totalSuggestions ?? this.totalSuggestions,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeNextEditSuggestionStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          forceGeneratedFalse == other.forceGeneratedFalse &&
          forceGeneratedTrue == other.forceGeneratedTrue &&
          outcomeAborted == other.outcomeAborted &&
          outcomeAccepted == other.outcomeAccepted &&
          outcomeDismissed == other.outcomeDismissed &&
          outcomeRejected == other.outcomeRejected &&
          outcomeTimeout == other.outcomeTimeout &&
          surfaceGhostText == other.surfaceGhostText &&
          surfaceWidget == other.surfaceWidget &&
          totalSuggestions == other.totalSuggestions;

  @override
  int get hashCode => Object.hashAll([
    day,
    forceGeneratedFalse,
    forceGeneratedTrue,
    outcomeAborted,
    outcomeAccepted,
    outcomeDismissed,
    outcomeRejected,
    outcomeTimeout,
    surfaceGhostText,
    surfaceWidget,
    totalSuggestions,
  ]);

  @override
  String toString() =>
      'VibeNextEditSuggestionStat('
      'day: $day, '
      'forceGeneratedFalse: $forceGeneratedFalse, '
      'forceGeneratedTrue: $forceGeneratedTrue, '
      'outcomeAborted: $outcomeAborted, '
      'outcomeAccepted: $outcomeAccepted, '
      'outcomeDismissed: $outcomeDismissed, '
      'outcomeRejected: $outcomeRejected, '
      'outcomeTimeout: $outcomeTimeout, '
      'surfaceGhostText: $surfaceGhostText, '
      'surfaceWidget: $surfaceWidget, '
      'totalSuggestions: $totalSuggestions)';
}

/// Administrative vibe active users stat.
@immutable
class VibeActiveUsersStat {
  /// Creates a [VibeActiveUsersStat].
  const VibeActiveUsersStat({
    required this.day,
    required this.nbActiveUsersAcp,
    required this.nbActiveUsersCli,
    required this.nbActiveUsersProgrammatic,
    required this.nbActiveUsersTotal,
  });

  /// The day field.
  final String day;

  /// The nb_active_users_acp field.
  final int nbActiveUsersAcp;

  /// The nb_active_users_cli field.
  final int nbActiveUsersCli;

  /// The nb_active_users_programmatic field.
  final int nbActiveUsersProgrammatic;

  /// The nb_active_users_total field.
  final int nbActiveUsersTotal;

  /// Parses a [VibeActiveUsersStat] from JSON.
  factory VibeActiveUsersStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeActiveUsersStat: missing day');
    }
    if (json['nb_active_users_acp'] == null) {
      throw const FormatException(
        'VibeActiveUsersStat: missing nb_active_users_acp',
      );
    }
    if (json['nb_active_users_cli'] == null) {
      throw const FormatException(
        'VibeActiveUsersStat: missing nb_active_users_cli',
      );
    }
    if (json['nb_active_users_programmatic'] == null) {
      throw const FormatException(
        'VibeActiveUsersStat: missing nb_active_users_programmatic',
      );
    }
    if (json['nb_active_users_total'] == null) {
      throw const FormatException(
        'VibeActiveUsersStat: missing nb_active_users_total',
      );
    }
    return VibeActiveUsersStat(
      day: json['day'] as String,
      nbActiveUsersAcp: json['nb_active_users_acp'] as int,
      nbActiveUsersCli: json['nb_active_users_cli'] as int,
      nbActiveUsersProgrammatic: json['nb_active_users_programmatic'] as int,
      nbActiveUsersTotal: json['nb_active_users_total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'nb_active_users_acp': nbActiveUsersAcp,
    'nb_active_users_cli': nbActiveUsersCli,
    'nb_active_users_programmatic': nbActiveUsersProgrammatic,
    'nb_active_users_total': nbActiveUsersTotal,
  };

  /// Creates a copy with the given fields replaced.
  VibeActiveUsersStat copyWith({
    String? day,
    int? nbActiveUsersAcp,
    int? nbActiveUsersCli,
    int? nbActiveUsersProgrammatic,
    int? nbActiveUsersTotal,
  }) => VibeActiveUsersStat(
    day: day ?? this.day,
    nbActiveUsersAcp: nbActiveUsersAcp ?? this.nbActiveUsersAcp,
    nbActiveUsersCli: nbActiveUsersCli ?? this.nbActiveUsersCli,
    nbActiveUsersProgrammatic:
        nbActiveUsersProgrammatic ?? this.nbActiveUsersProgrammatic,
    nbActiveUsersTotal: nbActiveUsersTotal ?? this.nbActiveUsersTotal,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeActiveUsersStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          nbActiveUsersAcp == other.nbActiveUsersAcp &&
          nbActiveUsersCli == other.nbActiveUsersCli &&
          nbActiveUsersProgrammatic == other.nbActiveUsersProgrammatic &&
          nbActiveUsersTotal == other.nbActiveUsersTotal;

  @override
  int get hashCode => Object.hashAll([
    day,
    nbActiveUsersAcp,
    nbActiveUsersCli,
    nbActiveUsersProgrammatic,
    nbActiveUsersTotal,
  ]);

  @override
  String toString() =>
      'VibeActiveUsersStat('
      'day: $day, '
      'nbActiveUsersAcp: $nbActiveUsersAcp, '
      'nbActiveUsersCli: $nbActiveUsersCli, '
      'nbActiveUsersProgrammatic: $nbActiveUsersProgrammatic, '
      'nbActiveUsersTotal: $nbActiveUsersTotal)';
}

/// Administrative vibe consumed tokens stat.
@immutable
class VibeConsumedTokensStat {
  /// Creates a [VibeConsumedTokensStat].
  const VibeConsumedTokensStat({
    required this.cachedTokens,
    required this.day,
    required this.inputTokens,
    required this.model,
    required this.outputTokens,
  });

  /// The cached_tokens field.
  final int cachedTokens;

  /// The day field.
  final String day;

  /// The input_tokens field.
  final int inputTokens;

  /// The model field.
  final String model;

  /// The output_tokens field.
  final int outputTokens;

  /// Parses a [VibeConsumedTokensStat] from JSON.
  factory VibeConsumedTokensStat.fromJson(Map<String, dynamic> json) {
    if (json['cached_tokens'] == null) {
      throw const FormatException(
        'VibeConsumedTokensStat: missing cached_tokens',
      );
    }
    if (json['day'] == null) {
      throw const FormatException('VibeConsumedTokensStat: missing day');
    }
    if (json['input_tokens'] == null) {
      throw const FormatException(
        'VibeConsumedTokensStat: missing input_tokens',
      );
    }
    if (json['model'] == null) {
      throw const FormatException('VibeConsumedTokensStat: missing model');
    }
    if (json['output_tokens'] == null) {
      throw const FormatException(
        'VibeConsumedTokensStat: missing output_tokens',
      );
    }
    return VibeConsumedTokensStat(
      cachedTokens: json['cached_tokens'] as int,
      day: json['day'] as String,
      inputTokens: json['input_tokens'] as int,
      model: json['model'] as String,
      outputTokens: json['output_tokens'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'cached_tokens': cachedTokens,
    'day': day,
    'input_tokens': inputTokens,
    'model': model,
    'output_tokens': outputTokens,
  };

  /// Creates a copy with the given fields replaced.
  VibeConsumedTokensStat copyWith({
    int? cachedTokens,
    String? day,
    int? inputTokens,
    String? model,
    int? outputTokens,
  }) => VibeConsumedTokensStat(
    cachedTokens: cachedTokens ?? this.cachedTokens,
    day: day ?? this.day,
    inputTokens: inputTokens ?? this.inputTokens,
    model: model ?? this.model,
    outputTokens: outputTokens ?? this.outputTokens,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeConsumedTokensStat &&
          runtimeType == other.runtimeType &&
          cachedTokens == other.cachedTokens &&
          day == other.day &&
          inputTokens == other.inputTokens &&
          model == other.model &&
          outputTokens == other.outputTokens;

  @override
  int get hashCode =>
      Object.hashAll([cachedTokens, day, inputTokens, model, outputTokens]);

  @override
  String toString() =>
      'VibeConsumedTokensStat('
      'cachedTokens: $cachedTokens, '
      'day: $day, '
      'inputTokens: $inputTokens, '
      'model: $model, '
      'outputTokens: $outputTokens)';
}

/// Administrative vibe session duration stat.
@immutable
class VibeSessionDurationStat {
  /// Creates a [VibeSessionDurationStat].
  const VibeSessionDurationStat({
    required this.day,
    required this.totalDurationHours,
  });

  /// The day field.
  final String day;

  /// The total_duration_hours field.
  final double totalDurationHours;

  /// Parses a [VibeSessionDurationStat] from JSON.
  factory VibeSessionDurationStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeSessionDurationStat: missing day');
    }
    if (json['total_duration_hours'] == null) {
      throw const FormatException(
        'VibeSessionDurationStat: missing total_duration_hours',
      );
    }
    return VibeSessionDurationStat(
      day: json['day'] as String,
      totalDurationHours: (json['total_duration_hours'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'total_duration_hours': totalDurationHours,
  };

  /// Creates a copy with the given fields replaced.
  VibeSessionDurationStat copyWith({String? day, double? totalDurationHours}) =>
      VibeSessionDurationStat(
        day: day ?? this.day,
        totalDurationHours: totalDurationHours ?? this.totalDurationHours,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeSessionDurationStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          totalDurationHours == other.totalDurationHours;

  @override
  int get hashCode => Object.hashAll([day, totalDurationHours]);

  @override
  String toString() =>
      'VibeSessionDurationStat('
      'day: $day, '
      'totalDurationHours: $totalDurationHours)';
}

/// Administrative vibe session stat.
@immutable
class VibeSessionStat {
  /// Creates a [VibeSessionStat].
  const VibeSessionStat({
    required this.day,
    required this.nbSessions,
    required this.nbSessionsAcp,
    required this.nbSessionsCli,
    required this.nbSessionsProgrammatic,
  });

  /// The day field.
  final String day;

  /// The nb_sessions field.
  final int nbSessions;

  /// The nb_sessions_acp field.
  final int nbSessionsAcp;

  /// The nb_sessions_cli field.
  final int nbSessionsCli;

  /// The nb_sessions_programmatic field.
  final int nbSessionsProgrammatic;

  /// Parses a [VibeSessionStat] from JSON.
  factory VibeSessionStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeSessionStat: missing day');
    }
    if (json['nb_sessions'] == null) {
      throw const FormatException('VibeSessionStat: missing nb_sessions');
    }
    if (json['nb_sessions_acp'] == null) {
      throw const FormatException('VibeSessionStat: missing nb_sessions_acp');
    }
    if (json['nb_sessions_cli'] == null) {
      throw const FormatException('VibeSessionStat: missing nb_sessions_cli');
    }
    if (json['nb_sessions_programmatic'] == null) {
      throw const FormatException(
        'VibeSessionStat: missing nb_sessions_programmatic',
      );
    }
    return VibeSessionStat(
      day: json['day'] as String,
      nbSessions: json['nb_sessions'] as int,
      nbSessionsAcp: json['nb_sessions_acp'] as int,
      nbSessionsCli: json['nb_sessions_cli'] as int,
      nbSessionsProgrammatic: json['nb_sessions_programmatic'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'nb_sessions': nbSessions,
    'nb_sessions_acp': nbSessionsAcp,
    'nb_sessions_cli': nbSessionsCli,
    'nb_sessions_programmatic': nbSessionsProgrammatic,
  };

  /// Creates a copy with the given fields replaced.
  VibeSessionStat copyWith({
    String? day,
    int? nbSessions,
    int? nbSessionsAcp,
    int? nbSessionsCli,
    int? nbSessionsProgrammatic,
  }) => VibeSessionStat(
    day: day ?? this.day,
    nbSessions: nbSessions ?? this.nbSessions,
    nbSessionsAcp: nbSessionsAcp ?? this.nbSessionsAcp,
    nbSessionsCli: nbSessionsCli ?? this.nbSessionsCli,
    nbSessionsProgrammatic:
        nbSessionsProgrammatic ?? this.nbSessionsProgrammatic,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeSessionStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          nbSessions == other.nbSessions &&
          nbSessionsAcp == other.nbSessionsAcp &&
          nbSessionsCli == other.nbSessionsCli &&
          nbSessionsProgrammatic == other.nbSessionsProgrammatic;

  @override
  int get hashCode => Object.hashAll([
    day,
    nbSessions,
    nbSessionsAcp,
    nbSessionsCli,
    nbSessionsProgrammatic,
  ]);

  @override
  String toString() =>
      'VibeSessionStat('
      'day: $day, '
      'nbSessions: $nbSessions, '
      'nbSessionsAcp: $nbSessionsAcp, '
      'nbSessionsCli: $nbSessionsCli, '
      'nbSessionsProgrammatic: $nbSessionsProgrammatic)';
}

/// Administrative vibe tool calls stat.
@immutable
class VibeToolCallsStat {
  /// Creates a [VibeToolCallsStat].
  const VibeToolCallsStat({
    required this.approvalAlways,
    required this.approvalAsk,
    required this.approvalNever,
    required this.day,
    required this.statusFailure,
    required this.statusSkipped,
    required this.statusSuccess,
    required this.total,
  });

  /// The approval_always field.
  final int approvalAlways;

  /// The approval_ask field.
  final int approvalAsk;

  /// The approval_never field.
  final int approvalNever;

  /// The day field.
  final String day;

  /// The status_failure field.
  final int statusFailure;

  /// The status_skipped field.
  final int statusSkipped;

  /// The status_success field.
  final int statusSuccess;

  /// The total field.
  final int total;

  /// Parses a [VibeToolCallsStat] from JSON.
  factory VibeToolCallsStat.fromJson(Map<String, dynamic> json) {
    if (json['approval_always'] == null) {
      throw const FormatException('VibeToolCallsStat: missing approval_always');
    }
    if (json['approval_ask'] == null) {
      throw const FormatException('VibeToolCallsStat: missing approval_ask');
    }
    if (json['approval_never'] == null) {
      throw const FormatException('VibeToolCallsStat: missing approval_never');
    }
    if (json['day'] == null) {
      throw const FormatException('VibeToolCallsStat: missing day');
    }
    if (json['status_failure'] == null) {
      throw const FormatException('VibeToolCallsStat: missing status_failure');
    }
    if (json['status_skipped'] == null) {
      throw const FormatException('VibeToolCallsStat: missing status_skipped');
    }
    if (json['status_success'] == null) {
      throw const FormatException('VibeToolCallsStat: missing status_success');
    }
    if (json['total'] == null) {
      throw const FormatException('VibeToolCallsStat: missing total');
    }
    return VibeToolCallsStat(
      approvalAlways: json['approval_always'] as int,
      approvalAsk: json['approval_ask'] as int,
      approvalNever: json['approval_never'] as int,
      day: json['day'] as String,
      statusFailure: json['status_failure'] as int,
      statusSkipped: json['status_skipped'] as int,
      statusSuccess: json['status_success'] as int,
      total: json['total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'approval_always': approvalAlways,
    'approval_ask': approvalAsk,
    'approval_never': approvalNever,
    'day': day,
    'status_failure': statusFailure,
    'status_skipped': statusSkipped,
    'status_success': statusSuccess,
    'total': total,
  };

  /// Creates a copy with the given fields replaced.
  VibeToolCallsStat copyWith({
    int? approvalAlways,
    int? approvalAsk,
    int? approvalNever,
    String? day,
    int? statusFailure,
    int? statusSkipped,
    int? statusSuccess,
    int? total,
  }) => VibeToolCallsStat(
    approvalAlways: approvalAlways ?? this.approvalAlways,
    approvalAsk: approvalAsk ?? this.approvalAsk,
    approvalNever: approvalNever ?? this.approvalNever,
    day: day ?? this.day,
    statusFailure: statusFailure ?? this.statusFailure,
    statusSkipped: statusSkipped ?? this.statusSkipped,
    statusSuccess: statusSuccess ?? this.statusSuccess,
    total: total ?? this.total,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeToolCallsStat &&
          runtimeType == other.runtimeType &&
          approvalAlways == other.approvalAlways &&
          approvalAsk == other.approvalAsk &&
          approvalNever == other.approvalNever &&
          day == other.day &&
          statusFailure == other.statusFailure &&
          statusSkipped == other.statusSkipped &&
          statusSuccess == other.statusSuccess &&
          total == other.total;

  @override
  int get hashCode => Object.hashAll([
    approvalAlways,
    approvalAsk,
    approvalNever,
    day,
    statusFailure,
    statusSkipped,
    statusSuccess,
    total,
  ]);

  @override
  String toString() =>
      'VibeToolCallsStat('
      'approvalAlways: $approvalAlways, '
      'approvalAsk: $approvalAsk, '
      'approvalNever: $approvalNever, '
      'day: $day, '
      'statusFailure: $statusFailure, '
      'statusSkipped: $statusSkipped, '
      'statusSuccess: $statusSuccess, '
      'total: $total)';
}

/// Administrative vibe tool calls by name stat.
@immutable
class VibeToolCallsByNameStat {
  /// Creates a [VibeToolCallsByNameStat].
  const VibeToolCallsByNameStat({
    required this.count,
    required this.day,
    required this.toolName,
  });

  /// The count field.
  final int count;

  /// The day field.
  final String day;

  /// The tool_name field.
  final String toolName;

  /// Parses a [VibeToolCallsByNameStat] from JSON.
  factory VibeToolCallsByNameStat.fromJson(Map<String, dynamic> json) {
    if (json['count'] == null) {
      throw const FormatException('VibeToolCallsByNameStat: missing count');
    }
    if (json['day'] == null) {
      throw const FormatException('VibeToolCallsByNameStat: missing day');
    }
    if (json['tool_name'] == null) {
      throw const FormatException('VibeToolCallsByNameStat: missing tool_name');
    }
    return VibeToolCallsByNameStat(
      count: json['count'] as int,
      day: json['day'] as String,
      toolName: json['tool_name'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'count': count,
    'day': day,
    'tool_name': toolName,
  };

  /// Creates a copy with the given fields replaced.
  VibeToolCallsByNameStat copyWith({
    int? count,
    String? day,
    String? toolName,
  }) => VibeToolCallsByNameStat(
    count: count ?? this.count,
    day: day ?? this.day,
    toolName: toolName ?? this.toolName,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeToolCallsByNameStat &&
          runtimeType == other.runtimeType &&
          count == other.count &&
          day == other.day &&
          toolName == other.toolName;

  @override
  int get hashCode => Object.hashAll([count, day, toolName]);

  @override
  String toString() =>
      'VibeToolCallsByNameStat('
      'count: $count, '
      'day: $day, '
      'toolName: $toolName)';
}

/// Administrative vibe user prompts stat.
@immutable
class VibeUserPromptsStat {
  /// Creates a [VibeUserPromptsStat].
  const VibeUserPromptsStat({
    required this.day,
    required this.nbPromptsAcp,
    required this.nbPromptsCli,
    required this.nbPromptsProgrammatic,
    required this.nbPromptsTotal,
  });

  /// The day field.
  final String day;

  /// The nb_prompts_acp field.
  final int nbPromptsAcp;

  /// The nb_prompts_cli field.
  final int nbPromptsCli;

  /// The nb_prompts_programmatic field.
  final int nbPromptsProgrammatic;

  /// The nb_prompts_total field.
  final int nbPromptsTotal;

  /// Parses a [VibeUserPromptsStat] from JSON.
  factory VibeUserPromptsStat.fromJson(Map<String, dynamic> json) {
    if (json['day'] == null) {
      throw const FormatException('VibeUserPromptsStat: missing day');
    }
    if (json['nb_prompts_acp'] == null) {
      throw const FormatException(
        'VibeUserPromptsStat: missing nb_prompts_acp',
      );
    }
    if (json['nb_prompts_cli'] == null) {
      throw const FormatException(
        'VibeUserPromptsStat: missing nb_prompts_cli',
      );
    }
    if (json['nb_prompts_programmatic'] == null) {
      throw const FormatException(
        'VibeUserPromptsStat: missing nb_prompts_programmatic',
      );
    }
    if (json['nb_prompts_total'] == null) {
      throw const FormatException(
        'VibeUserPromptsStat: missing nb_prompts_total',
      );
    }
    return VibeUserPromptsStat(
      day: json['day'] as String,
      nbPromptsAcp: json['nb_prompts_acp'] as int,
      nbPromptsCli: json['nb_prompts_cli'] as int,
      nbPromptsProgrammatic: json['nb_prompts_programmatic'] as int,
      nbPromptsTotal: json['nb_prompts_total'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'day': day,
    'nb_prompts_acp': nbPromptsAcp,
    'nb_prompts_cli': nbPromptsCli,
    'nb_prompts_programmatic': nbPromptsProgrammatic,
    'nb_prompts_total': nbPromptsTotal,
  };

  /// Creates a copy with the given fields replaced.
  VibeUserPromptsStat copyWith({
    String? day,
    int? nbPromptsAcp,
    int? nbPromptsCli,
    int? nbPromptsProgrammatic,
    int? nbPromptsTotal,
  }) => VibeUserPromptsStat(
    day: day ?? this.day,
    nbPromptsAcp: nbPromptsAcp ?? this.nbPromptsAcp,
    nbPromptsCli: nbPromptsCli ?? this.nbPromptsCli,
    nbPromptsProgrammatic: nbPromptsProgrammatic ?? this.nbPromptsProgrammatic,
    nbPromptsTotal: nbPromptsTotal ?? this.nbPromptsTotal,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeUserPromptsStat &&
          runtimeType == other.runtimeType &&
          day == other.day &&
          nbPromptsAcp == other.nbPromptsAcp &&
          nbPromptsCli == other.nbPromptsCli &&
          nbPromptsProgrammatic == other.nbPromptsProgrammatic &&
          nbPromptsTotal == other.nbPromptsTotal;

  @override
  int get hashCode => Object.hashAll([
    day,
    nbPromptsAcp,
    nbPromptsCli,
    nbPromptsProgrammatic,
    nbPromptsTotal,
  ]);

  @override
  String toString() =>
      'VibeUserPromptsStat('
      'day: $day, '
      'nbPromptsAcp: $nbPromptsAcp, '
      'nbPromptsCli: $nbPromptsCli, '
      'nbPromptsProgrammatic: $nbPromptsProgrammatic, '
      'nbPromptsTotal: $nbPromptsTotal)';
}

/// Administrative vibe work by agent stat.
@immutable
class VibeWorkByAgentStat {
  /// Creates a [VibeWorkByAgentStat].
  const VibeWorkByAgentStat({
    required this.agentId,
    required this.filesCount,
    required this.imagesCount,
    required this.lastMessageAt,
    required this.messagesCount,
    required this.spreadsheetsCount,
    required this.uniqueConversationsCount,
    required this.uniqueUsersCount,
  });

  /// The agent_id field.
  final String agentId;

  /// The files_count field.
  final int filesCount;

  /// The images_count field.
  final int imagesCount;

  /// The last_message_at field.
  final String lastMessageAt;

  /// The messages_count field.
  final int messagesCount;

  /// The spreadsheets_count field.
  final int spreadsheetsCount;

  /// The unique_conversations_count field.
  final int uniqueConversationsCount;

  /// The unique_users_count field.
  final int uniqueUsersCount;

  /// Parses a [VibeWorkByAgentStat] from JSON.
  factory VibeWorkByAgentStat.fromJson(Map<String, dynamic> json) {
    if (json['agent_id'] == null) {
      throw const FormatException('VibeWorkByAgentStat: missing agent_id');
    }
    if (json['files_count'] == null) {
      throw const FormatException('VibeWorkByAgentStat: missing files_count');
    }
    if (json['images_count'] == null) {
      throw const FormatException('VibeWorkByAgentStat: missing images_count');
    }
    if (json['last_message_at'] == null) {
      throw const FormatException(
        'VibeWorkByAgentStat: missing last_message_at',
      );
    }
    if (json['messages_count'] == null) {
      throw const FormatException(
        'VibeWorkByAgentStat: missing messages_count',
      );
    }
    if (json['spreadsheets_count'] == null) {
      throw const FormatException(
        'VibeWorkByAgentStat: missing spreadsheets_count',
      );
    }
    if (json['unique_conversations_count'] == null) {
      throw const FormatException(
        'VibeWorkByAgentStat: missing unique_conversations_count',
      );
    }
    if (json['unique_users_count'] == null) {
      throw const FormatException(
        'VibeWorkByAgentStat: missing unique_users_count',
      );
    }
    return VibeWorkByAgentStat(
      agentId: json['agent_id'] as String,
      filesCount: json['files_count'] as int,
      imagesCount: json['images_count'] as int,
      lastMessageAt: json['last_message_at'] as String,
      messagesCount: json['messages_count'] as int,
      spreadsheetsCount: json['spreadsheets_count'] as int,
      uniqueConversationsCount: json['unique_conversations_count'] as int,
      uniqueUsersCount: json['unique_users_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'files_count': filesCount,
    'images_count': imagesCount,
    'last_message_at': lastMessageAt,
    'messages_count': messagesCount,
    'spreadsheets_count': spreadsheetsCount,
    'unique_conversations_count': uniqueConversationsCount,
    'unique_users_count': uniqueUsersCount,
  };

  /// Creates a copy with the given fields replaced.
  VibeWorkByAgentStat copyWith({
    String? agentId,
    int? filesCount,
    int? imagesCount,
    String? lastMessageAt,
    int? messagesCount,
    int? spreadsheetsCount,
    int? uniqueConversationsCount,
    int? uniqueUsersCount,
  }) => VibeWorkByAgentStat(
    agentId: agentId ?? this.agentId,
    filesCount: filesCount ?? this.filesCount,
    imagesCount: imagesCount ?? this.imagesCount,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    messagesCount: messagesCount ?? this.messagesCount,
    spreadsheetsCount: spreadsheetsCount ?? this.spreadsheetsCount,
    uniqueConversationsCount:
        uniqueConversationsCount ?? this.uniqueConversationsCount,
    uniqueUsersCount: uniqueUsersCount ?? this.uniqueUsersCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeWorkByAgentStat &&
          runtimeType == other.runtimeType &&
          agentId == other.agentId &&
          filesCount == other.filesCount &&
          imagesCount == other.imagesCount &&
          lastMessageAt == other.lastMessageAt &&
          messagesCount == other.messagesCount &&
          spreadsheetsCount == other.spreadsheetsCount &&
          uniqueConversationsCount == other.uniqueConversationsCount &&
          uniqueUsersCount == other.uniqueUsersCount;

  @override
  int get hashCode => Object.hashAll([
    agentId,
    filesCount,
    imagesCount,
    lastMessageAt,
    messagesCount,
    spreadsheetsCount,
    uniqueConversationsCount,
    uniqueUsersCount,
  ]);

  @override
  String toString() =>
      'VibeWorkByAgentStat('
      'agentId: $agentId, '
      'filesCount: $filesCount, '
      'imagesCount: $imagesCount, '
      'lastMessageAt: $lastMessageAt, '
      'messagesCount: $messagesCount, '
      'spreadsheetsCount: $spreadsheetsCount, '
      'uniqueConversationsCount: $uniqueConversationsCount, '
      'uniqueUsersCount: $uniqueUsersCount)';
}

/// Administrative vibe work by time stat.
@immutable
class VibeWorkByTimeStat {
  /// Creates a [VibeWorkByTimeStat].
  const VibeWorkByTimeStat({
    required this.filesCount,
    required this.imagesCount,
    required this.messagesCount,
    required this.messagesToAgentsCount,
    required this.spreadsheetsCount,
    required this.timeBucket,
    required this.uniqueAgentsCount,
    required this.uniqueConversationsCount,
    required this.uniqueUsersCount,
  });

  /// The files_count field.
  final int filesCount;

  /// The images_count field.
  final int imagesCount;

  /// The messages_count field.
  final int messagesCount;

  /// The messages_to_agents_count field.
  final int messagesToAgentsCount;

  /// The spreadsheets_count field.
  final int spreadsheetsCount;

  /// The time_bucket field.
  final String? timeBucket;

  /// The unique_agents_count field.
  final int uniqueAgentsCount;

  /// The unique_conversations_count field.
  final int uniqueConversationsCount;

  /// The unique_users_count field.
  final int uniqueUsersCount;

  /// Parses a [VibeWorkByTimeStat] from JSON.
  factory VibeWorkByTimeStat.fromJson(Map<String, dynamic> json) {
    if (json['files_count'] == null) {
      throw const FormatException('VibeWorkByTimeStat: missing files_count');
    }
    if (json['images_count'] == null) {
      throw const FormatException('VibeWorkByTimeStat: missing images_count');
    }
    if (json['messages_count'] == null) {
      throw const FormatException('VibeWorkByTimeStat: missing messages_count');
    }
    if (json['messages_to_agents_count'] == null) {
      throw const FormatException(
        'VibeWorkByTimeStat: missing messages_to_agents_count',
      );
    }
    if (json['spreadsheets_count'] == null) {
      throw const FormatException(
        'VibeWorkByTimeStat: missing spreadsheets_count',
      );
    }
    if (!json.containsKey('time_bucket')) {
      throw const FormatException('VibeWorkByTimeStat: missing time_bucket');
    }
    if (json['unique_agents_count'] == null) {
      throw const FormatException(
        'VibeWorkByTimeStat: missing unique_agents_count',
      );
    }
    if (json['unique_conversations_count'] == null) {
      throw const FormatException(
        'VibeWorkByTimeStat: missing unique_conversations_count',
      );
    }
    if (json['unique_users_count'] == null) {
      throw const FormatException(
        'VibeWorkByTimeStat: missing unique_users_count',
      );
    }
    return VibeWorkByTimeStat(
      filesCount: json['files_count'] as int,
      imagesCount: json['images_count'] as int,
      messagesCount: json['messages_count'] as int,
      messagesToAgentsCount: json['messages_to_agents_count'] as int,
      spreadsheetsCount: json['spreadsheets_count'] as int,
      timeBucket: json['time_bucket'] == null
          ? null
          : json['time_bucket'] as String,
      uniqueAgentsCount: json['unique_agents_count'] as int,
      uniqueConversationsCount: json['unique_conversations_count'] as int,
      uniqueUsersCount: json['unique_users_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'files_count': filesCount,
    'images_count': imagesCount,
    'messages_count': messagesCount,
    'messages_to_agents_count': messagesToAgentsCount,
    'spreadsheets_count': spreadsheetsCount,
    'time_bucket': timeBucket,
    'unique_agents_count': uniqueAgentsCount,
    'unique_conversations_count': uniqueConversationsCount,
    'unique_users_count': uniqueUsersCount,
  };

  /// Creates a copy with the given fields replaced.
  VibeWorkByTimeStat copyWith({
    int? filesCount,
    int? imagesCount,
    int? messagesCount,
    int? messagesToAgentsCount,
    int? spreadsheetsCount,
    Object? timeBucket = unsetCopyWithValue,
    int? uniqueAgentsCount,
    int? uniqueConversationsCount,
    int? uniqueUsersCount,
  }) => VibeWorkByTimeStat(
    filesCount: filesCount ?? this.filesCount,
    imagesCount: imagesCount ?? this.imagesCount,
    messagesCount: messagesCount ?? this.messagesCount,
    messagesToAgentsCount: messagesToAgentsCount ?? this.messagesToAgentsCount,
    spreadsheetsCount: spreadsheetsCount ?? this.spreadsheetsCount,
    timeBucket: timeBucket == unsetCopyWithValue
        ? this.timeBucket
        : timeBucket as String?,
    uniqueAgentsCount: uniqueAgentsCount ?? this.uniqueAgentsCount,
    uniqueConversationsCount:
        uniqueConversationsCount ?? this.uniqueConversationsCount,
    uniqueUsersCount: uniqueUsersCount ?? this.uniqueUsersCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeWorkByTimeStat &&
          runtimeType == other.runtimeType &&
          filesCount == other.filesCount &&
          imagesCount == other.imagesCount &&
          messagesCount == other.messagesCount &&
          messagesToAgentsCount == other.messagesToAgentsCount &&
          spreadsheetsCount == other.spreadsheetsCount &&
          timeBucket == other.timeBucket &&
          uniqueAgentsCount == other.uniqueAgentsCount &&
          uniqueConversationsCount == other.uniqueConversationsCount &&
          uniqueUsersCount == other.uniqueUsersCount;

  @override
  int get hashCode => Object.hashAll([
    filesCount,
    imagesCount,
    messagesCount,
    messagesToAgentsCount,
    spreadsheetsCount,
    timeBucket,
    uniqueAgentsCount,
    uniqueConversationsCount,
    uniqueUsersCount,
  ]);

  @override
  String toString() =>
      'VibeWorkByTimeStat('
      'filesCount: $filesCount, '
      'imagesCount: $imagesCount, '
      'messagesCount: $messagesCount, '
      'messagesToAgentsCount: $messagesToAgentsCount, '
      'spreadsheetsCount: $spreadsheetsCount, '
      'timeBucket: $timeBucket, '
      'uniqueAgentsCount: $uniqueAgentsCount, '
      'uniqueConversationsCount: $uniqueConversationsCount, '
      'uniqueUsersCount: $uniqueUsersCount)';
}

/// Administrative vibe work by user stat.
@immutable
class VibeWorkByUserStat {
  /// Creates a [VibeWorkByUserStat].
  const VibeWorkByUserStat({
    required this.filesCount,
    required this.imagesCount,
    required this.lastMessageAt,
    required this.messagesCount,
    required this.messagesToAgentsCount,
    required this.spreadsheetsCount,
    required this.uniqueAgentsCount,
    required this.uniqueConversationsCount,
    required this.userId,
  });

  /// The files_count field.
  final int filesCount;

  /// The images_count field.
  final int imagesCount;

  /// The last_message_at field.
  final String lastMessageAt;

  /// The messages_count field.
  final int messagesCount;

  /// The messages_to_agents_count field.
  final int messagesToAgentsCount;

  /// The spreadsheets_count field.
  final int spreadsheetsCount;

  /// The unique_agents_count field.
  final int uniqueAgentsCount;

  /// The unique_conversations_count field.
  final int uniqueConversationsCount;

  /// The user_id field.
  final String userId;

  /// Parses a [VibeWorkByUserStat] from JSON.
  factory VibeWorkByUserStat.fromJson(Map<String, dynamic> json) {
    if (json['files_count'] == null) {
      throw const FormatException('VibeWorkByUserStat: missing files_count');
    }
    if (json['images_count'] == null) {
      throw const FormatException('VibeWorkByUserStat: missing images_count');
    }
    if (json['last_message_at'] == null) {
      throw const FormatException(
        'VibeWorkByUserStat: missing last_message_at',
      );
    }
    if (json['messages_count'] == null) {
      throw const FormatException('VibeWorkByUserStat: missing messages_count');
    }
    if (json['messages_to_agents_count'] == null) {
      throw const FormatException(
        'VibeWorkByUserStat: missing messages_to_agents_count',
      );
    }
    if (json['spreadsheets_count'] == null) {
      throw const FormatException(
        'VibeWorkByUserStat: missing spreadsheets_count',
      );
    }
    if (json['unique_agents_count'] == null) {
      throw const FormatException(
        'VibeWorkByUserStat: missing unique_agents_count',
      );
    }
    if (json['unique_conversations_count'] == null) {
      throw const FormatException(
        'VibeWorkByUserStat: missing unique_conversations_count',
      );
    }
    if (json['user_id'] == null) {
      throw const FormatException('VibeWorkByUserStat: missing user_id');
    }
    return VibeWorkByUserStat(
      filesCount: json['files_count'] as int,
      imagesCount: json['images_count'] as int,
      lastMessageAt: json['last_message_at'] as String,
      messagesCount: json['messages_count'] as int,
      messagesToAgentsCount: json['messages_to_agents_count'] as int,
      spreadsheetsCount: json['spreadsheets_count'] as int,
      uniqueAgentsCount: json['unique_agents_count'] as int,
      uniqueConversationsCount: json['unique_conversations_count'] as int,
      userId: json['user_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'files_count': filesCount,
    'images_count': imagesCount,
    'last_message_at': lastMessageAt,
    'messages_count': messagesCount,
    'messages_to_agents_count': messagesToAgentsCount,
    'spreadsheets_count': spreadsheetsCount,
    'unique_agents_count': uniqueAgentsCount,
    'unique_conversations_count': uniqueConversationsCount,
    'user_id': userId,
  };

  /// Creates a copy with the given fields replaced.
  VibeWorkByUserStat copyWith({
    int? filesCount,
    int? imagesCount,
    String? lastMessageAt,
    int? messagesCount,
    int? messagesToAgentsCount,
    int? spreadsheetsCount,
    int? uniqueAgentsCount,
    int? uniqueConversationsCount,
    String? userId,
  }) => VibeWorkByUserStat(
    filesCount: filesCount ?? this.filesCount,
    imagesCount: imagesCount ?? this.imagesCount,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt,
    messagesCount: messagesCount ?? this.messagesCount,
    messagesToAgentsCount: messagesToAgentsCount ?? this.messagesToAgentsCount,
    spreadsheetsCount: spreadsheetsCount ?? this.spreadsheetsCount,
    uniqueAgentsCount: uniqueAgentsCount ?? this.uniqueAgentsCount,
    uniqueConversationsCount:
        uniqueConversationsCount ?? this.uniqueConversationsCount,
    userId: userId ?? this.userId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VibeWorkByUserStat &&
          runtimeType == other.runtimeType &&
          filesCount == other.filesCount &&
          imagesCount == other.imagesCount &&
          lastMessageAt == other.lastMessageAt &&
          messagesCount == other.messagesCount &&
          messagesToAgentsCount == other.messagesToAgentsCount &&
          spreadsheetsCount == other.spreadsheetsCount &&
          uniqueAgentsCount == other.uniqueAgentsCount &&
          uniqueConversationsCount == other.uniqueConversationsCount &&
          userId == other.userId;

  @override
  int get hashCode => Object.hashAll([
    filesCount,
    imagesCount,
    lastMessageAt,
    messagesCount,
    messagesToAgentsCount,
    spreadsheetsCount,
    uniqueAgentsCount,
    uniqueConversationsCount,
    userId,
  ]);

  @override
  String toString() =>
      'VibeWorkByUserStat('
      'filesCount: $filesCount, '
      'imagesCount: $imagesCount, '
      'lastMessageAt: $lastMessageAt, '
      'messagesCount: $messagesCount, '
      'messagesToAgentsCount: $messagesToAgentsCount, '
      'spreadsheetsCount: $spreadsheetsCount, '
      'uniqueAgentsCount: $uniqueAgentsCount, '
      'uniqueConversationsCount: $uniqueConversationsCount, '
      'userId: $userId)';
}

/// Time bucket for Vibe Work analytics.
enum VibeUsageGranularity {
  /// Hourly buckets.
  hour('hour'),

  /// Daily buckets.
  day('day'),

  /// Weekly buckets.
  week('week'),

  /// Monthly buckets.
  month('month');

  const VibeUsageGranularity(this.value);

  /// The wire value.
  final String value;
}
