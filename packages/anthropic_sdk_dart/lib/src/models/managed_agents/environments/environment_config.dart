import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Configuration returned for a Managed Agents environment.
@immutable
sealed class EnvironmentConfig {
  const EnvironmentConfig();

  /// Reads the configuration discriminator.
  factory EnvironmentConfig.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'cloud' => CloudEnvironmentConfig.fromJson(json),
        'self_hosted' => SelfHostedEnvironmentConfig.fromJson(json),
        String() => UnknownEnvironmentConfig(
          rawJson: deepUnmodifiableMap(json),
        ),
        _ => throw const FormatException('Environment variant requires type'),
      };

  /// The wire discriminator.
  String get type;

  /// Serializes to API JSON.
  Map<String, dynamic> toJson();
}

/// A future configuration variant preserved as raw JSON.
@immutable
final class UnknownEnvironmentConfig extends EnvironmentConfig {
  /// Creates an [UnknownEnvironmentConfig].
  const UnknownEnvironmentConfig({required this.rawJson});

  /// The received configuration.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  @override
  bool operator ==(Object other) =>
      other is UnknownEnvironmentConfig &&
      mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownEnvironmentConfig(type: $type)';
}

/// Configuration of a Claude-managed cloud environment.
@immutable
final class CloudEnvironmentConfig extends EnvironmentConfig {
  /// The wire discriminator.
  @override
  String get type => 'cloud';

  /// The network access policy.
  final EnvironmentNetwork networking;

  /// Packages in the environment.
  final EnvironmentPackages packages;

  /// Creates a [CloudEnvironmentConfig].
  const CloudEnvironmentConfig({
    required this.networking,
    required this.packages,
  });

  /// Reads a [CloudEnvironmentConfig] from JSON.
  factory CloudEnvironmentConfig.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'cloud');
    return CloudEnvironmentConfig(
      networking: EnvironmentNetwork.fromJson(
        json['networking'] as Map<String, dynamic>,
      ),
      packages: EnvironmentPackages.fromJson(
        json['packages'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'networking': networking.toJson(),
    'packages': packages.toJson(),
  };

  /// Copies this object with the selected values replaced.
  CloudEnvironmentConfig copyWith({
    EnvironmentNetwork? networking,
    EnvironmentPackages? packages,
  }) => CloudEnvironmentConfig(
    networking: networking ?? this.networking,
    packages: packages ?? this.packages,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudEnvironmentConfig &&
          networking == other.networking &&
          packages == other.packages;

  @override
  int get hashCode => Object.hash(networking, packages);

  @override
  String toString() =>
      'CloudEnvironmentConfig(networking: $networking, packages: $packages)';
}

/// Configuration of an environment operated by your workers.
@immutable
final class SelfHostedEnvironmentConfig extends EnvironmentConfig {
  /// The wire discriminator.
  @override
  String get type => 'self_hosted';

  /// Creates a [SelfHostedEnvironmentConfig].
  const SelfHostedEnvironmentConfig();

  /// Reads a [SelfHostedEnvironmentConfig] from JSON.
  factory SelfHostedEnvironmentConfig.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'self_hosted');
    return const SelfHostedEnvironmentConfig();
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) => other is SelfHostedEnvironmentConfig;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'SelfHostedEnvironmentConfig(${toJson()})';
}

/// Configuration accepted when creating or updating an environment.
@immutable
sealed class EnvironmentConfigParams {
  const EnvironmentConfigParams();

  /// Reads the configuration discriminator.
  factory EnvironmentConfigParams.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'cloud' => CloudEnvironmentConfigParams.fromJson(json),
        'self_hosted' => SelfHostedEnvironmentConfigParams.fromJson(json),
        _ => throw FormatException(
          'Unknown EnvironmentConfigParams type: ${json['type']}',
        ),
      };

  /// The wire discriminator.
  String get type;

  /// Serializes to API JSON.
  Map<String, dynamic> toJson();
}

/// Cloud environment configuration request.
@immutable
final class CloudEnvironmentConfigParams extends EnvironmentConfigParams {
  /// The wire discriminator.
  @override
  String get type => 'cloud';

  /// The network access policy.
  EnvironmentNetworkParams? get networking => _networking == unsetCopyWithValue
      ? null
      : _networking as EnvironmentNetworkParams?;
  final Object? _networking;

  /// Package manager configuration.
  EnvironmentPackagesParams? get packages => _packages == unsetCopyWithValue
      ? null
      : _packages as EnvironmentPackagesParams?;
  final Object? _packages;

  /// Creates a [CloudEnvironmentConfigParams].
  ///
  /// Omit an optional field to omit its wire key. Pass null to send JSON null.
  const CloudEnvironmentConfigParams({
    this._networking = unsetCopyWithValue,
    this._packages = unsetCopyWithValue,
  });

  /// Reads a [CloudEnvironmentConfigParams] from JSON.
  factory CloudEnvironmentConfigParams.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'cloud');
    return CloudEnvironmentConfigParams(
      networking: json.containsKey('networking')
          ? (json['networking'] == null
                ? null
                : EnvironmentNetworkParams.fromJson(
                    json['networking'] as Map<String, dynamic>,
                  ))
          : unsetCopyWithValue,
      packages: json.containsKey('packages')
          ? (json['packages'] == null
                ? null
                : EnvironmentPackagesParams.fromJson(
                    json['packages'] as Map<String, dynamic>,
                  ))
          : unsetCopyWithValue,
    );
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (_networking != unsetCopyWithValue) 'networking': networking?.toJson(),
    if (_packages != unsetCopyWithValue) 'packages': packages?.toJson(),
  };

  /// Copies this object with the selected values replaced.
  CloudEnvironmentConfigParams copyWith({
    Object? networking = unsetCopyWithValue,
    Object? packages = unsetCopyWithValue,
  }) => CloudEnvironmentConfigParams(
    networking: networking == unsetCopyWithValue ? _networking : networking,
    packages: packages == unsetCopyWithValue ? _packages : packages,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudEnvironmentConfigParams &&
          (_networking == unsetCopyWithValue) ==
              (other._networking == unsetCopyWithValue) &&
          networking == other.networking &&
          (_packages == unsetCopyWithValue) ==
              (other._packages == unsetCopyWithValue) &&
          packages == other.packages;

  @override
  int get hashCode => Object.hash(
    _networking == unsetCopyWithValue ? unsetCopyWithValue : networking,
    _packages == unsetCopyWithValue ? unsetCopyWithValue : packages,
  );

  @override
  String toString() =>
      'CloudEnvironmentConfigParams(networking: $networking, packages: $packages)';
}

/// Self-hosted environment configuration request.
@immutable
final class SelfHostedEnvironmentConfigParams extends EnvironmentConfigParams {
  /// The wire discriminator.
  @override
  String get type => 'self_hosted';

  /// Creates a [SelfHostedEnvironmentConfigParams].
  const SelfHostedEnvironmentConfigParams();

  /// Reads a [SelfHostedEnvironmentConfigParams] from JSON.
  factory SelfHostedEnvironmentConfigParams.fromJson(
    Map<String, dynamic> json,
  ) {
    _validateType(json, 'self_hosted');
    return const SelfHostedEnvironmentConfigParams();
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) => other is SelfHostedEnvironmentConfigParams;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'SelfHostedEnvironmentConfigParams(${toJson()})';
}

/// A cloud environment network access policy.
@immutable
sealed class EnvironmentNetwork {
  const EnvironmentNetwork();

  /// Reads the configuration discriminator.
  factory EnvironmentNetwork.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'limited' => LimitedEnvironmentNetwork.fromJson(json),
        'unrestricted' => UnrestrictedEnvironmentNetwork.fromJson(json),
        String() => UnknownEnvironmentNetwork(
          rawJson: deepUnmodifiableMap(json),
        ),
        _ => throw const FormatException('Environment variant requires type'),
      };

  /// The wire discriminator.
  String get type;

  /// Serializes to API JSON.
  Map<String, dynamic> toJson();
}

/// A future configuration variant preserved as raw JSON.
@immutable
final class UnknownEnvironmentNetwork extends EnvironmentNetwork {
  /// Creates an [UnknownEnvironmentNetwork].
  const UnknownEnvironmentNetwork({required this.rawJson});

  /// The received configuration.
  final Map<String, dynamic> rawJson;

  @override
  String get type => rawJson['type'] as String;

  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  @override
  bool operator ==(Object other) =>
      other is UnknownEnvironmentNetwork &&
      mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownEnvironmentNetwork(type: $type)';
}

/// Cloud networking restricted to selected destinations.
@immutable
final class LimitedEnvironmentNetwork extends EnvironmentNetwork {
  /// The wire discriminator.
  @override
  String get type => 'limited';

  /// Whether configured MCP endpoints may be reached.
  final bool allowMcpServers;

  /// Whether public package registries may be reached.
  final bool allowPackageManagers;

  /// Domains the environment can reach.
  final List<String> allowedHosts;

  /// Creates a [LimitedEnvironmentNetwork].
  const LimitedEnvironmentNetwork({
    required this.allowMcpServers,
    required this.allowPackageManagers,
    required this.allowedHosts,
  });

  /// Reads a [LimitedEnvironmentNetwork] from JSON.
  factory LimitedEnvironmentNetwork.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'limited');
    return LimitedEnvironmentNetwork(
      allowMcpServers: json['allow_mcp_servers'] as bool,
      allowPackageManagers: json['allow_package_managers'] as bool,
      allowedHosts: (json['allowed_hosts'] as List).cast<String>(),
    );
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'allow_mcp_servers': allowMcpServers,
    'allow_package_managers': allowPackageManagers,
    'allowed_hosts': allowedHosts,
  };

  /// Copies this object with the selected values replaced.
  LimitedEnvironmentNetwork copyWith({
    bool? allowMcpServers,
    bool? allowPackageManagers,
    List<String>? allowedHosts,
  }) => LimitedEnvironmentNetwork(
    allowMcpServers: allowMcpServers ?? this.allowMcpServers,
    allowPackageManagers: allowPackageManagers ?? this.allowPackageManagers,
    allowedHosts: allowedHosts ?? this.allowedHosts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitedEnvironmentNetwork &&
          allowMcpServers == other.allowMcpServers &&
          allowPackageManagers == other.allowPackageManagers &&
          listsEqual(allowedHosts, other.allowedHosts);

  @override
  int get hashCode => Object.hash(
    allowMcpServers,
    allowPackageManagers,
    listHash(allowedHosts),
  );

  @override
  String toString() =>
      'LimitedEnvironmentNetwork(allowMcpServers: $allowMcpServers, allowPackageManagers: $allowPackageManagers, allowedHosts: $allowedHosts)';
}

/// Cloud networking with unrestricted outbound access.
@immutable
final class UnrestrictedEnvironmentNetwork extends EnvironmentNetwork {
  /// The wire discriminator.
  @override
  String get type => 'unrestricted';

  /// Creates a [UnrestrictedEnvironmentNetwork].
  const UnrestrictedEnvironmentNetwork();

  /// Reads a [UnrestrictedEnvironmentNetwork] from JSON.
  factory UnrestrictedEnvironmentNetwork.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'unrestricted');
    return const UnrestrictedEnvironmentNetwork();
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) => other is UnrestrictedEnvironmentNetwork;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'UnrestrictedEnvironmentNetwork(${toJson()})';
}

/// Network access policy accepted in cloud configuration requests.
@immutable
sealed class EnvironmentNetworkParams {
  const EnvironmentNetworkParams();

  /// Reads the configuration discriminator.
  factory EnvironmentNetworkParams.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'limited' => LimitedEnvironmentNetworkParams.fromJson(json),
        'unrestricted' => UnrestrictedEnvironmentNetworkParams.fromJson(json),
        _ => throw FormatException(
          'Unknown EnvironmentNetworkParams type: ${json['type']}',
        ),
      };

  /// The wire discriminator.
  String get type;

  /// Serializes to API JSON.
  Map<String, dynamic> toJson();
}

/// Request to restrict cloud environment networking.
@immutable
final class LimitedEnvironmentNetworkParams extends EnvironmentNetworkParams {
  /// The wire discriminator.
  @override
  String get type => 'limited';

  /// Whether configured MCP endpoints may be reached.
  bool? get allowMcpServers =>
      _allowMcpServers == unsetCopyWithValue ? null : _allowMcpServers as bool?;
  final Object? _allowMcpServers;

  /// Whether public package registries may be reached.
  bool? get allowPackageManagers => _allowPackageManagers == unsetCopyWithValue
      ? null
      : _allowPackageManagers as bool?;
  final Object? _allowPackageManagers;

  /// Domains the environment can reach.
  List<String>? get allowedHosts => _allowedHosts == unsetCopyWithValue
      ? null
      : (_allowedHosts as List?)?.cast<String>();
  final Object? _allowedHosts;

  /// Creates a [LimitedEnvironmentNetworkParams].
  ///
  /// Omit an optional field to omit its wire key. Pass null to send JSON null.
  const LimitedEnvironmentNetworkParams({
    this._allowMcpServers = unsetCopyWithValue,
    this._allowPackageManagers = unsetCopyWithValue,
    this._allowedHosts = unsetCopyWithValue,
  });

  /// Reads a [LimitedEnvironmentNetworkParams] from JSON.
  factory LimitedEnvironmentNetworkParams.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'limited');
    return LimitedEnvironmentNetworkParams(
      allowMcpServers: json.containsKey('allow_mcp_servers')
          ? (json['allow_mcp_servers'] as bool?)
          : unsetCopyWithValue,
      allowPackageManagers: json.containsKey('allow_package_managers')
          ? (json['allow_package_managers'] as bool?)
          : unsetCopyWithValue,
      allowedHosts: json.containsKey('allowed_hosts')
          ? (json['allowed_hosts'] as List?)?.cast<String>()
          : unsetCopyWithValue,
    );
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (_allowMcpServers != unsetCopyWithValue)
      'allow_mcp_servers': allowMcpServers,
    if (_allowPackageManagers != unsetCopyWithValue)
      'allow_package_managers': allowPackageManagers,
    if (_allowedHosts != unsetCopyWithValue) 'allowed_hosts': allowedHosts,
  };

  /// Copies this object with the selected values replaced.
  LimitedEnvironmentNetworkParams copyWith({
    Object? allowMcpServers = unsetCopyWithValue,
    Object? allowPackageManagers = unsetCopyWithValue,
    Object? allowedHosts = unsetCopyWithValue,
  }) => LimitedEnvironmentNetworkParams(
    allowMcpServers: allowMcpServers == unsetCopyWithValue
        ? _allowMcpServers
        : allowMcpServers,
    allowPackageManagers: allowPackageManagers == unsetCopyWithValue
        ? _allowPackageManagers
        : allowPackageManagers,
    allowedHosts: allowedHosts == unsetCopyWithValue
        ? _allowedHosts
        : allowedHosts,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LimitedEnvironmentNetworkParams &&
          (_allowMcpServers == unsetCopyWithValue) ==
              (other._allowMcpServers == unsetCopyWithValue) &&
          allowMcpServers == other.allowMcpServers &&
          (_allowPackageManagers == unsetCopyWithValue) ==
              (other._allowPackageManagers == unsetCopyWithValue) &&
          allowPackageManagers == other.allowPackageManagers &&
          (_allowedHosts == unsetCopyWithValue) ==
              (other._allowedHosts == unsetCopyWithValue) &&
          listsEqual(allowedHosts, other.allowedHosts);

  @override
  int get hashCode => Object.hash(
    _allowMcpServers == unsetCopyWithValue
        ? unsetCopyWithValue
        : allowMcpServers,
    _allowPackageManagers == unsetCopyWithValue
        ? unsetCopyWithValue
        : allowPackageManagers,
    _allowedHosts == unsetCopyWithValue
        ? unsetCopyWithValue
        : listHash(allowedHosts),
  );

  @override
  String toString() =>
      'LimitedEnvironmentNetworkParams(allowMcpServers: $allowMcpServers, allowPackageManagers: $allowPackageManagers, allowedHosts: $allowedHosts)';
}

/// Request for unrestricted cloud environment networking.
@immutable
final class UnrestrictedEnvironmentNetworkParams
    extends EnvironmentNetworkParams {
  /// The wire discriminator.
  @override
  String get type => 'unrestricted';

  /// Creates a [UnrestrictedEnvironmentNetworkParams].
  const UnrestrictedEnvironmentNetworkParams();

  /// Reads a [UnrestrictedEnvironmentNetworkParams] from JSON.
  factory UnrestrictedEnvironmentNetworkParams.fromJson(
    Map<String, dynamic> json,
  ) {
    _validateType(json, 'unrestricted');
    return const UnrestrictedEnvironmentNetworkParams();
  }

  /// Serializes to API JSON.
  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      other is UnrestrictedEnvironmentNetworkParams;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'UnrestrictedEnvironmentNetworkParams(${toJson()})';
}

/// Packages installed by the cloud environment.
@immutable
final class EnvironmentPackages {
  /// The wire discriminator.
  String get type => 'packages';

  /// Ubuntu/Debian packages to install.
  final List<String> apt;

  /// Rust packages to install.
  final List<String> cargo;

  /// Ruby packages to install.
  final List<String> gem;

  /// Go packages to install.
  final List<String> go;

  /// Node.js packages to install.
  final List<String> npm;

  /// Python packages to install.
  final List<String> pip;

  /// Creates a [EnvironmentPackages].
  const EnvironmentPackages({
    required this.apt,
    required this.cargo,
    required this.gem,
    required this.go,
    required this.npm,
    required this.pip,
  });

  /// Reads a [EnvironmentPackages] from JSON.
  factory EnvironmentPackages.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'packages');
    return EnvironmentPackages(
      apt: (json['apt'] as List).cast<String>(),
      cargo: (json['cargo'] as List).cast<String>(),
      gem: (json['gem'] as List).cast<String>(),
      go: (json['go'] as List).cast<String>(),
      npm: (json['npm'] as List).cast<String>(),
      pip: (json['pip'] as List).cast<String>(),
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'apt': apt,
    'cargo': cargo,
    'gem': gem,
    'go': go,
    'npm': npm,
    'pip': pip,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentPackages copyWith({
    List<String>? apt,
    List<String>? cargo,
    List<String>? gem,
    List<String>? go,
    List<String>? npm,
    List<String>? pip,
  }) => EnvironmentPackages(
    apt: apt ?? this.apt,
    cargo: cargo ?? this.cargo,
    gem: gem ?? this.gem,
    go: go ?? this.go,
    npm: npm ?? this.npm,
    pip: pip ?? this.pip,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentPackages &&
          listsEqual(apt, other.apt) &&
          listsEqual(cargo, other.cargo) &&
          listsEqual(gem, other.gem) &&
          listsEqual(go, other.go) &&
          listsEqual(npm, other.npm) &&
          listsEqual(pip, other.pip);

  @override
  int get hashCode => Object.hash(
    listHash(apt),
    listHash(cargo),
    listHash(gem),
    listHash(go),
    listHash(npm),
    listHash(pip),
  );

  @override
  String toString() =>
      'EnvironmentPackages(apt: $apt, cargo: $cargo, gem: $gem, go: $go, npm: $npm, pip: $pip)';
}

/// Packages to install when configuring a cloud environment.
@immutable
final class EnvironmentPackagesParams {
  /// The wire discriminator.
  String get type => 'packages';

  /// Ubuntu/Debian packages to install.
  List<String>? get apt =>
      _apt == unsetCopyWithValue ? null : (_apt as List?)?.cast<String>();
  final Object? _apt;

  /// Rust packages to install.
  List<String>? get cargo =>
      _cargo == unsetCopyWithValue ? null : (_cargo as List?)?.cast<String>();
  final Object? _cargo;

  /// Ruby packages to install.
  List<String>? get gem =>
      _gem == unsetCopyWithValue ? null : (_gem as List?)?.cast<String>();
  final Object? _gem;

  /// Go packages to install.
  List<String>? get go =>
      _go == unsetCopyWithValue ? null : (_go as List?)?.cast<String>();
  final Object? _go;

  /// Node.js packages to install.
  List<String>? get npm =>
      _npm == unsetCopyWithValue ? null : (_npm as List?)?.cast<String>();
  final Object? _npm;

  /// Python packages to install.
  List<String>? get pip =>
      _pip == unsetCopyWithValue ? null : (_pip as List?)?.cast<String>();
  final Object? _pip;

  /// Creates a [EnvironmentPackagesParams].
  ///
  /// Omit an optional field to omit its wire key. Pass null to send JSON null.
  const EnvironmentPackagesParams({
    this._apt = unsetCopyWithValue,
    this._cargo = unsetCopyWithValue,
    this._gem = unsetCopyWithValue,
    this._go = unsetCopyWithValue,
    this._npm = unsetCopyWithValue,
    this._pip = unsetCopyWithValue,
  });

  /// Reads a [EnvironmentPackagesParams] from JSON.
  factory EnvironmentPackagesParams.fromJson(Map<String, dynamic> json) {
    _validateType(json, 'packages');
    return EnvironmentPackagesParams(
      apt: json.containsKey('apt')
          ? (json['apt'] as List?)?.cast<String>()
          : unsetCopyWithValue,
      cargo: json.containsKey('cargo')
          ? (json['cargo'] as List?)?.cast<String>()
          : unsetCopyWithValue,
      gem: json.containsKey('gem')
          ? (json['gem'] as List?)?.cast<String>()
          : unsetCopyWithValue,
      go: json.containsKey('go')
          ? (json['go'] as List?)?.cast<String>()
          : unsetCopyWithValue,
      npm: json.containsKey('npm')
          ? (json['npm'] as List?)?.cast<String>()
          : unsetCopyWithValue,
      pip: json.containsKey('pip')
          ? (json['pip'] as List?)?.cast<String>()
          : unsetCopyWithValue,
    );
  }

  /// Serializes to API JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (_apt != unsetCopyWithValue) 'apt': apt,
    if (_cargo != unsetCopyWithValue) 'cargo': cargo,
    if (_gem != unsetCopyWithValue) 'gem': gem,
    if (_go != unsetCopyWithValue) 'go': go,
    if (_npm != unsetCopyWithValue) 'npm': npm,
    if (_pip != unsetCopyWithValue) 'pip': pip,
  };

  /// Copies this object with the selected values replaced.
  EnvironmentPackagesParams copyWith({
    Object? apt = unsetCopyWithValue,
    Object? cargo = unsetCopyWithValue,
    Object? gem = unsetCopyWithValue,
    Object? go = unsetCopyWithValue,
    Object? npm = unsetCopyWithValue,
    Object? pip = unsetCopyWithValue,
  }) => EnvironmentPackagesParams(
    apt: apt == unsetCopyWithValue ? _apt : apt,
    cargo: cargo == unsetCopyWithValue ? _cargo : cargo,
    gem: gem == unsetCopyWithValue ? _gem : gem,
    go: go == unsetCopyWithValue ? _go : go,
    npm: npm == unsetCopyWithValue ? _npm : npm,
    pip: pip == unsetCopyWithValue ? _pip : pip,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EnvironmentPackagesParams &&
          (_apt == unsetCopyWithValue) == (other._apt == unsetCopyWithValue) &&
          listsEqual(apt, other.apt) &&
          (_cargo == unsetCopyWithValue) ==
              (other._cargo == unsetCopyWithValue) &&
          listsEqual(cargo, other.cargo) &&
          (_gem == unsetCopyWithValue) == (other._gem == unsetCopyWithValue) &&
          listsEqual(gem, other.gem) &&
          (_go == unsetCopyWithValue) == (other._go == unsetCopyWithValue) &&
          listsEqual(go, other.go) &&
          (_npm == unsetCopyWithValue) == (other._npm == unsetCopyWithValue) &&
          listsEqual(npm, other.npm) &&
          (_pip == unsetCopyWithValue) == (other._pip == unsetCopyWithValue) &&
          listsEqual(pip, other.pip);

  @override
  int get hashCode => Object.hash(
    _apt == unsetCopyWithValue ? unsetCopyWithValue : listHash(apt),
    _cargo == unsetCopyWithValue ? unsetCopyWithValue : listHash(cargo),
    _gem == unsetCopyWithValue ? unsetCopyWithValue : listHash(gem),
    _go == unsetCopyWithValue ? unsetCopyWithValue : listHash(go),
    _npm == unsetCopyWithValue ? unsetCopyWithValue : listHash(npm),
    _pip == unsetCopyWithValue ? unsetCopyWithValue : listHash(pip),
  );

  @override
  String toString() =>
      'EnvironmentPackagesParams(apt: $apt, cargo: $cargo, gem: $gem, go: $go, npm: $npm, pip: $pip)';
}

void _validateType(Map<String, dynamic> json, String type) {
  if (json.containsKey('type') && json['type'] != type) {
    throw FormatException('Expected $type, got ${json['type']}');
  }
}
