import 'package:meta/meta.dart';

/// A request to check content for harmful material.
///
/// The moderation API classifies content into categories like hate speech,
/// self-harm, violence, and more. Use `omni-moderation-latest` for
/// multi-modal input (text and images).
///
/// ## Example
///
/// ```dart
/// final request = ModerationRequest(
///   input: ModerationInput.text('Some text to check'),
///   model: 'text-moderation-latest',
/// );
///
/// final response = await client.moderations.create(request);
/// if (response.results.first.flagged) {
///   print('Content was flagged!');
/// }
/// ```
@immutable
class ModerationRequest {
  /// Creates a [ModerationRequest].
  const ModerationRequest({required this.input, this.model});

  /// Creates a [ModerationRequest] from JSON.
  factory ModerationRequest.fromJson(Map<String, dynamic> json) {
    return ModerationRequest(
      input: ModerationInput.fromJson(json['input']),
      model: json['model'] as String?,
    );
  }

  /// The input to moderate.
  ///
  /// Can be a single string, a list of strings, or a list of multi-modal
  /// input objects (for use with omni-moderation models).
  final ModerationInput input;

  /// The moderation model to use.
  ///
  /// If omitted, the server will use its current default moderation model
  /// (see the API documentation for details). Use `text-moderation-stable`
  /// for consistent behavior across model updates, or
  /// `omni-moderation-latest` for multi-modal (text + image) moderation.
  final String? model;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input': input.toJson(),
    if (model != null) 'model': model,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationRequest &&
          runtimeType == other.runtimeType &&
          input == other.input &&
          model == other.model;

  @override
  int get hashCode => Object.hash(input, model);

  @override
  String toString() => 'ModerationRequest(model: $model)';
}

/// Input for moderation.
///
/// Supports three formats:
/// - [ModerationInputText]: A single text string.
/// - [ModerationInputTextList]: An array of text strings.
/// - [ModerationInputMultiModal]: An array of multi-modal input objects
///   (text and/or image URLs), for use with omni-moderation models.
sealed class ModerationInput {
  /// Creates a [ModerationInput] from JSON.
  factory ModerationInput.fromJson(Object json) {
    if (json is String) {
      return ModerationInputText(json);
    } else if (json is List) {
      if (json.isEmpty) {
        return const ModerationInputTextList([]);
      }
      if (json.first is String) {
        return ModerationInputTextList(json.cast<String>());
      }
      return ModerationInputMultiModal(
        json
            .cast<Map<String, dynamic>>()
            .map(ModerationInputItem.fromJson)
            .toList(),
      );
    }
    throw FormatException('Unknown moderation input format: $json');
  }

  /// Creates input from a single text string.
  static ModerationInput text(String text) => ModerationInputText(text);

  /// Creates input from multiple text strings.
  static ModerationInput textList(List<String> texts) =>
      ModerationInputTextList(texts);

  /// Creates multi-modal input from a list of input items.
  ///
  /// Use this with omni-moderation models to moderate text and images.
  static ModerationInput multiModal(List<ModerationInputItem> items) =>
      ModerationInputMultiModal(items);

  /// Converts to JSON.
  Object toJson();
}

/// A single text string input for moderation.
@immutable
class ModerationInputText implements ModerationInput {
  /// Creates a [ModerationInputText].
  const ModerationInputText(this.text);

  /// The text to moderate.
  final String text;

  @override
  Object toJson() => text;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationInputText &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ModerationInputText(${text.length} chars)';
}

/// Multiple text strings input for moderation.
@immutable
class ModerationInputTextList implements ModerationInput {
  /// Creates a [ModerationInputTextList].
  const ModerationInputTextList(this.texts);

  /// The texts to moderate.
  final List<String> texts;

  @override
  Object toJson() => texts;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationInputTextList &&
          runtimeType == other.runtimeType &&
          _listEquals(texts, other.texts);

  @override
  int get hashCode => Object.hashAll(texts);

  @override
  String toString() => 'ModerationInputTextList(${texts.length} texts)';
}

/// Multi-modal input for moderation (text and/or images).
///
/// Use with omni-moderation models like `omni-moderation-latest`.
@immutable
class ModerationInputMultiModal implements ModerationInput {
  /// Creates a [ModerationInputMultiModal].
  const ModerationInputMultiModal(this.items);

  /// The list of multi-modal input items.
  final List<ModerationInputItem> items;

  @override
  Object toJson() => items.map((e) => e.toJson()).toList();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationInputMultiModal &&
          runtimeType == other.runtimeType &&
          _listEquals(items, other.items);

  @override
  int get hashCode => Object.hashAll(items);

  @override
  String toString() => 'ModerationInputMultiModal(${items.length} items)';
}

/// A single item in a multi-modal moderation input.
///
/// Either a [ModerationInputItemText] or a [ModerationInputItemImageUrl].
sealed class ModerationInputItem {
  /// Creates a [ModerationInputItem] from JSON.
  factory ModerationInputItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => ModerationInputItemText(json['text'] as String),
      'image_url' => ModerationInputItemImageUrl(
        url: (json['image_url'] as Map<String, dynamic>)['url'] as String,
      ),
      _ => throw FormatException('Unknown moderation input item type: $type'),
    };
  }

  /// Creates a text input item.
  static ModerationInputItem text(String text) => ModerationInputItemText(text);

  /// Creates an image URL input item.
  static ModerationInputItem imageUrl(String url) =>
      ModerationInputItemImageUrl(url: url);

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A text input item for multi-modal moderation.
@immutable
class ModerationInputItemText implements ModerationInputItem {
  /// Creates a [ModerationInputItemText].
  const ModerationInputItemText(this.text);

  /// The text to classify.
  final String text;

  @override
  Map<String, dynamic> toJson() => {'type': 'text', 'text': text};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationInputItemText &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;

  @override
  String toString() => 'ModerationInputItemText(${text.length} chars)';
}

/// An image URL input item for multi-modal moderation.
///
/// Contains either a URL or a base64 data URL for the image.
@immutable
class ModerationInputItemImageUrl implements ModerationInputItem {
  /// Creates a [ModerationInputItemImageUrl].
  const ModerationInputItemImageUrl({required this.url});

  /// Either a URL of the image or the base64 encoded image data.
  final String url;

  @override
  Map<String, dynamic> toJson() => {
    'type': 'image_url',
    'image_url': {'url': url},
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationInputItemImageUrl &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;

  @override
  String toString() => 'ModerationInputItemImageUrl($url)';
}

/// A moderation response.
///
/// Contains the moderation results for each input.
@immutable
class ModerationResponse {
  /// Creates a [ModerationResponse].
  const ModerationResponse({
    required this.id,
    required this.model,
    required this.results,
  });

  /// Creates a [ModerationResponse] from JSON.
  factory ModerationResponse.fromJson(Map<String, dynamic> json) {
    return ModerationResponse(
      id: json['id'] as String,
      model: json['model'] as String,
      results: (json['results'] as List<dynamic>)
          .map((e) => ModerationResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// The moderation ID.
  final String id;

  /// The model used for moderation.
  final String model;

  /// The moderation results.
  final List<ModerationResult> results;

  /// Whether any input was flagged.
  bool get anyFlagged => results.any((r) => r.flagged);

  /// The first result (convenient for single-input requests).
  ModerationResult get first => results.first;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'model': model,
    'results': results.map((r) => r.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ModerationResponse(id: $id, flagged: $anyFlagged)';
}

/// The moderation result for a single input.
@immutable
class ModerationResult {
  /// Creates a [ModerationResult].
  const ModerationResult({
    required this.flagged,
    required this.categories,
    required this.categoryScores,
    this.categoryAppliedInputTypes,
  });

  /// Creates a [ModerationResult] from JSON.
  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    return ModerationResult(
      flagged: json['flagged'] as bool,
      categories: ModerationCategories.fromJson(
        json['categories'] as Map<String, dynamic>,
      ),
      categoryScores: ModerationCategoryScores.fromJson(
        json['category_scores'] as Map<String, dynamic>,
      ),
      categoryAppliedInputTypes: json['category_applied_input_types'] != null
          ? ModerationCategoryAppliedInputTypes.fromJson(
              json['category_applied_input_types'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Whether the content was flagged by the model.
  final bool flagged;

  /// The categories and whether they were flagged.
  final ModerationCategories categories;

  /// The category confidence scores.
  final ModerationCategoryScores categoryScores;

  /// The input type(s) that each category score applies to.
  ///
  /// Only returned by omni-moderation models. Will be `null` for legacy
  /// text-moderation models.
  final ModerationCategoryAppliedInputTypes? categoryAppliedInputTypes;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'flagged': flagged,
    'categories': categories.toJson(),
    'category_scores': categoryScores.toJson(),
    if (categoryAppliedInputTypes != null)
      'category_applied_input_types': categoryAppliedInputTypes!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationResult &&
          runtimeType == other.runtimeType &&
          flagged == other.flagged &&
          categories == other.categories &&
          categoryScores == other.categoryScores &&
          categoryAppliedInputTypes == other.categoryAppliedInputTypes;

  @override
  int get hashCode => Object.hash(
    flagged,
    categories,
    categoryScores,
    categoryAppliedInputTypes,
  );

  @override
  String toString() => 'ModerationResult(flagged: $flagged)';
}

/// Moderation category flags.
@immutable
class ModerationCategories {
  /// Creates a [ModerationCategories].
  const ModerationCategories({
    required this.hate,
    required this.hateThreatening,
    required this.harassment,
    required this.harassmentThreatening,
    this.illicit,
    this.illicitViolent,
    required this.selfHarm,
    required this.selfHarmIntent,
    required this.selfHarmInstructions,
    required this.sexual,
    required this.sexualMinors,
    required this.violence,
    required this.violenceGraphic,
  });

  /// Creates a [ModerationCategories] from JSON.
  factory ModerationCategories.fromJson(Map<String, dynamic> json) {
    return ModerationCategories(
      hate: json['hate'] as bool,
      hateThreatening: json['hate/threatening'] as bool,
      harassment: json['harassment'] as bool,
      harassmentThreatening: json['harassment/threatening'] as bool,
      illicit: json['illicit'] as bool?,
      illicitViolent: json['illicit/violent'] as bool?,
      selfHarm: json['self-harm'] as bool,
      selfHarmIntent: json['self-harm/intent'] as bool,
      selfHarmInstructions: json['self-harm/instructions'] as bool,
      sexual: json['sexual'] as bool,
      sexualMinors: json['sexual/minors'] as bool,
      violence: json['violence'] as bool,
      violenceGraphic: json['violence/graphic'] as bool,
    );
  }

  /// Hate content.
  final bool hate;

  /// Hate content with threatening language.
  final bool hateThreatening;

  /// Harassment content.
  final bool harassment;

  /// Harassment with threatening language.
  final bool harassmentThreatening;

  /// Illicit content such as instructions for wrongdoing.
  ///
  /// Only present when using omni-moderation models.
  final bool? illicit;

  /// Illicit content that also includes violence.
  ///
  /// Only present when using omni-moderation models.
  final bool? illicitViolent;

  /// Self-harm content.
  final bool selfHarm;

  /// Self-harm with intent.
  final bool selfHarmIntent;

  /// Self-harm instructions.
  final bool selfHarmInstructions;

  /// Sexual content.
  final bool sexual;

  /// Sexual content involving minors.
  final bool sexualMinors;

  /// Violence.
  final bool violence;

  /// Graphic violence.
  final bool violenceGraphic;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'hate': hate,
    'hate/threatening': hateThreatening,
    'harassment': harassment,
    'harassment/threatening': harassmentThreatening,
    if (illicit != null) 'illicit': illicit,
    if (illicitViolent != null) 'illicit/violent': illicitViolent,
    'self-harm': selfHarm,
    'self-harm/intent': selfHarmIntent,
    'self-harm/instructions': selfHarmInstructions,
    'sexual': sexual,
    'sexual/minors': sexualMinors,
    'violence': violence,
    'violence/graphic': violenceGraphic,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationCategories &&
          runtimeType == other.runtimeType &&
          hate == other.hate &&
          hateThreatening == other.hateThreatening &&
          harassment == other.harassment &&
          harassmentThreatening == other.harassmentThreatening &&
          illicit == other.illicit &&
          illicitViolent == other.illicitViolent &&
          selfHarm == other.selfHarm &&
          selfHarmIntent == other.selfHarmIntent &&
          selfHarmInstructions == other.selfHarmInstructions &&
          sexual == other.sexual &&
          sexualMinors == other.sexualMinors &&
          violence == other.violence &&
          violenceGraphic == other.violenceGraphic;

  @override
  int get hashCode => Object.hash(
    hate,
    hateThreatening,
    harassment,
    harassmentThreatening,
    illicit,
    illicitViolent,
    selfHarm,
    selfHarmIntent,
    selfHarmInstructions,
    sexual,
    sexualMinors,
    violence,
    violenceGraphic,
  );

  @override
  String toString() => 'ModerationCategories(...)';
}

/// Moderation category confidence scores.
@immutable
class ModerationCategoryScores {
  /// Creates a [ModerationCategoryScores].
  const ModerationCategoryScores({
    required this.hate,
    required this.hateThreatening,
    required this.harassment,
    required this.harassmentThreatening,
    this.illicit,
    this.illicitViolent,
    required this.selfHarm,
    required this.selfHarmIntent,
    required this.selfHarmInstructions,
    required this.sexual,
    required this.sexualMinors,
    required this.violence,
    required this.violenceGraphic,
  });

  /// Creates a [ModerationCategoryScores] from JSON.
  factory ModerationCategoryScores.fromJson(Map<String, dynamic> json) {
    return ModerationCategoryScores(
      hate: (json['hate'] as num).toDouble(),
      hateThreatening: (json['hate/threatening'] as num).toDouble(),
      harassment: (json['harassment'] as num).toDouble(),
      harassmentThreatening: (json['harassment/threatening'] as num).toDouble(),
      illicit: (json['illicit'] as num?)?.toDouble(),
      illicitViolent: (json['illicit/violent'] as num?)?.toDouble(),
      selfHarm: (json['self-harm'] as num).toDouble(),
      selfHarmIntent: (json['self-harm/intent'] as num).toDouble(),
      selfHarmInstructions: (json['self-harm/instructions'] as num).toDouble(),
      sexual: (json['sexual'] as num).toDouble(),
      sexualMinors: (json['sexual/minors'] as num).toDouble(),
      violence: (json['violence'] as num).toDouble(),
      violenceGraphic: (json['violence/graphic'] as num).toDouble(),
    );
  }

  /// Hate content score.
  final double hate;

  /// Hate/threatening score.
  final double hateThreatening;

  /// Harassment score.
  final double harassment;

  /// Harassment/threatening score.
  final double harassmentThreatening;

  /// Illicit content score.
  ///
  /// Only present when using omni-moderation models.
  final double? illicit;

  /// Illicit/violent content score.
  ///
  /// Only present when using omni-moderation models.
  final double? illicitViolent;

  /// Self-harm score.
  final double selfHarm;

  /// Self-harm/intent score.
  final double selfHarmIntent;

  /// Self-harm/instructions score.
  final double selfHarmInstructions;

  /// Sexual content score.
  final double sexual;

  /// Sexual/minors score.
  final double sexualMinors;

  /// Violence score.
  final double violence;

  /// Violence/graphic score.
  final double violenceGraphic;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'hate': hate,
    'hate/threatening': hateThreatening,
    'harassment': harassment,
    'harassment/threatening': harassmentThreatening,
    if (illicit != null) 'illicit': illicit,
    if (illicitViolent != null) 'illicit/violent': illicitViolent,
    'self-harm': selfHarm,
    'self-harm/intent': selfHarmIntent,
    'self-harm/instructions': selfHarmInstructions,
    'sexual': sexual,
    'sexual/minors': sexualMinors,
    'violence': violence,
    'violence/graphic': violenceGraphic,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationCategoryScores &&
          runtimeType == other.runtimeType &&
          hate == other.hate &&
          hateThreatening == other.hateThreatening &&
          harassment == other.harassment &&
          harassmentThreatening == other.harassmentThreatening &&
          illicit == other.illicit &&
          illicitViolent == other.illicitViolent &&
          selfHarm == other.selfHarm &&
          selfHarmIntent == other.selfHarmIntent &&
          selfHarmInstructions == other.selfHarmInstructions &&
          sexual == other.sexual &&
          sexualMinors == other.sexualMinors &&
          violence == other.violence &&
          violenceGraphic == other.violenceGraphic;

  @override
  int get hashCode => Object.hash(
    hate,
    hateThreatening,
    harassment,
    harassmentThreatening,
    illicit,
    illicitViolent,
    selfHarm,
    selfHarmIntent,
    selfHarmInstructions,
    sexual,
    sexualMinors,
    violence,
    violenceGraphic,
  );

  @override
  String toString() => 'ModerationCategoryScores(...)';
}

/// The input type(s) that each category score applies to.
///
/// Only returned by omni-moderation models. Each category lists the input
/// types (e.g., `['text']` or `['text', 'image']`) it was evaluated against.
@immutable
class ModerationCategoryAppliedInputTypes {
  /// Creates a [ModerationCategoryAppliedInputTypes].
  const ModerationCategoryAppliedInputTypes({
    required this.hate,
    required this.hateThreatening,
    required this.harassment,
    required this.harassmentThreatening,
    required this.illicit,
    required this.illicitViolent,
    required this.selfHarm,
    required this.selfHarmIntent,
    required this.selfHarmInstructions,
    required this.sexual,
    required this.sexualMinors,
    required this.violence,
    required this.violenceGraphic,
  });

  /// Creates a [ModerationCategoryAppliedInputTypes] from JSON.
  factory ModerationCategoryAppliedInputTypes.fromJson(
    Map<String, dynamic> json,
  ) {
    return ModerationCategoryAppliedInputTypes(
      hate: (json['hate'] as List<dynamic>).cast<String>(),
      hateThreatening: (json['hate/threatening'] as List<dynamic>)
          .cast<String>(),
      harassment: (json['harassment'] as List<dynamic>).cast<String>(),
      harassmentThreatening: (json['harassment/threatening'] as List<dynamic>)
          .cast<String>(),
      illicit: (json['illicit'] as List<dynamic>).cast<String>(),
      illicitViolent: (json['illicit/violent'] as List<dynamic>).cast<String>(),
      selfHarm: (json['self-harm'] as List<dynamic>).cast<String>(),
      selfHarmIntent: (json['self-harm/intent'] as List<dynamic>)
          .cast<String>(),
      selfHarmInstructions: (json['self-harm/instructions'] as List<dynamic>)
          .cast<String>(),
      sexual: (json['sexual'] as List<dynamic>).cast<String>(),
      sexualMinors: (json['sexual/minors'] as List<dynamic>).cast<String>(),
      violence: (json['violence'] as List<dynamic>).cast<String>(),
      violenceGraphic: (json['violence/graphic'] as List<dynamic>)
          .cast<String>(),
    );
  }

  /// Applied input types for the 'hate' category.
  final List<String> hate;

  /// Applied input types for the 'hate/threatening' category.
  final List<String> hateThreatening;

  /// Applied input types for the 'harassment' category.
  final List<String> harassment;

  /// Applied input types for the 'harassment/threatening' category.
  final List<String> harassmentThreatening;

  /// Applied input types for the 'illicit' category.
  final List<String> illicit;

  /// Applied input types for the 'illicit/violent' category.
  final List<String> illicitViolent;

  /// Applied input types for the 'self-harm' category.
  final List<String> selfHarm;

  /// Applied input types for the 'self-harm/intent' category.
  final List<String> selfHarmIntent;

  /// Applied input types for the 'self-harm/instructions' category.
  final List<String> selfHarmInstructions;

  /// Applied input types for the 'sexual' category.
  final List<String> sexual;

  /// Applied input types for the 'sexual/minors' category.
  final List<String> sexualMinors;

  /// Applied input types for the 'violence' category.
  final List<String> violence;

  /// Applied input types for the 'violence/graphic' category.
  final List<String> violenceGraphic;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'hate': hate,
    'hate/threatening': hateThreatening,
    'harassment': harassment,
    'harassment/threatening': harassmentThreatening,
    'illicit': illicit,
    'illicit/violent': illicitViolent,
    'self-harm': selfHarm,
    'self-harm/intent': selfHarmIntent,
    'self-harm/instructions': selfHarmInstructions,
    'sexual': sexual,
    'sexual/minors': sexualMinors,
    'violence': violence,
    'violence/graphic': violenceGraphic,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationCategoryAppliedInputTypes &&
          runtimeType == other.runtimeType &&
          _listEquals(hate, other.hate) &&
          _listEquals(hateThreatening, other.hateThreatening) &&
          _listEquals(harassment, other.harassment) &&
          _listEquals(harassmentThreatening, other.harassmentThreatening) &&
          _listEquals(illicit, other.illicit) &&
          _listEquals(illicitViolent, other.illicitViolent) &&
          _listEquals(selfHarm, other.selfHarm) &&
          _listEquals(selfHarmIntent, other.selfHarmIntent) &&
          _listEquals(selfHarmInstructions, other.selfHarmInstructions) &&
          _listEquals(sexual, other.sexual) &&
          _listEquals(sexualMinors, other.sexualMinors) &&
          _listEquals(violence, other.violence) &&
          _listEquals(violenceGraphic, other.violenceGraphic);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(hate),
    Object.hashAll(hateThreatening),
    Object.hashAll(harassment),
    Object.hashAll(harassmentThreatening),
    Object.hashAll(illicit),
    Object.hashAll(illicitViolent),
    Object.hashAll(selfHarm),
    Object.hashAll(selfHarmIntent),
    Object.hashAll(selfHarmInstructions),
    Object.hashAll(sexual),
    Object.hashAll(sexualMinors),
    Object.hashAll(violence),
    Object.hashAll(violenceGraphic),
  );

  @override
  String toString() => 'ModerationCategoryAppliedInputTypes(...)';
}

// Helper for list equality
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
