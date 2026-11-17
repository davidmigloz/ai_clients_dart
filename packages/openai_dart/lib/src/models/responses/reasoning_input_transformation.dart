import 'package:meta/meta.dart';

/// Why a supplied reasoning item was withheld.
@immutable
final class InputRemovalReason {
  /// The item belonged to a different organization.
  static const organizationMismatch = InputRemovalReason(
    'organization_mismatch',
  );

  /// The item belonged to a different end user.
  static const endUserMismatch = InputRemovalReason('end_user_mismatch');

  /// The item used a different model.
  static const modelMismatch = InputRemovalReason('model_mismatch');

  /// The item did not match this request's prefix.
  static const prefixMismatch = InputRemovalReason('prefix_mismatch');

  /// The item fell outside the current turn.
  static const turnBoundary = InputRemovalReason('turn_boundary');

  /// The reason as reported by the API.
  final String value;

  /// Creates a reason and preserves provider-specific values.
  const InputRemovalReason(this.value);

  /// Parses the wire value.
  factory InputRemovalReason.fromJson(String value) =>
      InputRemovalReason(value);

  /// Returns the wire value.
  String toJson() => value;

  @override
  bool operator ==(Object other) =>
      other is InputRemovalReason && value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'InputRemovalReason($value)';
}

/// Records a reasoning input item that the server withheld from the model.
@immutable
final class ReasoningInputTransformation {
  /// The original reasoning item identifier.
  final String id;

  /// Why the server removed this input.
  final InputRemovalReason reason;

  /// Creates a removal record for a reasoning item.
  const ReasoningInputTransformation({required this.id, required this.reason});

  /// The wire type of the transformed item.
  String get type => 'reasoning';

  /// The action taken by the server.
  String get action => 'removed';

  /// Parses a reasoning removal record.
  factory ReasoningInputTransformation.fromJson(Map<String, dynamic> json) {
    if (json['type'] != 'reasoning' || json['action'] != 'removed') {
      throw const FormatException(
        'Expected a removed reasoning input transformation',
      );
    }
    return ReasoningInputTransformation(
      id: json['id'] as String,
      reason: InputRemovalReason.fromJson(json['reason'] as String),
    );
  }

  /// Returns the wire record.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'action': action,
    'reason': reason.toJson(),
  };

  /// Copies this record with replacement values.
  ReasoningInputTransformation copyWith({
    String? id,
    InputRemovalReason? reason,
  }) => ReasoningInputTransformation(
    id: id ?? this.id,
    reason: reason ?? this.reason,
  );

  @override
  bool operator ==(Object other) =>
      other is ReasoningInputTransformation &&
      id == other.id &&
      reason == other.reason;

  @override
  int get hashCode => Object.hash(id, reason);

  @override
  String toString() => 'ReasoningInputTransformation(reason: $reason)';
}
