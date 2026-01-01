import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// Request for text moderation.
@immutable
class ModerationRequest {
  /// The model to use for moderation.
  final String model;

  /// The input text(s) to moderate.
  ///
  /// Can be a single string or a list of strings.
  final List<String> input;

  /// Creates a [ModerationRequest].
  const ModerationRequest({
    this.model = 'mistral-moderation-latest',
    required this.input,
  });

  /// Creates a [ModerationRequest] for a single text input.
  factory ModerationRequest.single({
    String model = 'mistral-moderation-latest',
    required String input,
  }) {
    return ModerationRequest(model: model, input: [input]);
  }

  /// Creates a [ModerationRequest] from JSON.
  factory ModerationRequest.fromJson(Map<String, dynamic> json) {
    final inputValue = json['input'];
    final List<String> inputs;
    if (inputValue is String) {
      inputs = [inputValue];
    } else if (inputValue is List) {
      inputs = inputValue.map((e) => e.toString()).toList();
    } else {
      inputs = [];
    }

    return ModerationRequest(
      model: json['model'] as String? ?? 'mistral-moderation-latest',
      input: inputs,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'model': model, 'input': input};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          listEquals(input, other.input);

  @override
  int get hashCode => Object.hash(model, Object.hashAll(input));

  @override
  String toString() =>
      'ModerationRequest(model: $model, inputs: ${input.length})';
}
