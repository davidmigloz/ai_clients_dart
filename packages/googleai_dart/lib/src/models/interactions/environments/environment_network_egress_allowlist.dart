part of 'environments.dart';

/// Outbound networking configuration for an environment's sandbox.
///
/// Either an allowlist object ([EnvironmentNetworkAllowlist]) restricting which
/// external domains the sandbox can reach, or the string `"disabled"`
/// ([EnvironmentNetworkDisabled]) to block all network access. Omit entirely to
/// allow all outbound traffic with no header injection.
sealed class EnvironmentNetworkEgressAllowlist {
  const EnvironmentNetworkEgressAllowlist();

  /// Creates an [EnvironmentNetworkEgressAllowlist] from a JSON value.
  ///
  /// Accepts the `"disabled"` string ([EnvironmentNetworkDisabled]) or an
  /// allowlist object ([EnvironmentNetworkAllowlist]).
  factory EnvironmentNetworkEgressAllowlist.fromJson(Object json) {
    if (json is String) {
      return const EnvironmentNetworkDisabled();
    }
    if (json is Map<String, dynamic>) {
      return EnvironmentNetworkAllowlist(
        allowlist: (json['allowlist'] as List<dynamic>?)
            ?.map((e) => AllowlistEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    throw ArgumentError(
      'Unknown network egress config: expected an object or the string '
      '"disabled", got ${json.runtimeType}',
    );
  }

  /// Converts to its JSON representation (an object or the `"disabled"` string).
  Object toJson();
}

/// An allowlist restricting which external domains the sandbox can reach.
class EnvironmentNetworkAllowlist extends EnvironmentNetworkEgressAllowlist {
  /// List of allowed outbound domains. Only requests to listed domains are
  /// permitted.
  final List<AllowlistEntry>? allowlist;

  /// Creates an [EnvironmentNetworkAllowlist].
  const EnvironmentNetworkAllowlist({this.allowlist});

  @override
  Object toJson() => {
    if (allowlist != null)
      'allowlist': allowlist!.map((e) => e.toJson()).toList(),
  };
}

/// Disables all network egress for the sandbox (the `"disabled"` form).
class EnvironmentNetworkDisabled extends EnvironmentNetworkEgressAllowlist {
  /// Creates an [EnvironmentNetworkDisabled].
  const EnvironmentNetworkDisabled();

  @override
  Object toJson() => 'disabled';
}
