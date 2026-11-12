part of 'analytics_reports.dart';

/// Daily adoption and active-user counts for an organization or group.
final class AnalyticsSingleDayActivitySummary extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSingleDayActivitySummary.fromJson(super.json);

  /// Reported assigned seat count.
  int? get assignedSeatCount => rawJson['assigned_seat_count'] as int?;

  /// Chat and Cowork unified daily active user count.
  int? get chatCoworkUnifiedDailyActiveUserCount =>
      rawJson['chat_cowork_unified_daily_active_user_count'] as int?;

  /// Chat and Cowork unified monthly active user count.
  int? get chatCoworkUnifiedMonthlyActiveUserCount =>
      rawJson['chat_cowork_unified_monthly_active_user_count'] as int?;

  /// Chat and Cowork unified weekly active user count.
  int? get chatCoworkUnifiedWeeklyActiveUserCount =>
      rawJson['chat_cowork_unified_weekly_active_user_count'] as int?;

  /// Chat daily active user count.
  int? get chatDailyActiveUserCount =>
      rawJson['chat_daily_active_user_count'] as int?;

  /// Chat monthly active user count.
  int? get chatMonthlyActiveUserCount =>
      rawJson['chat_monthly_active_user_count'] as int?;

  /// Chat weekly active user count.
  int? get chatWeeklyActiveUserCount =>
      rawJson['chat_weekly_active_user_count'] as int?;

  /// Claude Code daily active user count.
  int? get claudeCodeDailyActiveUserCount =>
      rawJson['claude_code_daily_active_user_count'] as int?;

  /// Claude Code monthly active user count.
  int? get claudeCodeMonthlyActiveUserCount =>
      rawJson['claude_code_monthly_active_user_count'] as int?;

  /// Claude Code weekly active user count.
  int? get claudeCodeWeeklyActiveUserCount =>
      rawJson['claude_code_weekly_active_user_count'] as int?;

  /// Claude Design daily active user count.
  int? get claudeDesignDailyActiveUserCount =>
      rawJson['claude_design_daily_active_user_count'] as int?;

  /// Claude Design monthly active user count.
  int? get claudeDesignMonthlyActiveUserCount =>
      rawJson['claude_design_monthly_active_user_count'] as int?;

  /// Claude Design weekly active user count.
  int? get claudeDesignWeeklyActiveUserCount =>
      rawJson['claude_design_weekly_active_user_count'] as int?;

  /// Claude Tag daily active user count.
  int? get claudeTagDailyActiveUserCount =>
      rawJson['claude_tag_daily_active_user_count'] as int?;

  /// Claude Tag monthly active user count.
  int? get claudeTagMonthlyActiveUserCount =>
      rawJson['claude_tag_monthly_active_user_count'] as int?;

  /// Claude Tag weekly active user count.
  int? get claudeTagWeeklyActiveUserCount =>
      rawJson['claude_tag_weekly_active_user_count'] as int?;

  /// Cowork daily active user count.
  int get coworkDailyActiveUserCount =>
      rawJson['cowork_daily_active_user_count'] as int;

  /// Cowork monthly active user count.
  int get coworkMonthlyActiveUserCount =>
      rawJson['cowork_monthly_active_user_count'] as int;

  /// Cowork weekly active user count.
  int get coworkWeeklyActiveUserCount =>
      rawJson['cowork_weekly_active_user_count'] as int;

  /// Daily active user count.
  int get dailyActiveUserCount => rawJson['daily_active_user_count'] as int;

  /// Daily adoption rate.
  num? get dailyAdoptionRate => rawJson['daily_adoption_rate'] as num?;

  /// End of the UTC reporting interval.
  DateTime get endingAt => _requiredReportTime(rawJson, 'ending_at');

  /// Monthly active user count.
  int get monthlyActiveUserCount => rawJson['monthly_active_user_count'] as int;

  /// Monthly adoption rate.
  num? get monthlyAdoptionRate => rawJson['monthly_adoption_rate'] as num?;

  /// Office Agent daily active user count.
  int? get officeAgentDailyActiveUserCount =>
      rawJson['office_agent_daily_active_user_count'] as int?;

  /// Office Agent monthly active user count.
  int? get officeAgentMonthlyActiveUserCount =>
      rawJson['office_agent_monthly_active_user_count'] as int?;

  /// Office Agent weekly active user count.
  int? get officeAgentWeeklyActiveUserCount =>
      rawJson['office_agent_weekly_active_user_count'] as int?;

  /// Reported pending invite count.
  int? get pendingInviteCount => rawJson['pending_invite_count'] as int?;

  /// Science daily active user count.
  int? get scienceDailyActiveUserCount =>
      rawJson['science_daily_active_user_count'] as int?;

  /// Reported science entitled user count.
  int? get scienceEntitledUserCount =>
      rawJson['science_entitled_user_count'] as int?;

  /// Science monthly active user count.
  int? get scienceMonthlyActiveUserCount =>
      rawJson['science_monthly_active_user_count'] as int?;

  /// Science weekly active user count.
  int? get scienceWeeklyActiveUserCount =>
      rawJson['science_weekly_active_user_count'] as int?;

  /// Start of the UTC reporting interval.
  DateTime get startingAt => _requiredReportTime(rawJson, 'starting_at');

  /// Weekly active user count.
  int get weeklyActiveUserCount => rawJson['weekly_active_user_count'] as int;

  /// Weekly adoption rate.
  num? get weeklyAdoptionRate => rawJson['weekly_adoption_rate'] as num?;
}

/// Enterprise activity for a member or a grouped row.
final class AnalyticsUserActivity extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsUserActivity.fromJson(super.json);

  /// Metrics for Chat and Cowork unified.
  AnalyticsChatCoworkUnifiedMetrics? get chatCoworkUnifiedMetrics =>
      switch (rawJson['chat_cowork_unified_metrics']) {
        final Map<String, dynamic> value =>
          AnalyticsChatCoworkUnifiedMetrics.fromJson(value),
        _ => null,
      };

  /// Metrics for chat.
  AnalyticsChatMetrics get chatMetrics =>
      AnalyticsChatMetrics.fromJson(_reportObject(rawJson, 'chat_metrics'));

  /// Metrics for Claude Code.
  AnalyticsClaudeCodeMetrics get claudeCodeMetrics =>
      AnalyticsClaudeCodeMetrics.fromJson(
        _reportObject(rawJson, 'claude_code_metrics'),
      );

  /// Claude Tag activity for a Slack user with a linked Claude account.
  AnalyticsClaudeTagMetrics? get claudeTagMetrics =>
      switch (rawJson['claude_tag_metrics']) {
        final Map<String, dynamic> value => AnalyticsClaudeTagMetrics.fromJson(
          value,
        ),
        _ => null,
      };

  /// Metrics for cowork.
  AnalyticsCoworkMetrics get coworkMetrics =>
      AnalyticsCoworkMetrics.fromJson(_reportObject(rawJson, 'cowork_metrics'));

  /// Metrics for design.
  AnalyticsDesignMetrics get designMetrics =>
      AnalyticsDesignMetrics.fromJson(_reportObject(rawJson, 'design_metrics'));

  /// Reported distinct user count.
  int? get distinctUserCount => rawJson['distinct_user_count'] as int?;

  /// Last activity day as a UTC YYYY-MM-DD date.
  String? get lastActivityDate => rawJson['last_activity_date'] as String?;

  /// Metrics for office.
  AnalyticsOfficeMetrics get officeMetrics =>
      AnalyticsOfficeMetrics.fromJson(_reportObject(rawJson, 'office_metrics'));

  /// Identifier for RBAC group.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// RBAC group name.
  String? get rbacGroupName => rawJson['rbac_group_name'] as String?;

  /// Metrics for science.
  AnalyticsScienceMetrics get scienceMetrics =>
      AnalyticsScienceMetrics.fromJson(
        _reportObject(rawJson, 'science_metrics'),
      );

  /// Member for a per-user row, when applicable.
  AnalyticsUser? get user => switch (rawJson['user']) {
    final Map<String, dynamic> value => AnalyticsUser.fromJson(value),
    _ => null,
  };

  /// Reported web search count.
  int get webSearchCount => rawJson['web_search_count'] as int;
}

/// Usage and creator information for a Chat project.
final class AnalyticsProjectActivity extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsProjectActivity.fromJson(super.json);

  /// Created at.
  DateTime? get createdAt => _optionalReportTime(rawJson['created_at']);

  /// Member who created the project, when known.
  AnalyticsUser? get createdBy => switch (rawJson['created_by']) {
    final Map<String, dynamic> value => AnalyticsUser.fromJson(value),
    _ => null,
  };

  /// Reported distinct conversation count.
  int? get distinctConversationCount =>
      rawJson['distinct_conversation_count'] as int?;

  /// Reported distinct user count.
  int get distinctUserCount => rawJson['distinct_user_count'] as int;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Identifier for project.
  String get projectId => rawJson['project_id'] as String;

  /// Project name.
  String get projectName => rawJson['project_name'] as String;

  /// Identifier for RBAC group.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// RBAC group name.
  String? get rbacGroupName => rawJson['rbac_group_name'] as String?;

  /// Identifier for user.
  String? get userId => rawJson['user_id'] as String?;
}

/// Skill usage, visibility, and cost attribution.
final class AnalyticsSkillActivity extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillActivity.fromJson(super.json);

  /// Attributed list-price amount as a decimal string in minor currency units.
  String? get attributedListPrice =>
      rawJson['attributed_list_price'] as String?;

  /// Metrics for Chat and Cowork unified.
  AnalyticsSkillChatCoworkUnifiedMetrics? get chatCoworkUnifiedMetrics =>
      switch (rawJson['chat_cowork_unified_metrics']) {
        final Map<String, dynamic> value =>
          AnalyticsSkillChatCoworkUnifiedMetrics.fromJson(value),
        _ => null,
      };

  /// Metrics for chat.
  AnalyticsSkillChatMetrics get chatMetrics =>
      AnalyticsSkillChatMetrics.fromJson(
        _reportObject(rawJson, 'chat_metrics'),
      );

  /// Metrics for Claude Code.
  AnalyticsSkillClaudeCodeMetrics get claudeCodeMetrics =>
      AnalyticsSkillClaudeCodeMetrics.fromJson(
        _reportObject(rawJson, 'claude_code_metrics'),
      );

  /// Metrics for cowork.
  AnalyticsSkillCoworkMetrics get coworkMetrics =>
      AnalyticsSkillCoworkMetrics.fromJson(
        _reportObject(rawJson, 'cowork_metrics'),
      );

  /// Currency.
  String? get currency => rawJson['currency'] as String?;

  /// Reported distinct user count.
  int get distinctUserCount => rawJson['distinct_user_count'] as int;

  /// Reported enable count.
  int? get enableCount => rawJson['enable_count'] as int?;

  /// Estimated metered overage as a decimal string in minor currency units.
  String? get estimatedOverageSpend =>
      rawJson['estimated_overage_spend'] as String?;

  /// Reported invocation count.
  int? get invocationCount => rawJson['invocation_count'] as int?;

  /// Metrics for office.
  AnalyticsSkillOfficeMetrics get officeMetrics =>
      AnalyticsSkillOfficeMetrics.fromJson(
        _reportObject(rawJson, 'office_metrics'),
      );

  /// Product.
  String? get product => rawJson['product'] as String?;

  /// Identifier for RBAC group.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// RBAC group name.
  String? get rbacGroupName => rawJson['rbac_group_name'] as String?;

  /// Share status.
  String? get shareStatus => rawJson['share_status'] as String?;

  /// Skill display name.
  String? get skillDisplayName => rawJson['skill_display_name'] as String?;

  /// Skill name.
  String get skillName => rawJson['skill_name'] as String;

  /// Identifier for user.
  String? get userId => rawJson['user_id'] as String?;
}

/// Connector usage and credential attribution.
final class AnalyticsConnectorActivity extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorActivity.fromJson(super.json);

  /// Metrics for Chat and Cowork unified.
  AnalyticsConnectorChatCoworkUnifiedMetrics? get chatCoworkUnifiedMetrics =>
      switch (rawJson['chat_cowork_unified_metrics']) {
        final Map<String, dynamic> value =>
          AnalyticsConnectorChatCoworkUnifiedMetrics.fromJson(value),
        _ => null,
      };

  /// Metrics for chat.
  AnalyticsConnectorChatMetrics get chatMetrics =>
      AnalyticsConnectorChatMetrics.fromJson(
        _reportObject(rawJson, 'chat_metrics'),
      );

  /// Metrics for Claude Code.
  AnalyticsConnectorClaudeCodeMetrics get claudeCodeMetrics =>
      AnalyticsConnectorClaudeCodeMetrics.fromJson(
        _reportObject(rawJson, 'claude_code_metrics'),
      );

  /// Connector display name.
  String? get connectorDisplayName =>
      rawJson['connector_display_name'] as String?;

  /// Connector name.
  String get connectorName => rawJson['connector_name'] as String;

  /// Metrics for cowork.
  AnalyticsConnectorCoworkMetrics get coworkMetrics =>
      AnalyticsConnectorCoworkMetrics.fromJson(
        _reportObject(rawJson, 'cowork_metrics'),
      );

  /// Reported distinct user count.
  int get distinctUserCount => rawJson['distinct_user_count'] as int;

  /// Reported individual auth distinct user count.
  int? get individualAuthDistinctUserCount =>
      rawJson['individual_auth_distinct_user_count'] as int?;

  /// Reported managed auth distinct user count.
  int? get managedAuthDistinctUserCount =>
      rawJson['managed_auth_distinct_user_count'] as int?;

  /// Metrics for office.
  AnalyticsConnectorOfficeMetrics get officeMetrics =>
      AnalyticsConnectorOfficeMetrics.fromJson(
        _reportObject(rawJson, 'office_metrics'),
      );

  /// Product.
  String? get product => rawJson['product'] as String?;

  /// Identifier for RBAC group.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// RBAC group name.
  String? get rbacGroupName => rawJson['rbac_group_name'] as String?;

  /// Reported read call count.
  int? get readCallCount => rawJson['read_call_count'] as int?;

  /// Reported unclassified call count.
  int? get unclassifiedCallCount => rawJson['unclassified_call_count'] as int?;

  /// Identifier for user.
  String? get userId => rawJson['user_id'] as String?;

  /// Reported write call count.
  int? get writeCallCount => rawJson['write_call_count'] as int?;
}

/// Plugin installation and invocation counts.
final class AnalyticsPluginActivity extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsPluginActivity.fromJson(super.json);

  /// Metrics for Chat and Cowork unified.
  AnalyticsPluginChatCoworkUnifiedMetrics? get chatCoworkUnifiedMetrics =>
      switch (rawJson['chat_cowork_unified_metrics']) {
        final Map<String, dynamic> value =>
          AnalyticsPluginChatCoworkUnifiedMetrics.fromJson(value),
        _ => null,
      };

  /// Metrics for Claude Code.
  AnalyticsPluginClaudeCodeMetrics get claudeCodeMetrics =>
      AnalyticsPluginClaudeCodeMetrics.fromJson(
        _reportObject(rawJson, 'claude_code_metrics'),
      );

  /// Metrics for cowork.
  AnalyticsPluginCoworkMetrics get coworkMetrics =>
      AnalyticsPluginCoworkMetrics.fromJson(
        _reportObject(rawJson, 'cowork_metrics'),
      );

  /// Reported distinct user count.
  int get distinctUserCount => rawJson['distinct_user_count'] as int;

  /// Reported install count.
  int? get installCount => rawJson['install_count'] as int?;

  /// Reported invocation count.
  int get invocationCount => rawJson['invocation_count'] as int;

  /// Identifier for plugin.
  String? get pluginId => rawJson['plugin_id'] as String?;

  /// Plugin name.
  String get pluginName => rawJson['plugin_name'] as String;

  /// Product.
  String? get product => rawJson['product'] as String?;

  /// Identifier for RBAC group.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// RBAC group name.
  String? get rbacGroupName => rawJson['rbac_group_name'] as String?;

  /// Identifier for user.
  String? get userId => rawJson['user_id'] as String?;
}

/// Artifact creation grouped by type and sharing state.
final class AnalyticsArtifactActivity extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsArtifactActivity.fromJson(super.json);

  /// Artifact type.
  String get artifactType => rawJson['artifact_type'] as String;

  /// Reported artifacts created count.
  int get artifactsCreatedCount => rawJson['artifacts_created_count'] as int;

  /// Reported distinct user count.
  int get distinctUserCount => rawJson['distinct_user_count'] as int;

  /// Whether this row counts shared artifacts.
  bool get isShared => rawJson['is_shared'] as bool;

  /// Product.
  String? get product => rawJson['product'] as String?;

  /// Reported published artifacts created count.
  int get publishedArtifactsCreatedCount =>
      rawJson['published_artifacts_created_count'] as int;

  /// Identifier for RBAC group.
  String? get rbacGroupId => rawJson['rbac_group_id'] as String?;

  /// RBAC group name.
  String? get rbacGroupName => rawJson['rbac_group_name'] as String?;

  /// Identifier for user.
  String? get userId => rawJson['user_id'] as String?;
}

/// Chat and Cowork unified Chat metrics for Enterprise activity.
final class AnalyticsChatCoworkUnifiedChatMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsChatCoworkUnifiedChatMetrics.fromJson(super.json);

  /// Reported connectors used count.
  int get connectorsUsedCount => rawJson['connectors_used_count'] as int;

  /// Reported distinct artifacts created count.
  int get distinctArtifactsCreatedCount =>
      rawJson['distinct_artifacts_created_count'] as int;

  /// Reported distinct connectors used count.
  int? get distinctConnectorsUsedCount =>
      rawJson['distinct_connectors_used_count'] as int?;

  /// Reported distinct conversation count.
  int? get distinctConversationCount =>
      rawJson['distinct_conversation_count'] as int?;

  /// Reported distinct files uploaded count.
  int? get distinctFilesUploadedCount =>
      rawJson['distinct_files_uploaded_count'] as int?;

  /// Reported distinct projects created count.
  int get distinctProjectsCreatedCount =>
      rawJson['distinct_projects_created_count'] as int;

  /// Reported distinct projects used count.
  int? get distinctProjectsUsedCount =>
      rawJson['distinct_projects_used_count'] as int?;

  /// Reported distinct shared artifacts viewed count.
  int? get distinctSharedArtifactsViewedCount =>
      rawJson['distinct_shared_artifacts_viewed_count'] as int?;

  /// Reported distinct skills used count.
  int? get distinctSkillsUsedCount =>
      rawJson['distinct_skills_used_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Reported shared conversations viewed count.
  int get sharedConversationsViewedCount =>
      rawJson['shared_conversations_viewed_count'] as int;

  /// Reported thinking message count.
  int get thinkingMessageCount => rawJson['thinking_message_count'] as int;
}

/// Chat and Cowork unified metrics for Enterprise activity.
final class AnalyticsChatCoworkUnifiedMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsChatCoworkUnifiedMetrics.fromJson(super.json);

  /// Chat.
  AnalyticsChatCoworkUnifiedChatMetrics get chat =>
      AnalyticsChatCoworkUnifiedChatMetrics.fromJson(
        _reportObject(rawJson, 'chat'),
      );

  /// Sessions.
  AnalyticsChatCoworkUnifiedSessionsMetrics get sessions =>
      AnalyticsChatCoworkUnifiedSessionsMetrics.fromJson(
        _reportObject(rawJson, 'sessions'),
      );
}

/// Chat and Cowork unified Sessions metrics for Enterprise activity.
final class AnalyticsChatCoworkUnifiedSessionsMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsChatCoworkUnifiedSessionsMetrics.fromJson(super.json);

  /// Reported action count.
  int get actionCount => rawJson['action_count'] as int;

  /// Reported artifacts created count.
  int get artifactsCreatedCount => rawJson['artifacts_created_count'] as int;

  /// Reported connectors used count.
  int get connectorsUsedCount => rawJson['connectors_used_count'] as int;

  /// Reported dispatch turn count.
  int get dispatchTurnCount => rawJson['dispatch_turn_count'] as int;

  /// Reported distinct connectors used count.
  int? get distinctConnectorsUsedCount =>
      rawJson['distinct_connectors_used_count'] as int?;

  /// Reported distinct plugins used count.
  int? get distinctPluginsUsedCount =>
      rawJson['distinct_plugins_used_count'] as int?;

  /// Reported distinct session count.
  int? get distinctSessionCount => rawJson['distinct_session_count'] as int?;

  /// Reported distinct skills used count.
  int? get distinctSkillsUsedCount =>
      rawJson['distinct_skills_used_count'] as int?;

  /// Reported edit tool count.
  int? get editToolCount => rawJson['edit_tool_count'] as int?;

  /// Reported file edit count.
  int? get fileEditCount => rawJson['file_edit_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Reported multi edit tool count.
  int? get multiEditToolCount => rawJson['multi_edit_tool_count'] as int?;

  /// Reported notebook edit tool count.
  int? get notebookEditToolCount => rawJson['notebook_edit_tool_count'] as int?;

  /// Reported plugins used count.
  int? get pluginsUsedCount => rawJson['plugins_used_count'] as int?;

  /// Reported sessions with file edits count.
  int? get sessionsWithFileEditsCount =>
      rawJson['sessions_with_file_edits_count'] as int?;

  /// Reported skills used count.
  int get skillsUsedCount => rawJson['skills_used_count'] as int;

  /// Reported write tool count.
  int? get writeToolCount => rawJson['write_tool_count'] as int?;
}

/// Chat metrics for Enterprise activity.
final class AnalyticsChatMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsChatMetrics.fromJson(super.json);

  /// Reported connectors used count.
  int get connectorsUsedCount => rawJson['connectors_used_count'] as int;

  /// Reported distinct artifacts created count.
  int get distinctArtifactsCreatedCount =>
      rawJson['distinct_artifacts_created_count'] as int;

  /// Reported distinct connectors used count.
  int? get distinctConnectorsUsedCount =>
      rawJson['distinct_connectors_used_count'] as int?;

  /// Reported distinct conversation count.
  int? get distinctConversationCount =>
      rawJson['distinct_conversation_count'] as int?;

  /// Reported distinct files uploaded count.
  int? get distinctFilesUploadedCount =>
      rawJson['distinct_files_uploaded_count'] as int?;

  /// Reported distinct projects created count.
  int get distinctProjectsCreatedCount =>
      rawJson['distinct_projects_created_count'] as int;

  /// Reported distinct projects used count.
  int? get distinctProjectsUsedCount =>
      rawJson['distinct_projects_used_count'] as int?;

  /// Reported distinct shared artifacts viewed count.
  int? get distinctSharedArtifactsViewedCount =>
      rawJson['distinct_shared_artifacts_viewed_count'] as int?;

  /// Reported distinct skills used count.
  int? get distinctSkillsUsedCount =>
      rawJson['distinct_skills_used_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Reported shared conversations viewed count.
  int get sharedConversationsViewedCount =>
      rawJson['shared_conversations_viewed_count'] as int;

  /// Reported thinking message count.
  int get thinkingMessageCount => rawJson['thinking_message_count'] as int;
}

/// Claude Code metrics for Enterprise activity.
final class AnalyticsClaudeCodeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsClaudeCodeMetrics.fromJson(super.json);

  /// Metrics for core.
  AnalyticsCoreCodeMetrics get coreMetrics =>
      AnalyticsCoreCodeMetrics.fromJson(_reportObject(rawJson, 'core_metrics'));

  /// Tool actions.
  AnalyticsToolActions get toolActions =>
      AnalyticsToolActions.fromJson(_reportObject(rawJson, 'tool_actions'));
}

/// Slack activity for users with linked Claude accounts.
final class AnalyticsClaudeTagMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsClaudeTagMetrics.fromJson(super.json);

  /// Reported active day count.
  int? get activeDayCount => rawJson['active_day_count'] as int?;

  /// Reported active message count.
  int? get activeMessageCount => rawJson['active_message_count'] as int?;
}

/// Connector Chat and Cowork unified Chat metrics for Enterprise activity.
final class AnalyticsConnectorChatCoworkUnifiedChatMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorChatCoworkUnifiedChatMetrics.fromJson(super.json);

  /// Reported distinct conversation connector used count.
  int? get distinctConversationConnectorUsedCount =>
      rawJson['distinct_conversation_connector_used_count'] as int?;
}

/// Connector Chat and Cowork unified metrics for Enterprise activity.
final class AnalyticsConnectorChatCoworkUnifiedMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorChatCoworkUnifiedMetrics.fromJson(super.json);

  /// Chat.
  AnalyticsConnectorChatCoworkUnifiedChatMetrics get chat =>
      AnalyticsConnectorChatCoworkUnifiedChatMetrics.fromJson(
        _reportObject(rawJson, 'chat'),
      );

  /// Sessions.
  AnalyticsConnectorChatCoworkUnifiedSessionsMetrics get sessions =>
      AnalyticsConnectorChatCoworkUnifiedSessionsMetrics.fromJson(
        _reportObject(rawJson, 'sessions'),
      );
}

/// Connector Chat and Cowork unified Sessions metrics for Enterprise activity.
final class AnalyticsConnectorChatCoworkUnifiedSessionsMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorChatCoworkUnifiedSessionsMetrics.fromJson(super.json);

  /// Reported distinct session connector used count.
  int? get distinctSessionConnectorUsedCount =>
      rawJson['distinct_session_connector_used_count'] as int?;
}

/// Connector Chat metrics for Enterprise activity.
final class AnalyticsConnectorChatMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorChatMetrics.fromJson(super.json);

  /// Reported distinct conversation connector used count.
  int? get distinctConversationConnectorUsedCount =>
      rawJson['distinct_conversation_connector_used_count'] as int?;
}

/// Connector Claude Code metrics for Enterprise activity.
final class AnalyticsConnectorClaudeCodeMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorClaudeCodeMetrics.fromJson(super.json);

  /// Reported distinct session connector used count.
  int? get distinctSessionConnectorUsedCount =>
      rawJson['distinct_session_connector_used_count'] as int?;
}

/// Connector Cowork metrics for Enterprise activity.
final class AnalyticsConnectorCoworkMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorCoworkMetrics.fromJson(super.json);

  /// Reported distinct session connector used count.
  int? get distinctSessionConnectorUsedCount =>
      rawJson['distinct_session_connector_used_count'] as int?;
}

/// Connector Office metrics for Enterprise activity.
final class AnalyticsConnectorOfficeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorOfficeMetrics.fromJson(super.json);

  /// Excel.
  AnalyticsConnectorOfficeProductMetrics get excel =>
      AnalyticsConnectorOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'excel'),
      );

  /// Outlook.
  AnalyticsConnectorOfficeProductMetrics get outlook =>
      AnalyticsConnectorOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'outlook'),
      );

  /// Powerpoint.
  AnalyticsConnectorOfficeProductMetrics get powerpoint =>
      AnalyticsConnectorOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'powerpoint'),
      );

  /// Word.
  AnalyticsConnectorOfficeProductMetrics get word =>
      AnalyticsConnectorOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'word'),
      );
}

/// Connector Office Product metrics for Enterprise activity.
final class AnalyticsConnectorOfficeProductMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsConnectorOfficeProductMetrics.fromJson(super.json);

  /// Reported distinct session connector used count.
  int? get distinctSessionConnectorUsedCount =>
      rawJson['distinct_session_connector_used_count'] as int?;
}

/// Core Code metrics for Enterprise activity.
final class AnalyticsCoreCodeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsCoreCodeMetrics.fromJson(super.json);

  /// Reported artifacts created count.
  int get artifactsCreatedCount => rawJson['artifacts_created_count'] as int;

  /// Reported commit count.
  int get commitCount => rawJson['commit_count'] as int;

  /// Reported distinct session count.
  int? get distinctSessionCount => rawJson['distinct_session_count'] as int?;

  /// Lines of code.
  AnalyticsLinesOfCode get linesOfCode =>
      AnalyticsLinesOfCode.fromJson(_reportObject(rawJson, 'lines_of_code'));

  /// Reported pull request count.
  int get pullRequestCount => rawJson['pull_request_count'] as int;
}

/// Cowork metrics for Enterprise activity.
final class AnalyticsCoworkMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsCoworkMetrics.fromJson(super.json);

  /// Reported action count.
  int get actionCount => rawJson['action_count'] as int;

  /// Reported artifacts created count.
  int get artifactsCreatedCount => rawJson['artifacts_created_count'] as int;

  /// Reported connectors used count.
  int get connectorsUsedCount => rawJson['connectors_used_count'] as int;

  /// Reported dispatch turn count.
  int get dispatchTurnCount => rawJson['dispatch_turn_count'] as int;

  /// Reported distinct connectors used count.
  int? get distinctConnectorsUsedCount =>
      rawJson['distinct_connectors_used_count'] as int?;

  /// Reported distinct plugins used count.
  int? get distinctPluginsUsedCount =>
      rawJson['distinct_plugins_used_count'] as int?;

  /// Reported distinct session count.
  int? get distinctSessionCount => rawJson['distinct_session_count'] as int?;

  /// Reported distinct skills used count.
  int? get distinctSkillsUsedCount =>
      rawJson['distinct_skills_used_count'] as int?;

  /// Reported edit tool count.
  int? get editToolCount => rawJson['edit_tool_count'] as int?;

  /// Reported file edit count.
  int? get fileEditCount => rawJson['file_edit_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Reported multi edit tool count.
  int? get multiEditToolCount => rawJson['multi_edit_tool_count'] as int?;

  /// Reported notebook edit tool count.
  int? get notebookEditToolCount => rawJson['notebook_edit_tool_count'] as int?;

  /// Reported plugins used count.
  int? get pluginsUsedCount => rawJson['plugins_used_count'] as int?;

  /// Reported sessions with file edits count.
  int? get sessionsWithFileEditsCount =>
      rawJson['sessions_with_file_edits_count'] as int?;

  /// Reported skills used count.
  int get skillsUsedCount => rawJson['skills_used_count'] as int;

  /// Reported write tool count.
  int? get writeToolCount => rawJson['write_tool_count'] as int?;
}

/// Design metrics for Enterprise activity.
final class AnalyticsDesignMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsDesignMetrics.fromJson(super.json);

  /// Reported distinct projects created count.
  int get distinctProjectsCreatedCount =>
      rawJson['distinct_projects_created_count'] as int;

  /// Reported distinct projects used count.
  int? get distinctProjectsUsedCount =>
      rawJson['distinct_projects_used_count'] as int?;

  /// Reported distinct session count.
  int? get distinctSessionCount => rawJson['distinct_session_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;
}

/// Lines added and removed in Claude Code.
final class AnalyticsLinesOfCode extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsLinesOfCode.fromJson(super.json);

  /// Reported added count.
  int get addedCount => rawJson['added_count'] as int;

  /// Reported removed count.
  int get removedCount => rawJson['removed_count'] as int;
}

/// Office metrics for Enterprise activity.
final class AnalyticsOfficeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsOfficeMetrics.fromJson(super.json);

  /// Excel.
  AnalyticsOfficeProductMetrics get excel =>
      AnalyticsOfficeProductMetrics.fromJson(_reportObject(rawJson, 'excel'));

  /// Outlook.
  AnalyticsOfficeProductMetrics get outlook =>
      AnalyticsOfficeProductMetrics.fromJson(_reportObject(rawJson, 'outlook'));

  /// Powerpoint.
  AnalyticsOfficeProductMetrics get powerpoint =>
      AnalyticsOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'powerpoint'),
      );

  /// Word.
  AnalyticsOfficeProductMetrics get word =>
      AnalyticsOfficeProductMetrics.fromJson(_reportObject(rawJson, 'word'));
}

/// Office Product metrics for Enterprise activity.
final class AnalyticsOfficeProductMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsOfficeProductMetrics.fromJson(super.json);

  /// Reported connectors used count.
  int get connectorsUsedCount => rawJson['connectors_used_count'] as int;

  /// Reported distinct connectors used count.
  int? get distinctConnectorsUsedCount =>
      rawJson['distinct_connectors_used_count'] as int?;

  /// Reported distinct session count.
  int? get distinctSessionCount => rawJson['distinct_session_count'] as int?;

  /// Reported distinct skills used count.
  int? get distinctSkillsUsedCount =>
      rawJson['distinct_skills_used_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Reported skills used count.
  int get skillsUsedCount => rawJson['skills_used_count'] as int;
}

/// Plugin Chat and Cowork unified metrics for Enterprise activity.
final class AnalyticsPluginChatCoworkUnifiedMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsPluginChatCoworkUnifiedMetrics.fromJson(super.json);

  /// Reported distinct session plugin used count.
  int? get distinctSessionPluginUsedCount =>
      rawJson['distinct_session_plugin_used_count'] as int?;
}

/// Plugin Claude Code metrics for Enterprise activity.
final class AnalyticsPluginClaudeCodeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsPluginClaudeCodeMetrics.fromJson(super.json);

  /// Reported distinct session plugin used count.
  int? get distinctSessionPluginUsedCount =>
      rawJson['distinct_session_plugin_used_count'] as int?;
}

/// Plugin Cowork metrics for Enterprise activity.
final class AnalyticsPluginCoworkMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsPluginCoworkMetrics.fromJson(super.json);

  /// Reported distinct session plugin used count.
  int? get distinctSessionPluginUsedCount =>
      rawJson['distinct_session_plugin_used_count'] as int?;
}

/// Science metrics for Enterprise activity.
final class AnalyticsScienceMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsScienceMetrics.fromJson(super.json);

  /// Reported delegation count.
  int get delegationCount => rawJson['delegation_count'] as int;

  /// Reported distinct session count.
  int? get distinctSessionCount => rawJson['distinct_session_count'] as int?;

  /// Reported message count.
  int get messageCount => rawJson['message_count'] as int;

  /// Reported remote compute job count.
  int get remoteComputeJobCount => rawJson['remote_compute_job_count'] as int;

  /// Reported skills used count.
  int get skillsUsedCount => rawJson['skills_used_count'] as int;
}

/// Skill Chat and Cowork unified Chat metrics for Enterprise activity.
final class AnalyticsSkillChatCoworkUnifiedChatMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillChatCoworkUnifiedChatMetrics.fromJson(super.json);

  /// Reported distinct conversation skill used count.
  int? get distinctConversationSkillUsedCount =>
      rawJson['distinct_conversation_skill_used_count'] as int?;
}

/// Skill Chat and Cowork unified metrics for Enterprise activity.
final class AnalyticsSkillChatCoworkUnifiedMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillChatCoworkUnifiedMetrics.fromJson(super.json);

  /// Chat.
  AnalyticsSkillChatCoworkUnifiedChatMetrics get chat =>
      AnalyticsSkillChatCoworkUnifiedChatMetrics.fromJson(
        _reportObject(rawJson, 'chat'),
      );

  /// Sessions.
  AnalyticsSkillChatCoworkUnifiedSessionsMetrics get sessions =>
      AnalyticsSkillChatCoworkUnifiedSessionsMetrics.fromJson(
        _reportObject(rawJson, 'sessions'),
      );
}

/// Skill Chat and Cowork unified Sessions metrics for Enterprise activity.
final class AnalyticsSkillChatCoworkUnifiedSessionsMetrics
    extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillChatCoworkUnifiedSessionsMetrics.fromJson(super.json);

  /// Reported distinct session skill used count.
  int? get distinctSessionSkillUsedCount =>
      rawJson['distinct_session_skill_used_count'] as int?;
}

/// Skill Chat metrics for Enterprise activity.
final class AnalyticsSkillChatMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillChatMetrics.fromJson(super.json);

  /// Reported distinct conversation skill used count.
  int? get distinctConversationSkillUsedCount =>
      rawJson['distinct_conversation_skill_used_count'] as int?;
}

/// Skill Claude Code metrics for Enterprise activity.
final class AnalyticsSkillClaudeCodeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillClaudeCodeMetrics.fromJson(super.json);

  /// Reported distinct session skill used count.
  int? get distinctSessionSkillUsedCount =>
      rawJson['distinct_session_skill_used_count'] as int?;
}

/// Skill Cowork metrics for Enterprise activity.
final class AnalyticsSkillCoworkMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillCoworkMetrics.fromJson(super.json);

  /// Reported distinct session skill used count.
  int? get distinctSessionSkillUsedCount =>
      rawJson['distinct_session_skill_used_count'] as int?;
}

/// Skill Office metrics for Enterprise activity.
final class AnalyticsSkillOfficeMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillOfficeMetrics.fromJson(super.json);

  /// Excel.
  AnalyticsSkillOfficeProductMetrics get excel =>
      AnalyticsSkillOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'excel'),
      );

  /// Outlook.
  AnalyticsSkillOfficeProductMetrics get outlook =>
      AnalyticsSkillOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'outlook'),
      );

  /// Powerpoint.
  AnalyticsSkillOfficeProductMetrics get powerpoint =>
      AnalyticsSkillOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'powerpoint'),
      );

  /// Word.
  AnalyticsSkillOfficeProductMetrics get word =>
      AnalyticsSkillOfficeProductMetrics.fromJson(
        _reportObject(rawJson, 'word'),
      );
}

/// Skill Office Product metrics for Enterprise activity.
final class AnalyticsSkillOfficeProductMetrics extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsSkillOfficeProductMetrics.fromJson(super.json);

  /// Reported distinct session skill used count.
  int? get distinctSessionSkillUsedCount =>
      rawJson['distinct_session_skill_used_count'] as int?;
}

/// Approval and rejection counts for a Claude Code tool.
final class AnalyticsToolActionCounts extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsToolActionCounts.fromJson(super.json);

  /// Reported accepted count.
  int get acceptedCount => rawJson['accepted_count'] as int;

  /// Reported rejected count.
  int get rejectedCount => rawJson['rejected_count'] as int;
}

/// Approval and rejection counts by Claude Code editing tool.
final class AnalyticsToolActions extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsToolActions.fromJson(super.json);

  /// Edit tool.
  AnalyticsToolActionCounts get editTool =>
      AnalyticsToolActionCounts.fromJson(_reportObject(rawJson, 'edit_tool'));

  /// Multi edit tool.
  AnalyticsToolActionCounts get multiEditTool =>
      AnalyticsToolActionCounts.fromJson(
        _reportObject(rawJson, 'multi_edit_tool'),
      );

  /// Notebook edit tool.
  AnalyticsToolActionCounts get notebookEditTool =>
      AnalyticsToolActionCounts.fromJson(
        _reportObject(rawJson, 'notebook_edit_tool'),
      );

  /// Write tool.
  AnalyticsToolActionCounts get writeTool =>
      AnalyticsToolActionCounts.fromJson(_reportObject(rawJson, 'write_tool'));
}

/// A user referenced by an Enterprise activity report.
final class AnalyticsUser extends AnalyticsResponseRecord {
  /// Parses the reported fields and preserves the original response.
  AnalyticsUser.fromJson(super.json);

  /// Email address.
  String get emailAddress => rawJson['email_address'] as String;

  /// Organization member ID.
  String get id => rawJson['id'] as String;

  /// Provider discriminator.
  String get type => rawJson['type'] as String;
}

/// An Enterprise activity page, with the current or historical wire envelope.
final class AnalyticsActivityPage<T> extends AnalyticsResponseRecord {
  /// Parses an activity page with its row decoder.
  AnalyticsActivityPage.fromJson(
    super.json,
    T Function(Map<String, dynamic>) decode, {
    bool allowLegacySummaries = false,
  }) : data = List.unmodifiable(
         _activityData(
           json,
           allowLegacySummaries,
         ).cast<Map<String, dynamic>>().map(decode),
       ),
       nextPage = _activityCursor(json, allowLegacySummaries);

  /// Activity rows, regardless of the version's wire field name.
  final List<T> data;

  /// Cursor for another page, when present.
  final String? nextPage;

  static String? _activityCursor(
    Map<String, dynamic> json,
    bool allowLegacySummaries,
  ) {
    final cursor = allowLegacySummaries && !json.containsKey('data')
        ? json['next_page'] as String?
        : requiredOrganizationField<String?>(
            json,
            'next_page',
            'Activity page',
          );
    return cursor == '' ? null : cursor;
  }

  static List<Object?> _activityData(
    Map<String, dynamic> json,
    bool allowLegacySummaries,
  ) => requiredOrganizationField<List<Object?>>(
    json,
    allowLegacySummaries && !json.containsKey('data') ? 'summaries' : 'data',
    'Activity page',
  );
}
