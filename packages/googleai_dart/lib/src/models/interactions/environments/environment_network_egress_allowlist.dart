part of 'environments.dart';

/// Outbound networking configuration for an environment's sandbox.
///
/// Either an allowlist object ([EnvironmentNetworkAllowlist]) restricting which
/// external domains the sandbox can reach, or a disabled configuration
/// ([EnvironmentNetworkDisabled]) to block all network access. Omit entirely to
/// allow all outbound traffic with no header injection.
sealed class EnvironmentNetworkEgressAllowlist {
  const EnvironmentNetworkEgressAllowlist();

  /// Creates an [EnvironmentNetworkEgressAllowlist] from a JSON value.
  ///
  /// Accepts the `"disabled"` string, an object with a disabled allowlist,
  /// or an object with a list of [AllowlistEntry] values.
  factory EnvironmentNetworkEgressAllowlist.fromJson(Object json) {
    if (json is String) {
      if (json == 'disabled') {
        return const EnvironmentNetworkDisabled();
      }
      throw ArgumentError(
        'Unknown network egress config string: expected "disabled", got '
        '"$json"',
      );
    }
    if (json is Map<String, dynamic>) {
      if (json['allowlist'] == 'disabled') {
        return const EnvironmentNetworkDisabled.allowlist();
      }
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

/// Disables all network egress for the sandbox.
class EnvironmentNetworkDisabled extends EnvironmentNetworkEgressAllowlist {
  final bool _allowlistForm;

  /// Sends the standalone `"disabled"` value.
  const EnvironmentNetworkDisabled() : _allowlistForm = false;

  /// Sends the object containing a disabled allowlist.
  const EnvironmentNetworkDisabled.allowlist() : _allowlistForm = true;

  @override
  Object toJson() =>
      _allowlistForm ? const {'allowlist': 'disabled'} : 'disabled';
}
