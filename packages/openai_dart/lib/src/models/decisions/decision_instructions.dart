part of 'decision_question.dart';

/// Text or multimodal instructions for one question, outside shared caching.
///
/// Variants are [TextDecisionInstructions] and [PartsDecisionInstructions].
@immutable
sealed class DecisionInstructions {
  const DecisionInstructions();

  /// Creates text instructions; empty text is permitted.
  const factory DecisionInstructions.text(String text) =
      TextDecisionInstructions;

  /// Creates between 1 and 16,384 text/image/JSON instruction parts.
  factory DecisionInstructions.parts(List<DecisionQuestionPart> parts) =
      PartsDecisionInstructions;

  /// Reads text or a nonempty array of question parts.
  factory DecisionInstructions.fromJson(Object? json) {
    if (json is String) return TextDecisionInstructions(json);
    final parts = parseDecisionObjects(
      json,
      DecisionQuestionPart.fromJson,
      'DecisionInstructions.parts',
    );
    try {
      return PartsDecisionInstructions(parts);
    } on ArgumentError {
      throw const FormatException(
        'DecisionInstructions: expected 1–16384 parts',
      );
    }
  }

  /// Converts to the API string or part array.
  Object toJson();
}

/// String instructions for a predicate, choice, or score question.
@immutable
class TextDecisionInstructions extends DecisionInstructions {
  /// Creates text instructions.
  const TextDecisionInstructions(this.text);

  /// The criteria to evaluate.
  final String text;

  @override
  String toJson() => text;

  /// Copies the text criteria.
  TextDecisionInstructions copyWith({String? text}) =>
      TextDecisionInstructions(text ?? this.text);

  @override
  bool operator ==(Object other) =>
      other is TextDecisionInstructions &&
      runtimeType == other.runtimeType &&
      text == other.text;

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() => 'TextDecisionInstructions(text: ${text.length} chars)';
}

/// An immutable nonempty list of question-specific evidence parts.
@immutable
class PartsDecisionInstructions extends DecisionInstructions {
  /// Copies and validates the part count.
  PartsDecisionInstructions(List<DecisionQuestionPart> parts)
    : parts = List.unmodifiable(parts) {
    if (parts.isEmpty || parts.length > 16384) {
      throw ArgumentError('DecisionInstructions: expected 1–16384 parts');
    }
  }

  /// The ordered instruction parts.
  final List<DecisionQuestionPart> parts;

  @override
  List<Map<String, dynamic>> toJson() =>
      parts.map((part) => part.toJson()).toList();

  /// Copies with replacement parts.
  PartsDecisionInstructions copyWith({List<DecisionQuestionPart>? parts}) =>
      PartsDecisionInstructions(parts ?? this.parts);

  @override
  bool operator ==(Object other) =>
      other is PartsDecisionInstructions &&
      runtimeType == other.runtimeType &&
      listsEqual(parts, other.parts);

  @override
  int get hashCode => Object.hash(runtimeType, listHash(parts));

  @override
  String toString() =>
      'PartsDecisionInstructions(parts: ${parts.length} items)';
}

/// A question part, which cannot carry a shared-input cache breakpoint.
///
/// Variants are [TextDecisionQuestionPart], [ImageDecisionQuestionPart], and
/// [JsonDecisionQuestionPart].
@immutable
sealed class DecisionQuestionPart {
  const DecisionQuestionPart();

  /// Creates text criteria.
  const factory DecisionQuestionPart.text(String text) =
      TextDecisionQuestionPart;

  /// Creates question-specific image evidence.
  factory DecisionQuestionPart.image({
    required String imageUrl,
    ImageDetail? detail,
  }) = ImageDecisionQuestionPart;

  /// Creates finite JSON evidence with the same bounds as shared JSON input.
  factory DecisionQuestionPart.json(Object data) = JsonDecisionQuestionPart;

  /// Reads a part, rejecting cache markers and other unsupported fields.
  factory DecisionQuestionPart.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'input_text' => TextDecisionQuestionPart.fromJson(json),
        'input_image' => ImageDecisionQuestionPart.fromJson(json),
        'input_json' => JsonDecisionQuestionPart.fromJson(json),
        _ => throw const FormatException(
          'DecisionQuestionPart: expected text, image, or JSON',
        ),
      };

  /// The part discriminator.
  String get type;

  /// Converts to the question-part JSON shape.
  Map<String, dynamic> toJson();
}

/// Text criteria in a question's instruction array.
@immutable
class TextDecisionQuestionPart extends DecisionQuestionPart {
  /// Creates text criteria.
  const TextDecisionQuestionPart(this.text);

  /// The criteria text.
  final String text;

  @override
  String get type => 'input_text';

  /// Reads a closed text part without input cache controls.
  factory TextDecisionQuestionPart.fromJson(Map<String, dynamic> json) {
    requireDecisionType(json, 'input_text', 'TextDecisionQuestionPart');
    requireDecisionKeys(json, {'type', 'text'}, 'TextDecisionQuestionPart');
    return TextDecisionQuestionPart(
      requireDecisionString(json['text'], 'TextDecisionQuestionPart.text'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'text': text};

  /// Copies the text criteria.
  TextDecisionQuestionPart copyWith({String? text}) =>
      TextDecisionQuestionPart(text ?? this.text);

  @override
  bool operator ==(Object other) =>
      other is TextDecisionQuestionPart &&
      runtimeType == other.runtimeType &&
      text == other.text;

  @override
  int get hashCode => Object.hash(runtimeType, text);

  @override
  String toString() => 'TextDecisionQuestionPart(text: ${text.length} chars)';
}

/// An image specific to a question, without cache controls.
@immutable
class ImageDecisionQuestionPart extends DecisionQuestionPart {
  /// Creates a data URL or public HTTP(S) image.
  ImageDecisionQuestionPart({required String imageUrl, ImageDetail? detail})
    : _image = ImageDecisionInputPart(imageUrl: imageUrl, detail: detail);

  final ImageDecisionInputPart _image;

  /// The literal, unnormalized image URL.
  String get imageUrl => _image.imageUrl;

  /// Optional image detail; omission uses the server default.
  ImageDetail? get detail => _image.detail;

  @override
  String get type => 'input_image';

  /// Reads a closed image part, rejecting input cache controls and file IDs.
  factory ImageDecisionQuestionPart.fromJson(Map<String, dynamic> json) {
    requireDecisionKeys(json, {
      'type',
      'image_url',
      'detail',
    }, 'ImageDecisionQuestionPart');
    final image = ImageDecisionInputPart.fromJson(json);
    return ImageDecisionQuestionPart(
      imageUrl: image.imageUrl,
      detail: image.detail,
    );
  }

  @override
  Map<String, dynamic> toJson() => _image.toJson();

  /// Copies the image; explicit null clears detail.
  ImageDecisionQuestionPart copyWith({
    String? imageUrl,
    Object? detail = unsetCopyWithValue,
  }) => ImageDecisionQuestionPart(
    imageUrl: imageUrl ?? this.imageUrl,
    detail: identical(detail, unsetCopyWithValue)
        ? this.detail
        : detail as ImageDetail?,
  );

  @override
  bool operator ==(Object other) =>
      other is ImageDecisionQuestionPart &&
      runtimeType == other.runtimeType &&
      _image == other._image;

  @override
  int get hashCode => _image.hashCode;

  @override
  String toString() =>
      'ImageDecisionQuestionPart(imageUrl: [${imageUrl.length} chars], detail: $detail)';
}

/// Finite structured evidence specific to one question.
@immutable
class JsonDecisionQuestionPart extends DecisionQuestionPart {
  /// Creates validated JSON evidence and snapshots its data.
  JsonDecisionQuestionPart(Object data) : _json = JsonDecisionInputPart(data);

  final JsonDecisionInputPart _json;

  /// The immutable object or object array.
  Object get data => _json.data;

  @override
  String get type => 'input_json';

  /// Reads the shared closed JSON-part shape without cache controls.
  factory JsonDecisionQuestionPart.fromJson(Map<String, dynamic> json) {
    final part = JsonDecisionInputPart.fromJson(json);
    return JsonDecisionQuestionPart(part.data);
  }

  @override
  Map<String, dynamic> toJson() => _json.toJson();

  /// Copies and snapshots replacement evidence.
  JsonDecisionQuestionPart copyWith({Object? data}) =>
      JsonDecisionQuestionPart(data ?? this.data);

  @override
  bool operator ==(Object other) =>
      other is JsonDecisionQuestionPart &&
      runtimeType == other.runtimeType &&
      _json == other._json;

  @override
  int get hashCode => _json.hashCode;

  @override
  String toString() => 'JsonDecisionQuestionPart(data: [structured evidence])';
}
