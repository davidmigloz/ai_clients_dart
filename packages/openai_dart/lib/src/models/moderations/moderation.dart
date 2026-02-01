import 'package:meta/meta.dart';

/// A request to check content for harmful material.
///
/// The moderation API classifies content into categories like hate speech,
/// self-harm, violence, and more.
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

  /// The input text to moderate.
  ///
  /// Can be a single string or a list of strings.
  final ModerationInput input;

  /// The moderation model to use.
  ///
  /// Defaults to `text-moderation-latest`. Use `text-moderation-stable`
  /// for consistent behavior across model updates.
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
sealed class ModerationInput {
  /// Creates a [ModerationInput] from JSON.
  factory ModerationInput.fromJson(Object json) {
    if (json is String) {
      return ModerationInputText(json);
    } else if (json is List) {
      return ModerationInputTextList(json.cast<String>());
    }
    throw FormatException('Unknown moderation input format: $json');
  }

  /// Creates input from a single text string.
  static ModerationInput text(String text) => ModerationInputText(text);

  /// Creates input from multiple text strings.
  static ModerationInput textList(List<String> texts) =>
      ModerationInputTextList(texts);

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
    );
  }

  /// Whether the content was flagged by the model.
  final bool flagged;

  /// The categories and whether they were flagged.
  final ModerationCategories categories;

  /// The category confidence scores.
  final ModerationCategoryScores categoryScores;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'flagged': flagged,
    'categories': categories.toJson(),
    'category_scores': categoryScores.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModerationResult &&
          runtimeType == other.runtimeType &&
          flagged == other.flagged;

  @override
  int get hashCode => flagged.hashCode;

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
          sexual == other.sexual &&
          violence == other.violence;

  @override
  int get hashCode => Object.hash(hate, sexual, violence);

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
      other is ModerationCategoryScores && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(hate, sexual, violence);

  @override
  String toString() => 'ModerationCategoryScores(...)';
}

// Helper for list equality
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
