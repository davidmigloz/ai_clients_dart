import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// Container configuration for the code interpreter tool.
///
/// See [CodeInterpreterContainerId] and [CodeInterpreterContainerAuto].
sealed class CodeInterpreterContainer {
  /// Creates a [CodeInterpreterContainer].
  const CodeInterpreterContainer();

  /// Creates a [CodeInterpreterContainer] from JSON.
  ///
  /// Accepts a [String] (container ID) or a [Map] with `type: "auto"`.
  factory CodeInterpreterContainer.fromJson(Object json) {
    if (json is String) return CodeInterpreterContainerId(json);
    if (json is Map<String, dynamic>) {
      final type = json['type'] as String?;
      if (type == 'auto') return CodeInterpreterContainerAuto.fromJson(json);
      throw FormatException('Unknown CodeInterpreterContainer type: $type');
    }
    throw FormatException(
      'Invalid CodeInterpreterContainer JSON: ${json.runtimeType}',
    );
  }

  /// Use an existing container by ID.
  static CodeInterpreterContainerId id(String id) =>
      CodeInterpreterContainerId(id);

  /// Auto-create a container.
  static CodeInterpreterContainerAuto auto({
    List<String>? fileIds,
    int? memoryLimit,
    ContainerNetworkPolicy? networkPolicy,
  }) => CodeInterpreterContainerAuto(
    fileIds: fileIds,
    memoryLimit: memoryLimit,
    networkPolicy: networkPolicy,
  );

  /// Converts to JSON.
  Object toJson();
}

/// Use an existing container by ID.
@immutable
class CodeInterpreterContainerId extends CodeInterpreterContainer {
  /// The container ID.
  final String id;

  /// Creates a [CodeInterpreterContainerId].
  const CodeInterpreterContainerId(this.id);

  @override
  Object toJson() => id;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterContainerId &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CodeInterpreterContainerId($id)';
}

/// Auto-create a container for code execution.
@immutable
class CodeInterpreterContainerAuto extends CodeInterpreterContainer {
  /// File IDs to make available in the container.
  final List<String>? fileIds;

  /// Memory limit in MB.
  ///
  /// Allowed values: 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536.
  final int? memoryLimit;

  /// Network access policy for the container.
  final ContainerNetworkPolicy? networkPolicy;

  /// Creates a [CodeInterpreterContainerAuto].
  const CodeInterpreterContainerAuto({
    this.fileIds,
    this.memoryLimit,
    this.networkPolicy,
  });

  /// Creates a [CodeInterpreterContainerAuto] from JSON.
  factory CodeInterpreterContainerAuto.fromJson(Map<String, dynamic> json) {
    return CodeInterpreterContainerAuto(
      fileIds: (json['file_ids'] as List?)?.cast<String>(),
      memoryLimit: json['memory_limit'] as int?,
      networkPolicy: json['network_policy'] != null
          ? ContainerNetworkPolicy.fromJson(json['network_policy'] as Object)
          : null,
    );
  }

  @override
  Object toJson() => {
    'type': 'auto',
    if (fileIds != null) 'file_ids': fileIds,
    if (memoryLimit != null) 'memory_limit': memoryLimit,
    if (networkPolicy != null) 'network_policy': networkPolicy!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeInterpreterContainerAuto &&
          runtimeType == other.runtimeType &&
          listsEqual(fileIds, other.fileIds) &&
          memoryLimit == other.memoryLimit &&
          networkPolicy == other.networkPolicy;

  @override
  int get hashCode => Object.hash(
    fileIds != null ? Object.hashAll(fileIds!) : null,
    memoryLimit,
    networkPolicy,
  );

  @override
  String toString() =>
      'CodeInterpreterContainerAuto(fileIds: $fileIds, memoryLimit: $memoryLimit, networkPolicy: $networkPolicy)';
}

/// Network access policy for a code interpreter container.
///
/// See [ContainerNetworkPolicyDisabled] and [ContainerNetworkPolicyAllowlist].
sealed class ContainerNetworkPolicy {
  /// Creates a [ContainerNetworkPolicy].
  const ContainerNetworkPolicy();

  /// Creates a [ContainerNetworkPolicy] from JSON.
  factory ContainerNetworkPolicy.fromJson(Object json) {
    if (json is Map<String, dynamic>) {
      final type = json['type'] as String?;
      return switch (type) {
        'disabled' => const ContainerNetworkPolicyDisabled(),
        'allowlist' => ContainerNetworkPolicyAllowlist.fromJson(json),
        _ => throw FormatException(
          'Unknown ContainerNetworkPolicy type: $type',
        ),
      };
    }
    throw FormatException(
      'Invalid ContainerNetworkPolicy JSON: ${json.runtimeType}',
    );
  }

  /// Disable network access.
  static const disabled = ContainerNetworkPolicyDisabled();

  /// Allow network access to specific hosts.
  static ContainerNetworkPolicyAllowlist allowlist(List<String> allowedHosts) =>
      ContainerNetworkPolicyAllowlist(allowedHosts: allowedHosts);

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Disable network access for the container.
@immutable
class ContainerNetworkPolicyDisabled extends ContainerNetworkPolicy {
  /// Creates a [ContainerNetworkPolicyDisabled].
  const ContainerNetworkPolicyDisabled();

  @override
  Map<String, dynamic> toJson() => const {'type': 'disabled'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ContainerNetworkPolicyDisabled;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'ContainerNetworkPolicyDisabled()';
}

/// Allow network access to specific hosts.
@immutable
class ContainerNetworkPolicyAllowlist extends ContainerNetworkPolicy {
  /// The list of allowed hostnames.
  final List<String> allowedHosts;

  /// Creates a [ContainerNetworkPolicyAllowlist].
  const ContainerNetworkPolicyAllowlist({required this.allowedHosts});

  /// Creates a [ContainerNetworkPolicyAllowlist] from JSON.
  factory ContainerNetworkPolicyAllowlist.fromJson(Map<String, dynamic> json) {
    return ContainerNetworkPolicyAllowlist(
      allowedHosts: (json['allowed_hosts'] as List).cast<String>(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'allowlist',
    'allowed_hosts': allowedHosts,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerNetworkPolicyAllowlist &&
          runtimeType == other.runtimeType &&
          listsEqual(allowedHosts, other.allowedHosts);

  @override
  int get hashCode => Object.hashAll(allowedHosts);

  @override
  String toString() =>
      'ContainerNetworkPolicyAllowlist(allowedHosts: $allowedHosts)';
}
