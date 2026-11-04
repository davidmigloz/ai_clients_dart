import 'admin_enums.dart';
import 'admin_json.dart';

/// The aggregated Decisions API usage details of the specific time bucket.
final class DecisionsUsageResult extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  DecisionsUsageResult({
    this.apiSource,
    bool hasApiSource = false,
    required this.inputTokens,
    this.inputCachedTokens,
    bool hasInputCachedTokens = false,
    this.inputCacheWriteTokens,
    bool hasInputCacheWriteTokens = false,
    this.inputCacheWrite30mTokens,
    bool hasInputCacheWrite30mTokens = false,
    this.inputCacheWrite12hTokens,
    bool hasInputCacheWrite12hTokens = false,
    this.inputUncachedTokens,
    bool hasInputUncachedTokens = false,
    required this.outputTokens,
    this.inputTextTokens,
    bool hasInputTextTokens = false,
    this.outputTextTokens,
    bool hasOutputTextTokens = false,
    this.inputCachedTextTokens,
    bool hasInputCachedTextTokens = false,
    this.inputAudioTokens,
    bool hasInputAudioTokens = false,
    this.inputCachedAudioTokens,
    bool hasInputCachedAudioTokens = false,
    this.outputAudioTokens,
    bool hasOutputAudioTokens = false,
    this.inputImageTokens,
    bool hasInputImageTokens = false,
    this.inputCachedImageTokens,
    bool hasInputCachedImageTokens = false,
    this.outputImageTokens,
    bool hasOutputImageTokens = false,
    required this.numModelRequests,
    this.projectId,
    bool hasProjectId = false,
    this.userId,
    bool hasUserId = false,
    this.apiKeyId,
    bool hasApiKeyId = false,
    this.model,
    bool hasModel = false,
    this.batch,
    bool hasBatch = false,
    this.serviceTier,
    bool hasServiceTier = false,
    Map<String, dynamic> rawJson = const {},
  }) : hasApiSource = hasApiSource || apiSource != null,
       hasInputCachedTokens = hasInputCachedTokens || inputCachedTokens != null,
       hasInputCacheWriteTokens =
           hasInputCacheWriteTokens || inputCacheWriteTokens != null,
       hasInputCacheWrite30mTokens =
           hasInputCacheWrite30mTokens || inputCacheWrite30mTokens != null,
       hasInputCacheWrite12hTokens =
           hasInputCacheWrite12hTokens || inputCacheWrite12hTokens != null,
       hasInputUncachedTokens =
           hasInputUncachedTokens || inputUncachedTokens != null,
       hasInputTextTokens = hasInputTextTokens || inputTextTokens != null,
       hasOutputTextTokens = hasOutputTextTokens || outputTextTokens != null,
       hasInputCachedTextTokens =
           hasInputCachedTextTokens || inputCachedTextTokens != null,
       hasInputAudioTokens = hasInputAudioTokens || inputAudioTokens != null,
       hasInputCachedAudioTokens =
           hasInputCachedAudioTokens || inputCachedAudioTokens != null,
       hasOutputAudioTokens = hasOutputAudioTokens || outputAudioTokens != null,
       hasInputImageTokens = hasInputImageTokens || inputImageTokens != null,
       hasInputCachedImageTokens =
           hasInputCachedImageTokens || inputCachedImageTokens != null,
       hasOutputImageTokens = hasOutputImageTokens || outputImageTokens != null,
       hasProjectId = hasProjectId || projectId != null,
       hasUserId = hasUserId || userId != null,
       hasApiKeyId = hasApiKeyId || apiKeyId != null,
       hasModel = hasModel || model != null,
       hasBatch = hasBatch || batch != null,
       hasServiceTier = hasServiceTier || serviceTier != null,
       rawJson = adminExtras(rawJson, {
         'api_source',
         'object',
         'input_tokens',
         'input_cached_tokens',
         'input_cache_write_tokens',
         'input_cache_write_30m_tokens',
         'input_cache_write_12h_tokens',
         'input_uncached_tokens',
         'output_tokens',
         'input_text_tokens',
         'output_text_tokens',
         'input_cached_text_tokens',
         'input_audio_tokens',
         'input_cached_audio_tokens',
         'output_audio_tokens',
         'input_image_tokens',
         'input_cached_image_tokens',
         'output_image_tokens',
         'num_model_requests',
         'project_id',
         'user_id',
         'api_key_id',
         'model',
         'batch',
         'service_tier',
       }, 'DecisionsUsageResult') {
    validate();
  }

  /// Exact `api_source` wire value.
  final DecisionsUsageApiSource? apiSource;

  /// Whether the optional nullable member is present, including null.
  final bool hasApiSource;

  /// Exact `input_tokens` wire value.
  final int inputTokens;

  /// Exact `input_cached_tokens` wire value.
  final int? inputCachedTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCachedTokens;

  /// Exact `input_cache_write_tokens` wire value.
  final int? inputCacheWriteTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCacheWriteTokens;

  /// Exact `input_cache_write_30m_tokens` wire value.
  final int? inputCacheWrite30mTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCacheWrite30mTokens;

  /// Exact `input_cache_write_12h_tokens` wire value.
  final int? inputCacheWrite12hTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCacheWrite12hTokens;

  /// Exact `input_uncached_tokens` wire value.
  final int? inputUncachedTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputUncachedTokens;

  /// Exact `output_tokens` wire value.
  final int outputTokens;

  /// Exact `input_text_tokens` wire value.
  final int? inputTextTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputTextTokens;

  /// Exact `output_text_tokens` wire value.
  final int? outputTextTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasOutputTextTokens;

  /// Exact `input_cached_text_tokens` wire value.
  final int? inputCachedTextTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCachedTextTokens;

  /// Exact `input_audio_tokens` wire value.
  final int? inputAudioTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputAudioTokens;

  /// Exact `input_cached_audio_tokens` wire value.
  final int? inputCachedAudioTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCachedAudioTokens;

  /// Exact `output_audio_tokens` wire value.
  final int? outputAudioTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasOutputAudioTokens;

  /// Exact `input_image_tokens` wire value.
  final int? inputImageTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputImageTokens;

  /// Exact `input_cached_image_tokens` wire value.
  final int? inputCachedImageTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasInputCachedImageTokens;

  /// Exact `output_image_tokens` wire value.
  final int? outputImageTokens;

  /// Whether the optional nullable member is present, including null.
  final bool hasOutputImageTokens;

  /// Exact `num_model_requests` wire value.
  final int numModelRequests;

  /// Exact `project_id` wire value.
  final String? projectId;

  /// Whether the optional nullable member is present, including null.
  final bool hasProjectId;

  /// Exact `user_id` wire value.
  final String? userId;

  /// Whether the optional nullable member is present, including null.
  final bool hasUserId;

  /// Exact `api_key_id` wire value.
  final String? apiKeyId;

  /// Whether the optional nullable member is present, including null.
  final bool hasApiKeyId;

  /// Exact `model` wire value.
  final String? model;

  /// Whether the optional nullable member is present, including null.
  final bool hasModel;

  /// Exact `batch` wire value.
  final bool? batch;

  /// Whether the optional nullable member is present, including null.
  final bool hasBatch;

  /// Exact `service_tier` wire value.
  final String? serviceTier;

  /// Whether the optional nullable member is present, including null.
  final bool hasServiceTier;

  /// Fixed native discriminator.
  String get object => 'organization.usage.decisions.result';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory DecisionsUsageResult.fromJson(Map<String, dynamic> json) {
    adminTag(
      json,
      'object',
      'organization.usage.decisions.result',
      'DecisionsUsageResult',
    );
    return DecisionsUsageResult(
      apiSource: adminOptional<DecisionsUsageApiSource>(
        json,
        'api_source',
        'DecisionsUsageResult.apiSource',
        (value, context) => DecisionsUsageApiSource.fromJson(value),
        nullable: true,
      ),
      hasApiSource: json.containsKey('api_source'),
      inputTokens: adminRequired<int>(
        json,
        'input_tokens',
        'DecisionsUsageResult.inputTokens',
        adminInt,
        nullable: false,
      )!,
      inputCachedTokens: adminOptional<int>(
        json,
        'input_cached_tokens',
        'DecisionsUsageResult.inputCachedTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCachedTokens: json.containsKey('input_cached_tokens'),
      inputCacheWriteTokens: adminOptional<int>(
        json,
        'input_cache_write_tokens',
        'DecisionsUsageResult.inputCacheWriteTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCacheWriteTokens: json.containsKey('input_cache_write_tokens'),
      inputCacheWrite30mTokens: adminOptional<int>(
        json,
        'input_cache_write_30m_tokens',
        'DecisionsUsageResult.inputCacheWrite30mTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCacheWrite30mTokens: json.containsKey(
        'input_cache_write_30m_tokens',
      ),
      inputCacheWrite12hTokens: adminOptional<int>(
        json,
        'input_cache_write_12h_tokens',
        'DecisionsUsageResult.inputCacheWrite12hTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCacheWrite12hTokens: json.containsKey(
        'input_cache_write_12h_tokens',
      ),
      inputUncachedTokens: adminOptional<int>(
        json,
        'input_uncached_tokens',
        'DecisionsUsageResult.inputUncachedTokens',
        adminInt,
        nullable: true,
      ),
      hasInputUncachedTokens: json.containsKey('input_uncached_tokens'),
      outputTokens: adminRequired<int>(
        json,
        'output_tokens',
        'DecisionsUsageResult.outputTokens',
        adminInt,
        nullable: false,
      )!,
      inputTextTokens: adminOptional<int>(
        json,
        'input_text_tokens',
        'DecisionsUsageResult.inputTextTokens',
        adminInt,
        nullable: true,
      ),
      hasInputTextTokens: json.containsKey('input_text_tokens'),
      outputTextTokens: adminOptional<int>(
        json,
        'output_text_tokens',
        'DecisionsUsageResult.outputTextTokens',
        adminInt,
        nullable: true,
      ),
      hasOutputTextTokens: json.containsKey('output_text_tokens'),
      inputCachedTextTokens: adminOptional<int>(
        json,
        'input_cached_text_tokens',
        'DecisionsUsageResult.inputCachedTextTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCachedTextTokens: json.containsKey('input_cached_text_tokens'),
      inputAudioTokens: adminOptional<int>(
        json,
        'input_audio_tokens',
        'DecisionsUsageResult.inputAudioTokens',
        adminInt,
        nullable: true,
      ),
      hasInputAudioTokens: json.containsKey('input_audio_tokens'),
      inputCachedAudioTokens: adminOptional<int>(
        json,
        'input_cached_audio_tokens',
        'DecisionsUsageResult.inputCachedAudioTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCachedAudioTokens: json.containsKey('input_cached_audio_tokens'),
      outputAudioTokens: adminOptional<int>(
        json,
        'output_audio_tokens',
        'DecisionsUsageResult.outputAudioTokens',
        adminInt,
        nullable: true,
      ),
      hasOutputAudioTokens: json.containsKey('output_audio_tokens'),
      inputImageTokens: adminOptional<int>(
        json,
        'input_image_tokens',
        'DecisionsUsageResult.inputImageTokens',
        adminInt,
        nullable: true,
      ),
      hasInputImageTokens: json.containsKey('input_image_tokens'),
      inputCachedImageTokens: adminOptional<int>(
        json,
        'input_cached_image_tokens',
        'DecisionsUsageResult.inputCachedImageTokens',
        adminInt,
        nullable: true,
      ),
      hasInputCachedImageTokens: json.containsKey('input_cached_image_tokens'),
      outputImageTokens: adminOptional<int>(
        json,
        'output_image_tokens',
        'DecisionsUsageResult.outputImageTokens',
        adminInt,
        nullable: true,
      ),
      hasOutputImageTokens: json.containsKey('output_image_tokens'),
      numModelRequests: adminRequired<int>(
        json,
        'num_model_requests',
        'DecisionsUsageResult.numModelRequests',
        adminInt,
        nullable: false,
      )!,
      projectId: adminOptional<String>(
        json,
        'project_id',
        'DecisionsUsageResult.projectId',
        adminString,
        nullable: true,
      ),
      hasProjectId: json.containsKey('project_id'),
      userId: adminOptional<String>(
        json,
        'user_id',
        'DecisionsUsageResult.userId',
        adminString,
        nullable: true,
      ),
      hasUserId: json.containsKey('user_id'),
      apiKeyId: adminOptional<String>(
        json,
        'api_key_id',
        'DecisionsUsageResult.apiKeyId',
        adminString,
        nullable: true,
      ),
      hasApiKeyId: json.containsKey('api_key_id'),
      model: adminOptional<String>(
        json,
        'model',
        'DecisionsUsageResult.model',
        adminString,
        nullable: true,
      ),
      hasModel: json.containsKey('model'),
      batch: adminOptional<bool>(
        json,
        'batch',
        'DecisionsUsageResult.batch',
        adminBool,
        nullable: true,
      ),
      hasBatch: json.containsKey('batch'),
      serviceTier: adminOptional<String>(
        json,
        'service_tier',
        'DecisionsUsageResult.serviceTier',
        adminString,
        nullable: true,
      ),
      hasServiceTier: json.containsKey('service_tier'),
      rawJson: json,
    );
  }
  @override
  void validate() {
    if (apiSource != null) {
      apiSource!.validate();
    }
    adminInt(inputTokens, 'DecisionsUsageResult.inputTokens');
    if (inputCachedTokens != null) {
      adminInt(inputCachedTokens, 'DecisionsUsageResult.inputCachedTokens');
    }
    if (inputCacheWriteTokens != null) {
      adminInt(
        inputCacheWriteTokens,
        'DecisionsUsageResult.inputCacheWriteTokens',
      );
    }
    if (inputCacheWrite30mTokens != null) {
      adminInt(
        inputCacheWrite30mTokens,
        'DecisionsUsageResult.inputCacheWrite30mTokens',
      );
    }
    if (inputCacheWrite12hTokens != null) {
      adminInt(
        inputCacheWrite12hTokens,
        'DecisionsUsageResult.inputCacheWrite12hTokens',
      );
    }
    if (inputUncachedTokens != null) {
      adminInt(inputUncachedTokens, 'DecisionsUsageResult.inputUncachedTokens');
    }
    adminInt(outputTokens, 'DecisionsUsageResult.outputTokens');
    if (inputTextTokens != null) {
      adminInt(inputTextTokens, 'DecisionsUsageResult.inputTextTokens');
    }
    if (outputTextTokens != null) {
      adminInt(outputTextTokens, 'DecisionsUsageResult.outputTextTokens');
    }
    if (inputCachedTextTokens != null) {
      adminInt(
        inputCachedTextTokens,
        'DecisionsUsageResult.inputCachedTextTokens',
      );
    }
    if (inputAudioTokens != null) {
      adminInt(inputAudioTokens, 'DecisionsUsageResult.inputAudioTokens');
    }
    if (inputCachedAudioTokens != null) {
      adminInt(
        inputCachedAudioTokens,
        'DecisionsUsageResult.inputCachedAudioTokens',
      );
    }
    if (outputAudioTokens != null) {
      adminInt(outputAudioTokens, 'DecisionsUsageResult.outputAudioTokens');
    }
    if (inputImageTokens != null) {
      adminInt(inputImageTokens, 'DecisionsUsageResult.inputImageTokens');
    }
    if (inputCachedImageTokens != null) {
      adminInt(
        inputCachedImageTokens,
        'DecisionsUsageResult.inputCachedImageTokens',
      );
    }
    if (outputImageTokens != null) {
      adminInt(outputImageTokens, 'DecisionsUsageResult.outputImageTokens');
    }
    adminInt(numModelRequests, 'DecisionsUsageResult.numModelRequests');
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    if (hasApiSource) 'api_source': apiSource?.toJson(),
    'input_tokens': inputTokens,
    if (hasInputCachedTokens) 'input_cached_tokens': inputCachedTokens,
    if (hasInputCacheWriteTokens)
      'input_cache_write_tokens': inputCacheWriteTokens,
    if (hasInputCacheWrite30mTokens)
      'input_cache_write_30m_tokens': inputCacheWrite30mTokens,
    if (hasInputCacheWrite12hTokens)
      'input_cache_write_12h_tokens': inputCacheWrite12hTokens,
    if (hasInputUncachedTokens) 'input_uncached_tokens': inputUncachedTokens,
    'output_tokens': outputTokens,
    if (hasInputTextTokens) 'input_text_tokens': inputTextTokens,
    if (hasOutputTextTokens) 'output_text_tokens': outputTextTokens,
    if (hasInputCachedTextTokens)
      'input_cached_text_tokens': inputCachedTextTokens,
    if (hasInputAudioTokens) 'input_audio_tokens': inputAudioTokens,
    if (hasInputCachedAudioTokens)
      'input_cached_audio_tokens': inputCachedAudioTokens,
    if (hasOutputAudioTokens) 'output_audio_tokens': outputAudioTokens,
    if (hasInputImageTokens) 'input_image_tokens': inputImageTokens,
    if (hasInputCachedImageTokens)
      'input_cached_image_tokens': inputCachedImageTokens,
    if (hasOutputImageTokens) 'output_image_tokens': outputImageTokens,
    'num_model_requests': numModelRequests,
    if (hasProjectId) 'project_id': projectId,
    if (hasUserId) 'user_id': userId,
    if (hasApiKeyId) 'api_key_id': apiKeyId,
    if (hasModel) 'model': model,
    if (hasBatch) 'batch': batch,
    if (hasServiceTier) 'service_tier': serviceTier,
  };

  /// Copies every field; clear flags omit optional nullable members.
  DecisionsUsageResult copyWith({
    Object? apiSource = unsetCopyWithValue,
    bool clearApiSource = false,
    int? inputTokens,
    Object? inputCachedTokens = unsetCopyWithValue,
    bool clearInputCachedTokens = false,
    Object? inputCacheWriteTokens = unsetCopyWithValue,
    bool clearInputCacheWriteTokens = false,
    Object? inputCacheWrite30mTokens = unsetCopyWithValue,
    bool clearInputCacheWrite30mTokens = false,
    Object? inputCacheWrite12hTokens = unsetCopyWithValue,
    bool clearInputCacheWrite12hTokens = false,
    Object? inputUncachedTokens = unsetCopyWithValue,
    bool clearInputUncachedTokens = false,
    int? outputTokens,
    Object? inputTextTokens = unsetCopyWithValue,
    bool clearInputTextTokens = false,
    Object? outputTextTokens = unsetCopyWithValue,
    bool clearOutputTextTokens = false,
    Object? inputCachedTextTokens = unsetCopyWithValue,
    bool clearInputCachedTextTokens = false,
    Object? inputAudioTokens = unsetCopyWithValue,
    bool clearInputAudioTokens = false,
    Object? inputCachedAudioTokens = unsetCopyWithValue,
    bool clearInputCachedAudioTokens = false,
    Object? outputAudioTokens = unsetCopyWithValue,
    bool clearOutputAudioTokens = false,
    Object? inputImageTokens = unsetCopyWithValue,
    bool clearInputImageTokens = false,
    Object? inputCachedImageTokens = unsetCopyWithValue,
    bool clearInputCachedImageTokens = false,
    Object? outputImageTokens = unsetCopyWithValue,
    bool clearOutputImageTokens = false,
    int? numModelRequests,
    Object? projectId = unsetCopyWithValue,
    bool clearProjectId = false,
    Object? userId = unsetCopyWithValue,
    bool clearUserId = false,
    Object? apiKeyId = unsetCopyWithValue,
    bool clearApiKeyId = false,
    Object? model = unsetCopyWithValue,
    bool clearModel = false,
    Object? batch = unsetCopyWithValue,
    bool clearBatch = false,
    Object? serviceTier = unsetCopyWithValue,
    bool clearServiceTier = false,
    Map<String, dynamic>? rawJson,
  }) => DecisionsUsageResult(
    apiSource: clearApiSource
        ? null
        : (adminCopy<DecisionsUsageApiSource>(
            apiSource,
            this.apiSource,
            'DecisionsUsageResult.apiSource',
          )),
    hasApiSource:
        !clearApiSource &&
        (!identical(apiSource, unsetCopyWithValue) || hasApiSource),
    inputTokens: inputTokens ?? this.inputTokens,
    inputCachedTokens: clearInputCachedTokens
        ? null
        : (adminCopy<int>(
            inputCachedTokens,
            this.inputCachedTokens,
            'DecisionsUsageResult.inputCachedTokens',
          )),
    hasInputCachedTokens:
        !clearInputCachedTokens &&
        (!identical(inputCachedTokens, unsetCopyWithValue) ||
            hasInputCachedTokens),
    inputCacheWriteTokens: clearInputCacheWriteTokens
        ? null
        : (adminCopy<int>(
            inputCacheWriteTokens,
            this.inputCacheWriteTokens,
            'DecisionsUsageResult.inputCacheWriteTokens',
          )),
    hasInputCacheWriteTokens:
        !clearInputCacheWriteTokens &&
        (!identical(inputCacheWriteTokens, unsetCopyWithValue) ||
            hasInputCacheWriteTokens),
    inputCacheWrite30mTokens: clearInputCacheWrite30mTokens
        ? null
        : (adminCopy<int>(
            inputCacheWrite30mTokens,
            this.inputCacheWrite30mTokens,
            'DecisionsUsageResult.inputCacheWrite30mTokens',
          )),
    hasInputCacheWrite30mTokens:
        !clearInputCacheWrite30mTokens &&
        (!identical(inputCacheWrite30mTokens, unsetCopyWithValue) ||
            hasInputCacheWrite30mTokens),
    inputCacheWrite12hTokens: clearInputCacheWrite12hTokens
        ? null
        : (adminCopy<int>(
            inputCacheWrite12hTokens,
            this.inputCacheWrite12hTokens,
            'DecisionsUsageResult.inputCacheWrite12hTokens',
          )),
    hasInputCacheWrite12hTokens:
        !clearInputCacheWrite12hTokens &&
        (!identical(inputCacheWrite12hTokens, unsetCopyWithValue) ||
            hasInputCacheWrite12hTokens),
    inputUncachedTokens: clearInputUncachedTokens
        ? null
        : (adminCopy<int>(
            inputUncachedTokens,
            this.inputUncachedTokens,
            'DecisionsUsageResult.inputUncachedTokens',
          )),
    hasInputUncachedTokens:
        !clearInputUncachedTokens &&
        (!identical(inputUncachedTokens, unsetCopyWithValue) ||
            hasInputUncachedTokens),
    outputTokens: outputTokens ?? this.outputTokens,
    inputTextTokens: clearInputTextTokens
        ? null
        : (adminCopy<int>(
            inputTextTokens,
            this.inputTextTokens,
            'DecisionsUsageResult.inputTextTokens',
          )),
    hasInputTextTokens:
        !clearInputTextTokens &&
        (!identical(inputTextTokens, unsetCopyWithValue) || hasInputTextTokens),
    outputTextTokens: clearOutputTextTokens
        ? null
        : (adminCopy<int>(
            outputTextTokens,
            this.outputTextTokens,
            'DecisionsUsageResult.outputTextTokens',
          )),
    hasOutputTextTokens:
        !clearOutputTextTokens &&
        (!identical(outputTextTokens, unsetCopyWithValue) ||
            hasOutputTextTokens),
    inputCachedTextTokens: clearInputCachedTextTokens
        ? null
        : (adminCopy<int>(
            inputCachedTextTokens,
            this.inputCachedTextTokens,
            'DecisionsUsageResult.inputCachedTextTokens',
          )),
    hasInputCachedTextTokens:
        !clearInputCachedTextTokens &&
        (!identical(inputCachedTextTokens, unsetCopyWithValue) ||
            hasInputCachedTextTokens),
    inputAudioTokens: clearInputAudioTokens
        ? null
        : (adminCopy<int>(
            inputAudioTokens,
            this.inputAudioTokens,
            'DecisionsUsageResult.inputAudioTokens',
          )),
    hasInputAudioTokens:
        !clearInputAudioTokens &&
        (!identical(inputAudioTokens, unsetCopyWithValue) ||
            hasInputAudioTokens),
    inputCachedAudioTokens: clearInputCachedAudioTokens
        ? null
        : (adminCopy<int>(
            inputCachedAudioTokens,
            this.inputCachedAudioTokens,
            'DecisionsUsageResult.inputCachedAudioTokens',
          )),
    hasInputCachedAudioTokens:
        !clearInputCachedAudioTokens &&
        (!identical(inputCachedAudioTokens, unsetCopyWithValue) ||
            hasInputCachedAudioTokens),
    outputAudioTokens: clearOutputAudioTokens
        ? null
        : (adminCopy<int>(
            outputAudioTokens,
            this.outputAudioTokens,
            'DecisionsUsageResult.outputAudioTokens',
          )),
    hasOutputAudioTokens:
        !clearOutputAudioTokens &&
        (!identical(outputAudioTokens, unsetCopyWithValue) ||
            hasOutputAudioTokens),
    inputImageTokens: clearInputImageTokens
        ? null
        : (adminCopy<int>(
            inputImageTokens,
            this.inputImageTokens,
            'DecisionsUsageResult.inputImageTokens',
          )),
    hasInputImageTokens:
        !clearInputImageTokens &&
        (!identical(inputImageTokens, unsetCopyWithValue) ||
            hasInputImageTokens),
    inputCachedImageTokens: clearInputCachedImageTokens
        ? null
        : (adminCopy<int>(
            inputCachedImageTokens,
            this.inputCachedImageTokens,
            'DecisionsUsageResult.inputCachedImageTokens',
          )),
    hasInputCachedImageTokens:
        !clearInputCachedImageTokens &&
        (!identical(inputCachedImageTokens, unsetCopyWithValue) ||
            hasInputCachedImageTokens),
    outputImageTokens: clearOutputImageTokens
        ? null
        : (adminCopy<int>(
            outputImageTokens,
            this.outputImageTokens,
            'DecisionsUsageResult.outputImageTokens',
          )),
    hasOutputImageTokens:
        !clearOutputImageTokens &&
        (!identical(outputImageTokens, unsetCopyWithValue) ||
            hasOutputImageTokens),
    numModelRequests: numModelRequests ?? this.numModelRequests,
    projectId: clearProjectId
        ? null
        : (adminCopy<String>(
            projectId,
            this.projectId,
            'DecisionsUsageResult.projectId',
          )),
    hasProjectId:
        !clearProjectId &&
        (!identical(projectId, unsetCopyWithValue) || hasProjectId),
    userId: clearUserId
        ? null
        : (adminCopy<String>(
            userId,
            this.userId,
            'DecisionsUsageResult.userId',
          )),
    hasUserId:
        !clearUserId && (!identical(userId, unsetCopyWithValue) || hasUserId),
    apiKeyId: clearApiKeyId
        ? null
        : (adminCopy<String>(
            apiKeyId,
            this.apiKeyId,
            'DecisionsUsageResult.apiKeyId',
          )),
    hasApiKeyId:
        !clearApiKeyId &&
        (!identical(apiKeyId, unsetCopyWithValue) || hasApiKeyId),
    model: clearModel
        ? null
        : (adminCopy<String>(model, this.model, 'DecisionsUsageResult.model')),
    hasModel:
        !clearModel && (!identical(model, unsetCopyWithValue) || hasModel),
    batch: clearBatch
        ? null
        : (adminCopy<bool>(batch, this.batch, 'DecisionsUsageResult.batch')),
    hasBatch:
        !clearBatch && (!identical(batch, unsetCopyWithValue) || hasBatch),
    serviceTier: clearServiceTier
        ? null
        : (adminCopy<String>(
            serviceTier,
            this.serviceTier,
            'DecisionsUsageResult.serviceTier',
          )),
    hasServiceTier:
        !clearServiceTier &&
        (!identical(serviceTier, unsetCopyWithValue) || hasServiceTier),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// DecisionsUsageBucket
final class DecisionsUsageBucket extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  DecisionsUsageBucket({
    required this.startTime,
    required this.endTime,
    required List<DecisionsUsageResult> results,
    Map<String, dynamic> rawJson = const {},
  }) : results = List<DecisionsUsageResult>.unmodifiable(results),
       rawJson = adminExtras(rawJson, {
         'object',
         'start_time',
         'end_time',
         'results',
       }, 'DecisionsUsageBucket') {
    validate();
  }

  /// Exact `start_time` wire value.
  final int startTime;

  /// Exact `end_time` wire value.
  final int endTime;

  /// Exact `results` wire value.
  final List<DecisionsUsageResult> results;

  /// Fixed native discriminator.
  String get object => 'bucket';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory DecisionsUsageBucket.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'object', 'bucket', 'DecisionsUsageBucket');
    return DecisionsUsageBucket(
      startTime: adminRequired<int>(
        json,
        'start_time',
        'DecisionsUsageBucket.startTime',
        adminInt,
        nullable: false,
      )!,
      endTime: adminRequired<int>(
        json,
        'end_time',
        'DecisionsUsageBucket.endTime',
        adminInt,
        nullable: false,
      )!,
      results: adminRequired<List<DecisionsUsageResult>>(
        json,
        'results',
        'DecisionsUsageBucket.results',
        (value, context) => [
          for (final item in adminList(value, context))
            DecisionsUsageResult.fromJson(adminObject(item, context)),
        ],
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    adminInt(startTime, 'DecisionsUsageBucket.startTime');
    adminInt(endTime, 'DecisionsUsageBucket.endTime');
    for (final value in results) {
      value.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'start_time': startTime,
    'end_time': endTime,
    'results': results.map((value) => value.toJson()).toList(),
  };

  /// Copies every field; clear flags omit optional nullable members.
  DecisionsUsageBucket copyWith({
    int? startTime,
    int? endTime,
    List<DecisionsUsageResult>? results,
    Map<String, dynamic>? rawJson,
  }) => DecisionsUsageBucket(
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    results: results ?? this.results,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// DecisionsUsagePage
final class DecisionsUsagePage extends AdminJsonValue {
  /// Captures typed fields and immutable permitted overflow JSON.
  DecisionsUsagePage({
    required this.hasMore,
    required this.nextPage,
    required List<DecisionsUsageBucket> data,
    Map<String, dynamic> rawJson = const {},
  }) : data = List<DecisionsUsageBucket>.unmodifiable(data),
       rawJson = adminExtras(rawJson, {
         'object',
         'has_more',
         'next_page',
         'data',
       }, 'DecisionsUsagePage') {
    validate();
  }

  /// Exact `has_more` wire value.
  final bool hasMore;

  /// Exact `next_page` wire value.
  final String? nextPage;

  /// Exact `data` wire value.
  final List<DecisionsUsageBucket> data;

  /// Fixed native discriminator.
  String get object => 'page';

  /// Immutable finite overflow fields; typed members remain authoritative.
  final Map<String, dynamic> rawJson;

  /// Parses the exact required/null/type contract without coercion.
  factory DecisionsUsagePage.fromJson(Map<String, dynamic> json) {
    adminTag(json, 'object', 'page', 'DecisionsUsagePage');
    return DecisionsUsagePage(
      hasMore: adminRequired<bool>(
        json,
        'has_more',
        'DecisionsUsagePage.hasMore',
        adminBool,
        nullable: false,
      )!,
      nextPage: adminRequired<String>(
        json,
        'next_page',
        'DecisionsUsagePage.nextPage',
        adminString,
        nullable: true,
      ),
      data: adminRequired<List<DecisionsUsageBucket>>(
        json,
        'data',
        'DecisionsUsagePage.data',
        (value, context) => [
          for (final item in adminList(value, context))
            DecisionsUsageBucket.fromJson(adminObject(item, context)),
        ],
        nullable: false,
      )!,
      rawJson: json,
    );
  }
  @override
  void validate() {
    for (final value in data) {
      value.validate();
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'object': object,
    'has_more': hasMore,
    'next_page': nextPage,
    'data': data.map((value) => value.toJson()).toList(),
  };

  /// Copies every field; clear flags omit optional nullable members.
  DecisionsUsagePage copyWith({
    bool? hasMore,
    Object? nextPage = unsetCopyWithValue,
    List<DecisionsUsageBucket>? data,
    Map<String, dynamic>? rawJson,
  }) => DecisionsUsagePage(
    hasMore: hasMore ?? this.hasMore,
    nextPage: adminCopy<String>(
      nextPage,
      this.nextPage,
      'DecisionsUsagePage.nextPage',
    ),
    data: data ?? this.data,
    rawJson: rawJson ?? this.rawJson,
  );
}
