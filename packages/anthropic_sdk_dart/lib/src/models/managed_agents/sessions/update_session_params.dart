import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import '../common/budget.dart';
import 'session_agent_update.dart';

/// Private sentinel to distinguish "not provided" from explicit `null`.
const Object _notSet = Object();

/// Request parameters for updating a session.
///
/// Omit a field to preserve its current value.
/// Pass `null` explicitly to clear a clearable field.
@immutable
class UpdateSessionParams {
  /// Human-readable session title.
  String? get title => _title == _notSet ? null : _title as String?;
  final Object? _title;

  /// Metadata patch. Set a key to a string to upsert, or to null to delete.
  Map<String, String?>? get metadata => _metadata == _notSet
      ? null
      : (_metadata as Map?)?.cast<String, String?>();
  final Object? _metadata;

  /// Vault IDs to attach to the session.
  List<String>? get vaultIds =>
      _vaultIds == _notSet ? null : (_vaultIds as List?)?.cast<String>();
  final Object? _vaultIds;

  /// Agent configuration patch to apply to the session.
  ///
  /// Provide a [SessionAgentUpdate] to replace the agent's tools and/or MCP
  /// servers. The API does not accept `null` for this field, so `null` here
  /// means "not provided" and is omitted from the request. To clear tools or
  /// MCP servers, pass empty arrays inside the [SessionAgentUpdate].
  final SessionAgentUpdate? agent;

  /// Enforced spend ceiling for the session. Set an object to replace the
  /// budget of a session that was created with one, or `null` to remove it;
  /// omit to preserve. A budget cannot be added to a session created without
  /// one (rejected with reason `budget_create_only`), and a removed budget
  /// cannot be re-added. Allowed in any non-terminated status. Lowering
  /// `maxListCost` to at or below the session's consumed list cost is
  /// rejected with reason `budget_not_raised`, and every model the session
  /// can run must have a public list price or the request is rejected with
  /// reason `model_not_budgetable`.
  Budget? get budget => _budget == _notSet ? null : _budget as Budget?;
  final Object? _budget;

  /// Creates an [UpdateSessionParams].
  ///
  /// Omit a field to preserve its current value on the server.
  /// Pass `null` explicitly to clear a clearable field.
  const UpdateSessionParams({
    Object? title = _notSet,
    Object? metadata = _notSet,
    Object? vaultIds = _notSet,
    this.agent,
    Object? budget = _notSet,
  }) : _title = title,
       _metadata = metadata,
       _vaultIds = vaultIds,
       _budget = budget;

  /// Creates an [UpdateSessionParams] from JSON.
  factory UpdateSessionParams.fromJson(Map<String, dynamic> json) {
    return UpdateSessionParams(
      title: json.containsKey('title') ? json['title'] as String? : _notSet,
      metadata: json.containsKey('metadata')
          ? (json['metadata'] as Map<String, dynamic>?)?.map(
              (k, v) => MapEntry(k, v as String?),
            )
          : _notSet,
      vaultIds: json.containsKey('vault_ids')
          ? (json['vault_ids'] as List?)?.map((e) => e as String).toList()
          : _notSet,
      agent: json['agent'] != null
          ? SessionAgentUpdate.fromJson(json['agent'] as Map<String, dynamic>)
          : null,
      budget: json.containsKey('budget')
          ? (json['budget'] != null
                ? Budget.fromJson(json['budget'] as Map<String, dynamic>)
                : null)
          : _notSet,
    );
  }

  /// Converts to JSON.
  ///
  /// Clearable fields ([title], [metadata], [vaultIds], [budget]) that were
  /// not set are omitted; when explicitly set to `null` they are included as
  /// `null` to clear the value on the server. [agent] is not nullable in the
  /// API, so it is emitted only when a value is provided.
  Map<String, dynamic> toJson() => {
    if (_title != _notSet) 'title': _title,
    if (_metadata != _notSet) 'metadata': _metadata,
    if (_vaultIds != _notSet) 'vault_ids': _vaultIds,
    if (agent != null) 'agent': agent!.toJson(),
    if (_budget != _notSet) 'budget': (_budget as Budget?)?.toJson(),
  };

  /// Creates a copy with replaced values.
  UpdateSessionParams copyWith({
    Object? title = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? vaultIds = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? budget = unsetCopyWithValue,
  }) {
    return UpdateSessionParams(
      title: title == unsetCopyWithValue ? _title : title,
      metadata: metadata == unsetCopyWithValue ? _metadata : metadata,
      vaultIds: vaultIds == unsetCopyWithValue ? _vaultIds : vaultIds,
      agent: agent == unsetCopyWithValue
          ? this.agent
          : agent as SessionAgentUpdate?,
      budget: budget == unsetCopyWithValue ? _budget : budget,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateSessionParams &&
          runtimeType == other.runtimeType &&
          _title == other._title &&
          _mapsEqualOrBothSentinel(_metadata, other._metadata) &&
          _listsEqualOrBothSentinel(_vaultIds, other._vaultIds) &&
          agent == other.agent &&
          _budget == other._budget;

  @override
  int get hashCode => Object.hash(
    _title,
    _metadata == _notSet ? _notSet : mapHash(metadata),
    _vaultIds == _notSet ? _notSet : listHash(vaultIds),
    agent,
    _budget,
  );

  @override
  String toString() =>
      'UpdateSessionParams('
      'title: $title, '
      'metadata: $metadata, '
      'vaultIds: $vaultIds, '
      'agent: $agent, '
      'budget: $budget)';
}

bool _listsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return listsEqual(a as List?, b as List?);
}

bool _mapsEqualOrBothSentinel(Object? a, Object? b) {
  if (identical(a, _notSet) && identical(b, _notSet)) return true;
  if (identical(a, _notSet) || identical(b, _notSet)) return false;
  return mapsEqual(a as Map?, b as Map?);
}
