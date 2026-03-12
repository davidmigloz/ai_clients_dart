import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import 'quantization.dart';

/// Configuration for SPANN vector index algorithm parameters.
///
/// All fields are optional — only specified parameters will be sent
/// to the server, allowing partial configuration updates.
@immutable
class SpannIndexConfig {
  /// Drift threshold for center recalculation.
  final double? centerDriftThreshold;

  /// Number of neighbors to consider during construction.
  final int? efConstruction;

  /// Number of neighbors to consider during search.
  final int? efSearch;

  /// Initial lambda value for the index.
  final double? initialLambda;

  /// Maximum number of neighbors per node.
  final int? maxNeighbors;

  /// Threshold for merging centers.
  final int? mergeThreshold;

  /// Number of replicas for each center.
  final int? nreplicaCount;

  /// Number of centers to merge to during optimization.
  final int? numCentersToMergeTo;

  /// Number of samples for k-means clustering.
  final int? numSamplesKmeans;

  /// Quantization implementation for vector search (cloud-only feature).
  final Quantization? quantize;

  /// Number of neighbors to consider during reassignment.
  final int? reassignNeighborCount;

  /// Number of probes during search.
  final int? searchNprobe;

  /// Epsilon value for range search.
  final double? searchRngEpsilon;

  /// Factor for range search.
  final double? searchRngFactor;

  /// Threshold for splitting centers.
  final int? splitThreshold;

  /// Number of probes during write.
  final int? writeNprobe;

  /// Epsilon value for write range.
  final double? writeRngEpsilon;

  /// Factor for write range.
  final double? writeRngFactor;

  /// Creates a SPANN index config.
  const SpannIndexConfig({
    this.centerDriftThreshold,
    this.efConstruction,
    this.efSearch,
    this.initialLambda,
    this.maxNeighbors,
    this.mergeThreshold,
    this.nreplicaCount,
    this.numCentersToMergeTo,
    this.numSamplesKmeans,
    this.quantize,
    this.reassignNeighborCount,
    this.searchNprobe,
    this.searchRngEpsilon,
    this.searchRngFactor,
    this.splitThreshold,
    this.writeNprobe,
    this.writeRngEpsilon,
    this.writeRngFactor,
  });

  /// Creates a SPANN index config from JSON.
  factory SpannIndexConfig.fromJson(Map<String, dynamic> json) {
    return SpannIndexConfig(
      centerDriftThreshold: (json['center_drift_threshold'] as num?)
          ?.toDouble(),
      efConstruction: json['ef_construction'] as int?,
      efSearch: json['ef_search'] as int?,
      initialLambda: (json['initial_lambda'] as num?)?.toDouble(),
      maxNeighbors: json['max_neighbors'] as int?,
      mergeThreshold: json['merge_threshold'] as int?,
      nreplicaCount: json['nreplica_count'] as int?,
      numCentersToMergeTo: json['num_centers_to_merge_to'] as int?,
      numSamplesKmeans: json['num_samples_kmeans'] as int?,
      quantize: json['quantize'] != null
          ? Quantization.fromJson(json['quantize'] as String)
          : null,
      reassignNeighborCount: json['reassign_neighbor_count'] as int?,
      searchNprobe: json['search_nprobe'] as int?,
      searchRngEpsilon: (json['search_rng_epsilon'] as num?)?.toDouble(),
      searchRngFactor: (json['search_rng_factor'] as num?)?.toDouble(),
      splitThreshold: json['split_threshold'] as int?,
      writeNprobe: json['write_nprobe'] as int?,
      writeRngEpsilon: (json['write_rng_epsilon'] as num?)?.toDouble(),
      writeRngFactor: (json['write_rng_factor'] as num?)?.toDouble(),
    );
  }

  /// Converts this config to JSON.
  Map<String, dynamic> toJson() {
    return {
      'center_drift_threshold': ?centerDriftThreshold,
      'ef_construction': ?efConstruction,
      'ef_search': ?efSearch,
      'initial_lambda': ?initialLambda,
      'max_neighbors': ?maxNeighbors,
      'merge_threshold': ?mergeThreshold,
      'nreplica_count': ?nreplicaCount,
      'num_centers_to_merge_to': ?numCentersToMergeTo,
      'num_samples_kmeans': ?numSamplesKmeans,
      if (quantize != null) 'quantize': quantize!.toJson(),
      'reassign_neighbor_count': ?reassignNeighborCount,
      'search_nprobe': ?searchNprobe,
      'search_rng_epsilon': ?searchRngEpsilon,
      'search_rng_factor': ?searchRngFactor,
      'split_threshold': ?splitThreshold,
      'write_nprobe': ?writeNprobe,
      'write_rng_epsilon': ?writeRngEpsilon,
      'write_rng_factor': ?writeRngFactor,
    };
  }

  /// Creates a copy with replaced values.
  SpannIndexConfig copyWith({
    Object? centerDriftThreshold = unsetCopyWithValue,
    Object? efConstruction = unsetCopyWithValue,
    Object? efSearch = unsetCopyWithValue,
    Object? initialLambda = unsetCopyWithValue,
    Object? maxNeighbors = unsetCopyWithValue,
    Object? mergeThreshold = unsetCopyWithValue,
    Object? nreplicaCount = unsetCopyWithValue,
    Object? numCentersToMergeTo = unsetCopyWithValue,
    Object? numSamplesKmeans = unsetCopyWithValue,
    Object? quantize = unsetCopyWithValue,
    Object? reassignNeighborCount = unsetCopyWithValue,
    Object? searchNprobe = unsetCopyWithValue,
    Object? searchRngEpsilon = unsetCopyWithValue,
    Object? searchRngFactor = unsetCopyWithValue,
    Object? splitThreshold = unsetCopyWithValue,
    Object? writeNprobe = unsetCopyWithValue,
    Object? writeRngEpsilon = unsetCopyWithValue,
    Object? writeRngFactor = unsetCopyWithValue,
  }) {
    return SpannIndexConfig(
      centerDriftThreshold: centerDriftThreshold == unsetCopyWithValue
          ? this.centerDriftThreshold
          : centerDriftThreshold as double?,
      efConstruction: efConstruction == unsetCopyWithValue
          ? this.efConstruction
          : efConstruction as int?,
      efSearch: efSearch == unsetCopyWithValue
          ? this.efSearch
          : efSearch as int?,
      initialLambda: initialLambda == unsetCopyWithValue
          ? this.initialLambda
          : initialLambda as double?,
      maxNeighbors: maxNeighbors == unsetCopyWithValue
          ? this.maxNeighbors
          : maxNeighbors as int?,
      mergeThreshold: mergeThreshold == unsetCopyWithValue
          ? this.mergeThreshold
          : mergeThreshold as int?,
      nreplicaCount: nreplicaCount == unsetCopyWithValue
          ? this.nreplicaCount
          : nreplicaCount as int?,
      numCentersToMergeTo: numCentersToMergeTo == unsetCopyWithValue
          ? this.numCentersToMergeTo
          : numCentersToMergeTo as int?,
      numSamplesKmeans: numSamplesKmeans == unsetCopyWithValue
          ? this.numSamplesKmeans
          : numSamplesKmeans as int?,
      quantize: quantize == unsetCopyWithValue
          ? this.quantize
          : quantize as Quantization?,
      reassignNeighborCount: reassignNeighborCount == unsetCopyWithValue
          ? this.reassignNeighborCount
          : reassignNeighborCount as int?,
      searchNprobe: searchNprobe == unsetCopyWithValue
          ? this.searchNprobe
          : searchNprobe as int?,
      searchRngEpsilon: searchRngEpsilon == unsetCopyWithValue
          ? this.searchRngEpsilon
          : searchRngEpsilon as double?,
      searchRngFactor: searchRngFactor == unsetCopyWithValue
          ? this.searchRngFactor
          : searchRngFactor as double?,
      splitThreshold: splitThreshold == unsetCopyWithValue
          ? this.splitThreshold
          : splitThreshold as int?,
      writeNprobe: writeNprobe == unsetCopyWithValue
          ? this.writeNprobe
          : writeNprobe as int?,
      writeRngEpsilon: writeRngEpsilon == unsetCopyWithValue
          ? this.writeRngEpsilon
          : writeRngEpsilon as double?,
      writeRngFactor: writeRngFactor == unsetCopyWithValue
          ? this.writeRngFactor
          : writeRngFactor as double?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpannIndexConfig &&
          runtimeType == other.runtimeType &&
          centerDriftThreshold == other.centerDriftThreshold &&
          efConstruction == other.efConstruction &&
          efSearch == other.efSearch &&
          initialLambda == other.initialLambda &&
          maxNeighbors == other.maxNeighbors &&
          mergeThreshold == other.mergeThreshold &&
          nreplicaCount == other.nreplicaCount &&
          numCentersToMergeTo == other.numCentersToMergeTo &&
          numSamplesKmeans == other.numSamplesKmeans &&
          quantize == other.quantize &&
          reassignNeighborCount == other.reassignNeighborCount &&
          searchNprobe == other.searchNprobe &&
          searchRngEpsilon == other.searchRngEpsilon &&
          searchRngFactor == other.searchRngFactor &&
          splitThreshold == other.splitThreshold &&
          writeNprobe == other.writeNprobe &&
          writeRngEpsilon == other.writeRngEpsilon &&
          writeRngFactor == other.writeRngFactor;

  @override
  int get hashCode => Object.hash(
    centerDriftThreshold,
    efConstruction,
    efSearch,
    initialLambda,
    maxNeighbors,
    mergeThreshold,
    nreplicaCount,
    numCentersToMergeTo,
    numSamplesKmeans,
    quantize,
    reassignNeighborCount,
    searchNprobe,
    searchRngEpsilon,
    searchRngFactor,
    splitThreshold,
    writeNprobe,
    writeRngEpsilon,
    writeRngFactor,
  );

  @override
  String toString() =>
      'SpannIndexConfig('
      'centerDriftThreshold: $centerDriftThreshold, '
      'efConstruction: $efConstruction, '
      'efSearch: $efSearch, '
      'initialLambda: $initialLambda, '
      'maxNeighbors: $maxNeighbors, '
      'mergeThreshold: $mergeThreshold, '
      'nreplicaCount: $nreplicaCount, '
      'numCentersToMergeTo: $numCentersToMergeTo, '
      'numSamplesKmeans: $numSamplesKmeans, '
      'quantize: $quantize, '
      'reassignNeighborCount: $reassignNeighborCount, '
      'searchNprobe: $searchNprobe, '
      'searchRngEpsilon: $searchRngEpsilon, '
      'searchRngFactor: $searchRngFactor, '
      'splitThreshold: $splitThreshold, '
      'writeNprobe: $writeNprobe, '
      'writeRngEpsilon: $writeRngEpsilon, '
      'writeRngFactor: $writeRngFactor)';
}
