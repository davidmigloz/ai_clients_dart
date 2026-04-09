import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Definition of a workflow signal.
@immutable
class SignalDefinition {
  /// The signal name.
  final String name;

  /// The input JSON schema.
  final Map<String, dynamic> inputSchema;

  /// Description of the signal.
  final String? description;

  /// Creates a [SignalDefinition].
  const SignalDefinition({
    required this.name,
    required this.inputSchema,
    this.description,
  });

  /// Creates a [SignalDefinition] from JSON.
  factory SignalDefinition.fromJson(Map<String, dynamic> json) =>
      SignalDefinition(
        name: json['name'] as String? ?? '',
        inputSchema: json['input_schema'] as Map<String, dynamic>? ?? {},
        description: json['description'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'input_schema': inputSchema,
    if (description != null) 'description': description,
  };

  /// Creates a copy with replaced values.
  SignalDefinition copyWith({
    String? name,
    Map<String, dynamic>? inputSchema,
    Object? description = unsetCopyWithValue,
  }) {
    return SignalDefinition(
      name: name ?? this.name,
      inputSchema: inputSchema ?? this.inputSchema,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SignalDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(inputSchema, other.inputSchema)) return false;
    return name == other.name && description == other.description;
  }

  @override
  int get hashCode =>
      Object.hash(name, mapDeepHashCode(inputSchema), description);

  @override
  String toString() =>
      'SignalDefinition(name: $name, inputSchema: ${inputSchema.length}, description: $description)';
}
