import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../tools/connector_auth.dart';
import '../tools/tool_configuration.dart';

/// A tool available to a voice agent.
///
/// [VoiceAgentWebSearchTool], [VoiceAgentDocumentLibraryTool], [VoiceAgentCustomConnector], [VoiceAgentFunctionTool], [TransferCallTool], [HangUpTool], or [UnknownVoiceAgentTool].
@immutable
sealed class VoiceAgentTool {
  const VoiceAgentTool();

  /// Parses an API payload.
  factory VoiceAgentTool.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'web_search' => VoiceAgentWebSearchTool.fromJson(json),
        'document_library' => VoiceAgentDocumentLibraryTool.fromJson(json),
        'connector' => VoiceAgentCustomConnector.fromJson(json),
        'function' => VoiceAgentFunctionTool.fromJson(json),
        'transfer_call' => TransferCallTool.fromJson(json),
        'hang_up' => HangUpTool.fromJson(json),
        _ => UnknownVoiceAgentTool(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();

  /// The wire type.
  String get type;
}

/// A future VoiceAgentTool value.
@immutable
final class UnknownVoiceAgentTool extends VoiceAgentTool {
  /// Creates a fallback from the original payload.
  UnknownVoiceAgentTool(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String get type => switch (raw['type']) {
    final String value => value,
    _ => 'unknown',
  };

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownVoiceAgentTool && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A response spoken while a tool runs.
///
/// [StaticToolFiller], [GeneratedToolFiller], or [UnknownToolFiller].
@immutable
sealed class ToolFiller {
  const ToolFiller();

  /// Parses an API payload.
  factory ToolFiller.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'static' => StaticToolFiller.fromJson(json),
        'generated' => GeneratedToolFiller.fromJson(json),
        _ => UnknownToolFiller(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();

  /// The wire type.
  String get type;
}

/// A future ToolFiller value.
@immutable
final class UnknownToolFiller extends ToolFiller {
  /// Creates a fallback from the original payload.
  UnknownToolFiller(Map<String, dynamic> json) : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String get type => switch (raw['type']) {
    final String value => value,
    _ => 'unknown',
  };

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownToolFiller && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A phone number or SIP address for transferring a call.
///
/// [PhoneDestination], [SipDestination], or [UnknownTransferDestination].
@immutable
sealed class TransferDestination {
  const TransferDestination();

  /// Parses an API payload.
  factory TransferDestination.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'phone' => PhoneDestination.fromJson(json),
        'sip' => SipDestination.fromJson(json),
        _ => UnknownTransferDestination(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();

  /// The wire type.
  String get type;
}

/// A future TransferDestination value.
@immutable
final class UnknownTransferDestination extends TransferDestination {
  /// Creates a fallback from the original payload.
  UnknownTransferDestination(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  String get type => switch (raw['type']) {
    final String value => value,
    _ => 'unknown',
  };

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownTransferDestination && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The VoiceAgentWebSearchTool wire payload.
@immutable
class VoiceAgentWebSearchTool extends VoiceAgentTool {
  /// Creates a [VoiceAgentWebSearchTool].
  const VoiceAgentWebSearchTool({this.filler, this.toolConfiguration});

  @override
  String get type => 'web_search';

  /// The filler field.
  final ToolFiller? filler;

  /// The tool_configuration field.
  final ToolConfiguration? toolConfiguration;

  /// Parses a [VoiceAgentWebSearchTool] from JSON.
  factory VoiceAgentWebSearchTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'web_search') {
      throw FormatException('VoiceAgentWebSearchTool: unexpected type $value');
    }
    return VoiceAgentWebSearchTool(
      filler: json['filler'] == null
          ? null
          : ToolFiller.fromJson(json['filler'] as Map<String, dynamic>),
      toolConfiguration: json['tool_configuration'] == null
          ? null
          : ToolConfiguration.fromJson(
              json['tool_configuration'] as Map<String, dynamic>,
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (filler != null) 'filler': filler!.toJson(),
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentWebSearchTool copyWith({
    Object? filler = unsetCopyWithValue,
    Object? toolConfiguration = unsetCopyWithValue,
  }) => VoiceAgentWebSearchTool(
    filler: filler == unsetCopyWithValue ? this.filler : filler as ToolFiller?,
    toolConfiguration: toolConfiguration == unsetCopyWithValue
        ? this.toolConfiguration
        : toolConfiguration as ToolConfiguration?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentWebSearchTool &&
          runtimeType == other.runtimeType &&
          filler == other.filler &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hashAll([filler, toolConfiguration]);

  @override
  String toString() =>
      'VoiceAgentWebSearchTool('
      'filler: $filler, '
      'toolConfiguration: $toolConfiguration)';
}

/// The VoiceAgentDocumentLibraryTool wire payload.
@immutable
class VoiceAgentDocumentLibraryTool extends VoiceAgentTool {
  /// Creates a [VoiceAgentDocumentLibraryTool].
  const VoiceAgentDocumentLibraryTool({
    this.filler,
    required this.libraryIds,
    this.toolConfiguration,
  });

  @override
  String get type => 'document_library';

  /// The filler field.
  final ToolFiller? filler;

  /// Ids of the library in which to search.
  final List<String> libraryIds;

  /// The tool_configuration field.
  final ToolConfiguration? toolConfiguration;

  /// Parses a [VoiceAgentDocumentLibraryTool] from JSON.
  factory VoiceAgentDocumentLibraryTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'document_library') {
      throw FormatException(
        'VoiceAgentDocumentLibraryTool: unexpected type $value',
      );
    }
    if (json['library_ids'] == null) {
      throw const FormatException(
        'VoiceAgentDocumentLibraryTool: missing library_ids',
      );
    }
    return VoiceAgentDocumentLibraryTool(
      filler: json['filler'] == null
          ? null
          : ToolFiller.fromJson(json['filler'] as Map<String, dynamic>),
      libraryIds: (json['library_ids'] as List)
          .map((item) => item as String)
          .toList(),
      toolConfiguration: json['tool_configuration'] == null
          ? null
          : ToolConfiguration.fromJson(
              json['tool_configuration'] as Map<String, dynamic>,
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (filler != null) 'filler': filler!.toJson(),
    'library_ids': libraryIds,
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentDocumentLibraryTool copyWith({
    Object? filler = unsetCopyWithValue,
    List<String>? libraryIds,
    Object? toolConfiguration = unsetCopyWithValue,
  }) => VoiceAgentDocumentLibraryTool(
    filler: filler == unsetCopyWithValue ? this.filler : filler as ToolFiller?,
    libraryIds: libraryIds ?? this.libraryIds,
    toolConfiguration: toolConfiguration == unsetCopyWithValue
        ? this.toolConfiguration
        : toolConfiguration as ToolConfiguration?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentDocumentLibraryTool &&
          runtimeType == other.runtimeType &&
          filler == other.filler &&
          valuesDeepEqual(libraryIds, other.libraryIds) &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode => Object.hashAll([
    filler,
    valueDeepHashCode(libraryIds),
    toolConfiguration,
  ]);

  @override
  String toString() =>
      'VoiceAgentDocumentLibraryTool('
      'filler: $filler, '
      'libraryIds: ${libraryIds.length}, '
      'toolConfiguration: $toolConfiguration)';
}

/// The VoiceAgentCustomConnector wire payload.
@immutable
class VoiceAgentCustomConnector extends VoiceAgentTool {
  /// Creates a [VoiceAgentCustomConnector].
  const VoiceAgentCustomConnector({
    this.authorization,
    required this.connectorId,
    this.filler,
    this.toolConfiguration,
  });

  @override
  String get type => 'connector';

  /// Deprecated: per-request connector credentials will be removed. Authenticate the connector through the Connectors API instead.
  final ConnectorAuth? authorization;

  /// The connector_id field.
  final String connectorId;

  /// The filler field.
  final ToolFiller? filler;

  /// The tool_configuration field.
  final ToolConfiguration? toolConfiguration;

  /// Parses a [VoiceAgentCustomConnector] from JSON.
  factory VoiceAgentCustomConnector.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'connector') {
      throw FormatException(
        'VoiceAgentCustomConnector: unexpected type $value',
      );
    }
    if (json['connector_id'] == null) {
      throw const FormatException(
        'VoiceAgentCustomConnector: missing connector_id',
      );
    }
    return VoiceAgentCustomConnector(
      authorization: json['authorization'] == null
          ? null
          : ConnectorAuth.fromJson(
              json['authorization'] as Map<String, dynamic>,
            ),
      connectorId: json['connector_id'] as String,
      filler: json['filler'] == null
          ? null
          : ToolFiller.fromJson(json['filler'] as Map<String, dynamic>),
      toolConfiguration: json['tool_configuration'] == null
          ? null
          : ToolConfiguration.fromJson(
              json['tool_configuration'] as Map<String, dynamic>,
            ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (authorization != null) 'authorization': authorization!.toJson(),
    'connector_id': connectorId,
    if (filler != null) 'filler': filler!.toJson(),
    if (toolConfiguration != null)
      'tool_configuration': toolConfiguration!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentCustomConnector copyWith({
    Object? authorization = unsetCopyWithValue,
    String? connectorId,
    Object? filler = unsetCopyWithValue,
    Object? toolConfiguration = unsetCopyWithValue,
  }) => VoiceAgentCustomConnector(
    authorization: authorization == unsetCopyWithValue
        ? this.authorization
        : authorization as ConnectorAuth?,
    connectorId: connectorId ?? this.connectorId,
    filler: filler == unsetCopyWithValue ? this.filler : filler as ToolFiller?,
    toolConfiguration: toolConfiguration == unsetCopyWithValue
        ? this.toolConfiguration
        : toolConfiguration as ToolConfiguration?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentCustomConnector &&
          runtimeType == other.runtimeType &&
          authorization == other.authorization &&
          connectorId == other.connectorId &&
          filler == other.filler &&
          toolConfiguration == other.toolConfiguration;

  @override
  int get hashCode =>
      Object.hashAll([authorization, connectorId, filler, toolConfiguration]);

  @override
  String toString() =>
      'VoiceAgentCustomConnector('
      'authorization: $authorization, '
      'connectorId: $connectorId, '
      'filler: $filler, '
      'toolConfiguration: $toolConfiguration)';
}

/// The VoiceAgentFunctionTool wire payload.
@immutable
class VoiceAgentFunctionTool extends VoiceAgentTool {
  /// Creates a [VoiceAgentFunctionTool].
  const VoiceAgentFunctionTool({
    this.filler,
    required this.function,
    this.timeoutMs,
  });

  @override
  String get type => 'function';

  /// The filler field.
  final ToolFiller? filler;

  /// The function field.
  final VoiceAgentFunction function;

  /// The timeout_ms field.
  final int? timeoutMs;

  /// Parses a [VoiceAgentFunctionTool] from JSON.
  factory VoiceAgentFunctionTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'function') {
      throw FormatException('VoiceAgentFunctionTool: unexpected type $value');
    }
    if (json['function'] == null) {
      throw const FormatException('VoiceAgentFunctionTool: missing function');
    }
    return VoiceAgentFunctionTool(
      filler: json['filler'] == null
          ? null
          : ToolFiller.fromJson(json['filler'] as Map<String, dynamic>),
      function: VoiceAgentFunction.fromJson(
        json['function'] as Map<String, dynamic>,
      ),
      timeoutMs: json['timeout_ms'] == null ? null : json['timeout_ms'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (filler != null) 'filler': filler!.toJson(),
    'function': function.toJson(),
    'timeout_ms': ?timeoutMs,
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentFunctionTool copyWith({
    Object? filler = unsetCopyWithValue,
    VoiceAgentFunction? function,
    Object? timeoutMs = unsetCopyWithValue,
  }) => VoiceAgentFunctionTool(
    filler: filler == unsetCopyWithValue ? this.filler : filler as ToolFiller?,
    function: function ?? this.function,
    timeoutMs: timeoutMs == unsetCopyWithValue
        ? this.timeoutMs
        : timeoutMs as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentFunctionTool &&
          runtimeType == other.runtimeType &&
          filler == other.filler &&
          function == other.function &&
          timeoutMs == other.timeoutMs;

  @override
  int get hashCode => Object.hashAll([filler, function, timeoutMs]);

  @override
  String toString() =>
      'VoiceAgentFunctionTool('
      'filler: $filler, '
      'function: $function, '
      'timeoutMs: $timeoutMs)';
}

/// The TransferCallTool wire payload.
@immutable
class TransferCallTool extends VoiceAgentTool {
  /// Creates a [TransferCallTool].
  const TransferCallTool({required this.destinations, this.filler});

  @override
  String get type => 'transfer_call';

  /// The destinations field.
  final List<TransferTarget> destinations;

  /// The filler field.
  final ToolFiller? filler;

  /// Parses a [TransferCallTool] from JSON.
  factory TransferCallTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'transfer_call') {
      throw FormatException('TransferCallTool: unexpected type $value');
    }
    if (json['destinations'] == null) {
      throw const FormatException('TransferCallTool: missing destinations');
    }
    return TransferCallTool(
      destinations: (json['destinations'] as List)
          .map((item) => TransferTarget.fromJson(item as Map<String, dynamic>))
          .toList(),
      filler: json['filler'] == null
          ? null
          : ToolFiller.fromJson(json['filler'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'destinations': destinations.map((item) => item.toJson()).toList(),
    if (filler != null) 'filler': filler!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  TransferCallTool copyWith({
    List<TransferTarget>? destinations,
    Object? filler = unsetCopyWithValue,
  }) => TransferCallTool(
    destinations: destinations ?? this.destinations,
    filler: filler == unsetCopyWithValue ? this.filler : filler as ToolFiller?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferCallTool &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(destinations, other.destinations) &&
          filler == other.filler;

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(destinations), filler]);

  @override
  String toString() =>
      'TransferCallTool('
      'destinations: ${destinations.length}, '
      'filler: $filler)';
}

/// The HangUpTool wire payload.
@immutable
class HangUpTool extends VoiceAgentTool {
  /// Creates a [HangUpTool].
  const HangUpTool({this.filler});

  @override
  String get type => 'hang_up';

  /// The filler field.
  final ToolFiller? filler;

  /// Parses a [HangUpTool] from JSON.
  factory HangUpTool.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'hang_up') {
      throw FormatException('HangUpTool: unexpected type $value');
    }
    return HangUpTool(
      filler: json['filler'] == null
          ? null
          : ToolFiller.fromJson(json['filler'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (filler != null) 'filler': filler!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  HangUpTool copyWith({Object? filler = unsetCopyWithValue}) => HangUpTool(
    filler: filler == unsetCopyWithValue ? this.filler : filler as ToolFiller?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HangUpTool &&
          runtimeType == other.runtimeType &&
          filler == other.filler;

  @override
  int get hashCode => Object.hashAll([filler]);

  @override
  String toString() =>
      'HangUpTool('
      'filler: $filler)';
}

/// The StaticToolFiller wire payload.
@immutable
class StaticToolFiller extends ToolFiller {
  /// Creates a [StaticToolFiller].
  const StaticToolFiller({required this.text});

  @override
  String get type => 'static';

  /// The text field.
  final String text;

  /// Parses a [StaticToolFiller] from JSON.
  factory StaticToolFiller.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'static') {
      throw FormatException('StaticToolFiller: unexpected type $value');
    }
    if (json['text'] == null) {
      throw const FormatException('StaticToolFiller: missing text');
    }
    return StaticToolFiller(text: json['text'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Creates a copy with the given fields replaced.
  StaticToolFiller copyWith({String? text}) =>
      StaticToolFiller(text: text ?? this.text);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaticToolFiller &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => Object.hashAll([text]);

  @override
  String toString() =>
      'StaticToolFiller('
      'text: $text)';
}

/// A filler the model writes for each call, in the user's language. `instructions` guide what it says. `fallback` is spoken when it writes none; without one, the call is silent.
@immutable
class GeneratedToolFiller extends ToolFiller {
  /// Creates a [GeneratedToolFiller].
  const GeneratedToolFiller({this.fallback, this.instructions});

  @override
  String get type => 'generated';

  /// The fallback field.
  final StaticToolFiller? fallback;

  /// The instructions field.
  final String? instructions;

  /// Parses a [GeneratedToolFiller] from JSON.
  factory GeneratedToolFiller.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'generated') {
      throw FormatException('GeneratedToolFiller: unexpected type $value');
    }
    return GeneratedToolFiller(
      fallback: json['fallback'] == null
          ? null
          : StaticToolFiller.fromJson(json['fallback'] as Map<String, dynamic>),
      instructions: json['instructions'] == null
          ? null
          : json['instructions'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (fallback != null) 'fallback': fallback!.toJson(),
    'instructions': ?instructions,
  };

  /// Creates a copy with the given fields replaced.
  GeneratedToolFiller copyWith({
    Object? fallback = unsetCopyWithValue,
    Object? instructions = unsetCopyWithValue,
  }) => GeneratedToolFiller(
    fallback: fallback == unsetCopyWithValue
        ? this.fallback
        : fallback as StaticToolFiller?,
    instructions: instructions == unsetCopyWithValue
        ? this.instructions
        : instructions as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneratedToolFiller &&
          runtimeType == other.runtimeType &&
          fallback == other.fallback &&
          instructions == other.instructions;

  @override
  int get hashCode => Object.hashAll([fallback, instructions]);

  @override
  String toString() =>
      'GeneratedToolFiller('
      'fallback: $fallback, '
      'instructions: $instructions)';
}

/// The PhoneDestination wire payload.
@immutable
class PhoneDestination extends TransferDestination {
  /// Creates a [PhoneDestination].
  const PhoneDestination({required this.number});

  @override
  String get type => 'phone';

  /// The number field.
  final String number;

  /// Parses a [PhoneDestination] from JSON.
  factory PhoneDestination.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'phone') {
      throw FormatException('PhoneDestination: unexpected type $value');
    }
    if (json['number'] == null) {
      throw const FormatException('PhoneDestination: missing number');
    }
    return PhoneDestination(number: json['number'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'number': number};

  /// Creates a copy with the given fields replaced.
  PhoneDestination copyWith({String? number}) =>
      PhoneDestination(number: number ?? this.number);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneDestination &&
          runtimeType == other.runtimeType &&
          number == other.number;

  @override
  int get hashCode => Object.hashAll([number]);

  @override
  String toString() =>
      'PhoneDestination('
      'number: $number)';
}

/// The SipDestination wire payload.
@immutable
class SipDestination extends TransferDestination {
  /// Creates a [SipDestination].
  const SipDestination({required this.uri});

  @override
  String get type => 'sip';

  /// The uri field.
  final String uri;

  /// Parses a [SipDestination] from JSON.
  factory SipDestination.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'sip') {
      throw FormatException('SipDestination: unexpected type $value');
    }
    if (json['uri'] == null) {
      throw const FormatException('SipDestination: missing uri');
    }
    return SipDestination(uri: json['uri'] as String);
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'uri': uri};

  /// Creates a copy with the given fields replaced.
  SipDestination copyWith({String? uri}) =>
      SipDestination(uri: uri ?? this.uri);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SipDestination &&
          runtimeType == other.runtimeType &&
          uri == other.uri;

  @override
  int get hashCode => Object.hashAll([uri]);

  @override
  String toString() =>
      'SipDestination('
      'uri: $uri)';
}

/// One allowed hand-off, chosen by the model through `id` alone. The address never reaches the model: it only sees `id` and `condition`, so it cannot dial a near-miss of a real number.
@immutable
class TransferTarget {
  /// Creates a [TransferTarget].
  const TransferTarget({
    required this.condition,
    required this.destination,
    required this.id,
  });

  /// The condition field.
  final String condition;

  /// The destination field.
  final TransferDestination destination;

  /// The id field.
  final String id;

  /// Parses a [TransferTarget] from JSON.
  factory TransferTarget.fromJson(Map<String, dynamic> json) {
    if (json['condition'] == null) {
      throw const FormatException('TransferTarget: missing condition');
    }
    if (json['destination'] == null) {
      throw const FormatException('TransferTarget: missing destination');
    }
    if (json['id'] == null) {
      throw const FormatException('TransferTarget: missing id');
    }
    return TransferTarget(
      condition: json['condition'] as String,
      destination: TransferDestination.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      id: json['id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'condition': condition,
    'destination': destination.toJson(),
    'id': id,
  };

  /// Creates a copy with the given fields replaced.
  TransferTarget copyWith({
    String? condition,
    TransferDestination? destination,
    String? id,
  }) => TransferTarget(
    condition: condition ?? this.condition,
    destination: destination ?? this.destination,
    id: id ?? this.id,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferTarget &&
          runtimeType == other.runtimeType &&
          condition == other.condition &&
          destination == other.destination &&
          id == other.id;

  @override
  int get hashCode => Object.hashAll([condition, destination, id]);

  @override
  String toString() =>
      'TransferTarget('
      'condition: $condition, '
      'destination: $destination, '
      'id: $id)';
}

/// The Function wire payload.
@immutable
class VoiceAgentFunction {
  /// Creates a [VoiceAgentFunction].
  const VoiceAgentFunction({
    this.description,
    required this.name,
    required this.parameters,
    this.strict,
  });

  /// The description field.
  final String? description;

  /// The name field.
  final String name;

  /// The parameters field.
  final Map<String, dynamic> parameters;

  /// The strict field.
  final bool? strict;

  /// Parses a [VoiceAgentFunction] from JSON.
  factory VoiceAgentFunction.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('VoiceAgentFunction: missing name');
    }
    if (json['parameters'] == null) {
      throw const FormatException('VoiceAgentFunction: missing parameters');
    }
    return VoiceAgentFunction(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      name: json['name'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
      strict: json['strict'] == null ? null : json['strict'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': ?description,
    'name': name,
    'parameters': parameters,
    'strict': ?strict,
  };

  /// Creates a copy with the given fields replaced.
  VoiceAgentFunction copyWith({
    Object? description = unsetCopyWithValue,
    String? name,
    Map<String, dynamic>? parameters,
    Object? strict = unsetCopyWithValue,
  }) => VoiceAgentFunction(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    name: name ?? this.name,
    parameters: parameters ?? this.parameters,
    strict: strict == unsetCopyWithValue ? this.strict : strict as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceAgentFunction &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          name == other.name &&
          valuesDeepEqual(parameters, other.parameters) &&
          strict == other.strict;

  @override
  int get hashCode => Object.hashAll([
    description,
    name,
    valueDeepHashCode(parameters),
    strict,
  ]);

  @override
  String toString() =>
      'VoiceAgentFunction('
      'description: $description, '
      'name: $name, '
      'parameters: ${parameters.length}, '
      'strict: $strict)';
}
