import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'evaluation_statistics.dart';

/// The ContentSearchFilter wire payload.
@immutable
class ContentSearchFilter {
  /// Creates a [ContentSearchFilter].
  const ContentSearchFilter({this.operator, this.path, required this.value});

  /// The operator field.
  final ContentSearchOperator? operator;

  /// The path field.
  final String? path;

  /// The value field.
  final String value;

  /// Parses a [ContentSearchFilter] from JSON.
  factory ContentSearchFilter.fromJson(Map<String, dynamic> json) {
    if (json['value'] == null) {
      throw const FormatException('ContentSearchFilter: missing value');
    }
    return ContentSearchFilter(
      operator: json['operator'] == null
          ? null
          : ContentSearchOperator.fromJson(json['operator'] as String),
      path: json['path'] == null ? null : json['path'] as String,
      value: json['value'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (operator != null) 'operator': operator!.toJson(),
    'path': ?path,
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  ContentSearchFilter copyWith({
    Object? operator = unsetCopyWithValue,
    Object? path = unsetCopyWithValue,
    String? value,
  }) => ContentSearchFilter(
    operator: operator == unsetCopyWithValue
        ? this.operator
        : operator as ContentSearchOperator?,
    path: path == unsetCopyWithValue ? this.path : path as String?,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSearchFilter &&
          runtimeType == other.runtimeType &&
          operator == other.operator &&
          path == other.path &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([operator, path, value]);

  @override
  String toString() =>
      'ContentSearchFilter('
      'operator: $operator, '
      'path: $path, '
      'value: $value)';
}

/// The ContentSearchFilterGroup wire payload.
@immutable
class ContentSearchFilterGroup {
  /// Creates a [ContentSearchFilterGroup].
  const ContentSearchFilterGroup({this.combinator, this.filters});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The filters field.
  final List<ContentSearchFilter>? filters;

  /// Parses a [ContentSearchFilterGroup] from JSON.
  factory ContentSearchFilterGroup.fromJson(Map<String, dynamic> json) {
    return ContentSearchFilterGroup(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List<Object?>)
                .map(
                  (item) => ContentSearchFilter.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ContentSearchFilterGroup copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
  }) => ContentSearchFilterGroup(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List<Object?>?)?.cast<ContentSearchFilter>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentSearchFilterGroup &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(filters, other.filters);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(filters)]);

  @override
  String toString() =>
      'ContentSearchFilterGroup('
      'combinator: $combinator, '
      'filters: ${filters?.length})';
}

/// Values for ContentSearchOperator.
enum ContentSearchOperator {
  /// Represents contains.
  contains('contains'),

  /// Represents equals.
  equals('equals'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ContentSearchOperator(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ContentSearchOperator fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The EvaluationRunFilterInput wire payload.
@immutable
class EvaluationRunFilterInput {
  /// Creates a [EvaluationRunFilterInput].
  const EvaluationRunFilterInput({
    this.creatorIds,
    this.evaluationIds,
    this.goalFilters,
    this.metadata,
    this.ownership,
    this.projectIds,
    this.runIds,
    this.scoreFilters,
    this.system,
    this.tags,
  });

  /// The creator_ids field.
  final List<String>? creatorIds;

  /// The evaluation_ids field.
  final List<String>? evaluationIds;

  /// The goal_filters field.
  final GoalStatusFilterGroup? goalFilters;

  /// The metadata field.
  final MetadataFilterGroup? metadata;

  /// The ownership field.
  final RunOwnershipFilter? ownership;

  /// The project_ids field.
  final List<String>? projectIds;

  /// The run_ids field.
  final List<String>? runIds;

  /// The score_filters field.
  final ScoreFilterGroup? scoreFilters;

  /// The system field.
  final SystemFilter? system;

  /// The tags field.
  final TagFilter? tags;

  /// Parses a [EvaluationRunFilterInput] from JSON.
  factory EvaluationRunFilterInput.fromJson(Map<String, dynamic> json) {
    return EvaluationRunFilterInput(
      creatorIds: json['creator_ids'] == null
          ? null
          : (json['creator_ids'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      evaluationIds: json['evaluation_ids'] == null
          ? null
          : (json['evaluation_ids'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      goalFilters: json['goal_filters'] == null
          ? null
          : GoalStatusFilterGroup.fromJson(
              json['goal_filters'] as Map<String, dynamic>,
            ),
      metadata: json['metadata'] == null
          ? null
          : MetadataFilterGroup.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
      ownership: json['ownership'] == null
          ? null
          : RunOwnershipFilter.fromJson(
              json['ownership'] as Map<String, dynamic>,
            ),
      projectIds: json['project_ids'] == null
          ? null
          : (json['project_ids'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      runIds: json['run_ids'] == null
          ? null
          : (json['run_ids'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      scoreFilters: json['score_filters'] == null
          ? null
          : ScoreFilterGroup.fromJson(
              json['score_filters'] as Map<String, dynamic>,
            ),
      system: json['system'] == null
          ? null
          : SystemFilter.fromJson(json['system'] as Map<String, dynamic>),
      tags: json['tags'] == null
          ? null
          : TagFilter.fromJson(json['tags'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'creator_ids': ?creatorIds,
    'evaluation_ids': ?evaluationIds,
    if (goalFilters != null) 'goal_filters': goalFilters!.toJson(),
    if (metadata != null) 'metadata': metadata!.toJson(),
    if (ownership != null) 'ownership': ownership!.toJson(),
    'project_ids': ?projectIds,
    'run_ids': ?runIds,
    if (scoreFilters != null) 'score_filters': scoreFilters!.toJson(),
    if (system != null) 'system': system!.toJson(),
    if (tags != null) 'tags': tags!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRunFilterInput copyWith({
    Object? creatorIds = unsetCopyWithValue,
    Object? evaluationIds = unsetCopyWithValue,
    Object? goalFilters = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    Object? ownership = unsetCopyWithValue,
    Object? projectIds = unsetCopyWithValue,
    Object? runIds = unsetCopyWithValue,
    Object? scoreFilters = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    Object? tags = unsetCopyWithValue,
  }) => EvaluationRunFilterInput(
    creatorIds: creatorIds == unsetCopyWithValue
        ? this.creatorIds
        : (creatorIds as List<Object?>?)?.cast<String>(),
    evaluationIds: evaluationIds == unsetCopyWithValue
        ? this.evaluationIds
        : (evaluationIds as List<Object?>?)?.cast<String>(),
    goalFilters: goalFilters == unsetCopyWithValue
        ? this.goalFilters
        : goalFilters as GoalStatusFilterGroup?,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : metadata as MetadataFilterGroup?,
    ownership: ownership == unsetCopyWithValue
        ? this.ownership
        : ownership as RunOwnershipFilter?,
    projectIds: projectIds == unsetCopyWithValue
        ? this.projectIds
        : (projectIds as List<Object?>?)?.cast<String>(),
    runIds: runIds == unsetCopyWithValue
        ? this.runIds
        : (runIds as List<Object?>?)?.cast<String>(),
    scoreFilters: scoreFilters == unsetCopyWithValue
        ? this.scoreFilters
        : scoreFilters as ScoreFilterGroup?,
    system: system == unsetCopyWithValue
        ? this.system
        : system as SystemFilter?,
    tags: tags == unsetCopyWithValue ? this.tags : tags as TagFilter?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRunFilterInput &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(creatorIds, other.creatorIds) &&
          valuesDeepEqual(evaluationIds, other.evaluationIds) &&
          goalFilters == other.goalFilters &&
          metadata == other.metadata &&
          ownership == other.ownership &&
          valuesDeepEqual(projectIds, other.projectIds) &&
          valuesDeepEqual(runIds, other.runIds) &&
          scoreFilters == other.scoreFilters &&
          system == other.system &&
          tags == other.tags;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(creatorIds),
    valueDeepHashCode(evaluationIds),
    goalFilters,
    metadata,
    ownership,
    valueDeepHashCode(projectIds),
    valueDeepHashCode(runIds),
    scoreFilters,
    system,
    tags,
  ]);

  @override
  String toString() =>
      'EvaluationRunFilterInput('
      'creatorIds: ${creatorIds?.length}, '
      'evaluationIds: ${evaluationIds?.length}, '
      'goalFilters: $goalFilters, '
      'metadata: $metadata, '
      'ownership: $ownership, '
      'projectIds: ${projectIds?.length}, '
      'runIds: ${runIds?.length}, '
      'scoreFilters: $scoreFilters, '
      'system: $system, '
      'tags: $tags)';
}

/// The EvaluationRunRecordFilterInput wire payload.
@immutable
class EvaluationRunRecordFilterInput {
  /// Creates a [EvaluationRunRecordFilterInput].
  const EvaluationRunRecordFilterInput({
    this.goalFilters,
    this.inputFilters,
    this.outputFilters,
    this.scoreFilters,
    this.sort,
  });

  /// The goal_filters field.
  final GoalStatusFilterGroup? goalFilters;

  /// The input_filters field.
  final ContentSearchFilterGroup? inputFilters;

  /// The output_filters field.
  final ContentSearchFilterGroup? outputFilters;

  /// The score_filters field.
  final ScoreFilterGroup? scoreFilters;

  /// The sort field.
  final EvaluationRecordSort? sort;

  /// Parses a [EvaluationRunRecordFilterInput] from JSON.
  factory EvaluationRunRecordFilterInput.fromJson(Map<String, dynamic> json) {
    return EvaluationRunRecordFilterInput(
      goalFilters: json['goal_filters'] == null
          ? null
          : GoalStatusFilterGroup.fromJson(
              json['goal_filters'] as Map<String, dynamic>,
            ),
      inputFilters: json['input_filters'] == null
          ? null
          : ContentSearchFilterGroup.fromJson(
              json['input_filters'] as Map<String, dynamic>,
            ),
      outputFilters: json['output_filters'] == null
          ? null
          : ContentSearchFilterGroup.fromJson(
              json['output_filters'] as Map<String, dynamic>,
            ),
      scoreFilters: json['score_filters'] == null
          ? null
          : ScoreFilterGroup.fromJson(
              json['score_filters'] as Map<String, dynamic>,
            ),
      sort: json['sort'] == null
          ? null
          : EvaluationRecordSort.fromJson(json['sort'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (goalFilters != null) 'goal_filters': goalFilters!.toJson(),
    if (inputFilters != null) 'input_filters': inputFilters!.toJson(),
    if (outputFilters != null) 'output_filters': outputFilters!.toJson(),
    if (scoreFilters != null) 'score_filters': scoreFilters!.toJson(),
    if (sort != null) 'sort': sort!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRunRecordFilterInput copyWith({
    Object? goalFilters = unsetCopyWithValue,
    Object? inputFilters = unsetCopyWithValue,
    Object? outputFilters = unsetCopyWithValue,
    Object? scoreFilters = unsetCopyWithValue,
    Object? sort = unsetCopyWithValue,
  }) => EvaluationRunRecordFilterInput(
    goalFilters: goalFilters == unsetCopyWithValue
        ? this.goalFilters
        : goalFilters as GoalStatusFilterGroup?,
    inputFilters: inputFilters == unsetCopyWithValue
        ? this.inputFilters
        : inputFilters as ContentSearchFilterGroup?,
    outputFilters: outputFilters == unsetCopyWithValue
        ? this.outputFilters
        : outputFilters as ContentSearchFilterGroup?,
    scoreFilters: scoreFilters == unsetCopyWithValue
        ? this.scoreFilters
        : scoreFilters as ScoreFilterGroup?,
    sort: sort == unsetCopyWithValue
        ? this.sort
        : sort as EvaluationRecordSort?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRunRecordFilterInput &&
          runtimeType == other.runtimeType &&
          goalFilters == other.goalFilters &&
          inputFilters == other.inputFilters &&
          outputFilters == other.outputFilters &&
          scoreFilters == other.scoreFilters &&
          sort == other.sort;

  @override
  int get hashCode => Object.hashAll([
    goalFilters,
    inputFilters,
    outputFilters,
    scoreFilters,
    sort,
  ]);

  @override
  String toString() =>
      'EvaluationRunRecordFilterInput('
      'goalFilters: $goalFilters, '
      'inputFilters: $inputFilters, '
      'outputFilters: $outputFilters, '
      'scoreFilters: $scoreFilters, '
      'sort: $sort)';
}

/// The FieldSortInput wire payload.
@immutable
final class FieldSortInput extends EvaluationRecordSort {
  /// Creates a [FieldSortInput].
  const FieldSortInput({this.direction, required this.field});

  /// The fixed kind discriminator.
  String get kind => 'field';

  /// The direction field.
  final SortDirection? direction;

  /// The field field.
  final RecordSortField field;

  /// Parses a [FieldSortInput] from JSON.
  factory FieldSortInput.fromJson(Map<String, dynamic> json) {
    if (json['kind'] case final value? when value != 'field') {
      throw FormatException('FieldSortInput: unexpected kind $value');
    }
    if (json['field'] == null) {
      throw const FormatException('FieldSortInput: missing field');
    }
    return FieldSortInput(
      direction: json['direction'] == null
          ? null
          : SortDirection.fromJson(json['direction'] as String),
      field: RecordSortField.fromJson(json['field'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'kind': kind,
    if (direction != null) 'direction': direction!.toJson(),
    'field': field.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  FieldSortInput copyWith({
    Object? direction = unsetCopyWithValue,
    RecordSortField? field,
  }) => FieldSortInput(
    direction: direction == unsetCopyWithValue
        ? this.direction
        : direction as SortDirection?,
    field: field ?? this.field,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FieldSortInput &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          field == other.field;

  @override
  int get hashCode => Object.hashAll([direction, field]);

  @override
  String toString() =>
      'FieldSortInput('
      'direction: $direction, '
      'field: $field)';
}

/// Values for FilterCombinator.
enum FilterCombinator {
  /// Represents and.
  andValue('and'),

  /// Represents or.
  orValue('or'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const FilterCombinator(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static FilterCombinator fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for GoalStatus.
enum GoalStatus {
  /// Represents passed.
  passed('passed'),

  /// Represents failed.
  failed('failed'),

  /// Represents not_evaluated.
  notEvaluated('not_evaluated'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const GoalStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static GoalStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The GoalStatusFilter wire payload.
@immutable
class GoalStatusFilter {
  /// Creates a [GoalStatusFilter].
  const GoalStatusFilter({this.evaluatorName, required this.values});

  /// The evaluator_name field.
  final String? evaluatorName;

  /// The values field.
  final List<GoalStatus> values;

  /// Parses a [GoalStatusFilter] from JSON.
  factory GoalStatusFilter.fromJson(Map<String, dynamic> json) {
    if (json['values'] == null) {
      throw const FormatException('GoalStatusFilter: missing values');
    }
    return GoalStatusFilter(
      evaluatorName: json['evaluator_name'] == null
          ? null
          : json['evaluator_name'] as String,
      values: (json['values'] as List<Object?>)
          .map((item) => GoalStatus.fromJson(item! as String))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'evaluator_name': ?evaluatorName,
    'values': values.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  GoalStatusFilter copyWith({
    Object? evaluatorName = unsetCopyWithValue,
    List<GoalStatus>? values,
  }) => GoalStatusFilter(
    evaluatorName: evaluatorName == unsetCopyWithValue
        ? this.evaluatorName
        : evaluatorName as String?,
    values: values ?? this.values,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusFilter &&
          runtimeType == other.runtimeType &&
          evaluatorName == other.evaluatorName &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode =>
      Object.hashAll([evaluatorName, valueDeepHashCode(values)]);

  @override
  String toString() =>
      'GoalStatusFilter('
      'evaluatorName: $evaluatorName, '
      'values: ${values.length})';
}

/// The GoalStatusFilterGroup wire payload.
@immutable
class GoalStatusFilterGroup {
  /// Creates a [GoalStatusFilterGroup].
  const GoalStatusFilterGroup({this.combinator, this.filters});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The filters field.
  final List<GoalStatusFilter>? filters;

  /// Parses a [GoalStatusFilterGroup] from JSON.
  factory GoalStatusFilterGroup.fromJson(Map<String, dynamic> json) {
    return GoalStatusFilterGroup(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List<Object?>)
                .map(
                  (item) =>
                      GoalStatusFilter.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  GoalStatusFilterGroup copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
  }) => GoalStatusFilterGroup(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List<Object?>?)?.cast<GoalStatusFilter>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalStatusFilterGroup &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(filters, other.filters);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(filters)]);

  @override
  String toString() =>
      'GoalStatusFilterGroup('
      'combinator: $combinator, '
      'filters: ${filters?.length})';
}

/// The MetadataFilter wire payload.
@immutable
class MetadataFilter {
  /// Creates a [MetadataFilter].
  const MetadataFilter({
    required this.key,
    required this.operator,
    required this.value,
  });

  /// The key field.
  final String key;

  /// The operator field.
  final SystemParamOperator operator;

  /// The value field.
  final Object value;

  /// Parses a [MetadataFilter] from JSON.
  factory MetadataFilter.fromJson(Map<String, dynamic> json) {
    if (json['key'] == null) {
      throw const FormatException('MetadataFilter: missing key');
    }
    if (json['operator'] == null) {
      throw const FormatException('MetadataFilter: missing operator');
    }
    if (json['value'] == null) {
      throw const FormatException('MetadataFilter: missing value');
    }
    return MetadataFilter(
      key: json['key'] as String,
      operator: SystemParamOperator.fromJson(json['operator'] as String),
      value: json['value'] as Object,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'key': key,
    'operator': operator.toJson(),
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  MetadataFilter copyWith({
    String? key,
    SystemParamOperator? operator,
    Object? value,
  }) => MetadataFilter(
    key: key ?? this.key,
    operator: operator ?? this.operator,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataFilter &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          operator == other.operator &&
          valuesDeepEqual(value, other.value);

  @override
  int get hashCode => Object.hashAll([key, operator, valueDeepHashCode(value)]);

  @override
  String toString() =>
      'MetadataFilter('
      'key: $key, '
      'operator: $operator, '
      'value: $value)';
}

/// The MetadataFilterGroup wire payload.
@immutable
class MetadataFilterGroup {
  /// Creates a [MetadataFilterGroup].
  const MetadataFilterGroup({this.combinator, this.filters});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The filters field.
  final List<MetadataFilter>? filters;

  /// Parses a [MetadataFilterGroup] from JSON.
  factory MetadataFilterGroup.fromJson(Map<String, dynamic> json) {
    return MetadataFilterGroup(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List<Object?>)
                .map(
                  (item) =>
                      MetadataFilter.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  MetadataFilterGroup copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
  }) => MetadataFilterGroup(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List<Object?>?)?.cast<MetadataFilter>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MetadataFilterGroup &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(filters, other.filters);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(filters)]);

  @override
  String toString() =>
      'MetadataFilterGroup('
      'combinator: $combinator, '
      'filters: ${filters?.length})';
}

/// Values for RecordSortField.
enum RecordSortField {
  /// Represents created_at.
  createdAt('created_at'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const RecordSortField(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static RecordSortField fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// OR-able group isolating the "runs I care about" default (created by me OR in my starred projects). Kept separate from the plain generic filters so it can OR internally while still AND-ing with everything else. The UI drives it via two sugar chips: "Created by me" writes `creator_ids`, and "Starred projects" sets `starred_by_me`. Dropping a chip clears its term and the OR collapses to the remaining one; dropping both leaves the group empty (no ownership scoping). `starred_by_me` is resolved server-side against the caller's favorites, so the client never has to page through projects to collect starred ids — and a caller with zero starred projects correctly matches no runs (rather than falling through to the whole workspace). `project_ids` remains for explicit, caller-supplied project scoping.
@immutable
class RunOwnershipFilter {
  /// Creates a [RunOwnershipFilter].
  const RunOwnershipFilter({
    this.combinator,
    this.creatorIds,
    this.projectIds,
    this.starredByMe,
  });

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The creator_ids field.
  final List<String>? creatorIds;

  /// The project_ids field.
  final List<String>? projectIds;

  /// The starred_by_me field.
  final bool? starredByMe;

  /// Parses a [RunOwnershipFilter] from JSON.
  factory RunOwnershipFilter.fromJson(Map<String, dynamic> json) {
    return RunOwnershipFilter(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      creatorIds: json['creator_ids'] == null
          ? null
          : (json['creator_ids'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      projectIds: json['project_ids'] == null
          ? null
          : (json['project_ids'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      starredByMe: json['starred_by_me'] == null
          ? null
          : json['starred_by_me'] as bool,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    'creator_ids': ?creatorIds,
    'project_ids': ?projectIds,
    'starred_by_me': ?starredByMe,
  };

  /// Creates a copy with the given fields replaced.
  RunOwnershipFilter copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? creatorIds = unsetCopyWithValue,
    Object? projectIds = unsetCopyWithValue,
    Object? starredByMe = unsetCopyWithValue,
  }) => RunOwnershipFilter(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    creatorIds: creatorIds == unsetCopyWithValue
        ? this.creatorIds
        : (creatorIds as List<Object?>?)?.cast<String>(),
    projectIds: projectIds == unsetCopyWithValue
        ? this.projectIds
        : (projectIds as List<Object?>?)?.cast<String>(),
    starredByMe: starredByMe == unsetCopyWithValue
        ? this.starredByMe
        : starredByMe as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunOwnershipFilter &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(creatorIds, other.creatorIds) &&
          valuesDeepEqual(projectIds, other.projectIds) &&
          starredByMe == other.starredByMe;

  @override
  int get hashCode => Object.hashAll([
    combinator,
    valueDeepHashCode(creatorIds),
    valueDeepHashCode(projectIds),
    starredByMe,
  ]);

  @override
  String toString() =>
      'RunOwnershipFilter('
      'combinator: $combinator, '
      'creatorIds: ${creatorIds?.length}, '
      'projectIds: ${projectIds?.length}, '
      'starredByMe: $starredByMe)';
}

/// The ScoreFilter wire payload.
@immutable
class ScoreFilter {
  /// Creates a [ScoreFilter].
  const ScoreFilter({
    required this.evaluatorName,
    required this.metric,
    required this.operator,
    required this.value,
  });

  /// The evaluator_name field.
  final String evaluatorName;

  /// The metric field.
  final String metric;

  /// The operator field.
  final ScoreOperator operator;

  /// The value field.
  final Object value;

  /// Parses a [ScoreFilter] from JSON.
  factory ScoreFilter.fromJson(Map<String, dynamic> json) {
    if (json['evaluator_name'] == null) {
      throw const FormatException('ScoreFilter: missing evaluator_name');
    }
    if (json['metric'] == null) {
      throw const FormatException('ScoreFilter: missing metric');
    }
    if (json['operator'] == null) {
      throw const FormatException('ScoreFilter: missing operator');
    }
    if (json['value'] == null) {
      throw const FormatException('ScoreFilter: missing value');
    }
    return ScoreFilter(
      evaluatorName: json['evaluator_name'] as String,
      metric: json['metric'] as String,
      operator: ScoreOperator.fromJson(json['operator'] as String),
      value: json['value'] as Object,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'evaluator_name': evaluatorName,
    'metric': metric,
    'operator': operator.toJson(),
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  ScoreFilter copyWith({
    String? evaluatorName,
    String? metric,
    ScoreOperator? operator,
    Object? value,
  }) => ScoreFilter(
    evaluatorName: evaluatorName ?? this.evaluatorName,
    metric: metric ?? this.metric,
    operator: operator ?? this.operator,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreFilter &&
          runtimeType == other.runtimeType &&
          evaluatorName == other.evaluatorName &&
          metric == other.metric &&
          operator == other.operator &&
          valuesDeepEqual(value, other.value);

  @override
  int get hashCode => Object.hashAll([
    evaluatorName,
    metric,
    operator,
    valueDeepHashCode(value),
  ]);

  @override
  String toString() =>
      'ScoreFilter('
      'evaluatorName: $evaluatorName, '
      'metric: $metric, '
      'operator: $operator, '
      'value: $value)';
}

/// The ScoreFilterGroup wire payload.
@immutable
class ScoreFilterGroup {
  /// Creates a [ScoreFilterGroup].
  const ScoreFilterGroup({this.combinator, this.filters});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The filters field.
  final List<ScoreFilter>? filters;

  /// Parses a [ScoreFilterGroup] from JSON.
  factory ScoreFilterGroup.fromJson(Map<String, dynamic> json) {
    return ScoreFilterGroup(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List<Object?>)
                .map(
                  (item) => ScoreFilter.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ScoreFilterGroup copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
  }) => ScoreFilterGroup(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List<Object?>?)?.cast<ScoreFilter>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreFilterGroup &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(filters, other.filters);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(filters)]);

  @override
  String toString() =>
      'ScoreFilterGroup('
      'combinator: $combinator, '
      'filters: ${filters?.length})';
}

/// Values for ScoreOperator.
enum ScoreOperator {
  /// Represents gt.
  gt('gt'),

  /// Represents gte.
  gte('gte'),

  /// Represents lt.
  lt('lt'),

  /// Represents lte.
  lte('lte'),

  /// Represents eq.
  eq('eq'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ScoreOperator(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ScoreOperator fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The ScoreSortInput wire payload.
@immutable
final class ScoreSortInput extends EvaluationRecordSort {
  /// Creates a [ScoreSortInput].
  const ScoreSortInput({
    this.direction,
    required this.evaluatorName,
    this.metric,
  });

  /// The fixed kind discriminator.
  String get kind => 'score';

  /// The direction field.
  final SortDirection? direction;

  /// The evaluator_name field.
  final String evaluatorName;

  /// The metric field.
  final NumericScoreMetric? metric;

  /// Parses a [ScoreSortInput] from JSON.
  factory ScoreSortInput.fromJson(Map<String, dynamic> json) {
    if (json['kind'] case final value? when value != 'score') {
      throw FormatException('ScoreSortInput: unexpected kind $value');
    }
    if (json['evaluator_name'] == null) {
      throw const FormatException('ScoreSortInput: missing evaluator_name');
    }
    return ScoreSortInput(
      direction: json['direction'] == null
          ? null
          : SortDirection.fromJson(json['direction'] as String),
      evaluatorName: json['evaluator_name'] as String,
      metric: json['metric'] == null
          ? null
          : NumericScoreMetric.fromJson(json['metric'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'kind': kind,
    if (direction != null) 'direction': direction!.toJson(),
    'evaluator_name': evaluatorName,
    if (metric != null) 'metric': metric!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ScoreSortInput copyWith({
    Object? direction = unsetCopyWithValue,
    String? evaluatorName,
    Object? metric = unsetCopyWithValue,
  }) => ScoreSortInput(
    direction: direction == unsetCopyWithValue
        ? this.direction
        : direction as SortDirection?,
    evaluatorName: evaluatorName ?? this.evaluatorName,
    metric: metric == unsetCopyWithValue
        ? this.metric
        : metric as NumericScoreMetric?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreSortInput &&
          runtimeType == other.runtimeType &&
          direction == other.direction &&
          evaluatorName == other.evaluatorName &&
          metric == other.metric;

  @override
  int get hashCode => Object.hashAll([direction, evaluatorName, metric]);

  @override
  String toString() =>
      'ScoreSortInput('
      'direction: $direction, '
      'evaluatorName: $evaluatorName, '
      'metric: $metric)';
}

/// Values for SortDirection.
enum SortDirection {
  /// Represents asc.
  asc('asc'),

  /// Represents desc.
  desc('desc'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SortDirection(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SortDirection fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The SystemFilter wire payload.
@immutable
class SystemFilter {
  /// Creates a [SystemFilter].
  const SystemFilter({this.name, this.params});

  /// The name field.
  final SystemNameFilterGroup? name;

  /// The params field.
  final SystemParamFilterGroup? params;

  /// Parses a [SystemFilter] from JSON.
  factory SystemFilter.fromJson(Map<String, dynamic> json) {
    return SystemFilter(
      name: json['name'] == null
          ? null
          : SystemNameFilterGroup.fromJson(
              json['name'] as Map<String, dynamic>,
            ),
      params: json['params'] == null
          ? null
          : SystemParamFilterGroup.fromJson(
              json['params'] as Map<String, dynamic>,
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name!.toJson(),
    if (params != null) 'params': params!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  SystemFilter copyWith({
    Object? name = unsetCopyWithValue,
    Object? params = unsetCopyWithValue,
  }) => SystemFilter(
    name: name == unsetCopyWithValue
        ? this.name
        : name as SystemNameFilterGroup?,
    params: params == unsetCopyWithValue
        ? this.params
        : params as SystemParamFilterGroup?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemFilter &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          params == other.params;

  @override
  int get hashCode => Object.hashAll([name, params]);

  @override
  String toString() =>
      'SystemFilter('
      'name: $name, '
      'params: $params)';
}

/// The SystemNameFilter wire payload.
@immutable
class SystemNameFilter {
  /// Creates a [SystemNameFilter].
  const SystemNameFilter({this.operator, required this.value});

  /// The operator field.
  final ContentSearchOperator? operator;

  /// The value field.
  final String value;

  /// Parses a [SystemNameFilter] from JSON.
  factory SystemNameFilter.fromJson(Map<String, dynamic> json) {
    if (json['value'] == null) {
      throw const FormatException('SystemNameFilter: missing value');
    }
    return SystemNameFilter(
      operator: json['operator'] == null
          ? null
          : ContentSearchOperator.fromJson(json['operator'] as String),
      value: json['value'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (operator != null) 'operator': operator!.toJson(),
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  SystemNameFilter copyWith({
    Object? operator = unsetCopyWithValue,
    String? value,
  }) => SystemNameFilter(
    operator: operator == unsetCopyWithValue
        ? this.operator
        : operator as ContentSearchOperator?,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemNameFilter &&
          runtimeType == other.runtimeType &&
          operator == other.operator &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([operator, value]);

  @override
  String toString() =>
      'SystemNameFilter('
      'operator: $operator, '
      'value: $value)';
}

/// The SystemNameFilterGroup wire payload.
@immutable
class SystemNameFilterGroup {
  /// Creates a [SystemNameFilterGroup].
  const SystemNameFilterGroup({this.combinator, this.filters});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The filters field.
  final List<SystemNameFilter>? filters;

  /// Parses a [SystemNameFilterGroup] from JSON.
  factory SystemNameFilterGroup.fromJson(Map<String, dynamic> json) {
    return SystemNameFilterGroup(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List<Object?>)
                .map(
                  (item) =>
                      SystemNameFilter.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  SystemNameFilterGroup copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
  }) => SystemNameFilterGroup(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List<Object?>?)?.cast<SystemNameFilter>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemNameFilterGroup &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(filters, other.filters);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(filters)]);

  @override
  String toString() =>
      'SystemNameFilterGroup('
      'combinator: $combinator, '
      'filters: ${filters?.length})';
}

/// The SystemParamFilter wire payload.
@immutable
class SystemParamFilter {
  /// Creates a [SystemParamFilter].
  const SystemParamFilter({
    required this.key,
    required this.operator,
    required this.value,
  });

  /// The key field.
  final String key;

  /// The operator field.
  final SystemParamOperator operator;

  /// The value field.
  final Object value;

  /// Parses a [SystemParamFilter] from JSON.
  factory SystemParamFilter.fromJson(Map<String, dynamic> json) {
    if (json['key'] == null) {
      throw const FormatException('SystemParamFilter: missing key');
    }
    if (json['operator'] == null) {
      throw const FormatException('SystemParamFilter: missing operator');
    }
    if (json['value'] == null) {
      throw const FormatException('SystemParamFilter: missing value');
    }
    return SystemParamFilter(
      key: json['key'] as String,
      operator: SystemParamOperator.fromJson(json['operator'] as String),
      value: json['value'] as Object,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'key': key,
    'operator': operator.toJson(),
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  SystemParamFilter copyWith({
    String? key,
    SystemParamOperator? operator,
    Object? value,
  }) => SystemParamFilter(
    key: key ?? this.key,
    operator: operator ?? this.operator,
    value: value ?? this.value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemParamFilter &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          operator == other.operator &&
          valuesDeepEqual(value, other.value);

  @override
  int get hashCode => Object.hashAll([key, operator, valueDeepHashCode(value)]);

  @override
  String toString() =>
      'SystemParamFilter('
      'key: $key, '
      'operator: $operator, '
      'value: $value)';
}

/// The SystemParamFilterGroup wire payload.
@immutable
class SystemParamFilterGroup {
  /// Creates a [SystemParamFilterGroup].
  const SystemParamFilterGroup({this.combinator, this.filters});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The filters field.
  final List<SystemParamFilter>? filters;

  /// Parses a [SystemParamFilterGroup] from JSON.
  factory SystemParamFilterGroup.fromJson(Map<String, dynamic> json) {
    return SystemParamFilterGroup(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      filters: json['filters'] == null
          ? null
          : (json['filters'] as List<Object?>)
                .map(
                  (item) =>
                      SystemParamFilter.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    if (filters != null)
      'filters': filters!.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  SystemParamFilterGroup copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? filters = unsetCopyWithValue,
  }) => SystemParamFilterGroup(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    filters: filters == unsetCopyWithValue
        ? this.filters
        : (filters as List<Object?>?)?.cast<SystemParamFilter>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemParamFilterGroup &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(filters, other.filters);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(filters)]);

  @override
  String toString() =>
      'SystemParamFilterGroup('
      'combinator: $combinator, '
      'filters: ${filters?.length})';
}

/// Values for SystemParamOperator.
enum SystemParamOperator {
  /// Represents eq.
  eq('eq'),

  /// Represents contains.
  contains('contains'),

  /// Represents gt.
  gt('gt'),

  /// Represents gte.
  gte('gte'),

  /// Represents lt.
  lt('lt'),

  /// Represents lte.
  lte('lte'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SystemParamOperator(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SystemParamOperator fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The TagFilter wire payload.
@immutable
class TagFilter {
  /// Creates a [TagFilter].
  const TagFilter({this.combinator, this.values});

  /// The combinator field.
  final FilterCombinator? combinator;

  /// The values field.
  final List<String>? values;

  /// Parses a [TagFilter] from JSON.
  factory TagFilter.fromJson(Map<String, dynamic> json) {
    return TagFilter(
      combinator: json['combinator'] == null
          ? null
          : FilterCombinator.fromJson(json['combinator'] as String),
      values: json['values'] == null
          ? null
          : (json['values'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (combinator != null) 'combinator': combinator!.toJson(),
    'values': ?values,
  };

  /// Creates a copy with the given fields replaced.
  TagFilter copyWith({
    Object? combinator = unsetCopyWithValue,
    Object? values = unsetCopyWithValue,
  }) => TagFilter(
    combinator: combinator == unsetCopyWithValue
        ? this.combinator
        : combinator as FilterCombinator?,
    values: values == unsetCopyWithValue
        ? this.values
        : (values as List<Object?>?)?.cast<String>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagFilter &&
          runtimeType == other.runtimeType &&
          combinator == other.combinator &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode => Object.hashAll([combinator, valueDeepHashCode(values)]);

  @override
  String toString() =>
      'TagFilter('
      'combinator: $combinator, '
      'values: ${values?.length})';
}

/// A variant of [EvaluationRecordSort] returned or accepted by Observability.
sealed class EvaluationRecordSort {
  const EvaluationRecordSort();

  /// Decodes a variant from its API representation.
  factory EvaluationRecordSort.fromJson(Map<String, dynamic> json) =>
      switch (json['kind']) {
        'field' => FieldSortInput.fromJson(json),
        'score' => ScoreSortInput.fromJson(json),
        _ => UnknownEvaluationRecordSort(json),
      };

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A server variant of [EvaluationRecordSort] unknown to this client.
@immutable
final class UnknownEvaluationRecordSort extends EvaluationRecordSort {
  /// Retains the original payload.
  UnknownEvaluationRecordSort(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The unrecognized payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownEvaluationRecordSort && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}
