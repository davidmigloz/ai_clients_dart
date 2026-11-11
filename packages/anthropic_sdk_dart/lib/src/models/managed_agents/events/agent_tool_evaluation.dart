import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';
import '../config/agent_tool.dart' show AgentEvaluatedPermission;

/// Details of the policy that evaluated a Managed Agents tool call.
@immutable
final class AgentToolEvaluation {
  final Map<String, dynamic> _raw;

  /// The resolved policy, such as `auto`, `always_ask`, or `always_allow`.
  final String type;

  /// The decision from an automatic policy.
  final AgentAutoToolDecision? autoDecision;

  AgentToolEvaluation._(Map<String, dynamic> raw, this.type, this.autoDecision)
    : _raw = deepUnmodifiableMap(raw);

  /// Parses evaluation details and preserves future policy variants.
  factory AgentToolEvaluation.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      throw const FormatException('Tool evaluation requires type');
    }
    if (type == 'auto') {
      final decision = json['evaluated_permission'];
      if (decision is! Map<String, dynamic>) {
        throw const FormatException(
          'Auto tool evaluation requires evaluated_permission',
        );
      }
      return AgentToolEvaluation._(
        json,
        type,
        AgentAutoToolDecision.fromJson(decision),
      );
    }
    return AgentToolEvaluation._(json, type, null);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentToolEvaluation && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() =>
      'AgentToolEvaluation(type: $type, autoDecision: $autoDecision)';
}

/// The allow, ask, or deny judgement from an automatic permission policy.
@immutable
final class AgentAutoToolDecision {
  final Map<String, dynamic> _raw;

  /// The original decision discriminator.
  final String type;

  /// The interpreted decision. Unknown values map to the enum fallback.
  AgentEvaluatedPermission get permission =>
      AgentEvaluatedPermission.fromJson(type);

  /// The service reason code for an ask or deny decision.
  final String? reasonCode;

  AgentAutoToolDecision._(Map<String, dynamic> raw, this.type, this.reasonCode)
    : _raw = deepUnmodifiableMap(raw);

  /// Parses a decision, preserving unrecognized types and reason codes.
  factory AgentAutoToolDecision.fromJson(Map<String, dynamic> json) {
    final type = json['type'];
    if (type is! String) {
      throw const FormatException('Auto tool decision requires type');
    }
    final reason = json['reason_code'];
    if ((type == 'ask' || type == 'deny') && reason is! String) {
      throw const FormatException('Ask or deny decisions require reason_code');
    }
    return AgentAutoToolDecision._(
      json,
      type,
      reason is String ? reason : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => Map.of(_raw);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentAutoToolDecision && mapsDeepEqual(_raw, other._raw);

  @override
  int get hashCode => mapDeepHashCode(_raw);

  @override
  String toString() =>
      'AgentAutoToolDecision(type: $type, reasonCode: $reasonCode)';
}
