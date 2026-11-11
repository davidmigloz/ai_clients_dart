import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// The principal used to execute a Managed Agents agent.
@immutable
final class AgentExecutionIdentity {
  /// The execution identity discriminator.
  final String type;

  /// IAM role ARN for an AWS role execution identity.
  final String? roleArn;

  final Map<String, dynamic>? _unknown;

  /// The default Anthropic-managed service account.
  const AgentExecutionIdentity.serviceAccount()
    : type = 'service_account',
      roleArn = null,
      _unknown = null;

  /// An IAM role for runs hosted on Claude Platform on AWS.
  const AgentExecutionIdentity.awsRole(String this.roleArn)
    : type = 'aws_role',
      _unknown = null;

  AgentExecutionIdentity._unknown(this.type, Map<String, dynamic> raw)
    : roleArn = null,
      _unknown = deepUnmodifiableMap(raw);

  /// Parses a principal and preserves future principal types.
  factory AgentExecutionIdentity.fromJson(Map<String, dynamic> json) =>
      switch (json) {
        {'type': 'service_account'} =>
          const AgentExecutionIdentity.serviceAccount(),
        {'type': 'aws_role', 'role_arn': final String roleArn} =>
          AgentExecutionIdentity.awsRole(roleArn),
        {'type': 'aws_role'} => throw const FormatException(
          'AWS execution identity requires role_arn',
        ),
        {'type': final String type} => AgentExecutionIdentity._unknown(
          type,
          json,
        ),
        _ => throw const FormatException('Execution identity requires type'),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    ...?_unknown,
    'type': type,
    'role_arn': ?roleArn,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentExecutionIdentity &&
          type == other.type &&
          roleArn == other.roleArn &&
          mapsDeepEqual(_unknown, other._unknown);

  @override
  int get hashCode => Object.hash(type, roleArn, mapDeepHashCode(_unknown));

  @override
  String toString() => 'AgentExecutionIdentity(type: $type, roleArn: $roleArn)';
}
