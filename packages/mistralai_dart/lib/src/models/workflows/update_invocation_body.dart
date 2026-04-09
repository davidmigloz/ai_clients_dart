import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Body for sending a workflow update.
@immutable
class UpdateInvocationBody {
  /// The update name.
  final String name;

  /// The update input.
  final Object? input;

  /// Creates a [UpdateInvocationBody].
  const UpdateInvocationBody({required this.name, this.input});

  /// Creates a [UpdateInvocationBody] from JSON.
  factory UpdateInvocationBody.fromJson(Map<String, dynamic> json) =>
      UpdateInvocationBody(
        name: json['name'] as String? ?? '',
        input: json['input'],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (input != null) 'input': input,
  };

  /// Creates a copy with replaced values.
  UpdateInvocationBody copyWith({
    String? name,
    Object? input = unsetCopyWithValue,
  }) {
    return UpdateInvocationBody(
      name: name ?? this.name,
      input: input == unsetCopyWithValue ? this.input : input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateInvocationBody) return false;
    if (runtimeType != other.runtimeType) return false;
    return name == other.name && valuesDeepEqual(input, other.input);
  }

  @override
  int get hashCode => Object.hash(name, valueDeepHashCode(input));

  @override
  String toString() => 'UpdateInvocationBody(name: $name, input: $input)';
}
