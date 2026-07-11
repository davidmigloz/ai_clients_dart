import 'package:meta/meta.dart';

/// The execution context that produced this tool call.
///
/// See [DirectToolCallCaller] and [ProgramToolCallCaller].
sealed class ToolCallCaller {
  /// Creates a [ToolCallCaller].
  const ToolCallCaller();

  /// Creates a [ToolCallCaller] from JSON.
  factory ToolCallCaller.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'direct' => DirectToolCallCaller.fromJson(json),
      'program' => ProgramToolCallCaller.fromJson(json),
      _ => throw FormatException('Unknown ToolCallCaller type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// The tool call was produced directly by the model.
@immutable
class DirectToolCallCaller extends ToolCallCaller {
  /// The caller type. Always `direct`.
  final String type;

  /// Creates a [DirectToolCallCaller].
  const DirectToolCallCaller({this.type = 'direct'});

  /// Creates a [DirectToolCallCaller] from JSON.
  factory DirectToolCallCaller.fromJson(Map<String, dynamic> json) {
    return DirectToolCallCaller(type: json['type'] as String? ?? 'direct');
  }

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DirectToolCallCaller &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'DirectToolCallCaller(type: $type)';
}

/// The tool call was produced by a program item.
@immutable
class ProgramToolCallCaller extends ToolCallCaller {
  /// The caller type. Always `program`.
  final String type;

  /// The call ID of the program item that produced this tool call.
  final String callerId;

  /// Creates a [ProgramToolCallCaller].
  const ProgramToolCallCaller({this.type = 'program', required this.callerId});

  /// Creates a [ProgramToolCallCaller] from JSON.
  factory ProgramToolCallCaller.fromJson(Map<String, dynamic> json) {
    return ProgramToolCallCaller(
      type: json['type'] as String? ?? 'program',
      callerId: json['caller_id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'caller_id': callerId};

  /// Creates a copy with the given fields replaced.
  ProgramToolCallCaller copyWith({String? type, String? callerId}) =>
      ProgramToolCallCaller(
        type: type ?? this.type,
        callerId: callerId ?? this.callerId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgramToolCallCaller &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          callerId == other.callerId;

  @override
  int get hashCode => Object.hash(type, callerId);

  @override
  String toString() =>
      'ProgramToolCallCaller(type: $type, callerId: $callerId)';
}

/// The tool invocation context(s) a callable tool may be invoked from.
enum CallableToolAllowedCaller {
  /// Unknown caller (fallback for unrecognized values).
  unknown('unknown'),

  /// The tool may be invoked directly by the model.
  direct('direct'),

  /// The tool may be invoked programmatically (e.g. by a program item).
  programmatic('programmatic');

  /// The JSON value for this caller.
  final String value;

  const CallableToolAllowedCaller(this.value);

  /// Creates a [CallableToolAllowedCaller] from a JSON value.
  factory CallableToolAllowedCaller.fromJson(String json) {
    return CallableToolAllowedCaller.values.firstWhere(
      (e) => e.value == json,
      orElse: () => CallableToolAllowedCaller.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
