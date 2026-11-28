import '../common/service_tier.dart';
import '../copy_with_sentinel.dart';
import 'agent_config.dart';
import 'environments/environments.dart';
import 'events/events.dart';
import 'generation_config.dart';
import 'interaction_input.dart';
import 'interaction_status.dart';
import 'response_formats/response_formats.dart';
import 'response_modality.dart';
import 'safety_setting.dart';
import 'steps/steps.dart';
import 'tools/tools.dart';
import 'usage.dart';
import 'webhook_config.dart';

/// The Interaction resource.
///
/// Represents a single interaction with the Gemini API using server-side
/// state management. Contains both request parameters (input, tools, config)
/// and response fields (steps, usage, status).
class Interaction {
  /// A unique identifier for the interaction.
  final String id;

  /// The status of the interaction.
  final InteractionStatus status;

  /// The original wire status when this client does not recognize it.
  final String? unrecognizedStatus;

  /// The name of the model used for generating the interaction.
  final String? model;

  /// The name of the agent used for generating the interaction.
  final String? agent;

  /// The time at which the interaction was created (ISO 8601 format).
  final DateTime? created;

  /// The time at which the interaction was last updated (ISO 8601 format).
  final DateTime? updated;

  /// The inputs for the interaction.
  ///
  /// Can be a [TextInput], a [StepListInput], a [ContentListInput],
  /// or a [SingleContentInput].
  final InteractionInput? input;

  /// Output only. The steps that make up the interaction.
  final List<InteractionStep>? steps;

  /// Statistics on the interaction request's token usage.
  final InteractionUsage? usage;

  /// Diagnostic faults recorded by the server.
  final List<InteractionError>? errors;

  /// Maximum total tokens for an agent run, as an exact int64 decimal string.
  final String? maxTotalTokens;

  /// The object type of the interaction. Always 'interaction'.
  final String object;

  /// The ID of the previous interaction, if any.
  final String? previousInteractionId;

  /// Opaque token for starting the next hop when decoding can continue.
  ///
  /// A stored continuation must identify this interaction as the previous
  /// interaction. A stateless continuation must resend its original input.
  final String? continuationToken;

  /// Ordered IDs of the hops combined by automatic continuation.
  final List<String>? continuationIds;

  /// System instruction for the interaction.
  final String? systemInstruction;

  /// A list of tool declarations the model may call during interaction.
  final List<InteractionTool>? tools;

  /// Configuration parameters for the model interaction.
  final InteractionGenerationConfig? generationConfig;

  /// The requested modalities of the response.
  final List<InteractionResponseModality>? responseModalities;

  /// The mime type of the response.
  final String? responseMimeType;

  /// Enforces the response format (a single [InteractionResponseFormat] or a list of
  /// them). Used for structured output and per-modality output configuration.
  final InteractionResponseFormatConfig? responseFormat;

  /// Configuration for the agent.
  final AgentConfig? agentConfig;

  /// The service tier for the interaction.
  final ServiceTier? serviceTier;

  /// The environment configuration for the interaction.
  ///
  /// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) or a
  /// string reference ([EnvironmentIdRef]) — an existing environment id, or a
  /// literal such as `"remote"`.
  final EnvironmentConfigOrId? environment;

  /// Output only. The id of the environment created for this interaction when
  /// an [environment] config was provided.
  final String? environmentId;

  /// Webhook configuration for receiving notifications when the interaction
  /// completes.
  final WebhookConfig? webhookConfig;

  /// The labels with user-defined metadata for the request.
  final Map<String, String>? labels;

  /// Safety settings for the interaction.
  final List<InteractionSafetySetting>? safetySettings;

  /// Creates an [Interaction] instance.
  const Interaction({
    required this.id,
    required this.status,
    this.unrecognizedStatus,
    this.model,
    this.agent,
    this.created,
    this.updated,
    this.input,
    this.steps,
    this.usage,
    this.errors,
    this.maxTotalTokens,
    this.object = 'interaction',
    this.previousInteractionId,
    this.continuationToken,
    this.continuationIds,
    this.systemInstruction,
    this.tools,
    this.generationConfig,
    this.responseModalities,
    this.responseMimeType,
    this.responseFormat,
    this.agentConfig,
    this.serviceTier,
    this.environment,
    this.environmentId,
    this.webhookConfig,
    this.labels,
    this.safetySettings,
  });

  /// Creates an [Interaction] from JSON.
  factory Interaction.fromJson(Map<String, dynamic> json) => Interaction(
    id: json['id'] as String,
    status: InteractionStatus.fromString(json['status'] as String?),
    unrecognizedStatus: switch (json['status'] as String?) {
      final String value when InteractionStatus.tryFromString(value) == null =>
        value,
      _ => null,
    },
    model: json['model'] as String?,
    agent: json['agent'] as String?,
    created: json['created'] != null
        ? DateTime.parse(json['created'] as String)
        : null,
    updated: json['updated'] != null
        ? DateTime.parse(json['updated'] as String)
        : null,
    input: json['input'] != null
        ? InteractionInput.fromJson(json['input'] as Object)
        : null,
    steps: (json['steps'] as List<dynamic>?)
        ?.map((e) => InteractionStep.fromJson(e as Map<String, dynamic>))
        .toList(),
    usage: json['usage'] != null
        ? InteractionUsage.fromJson(json['usage'] as Map<String, dynamic>)
        : null,
    errors: (json['errors'] as List<dynamic>?)
        ?.map(
          (error) => InteractionError.fromJson(error as Map<String, dynamic>),
        )
        .toList(),
    maxTotalTokens: switch (json['max_total_tokens']) {
      final String value => value,
      final int value => value.toString(),
      _ => null,
    },
    object: json['object'] as String? ?? 'interaction',
    previousInteractionId: json['previous_interaction_id'] as String?,
    continuationToken: json['continuation_token'] as String?,
    continuationIds: (json['continuation_ids'] as List<dynamic>?)
        ?.map((id) => id as String)
        .toList(),
    systemInstruction: json['system_instruction'] as String?,
    tools: (json['tools'] as List<dynamic>?)
        ?.map((e) => InteractionTool.fromJson(e as Map<String, dynamic>))
        .toList(),
    generationConfig: json['generation_config'] != null
        ? InteractionGenerationConfig.fromJson(
            json['generation_config'] as Map<String, dynamic>,
          )
        : null,
    responseModalities: (json['response_modalities'] as List<dynamic>?)
        ?.map((e) => interactionResponseModalityFromString(e as String))
        .toList(),
    responseMimeType: json['response_mime_type'] as String?,
    responseFormat: json['response_format'] != null
        ? InteractionResponseFormatConfig.fromJson(
            json['response_format'] as Object,
          )
        : null,
    agentConfig: json['agent_config'] != null
        ? AgentConfig.fromJson(json['agent_config'] as Map<String, dynamic>)
        : null,
    serviceTier: json['service_tier'] != null
        ? serviceTierFromString(json['service_tier'] as String?)
        : null,
    environment: json['environment'] != null
        ? EnvironmentConfigOrId.fromJson(json['environment'] as Object)
        : null,
    environmentId: json['environment_id'] as String?,
    webhookConfig: json['webhook_config'] != null
        ? WebhookConfig.fromJson(json['webhook_config'] as Map<String, dynamic>)
        : null,
    labels: (json['labels'] as Map<String, dynamic>?)?.cast<String, String>(),
    safetySettings: (json['safety_settings'] as List<dynamic>?)
        ?.map(
          (e) => InteractionSafetySetting.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': unrecognizedStatus ?? status.toJson(),
    if (model != null) 'model': model,
    if (agent != null) 'agent': agent,
    if (created != null) 'created': created!.toIso8601String(),
    if (updated != null) 'updated': updated!.toIso8601String(),
    if (input != null) 'input': input!.toJson(),
    if (steps != null) 'steps': steps!.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    if (errors != null)
      'errors': errors!.map((error) => error.toJson()).toList(),
    'max_total_tokens': ?maxTotalTokens,
    'object': object,
    if (previousInteractionId != null)
      'previous_interaction_id': previousInteractionId,
    if (continuationToken != null) 'continuation_token': continuationToken,
    if (continuationIds != null) 'continuation_ids': continuationIds,
    if (systemInstruction != null) 'system_instruction': systemInstruction,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (generationConfig != null)
      'generation_config': generationConfig!.toJson(),
    if (responseModalities != null)
      'response_modalities': responseModalities!
          .map(interactionResponseModalityToString)
          .toList(),
    if (responseMimeType != null) 'response_mime_type': responseMimeType,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (agentConfig != null) 'agent_config': agentConfig!.toJson(),
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'service_tier': serviceTierToString(serviceTier!),
    if (environment != null) 'environment': environment!.toJson(),
    if (environmentId != null) 'environment_id': environmentId,
    if (webhookConfig != null) 'webhook_config': webhookConfig!.toJson(),
    if (labels != null) 'labels': labels,
    if (safetySettings != null)
      'safety_settings': safetySettings!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  Interaction copyWith({
    Object? id = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? unrecognizedStatus = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? created = unsetCopyWithValue,
    Object? updated = unsetCopyWithValue,
    Object? input = unsetCopyWithValue,
    Object? steps = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? errors = unsetCopyWithValue,
    Object? maxTotalTokens = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? previousInteractionId = unsetCopyWithValue,
    Object? continuationToken = unsetCopyWithValue,
    Object? continuationIds = unsetCopyWithValue,
    Object? systemInstruction = unsetCopyWithValue,
    Object? tools = unsetCopyWithValue,
    Object? generationConfig = unsetCopyWithValue,
    Object? responseModalities = unsetCopyWithValue,
    Object? responseMimeType = unsetCopyWithValue,
    Object? responseFormat = unsetCopyWithValue,
    Object? agentConfig = unsetCopyWithValue,
    Object? serviceTier = unsetCopyWithValue,
    Object? environment = unsetCopyWithValue,
    Object? environmentId = unsetCopyWithValue,
    Object? webhookConfig = unsetCopyWithValue,
    Object? labels = unsetCopyWithValue,
    Object? safetySettings = unsetCopyWithValue,
  }) {
    return Interaction(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      status: status == unsetCopyWithValue
          ? this.status
          : status! as InteractionStatus,
      unrecognizedStatus: unrecognizedStatus == unsetCopyWithValue
          ? (status == unsetCopyWithValue ? this.unrecognizedStatus : null)
          : unrecognizedStatus as String?,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as String?,
      created: created == unsetCopyWithValue
          ? this.created
          : created as DateTime?,
      updated: updated == unsetCopyWithValue
          ? this.updated
          : updated as DateTime?,
      input: input == unsetCopyWithValue
          ? this.input
          : input as InteractionInput?,
      steps: steps == unsetCopyWithValue
          ? this.steps
          : steps as List<InteractionStep>?,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as InteractionUsage?,
      errors: errors == unsetCopyWithValue
          ? this.errors
          : errors as List<InteractionError>?,
      maxTotalTokens: maxTotalTokens == unsetCopyWithValue
          ? this.maxTotalTokens
          : maxTotalTokens as String?,
      object: object == unsetCopyWithValue ? this.object : object! as String,
      previousInteractionId: previousInteractionId == unsetCopyWithValue
          ? this.previousInteractionId
          : previousInteractionId as String?,
      continuationToken: continuationToken == unsetCopyWithValue
          ? this.continuationToken
          : continuationToken as String?,
      continuationIds: continuationIds == unsetCopyWithValue
          ? this.continuationIds
          : continuationIds as List<String>?,
      systemInstruction: systemInstruction == unsetCopyWithValue
          ? this.systemInstruction
          : systemInstruction as String?,
      tools: tools == unsetCopyWithValue
          ? this.tools
          : tools as List<InteractionTool>?,
      generationConfig: generationConfig == unsetCopyWithValue
          ? this.generationConfig
          : generationConfig as InteractionGenerationConfig?,
      responseModalities: responseModalities == unsetCopyWithValue
          ? this.responseModalities
          : responseModalities as List<InteractionResponseModality>?,
      responseMimeType: responseMimeType == unsetCopyWithValue
          ? this.responseMimeType
          : responseMimeType as String?,
      responseFormat: responseFormat == unsetCopyWithValue
          ? this.responseFormat
          : responseFormat as InteractionResponseFormatConfig?,
      agentConfig: agentConfig == unsetCopyWithValue
          ? this.agentConfig
          : agentConfig as AgentConfig?,
      serviceTier: serviceTier == unsetCopyWithValue
          ? this.serviceTier
          : serviceTier as ServiceTier?,
      environment: environment == unsetCopyWithValue
          ? this.environment
          : environment as EnvironmentConfigOrId?,
      environmentId: environmentId == unsetCopyWithValue
          ? this.environmentId
          : environmentId as String?,
      webhookConfig: webhookConfig == unsetCopyWithValue
          ? this.webhookConfig
          : webhookConfig as WebhookConfig?,
      labels: labels == unsetCopyWithValue
          ? this.labels
          : labels as Map<String, String>?,
      safetySettings: safetySettings == unsetCopyWithValue
          ? this.safetySettings
          : safetySettings as List<InteractionSafetySetting>?,
    );
  }
}

/// Parameters for creating an interaction — either model-based or agent-based.
sealed class CreateInteractionParams {
  const CreateInteractionParams();

  /// Creates the appropriate variant from JSON ('agent' key → agent params,
  /// otherwise model params).
  factory CreateInteractionParams.fromJson(Map<String, dynamic> json) =>
      json.containsKey('agent')
      ? CreateAgentInteractionParams.fromJson(json)
      : CreateModelInteractionParams.fromJson(json);

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Parameters for creating an interaction with a model.
class CreateModelInteractionParams extends CreateInteractionParams {
  /// The name of the model to use.
  final String model;

  /// The input for the interaction.
  ///
  /// Can be a [TextInput], a [StepListInput], a [ContentListInput],
  /// or a [SingleContentInput].
  final InteractionInput? input;

  /// System instruction for the interaction.
  final String? systemInstruction;

  /// A list of tool declarations the model may call during interaction.
  final List<InteractionTool>? tools;

  /// Configuration parameters for the model interaction.
  final InteractionGenerationConfig? generationConfig;

  /// The requested modalities of the response.
  final List<InteractionResponseModality>? responseModalities;

  /// The mime type of the response.
  final String? responseMimeType;

  /// Enforces the response format (a single [InteractionResponseFormat] or a list of
  /// them). Used for structured output and per-modality output configuration.
  final InteractionResponseFormatConfig? responseFormat;

  /// The ID of a previous interaction to continue from.
  final String? previousInteractionId;

  /// Opaque continuation token returned by a previous interaction or checkpoint.
  final String? continuationToken;

  /// Whether to store the request and response for later retrieval.
  final bool? store;

  /// Whether to run the model interaction in the background.
  final bool? background;

  /// The service tier for the interaction.
  final ServiceTier? serviceTier;

  /// The environment configuration for the interaction.
  ///
  /// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) or a
  /// string reference ([EnvironmentIdRef]) — an existing environment id, or a
  /// literal such as `"remote"`.
  final EnvironmentConfigOrId? environment;

  /// Webhook configuration for receiving notifications when the interaction
  /// completes.
  final WebhookConfig? webhookConfig;

  /// The labels with user-defined metadata for the request.
  final Map<String, String>? labels;

  /// Safety settings for the interaction.
  final List<InteractionSafetySetting>? safetySettings;

  /// Creates a [CreateModelInteractionParams] instance.
  const CreateModelInteractionParams({
    required this.model,
    this.input,
    this.systemInstruction,
    this.tools,
    this.generationConfig,
    this.responseModalities,
    this.responseMimeType,
    this.responseFormat,
    this.previousInteractionId,
    this.continuationToken,
    this.store,
    this.background,
    this.serviceTier,
    this.environment,
    this.webhookConfig,
    this.labels,
    this.safetySettings,
  });

  /// Creates from JSON.
  factory CreateModelInteractionParams.fromJson(
    Map<String, dynamic> json,
  ) => CreateModelInteractionParams(
    model: json['model'] as String,
    input: json['input'] != null
        ? InteractionInput.fromJson(json['input'] as Object)
        : null,
    systemInstruction: json['system_instruction'] as String?,
    tools: (json['tools'] as List<dynamic>?)
        ?.map((e) => InteractionTool.fromJson(e as Map<String, dynamic>))
        .toList(),
    generationConfig: json['generation_config'] != null
        ? InteractionGenerationConfig.fromJson(
            json['generation_config'] as Map<String, dynamic>,
          )
        : null,
    responseModalities: (json['response_modalities'] as List<dynamic>?)
        ?.map((e) => interactionResponseModalityFromString(e as String))
        .toList(),
    responseMimeType: json['response_mime_type'] as String?,
    responseFormat: json['response_format'] != null
        ? InteractionResponseFormatConfig.fromJson(
            json['response_format'] as Object,
          )
        : null,
    previousInteractionId: json['previous_interaction_id'] as String?,
    continuationToken: json['continuation_token'] as String?,
    store: json['store'] as bool?,
    background: json['background'] as bool?,
    serviceTier: json['service_tier'] != null
        ? serviceTierFromString(json['service_tier'] as String?)
        : null,
    environment: json['environment'] != null
        ? EnvironmentConfigOrId.fromJson(json['environment'] as Object)
        : null,
    webhookConfig: json['webhook_config'] != null
        ? WebhookConfig.fromJson(json['webhook_config'] as Map<String, dynamic>)
        : null,
    labels: (json['labels'] as Map<String, dynamic>?)?.cast<String, String>(),
    safetySettings: (json['safety_settings'] as List<dynamic>?)
        ?.map(
          (e) => InteractionSafetySetting.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  /// Converts to JSON.
  @override
  Map<String, dynamic> toJson() => {
    'model': model,
    if (input != null) 'input': input!.toJson(),
    if (systemInstruction != null) 'system_instruction': systemInstruction,
    if (tools != null) 'tools': tools!.map((e) => e.toJson()).toList(),
    if (generationConfig != null)
      'generation_config': generationConfig!.toJson(),
    if (responseModalities != null)
      'response_modalities': responseModalities!
          .map(interactionResponseModalityToString)
          .toList(),
    if (responseMimeType != null) 'response_mime_type': responseMimeType,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (previousInteractionId != null)
      'previous_interaction_id': previousInteractionId,
    if (continuationToken != null) 'continuation_token': continuationToken,
    if (store != null) 'store': store,
    if (background != null) 'background': background,
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'service_tier': serviceTierToString(serviceTier!),
    if (environment != null) 'environment': environment!.toJson(),
    if (webhookConfig != null) 'webhook_config': webhookConfig!.toJson(),
    if (labels != null) 'labels': labels,
    if (safetySettings != null)
      'safety_settings': safetySettings!.map((e) => e.toJson()).toList(),
  };
}

/// Parameters for creating an interaction with an agent.
class CreateAgentInteractionParams extends CreateInteractionParams {
  /// The name of the agent to use.
  final String agent;

  /// The input for the interaction.
  final InteractionInput? input;

  /// Configuration for the agent.
  final AgentConfig? agentConfig;

  /// System instruction for the interaction.
  final String? systemInstruction;

  /// Tools available to the agent.
  final List<InteractionTool>? tools;

  /// Requested response modalities on the legacy beta wire format.
  final List<InteractionResponseModality>? responseModalities;

  /// Requested response media type on the legacy beta wire format.
  final String? responseMimeType;

  /// Whether to request a streamed response.
  final bool? stream;

  /// Enforces the response format (a single [InteractionResponseFormat] or a list of
  /// them). Used for structured output and per-modality output configuration.
  final InteractionResponseFormatConfig? responseFormat;

  /// The ID of a previous interaction to continue from.
  final String? previousInteractionId;

  /// Opaque continuation token returned by a previous interaction or checkpoint.
  final String? continuationToken;

  /// Whether to store the request and response for later retrieval.
  final bool? store;

  /// Whether to run the agent interaction in the background.
  final bool? background;

  /// The service tier for the interaction.
  final ServiceTier? serviceTier;

  /// The environment configuration for the interaction.
  ///
  /// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) or a
  /// string reference ([EnvironmentIdRef]) — an existing environment id, or a
  /// literal such as `"remote"`.
  final EnvironmentConfigOrId? environment;

  /// Webhook configuration for receiving notifications when the interaction
  /// completes.
  final WebhookConfig? webhookConfig;

  /// The labels with user-defined metadata for the request.
  final Map<String, String>? labels;

  /// Safety settings for the interaction.
  final List<InteractionSafetySetting>? safetySettings;

  /// Creates a [CreateAgentInteractionParams] instance.
  const CreateAgentInteractionParams({
    required this.agent,
    this.input,
    this.agentConfig,
    this.systemInstruction,
    this.tools,
    this.responseModalities,
    this.responseMimeType,
    this.stream,
    this.responseFormat,
    this.previousInteractionId,
    this.continuationToken,
    this.store,
    this.background,
    this.serviceTier,
    this.environment,
    this.webhookConfig,
    this.labels,
    this.safetySettings,
  });

  /// Creates from JSON.
  factory CreateAgentInteractionParams.fromJson(
    Map<String, dynamic> json,
  ) => CreateAgentInteractionParams(
    agent: json['agent'] as String,
    input: json['input'] != null
        ? InteractionInput.fromJson(json['input'] as Object)
        : null,
    agentConfig: json['agent_config'] != null
        ? AgentConfig.fromJson(json['agent_config'] as Map<String, dynamic>)
        : null,
    systemInstruction: json['system_instruction'] as String?,
    tools: (json['tools'] as List<dynamic>?)
        ?.map((tool) => InteractionTool.fromJson(tool as Map<String, dynamic>))
        .toList(),
    responseModalities: (json['response_modalities'] as List<dynamic>?)
        ?.map((value) => interactionResponseModalityFromString(value as String))
        .toList(),
    responseMimeType: json['response_mime_type'] as String?,
    stream: json['stream'] as bool?,
    responseFormat: json['response_format'] != null
        ? InteractionResponseFormatConfig.fromJson(
            json['response_format'] as Object,
          )
        : null,
    previousInteractionId: json['previous_interaction_id'] as String?,
    continuationToken: json['continuation_token'] as String?,
    store: json['store'] as bool?,
    background: json['background'] as bool?,
    serviceTier: json['service_tier'] != null
        ? serviceTierFromString(json['service_tier'] as String?)
        : null,
    environment: json['environment'] != null
        ? EnvironmentConfigOrId.fromJson(json['environment'] as Object)
        : null,
    webhookConfig: json['webhook_config'] != null
        ? WebhookConfig.fromJson(json['webhook_config'] as Map<String, dynamic>)
        : null,
    labels: (json['labels'] as Map<String, dynamic>?)?.cast<String, String>(),
    safetySettings: (json['safety_settings'] as List<dynamic>?)
        ?.map(
          (e) => InteractionSafetySetting.fromJson(e as Map<String, dynamic>),
        )
        .toList(),
  );

  /// Converts to JSON.
  @override
  Map<String, dynamic> toJson() => {
    'agent': agent,
    if (input != null) 'input': input!.toJson(),
    if (agentConfig != null) 'agent_config': agentConfig!.toJson(),
    'system_instruction': ?systemInstruction,
    if (tools != null) 'tools': tools!.map((tool) => tool.toJson()).toList(),
    if (responseModalities != null)
      'response_modalities': responseModalities!
          .map(interactionResponseModalityToString)
          .toList(),
    'response_mime_type': ?responseMimeType,
    'stream': ?stream,
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (previousInteractionId != null)
      'previous_interaction_id': previousInteractionId,
    if (continuationToken != null) 'continuation_token': continuationToken,
    if (store != null) 'store': store,
    if (background != null) 'background': background,
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'service_tier': serviceTierToString(serviceTier!),
    if (environment != null) 'environment': environment!.toJson(),
    if (webhookConfig != null) 'webhook_config': webhookConfig!.toJson(),
    if (labels != null) 'labels': labels,
    if (safetySettings != null)
      'safety_settings': safetySettings!.map((e) => e.toJson()).toList(),
  };
}
