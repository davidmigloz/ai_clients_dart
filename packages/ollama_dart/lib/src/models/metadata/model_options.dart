import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/stop_sequence.dart';

/// Runtime options that control text generation.
@immutable
class ModelOptions {
  // ===========================================================================
  // Sampling parameters
  // ===========================================================================

  /// Random seed used for reproducible outputs.
  final int? seed;

  /// Controls randomness in generation (higher = more random).
  final double? temperature;

  /// Limits next token selection to the K most likely.
  final int? topK;

  /// Cumulative probability threshold for nucleus sampling.
  final double? topP;

  /// Minimum probability threshold for token selection.
  final double? minP;

  /// Tail free sampling parameter.
  ///
  /// Reduces the impact of less probable tokens (1.0 = disabled).
  final double? tfsZ;

  /// Typical P sampling parameter.
  ///
  /// Selects tokens based on "typicality" rather than probability.
  final double? typicalP;

  /// Number of tokens to look back for repeat penalty.
  final int? repeatLastN;

  /// Penalty for repeating tokens (1.0 = no penalty).
  final double? repeatPenalty;

  /// Penalty for tokens that have appeared at all.
  final double? presencePenalty;

  /// Penalty for tokens based on how often they have appeared.
  final double? frequencyPenalty;

  /// Mirostat sampling mode (0 = disabled, 1 = mirostat, 2 = mirostat 2.0).
  final int? mirostat;

  /// Mirostat target entropy.
  final double? mirostatTau;

  /// Mirostat learning rate.
  final double? mirostatEta;

  /// Whether to penalize newlines.
  final bool? penalizeNewline;

  /// Stop sequences that will halt generation.
  ///
  /// Can be a single string or a list of strings.
  final StopSequence? stop;

  // ===========================================================================
  // Context and output parameters
  // ===========================================================================

  /// Context length size (number of tokens).
  final int? numCtx;

  /// Maximum number of tokens to generate.
  final int? numPredict;

  /// Number of tokens to keep from the initial prompt.
  final int? numKeep;

  // ===========================================================================
  // Runtime and GPU parameters
  // ===========================================================================

  /// Enable NUMA (Non-Uniform Memory Access) optimization.
  final bool? numa;

  /// Batch size for prompt processing.
  final int? numBatch;

  /// Number of layers to offload to GPU.
  ///
  /// Use 0 for CPU-only, or a large number (e.g., 999) to offload all layers.
  final int? numGpu;

  /// Index of the primary GPU to use (for multi-GPU systems).
  final int? mainGpu;

  /// Enable low VRAM mode for limited GPU memory.
  final bool? lowVram;

  /// Number of CPU threads to use.
  ///
  /// Optimal value is typically the number of physical CPU cores.
  final int? numThread;

  // ===========================================================================
  // Memory and model loading parameters
  // ===========================================================================

  /// Use 16-bit floats for KV cache (reduces memory usage).
  final bool? f16Kv;

  /// Return logits for all tokens, not just the last one.
  final bool? logitsAll;

  /// Only load the vocabulary, not the model weights.
  final bool? vocabOnly;

  /// Use memory mapping to load the model.
  final bool? useMmap;

  /// Lock the model in memory to prevent swapping.
  final bool? useMlock;

  /// Creates a [ModelOptions].
  const ModelOptions({
    // Sampling
    this.seed,
    this.temperature,
    this.topK,
    this.topP,
    this.minP,
    this.tfsZ,
    this.typicalP,
    this.repeatLastN,
    this.repeatPenalty,
    this.presencePenalty,
    this.frequencyPenalty,
    this.mirostat,
    this.mirostatTau,
    this.mirostatEta,
    this.penalizeNewline,
    this.stop,
    // Context and output
    this.numCtx,
    this.numPredict,
    this.numKeep,
    // Runtime and GPU
    this.numa,
    this.numBatch,
    this.numGpu,
    this.mainGpu,
    this.lowVram,
    this.numThread,
    // Memory and loading
    this.f16Kv,
    this.logitsAll,
    this.vocabOnly,
    this.useMmap,
    this.useMlock,
  });

  /// Creates a [ModelOptions] from JSON.
  factory ModelOptions.fromJson(Map<String, dynamic> json) => ModelOptions(
    // Sampling
    seed: json['seed'] as int?,
    temperature: (json['temperature'] as num?)?.toDouble(),
    topK: json['top_k'] as int?,
    topP: (json['top_p'] as num?)?.toDouble(),
    minP: (json['min_p'] as num?)?.toDouble(),
    tfsZ: (json['tfs_z'] as num?)?.toDouble(),
    typicalP: (json['typical_p'] as num?)?.toDouble(),
    repeatLastN: json['repeat_last_n'] as int?,
    repeatPenalty: (json['repeat_penalty'] as num?)?.toDouble(),
    presencePenalty: (json['presence_penalty'] as num?)?.toDouble(),
    frequencyPenalty: (json['frequency_penalty'] as num?)?.toDouble(),
    mirostat: json['mirostat'] as int?,
    mirostatTau: (json['mirostat_tau'] as num?)?.toDouble(),
    mirostatEta: (json['mirostat_eta'] as num?)?.toDouble(),
    penalizeNewline: json['penalize_newline'] as bool?,
    stop: StopSequence.fromJson(json['stop']),
    // Context and output
    numCtx: json['num_ctx'] as int?,
    numPredict: json['num_predict'] as int?,
    numKeep: json['num_keep'] as int?,
    // Runtime and GPU
    numa: json['numa'] as bool?,
    numBatch: json['num_batch'] as int?,
    numGpu: json['num_gpu'] as int?,
    mainGpu: json['main_gpu'] as int?,
    lowVram: json['low_vram'] as bool?,
    numThread: json['num_thread'] as int?,
    // Memory and loading
    f16Kv: json['f16_kv'] as bool?,
    logitsAll: json['logits_all'] as bool?,
    vocabOnly: json['vocab_only'] as bool?,
    useMmap: json['use_mmap'] as bool?,
    useMlock: json['use_mlock'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    // Sampling
    if (seed != null) 'seed': seed,
    if (temperature != null) 'temperature': temperature,
    if (topK != null) 'top_k': topK,
    if (topP != null) 'top_p': topP,
    if (minP != null) 'min_p': minP,
    if (tfsZ != null) 'tfs_z': tfsZ,
    if (typicalP != null) 'typical_p': typicalP,
    if (repeatLastN != null) 'repeat_last_n': repeatLastN,
    if (repeatPenalty != null) 'repeat_penalty': repeatPenalty,
    if (presencePenalty != null) 'presence_penalty': presencePenalty,
    if (frequencyPenalty != null) 'frequency_penalty': frequencyPenalty,
    if (mirostat != null) 'mirostat': mirostat,
    if (mirostatTau != null) 'mirostat_tau': mirostatTau,
    if (mirostatEta != null) 'mirostat_eta': mirostatEta,
    if (penalizeNewline != null) 'penalize_newline': penalizeNewline,
    if (stop != null) 'stop': stop!.toJson(),
    // Context and output
    if (numCtx != null) 'num_ctx': numCtx,
    if (numPredict != null) 'num_predict': numPredict,
    if (numKeep != null) 'num_keep': numKeep,
    // Runtime and GPU
    if (numa != null) 'numa': numa,
    if (numBatch != null) 'num_batch': numBatch,
    if (numGpu != null) 'num_gpu': numGpu,
    if (mainGpu != null) 'main_gpu': mainGpu,
    if (lowVram != null) 'low_vram': lowVram,
    if (numThread != null) 'num_thread': numThread,
    // Memory and loading
    if (f16Kv != null) 'f16_kv': f16Kv,
    if (logitsAll != null) 'logits_all': logitsAll,
    if (vocabOnly != null) 'vocab_only': vocabOnly,
    if (useMmap != null) 'use_mmap': useMmap,
    if (useMlock != null) 'use_mlock': useMlock,
  };

  /// Creates a copy with replaced values.
  ModelOptions copyWith({
    // Sampling
    Object? seed = unsetCopyWithValue,
    Object? temperature = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
    Object? topP = unsetCopyWithValue,
    Object? minP = unsetCopyWithValue,
    Object? tfsZ = unsetCopyWithValue,
    Object? typicalP = unsetCopyWithValue,
    Object? repeatLastN = unsetCopyWithValue,
    Object? repeatPenalty = unsetCopyWithValue,
    Object? presencePenalty = unsetCopyWithValue,
    Object? frequencyPenalty = unsetCopyWithValue,
    Object? mirostat = unsetCopyWithValue,
    Object? mirostatTau = unsetCopyWithValue,
    Object? mirostatEta = unsetCopyWithValue,
    Object? penalizeNewline = unsetCopyWithValue,
    Object? stop = unsetCopyWithValue,
    // Context and output
    Object? numCtx = unsetCopyWithValue,
    Object? numPredict = unsetCopyWithValue,
    Object? numKeep = unsetCopyWithValue,
    // Runtime and GPU
    Object? numa = unsetCopyWithValue,
    Object? numBatch = unsetCopyWithValue,
    Object? numGpu = unsetCopyWithValue,
    Object? mainGpu = unsetCopyWithValue,
    Object? lowVram = unsetCopyWithValue,
    Object? numThread = unsetCopyWithValue,
    // Memory and loading
    Object? f16Kv = unsetCopyWithValue,
    Object? logitsAll = unsetCopyWithValue,
    Object? vocabOnly = unsetCopyWithValue,
    Object? useMmap = unsetCopyWithValue,
    Object? useMlock = unsetCopyWithValue,
  }) {
    return ModelOptions(
      // Sampling
      seed: seed == unsetCopyWithValue ? this.seed : seed as int?,
      temperature: temperature == unsetCopyWithValue
          ? this.temperature
          : temperature as double?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
      topP: topP == unsetCopyWithValue ? this.topP : topP as double?,
      minP: minP == unsetCopyWithValue ? this.minP : minP as double?,
      tfsZ: tfsZ == unsetCopyWithValue ? this.tfsZ : tfsZ as double?,
      typicalP: typicalP == unsetCopyWithValue
          ? this.typicalP
          : typicalP as double?,
      repeatLastN: repeatLastN == unsetCopyWithValue
          ? this.repeatLastN
          : repeatLastN as int?,
      repeatPenalty: repeatPenalty == unsetCopyWithValue
          ? this.repeatPenalty
          : repeatPenalty as double?,
      presencePenalty: presencePenalty == unsetCopyWithValue
          ? this.presencePenalty
          : presencePenalty as double?,
      frequencyPenalty: frequencyPenalty == unsetCopyWithValue
          ? this.frequencyPenalty
          : frequencyPenalty as double?,
      mirostat: mirostat == unsetCopyWithValue
          ? this.mirostat
          : mirostat as int?,
      mirostatTau: mirostatTau == unsetCopyWithValue
          ? this.mirostatTau
          : mirostatTau as double?,
      mirostatEta: mirostatEta == unsetCopyWithValue
          ? this.mirostatEta
          : mirostatEta as double?,
      penalizeNewline: penalizeNewline == unsetCopyWithValue
          ? this.penalizeNewline
          : penalizeNewline as bool?,
      stop: stop == unsetCopyWithValue ? this.stop : stop as StopSequence?,
      // Context and output
      numCtx: numCtx == unsetCopyWithValue ? this.numCtx : numCtx as int?,
      numPredict: numPredict == unsetCopyWithValue
          ? this.numPredict
          : numPredict as int?,
      numKeep: numKeep == unsetCopyWithValue ? this.numKeep : numKeep as int?,
      // Runtime and GPU
      numa: numa == unsetCopyWithValue ? this.numa : numa as bool?,
      numBatch: numBatch == unsetCopyWithValue
          ? this.numBatch
          : numBatch as int?,
      numGpu: numGpu == unsetCopyWithValue ? this.numGpu : numGpu as int?,
      mainGpu: mainGpu == unsetCopyWithValue ? this.mainGpu : mainGpu as int?,
      lowVram: lowVram == unsetCopyWithValue ? this.lowVram : lowVram as bool?,
      numThread: numThread == unsetCopyWithValue
          ? this.numThread
          : numThread as int?,
      // Memory and loading
      f16Kv: f16Kv == unsetCopyWithValue ? this.f16Kv : f16Kv as bool?,
      logitsAll: logitsAll == unsetCopyWithValue
          ? this.logitsAll
          : logitsAll as bool?,
      vocabOnly: vocabOnly == unsetCopyWithValue
          ? this.vocabOnly
          : vocabOnly as bool?,
      useMmap: useMmap == unsetCopyWithValue ? this.useMmap : useMmap as bool?,
      useMlock: useMlock == unsetCopyWithValue
          ? this.useMlock
          : useMlock as bool?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModelOptions &&
          runtimeType == other.runtimeType &&
          seed == other.seed &&
          temperature == other.temperature &&
          topK == other.topK &&
          topP == other.topP &&
          minP == other.minP &&
          tfsZ == other.tfsZ &&
          typicalP == other.typicalP &&
          repeatLastN == other.repeatLastN &&
          repeatPenalty == other.repeatPenalty &&
          presencePenalty == other.presencePenalty &&
          frequencyPenalty == other.frequencyPenalty &&
          mirostat == other.mirostat &&
          mirostatTau == other.mirostatTau &&
          mirostatEta == other.mirostatEta &&
          penalizeNewline == other.penalizeNewline &&
          stop == other.stop &&
          numCtx == other.numCtx &&
          numPredict == other.numPredict &&
          numKeep == other.numKeep &&
          numa == other.numa &&
          numBatch == other.numBatch &&
          numGpu == other.numGpu &&
          mainGpu == other.mainGpu &&
          lowVram == other.lowVram &&
          numThread == other.numThread &&
          f16Kv == other.f16Kv &&
          logitsAll == other.logitsAll &&
          vocabOnly == other.vocabOnly &&
          useMmap == other.useMmap &&
          useMlock == other.useMlock;

  @override
  int get hashCode => Object.hashAll([
    seed,
    temperature,
    topK,
    topP,
    minP,
    tfsZ,
    typicalP,
    repeatLastN,
    repeatPenalty,
    presencePenalty,
    frequencyPenalty,
    mirostat,
    mirostatTau,
    mirostatEta,
    penalizeNewline,
    stop,
    numCtx,
    numPredict,
    numKeep,
    numa,
    numBatch,
    numGpu,
    mainGpu,
    lowVram,
    numThread,
    f16Kv,
    logitsAll,
    vocabOnly,
    useMmap,
    useMlock,
  ]);

  @override
  String toString() =>
      'ModelOptions('
      'seed: $seed, '
      'temperature: $temperature, '
      'topK: $topK, '
      'topP: $topP, '
      'minP: $minP, '
      'tfsZ: $tfsZ, '
      'typicalP: $typicalP, '
      'repeatLastN: $repeatLastN, '
      'repeatPenalty: $repeatPenalty, '
      'presencePenalty: $presencePenalty, '
      'frequencyPenalty: $frequencyPenalty, '
      'mirostat: $mirostat, '
      'mirostatTau: $mirostatTau, '
      'mirostatEta: $mirostatEta, '
      'penalizeNewline: $penalizeNewline, '
      'stop: $stop, '
      'numCtx: $numCtx, '
      'numPredict: $numPredict, '
      'numKeep: $numKeep, '
      'numa: $numa, '
      'numBatch: $numBatch, '
      'numGpu: $numGpu, '
      'mainGpu: $mainGpu, '
      'lowVram: $lowVram, '
      'numThread: $numThread, '
      'f16Kv: $f16Kv, '
      'logitsAll: $logitsAll, '
      'vocabOnly: $vocabOnly, '
      'useMmap: $useMmap, '
      'useMlock: $useMlock)';
}
