/// Typed envelope for the canonical inline subagent-list response.
library;

import '../common/copy_with_sentinel.dart';
import 'agent_json_helpers.dart';
import 'agent_session_models.dart';

/// A page of Agents API resources, with IDs for retrieving additional pages.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionSubagentList extends AgentJsonModel {
  /// Creates a validated [AgentSessionSubagentList].
  AgentSessionSubagentList({
    required List<AgentSessionSubagent> data,
    required this.firstId,
    required this.hasMore,
    required this.lastId,
    Map<String, dynamic> rawJson = const {},
  }) : data = List.unmodifiable(data),
       rawJson = agentExtras(rawJson, const [
         'data',
         'first_id',
         'has_more',
         'last_id',
         'object',
       ], 'AgentSessionSubagentList') {
    validate();
  }

  /// The resources returned in this page, in the requested sort order.
  final List<AgentSessionSubagent> data;

  /// The ID of the first resource in `data`, or `null` if the page is empty.
  final String? firstId;

  /// Whether there are more resources to retrieve after this page.
  final bool hasMore;

  /// The ID of the last resource in `data`, or `null` if the page is empty. Pass this as `after` with the same order and filters.
  final String? lastId;

  /// The object type, which is always `list`.
  String get object => 'list';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionSubagentList] with contextual, payload-free errors.
  factory AgentSessionSubagentList.fromJson(Map<String, dynamic> json) {
    requireAgentTag(json, 'object', 'list', 'AgentSessionSubagentList');
    return AgentSessionSubagentList(
      data: requiredAgentValue(
        json,
        'data',
        'AgentSessionSubagentList.data',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionSubagent.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      firstId: requiredAgentValue(
        json,
        'first_id',
        'AgentSessionSubagentList.firstId',
        requireAgentString,
        nullable: true,
      ),
      hasMore: requiredAgentValue(
        json,
        'has_more',
        'AgentSessionSubagentList.hasMore',
        requireAgentBool,
        nullable: false,
      )!,
      lastId: requiredAgentValue(
        json,
        'last_id',
        'AgentSessionSubagentList.lastId',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'data',
            'first_id',
            'has_more',
            'last_id',
            'object',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      data.length,
      'AgentSessionSubagentList.data',
      min: 0,
      max: 2000,
    );
    for (final item in data) {
      item.validate();
    }
    if (firstId != null) {
      validateAgentLength(firstId!, 'AgentSessionSubagentList.firstId', min: 0);
    }
    if (lastId != null) {
      validateAgentLength(lastId!, 'AgentSessionSubagentList.lastId', min: 0);
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'data': data.map((value) => value.toJson()).toList(),
    'first_id': firstId,
    'has_more': hasMore,
    'last_id': lastId,
    'object': object,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionSubagentList copyWith({
    List<AgentSessionSubagent>? data,
    Object? firstId = unsetCopyWithValue,
    bool? hasMore,
    Object? lastId = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionSubagentList(
    data: data ?? this.data,
    firstId: copyAgentValue<String>(
      firstId,
      this.firstId,
      'AgentSessionSubagentList.firstId',
    ),
    hasMore: hasMore ?? this.hasMore,
    lastId: copyAgentValue<String>(
      lastId,
      this.lastId,
      'AgentSessionSubagentList.lastId',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}
