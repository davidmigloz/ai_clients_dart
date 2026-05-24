import '../common/service_tier.dart';
import '../copy_with_sentinel.dart';
import 'agent_config.dart';
import 'environments/environments.dart';
import 'generation_config.dart';
import 'interaction_input.dart';
import 'interaction_status.dart';
import 'response_formats/response_formats.dart';
import 'response_modality.dart';
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

  /// The name of the model used for generating the interaction.
  final String? model;

  /// The name of the agent used for generating the interaction.
  final String? agent;

  /// The time at which the interaction was created (ISO 8601 format).
  final DateTime? created;

  /// The time at which the interaction was last updated (ISO 8601 format).
  final DateTime? updated;

  /// The role of the interaction response.
  final String? role;

  /// The inputs for the interaction.
  ///
  /// Can be a [TextInput], a [StepListInput], a [ContentListInput],
  /// or a [SingleContentInput].
  final InteractionInput? input;

  /// Output only. The steps that make up the interaction.
  final List<InteractionStep>? steps;

  /// Statistics on the interaction request's token usage.
  final InteractionUsage? usage;

  /// The object type of the interaction. Always 'interaction'.
  final String object;

  /// The ID of the previous interaction, if any.
  final String? previousInteractionId;

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
  /// reference to an existing environment by id ([EnvironmentIdRef]).
  final EnvironmentConfigOrId? environment;

  /// Output only. The id of the environment created for this interaction when
  /// an [environment] config was provided.
  final String? environmentId;

  /// Webhook configuration for receiving notifications when the interaction
  /// completes.
  final WebhookConfig? webhookConfig;

  /// Creates an [Interaction] instance.
  const Interaction({
    required this.id,
    required this.status,
    this.model,
    this.agent,
    this.created,
    this.updated,
    this.role,
    this.input,
    this.steps,
    this.usage,
    this.object = 'interaction',
    this.previousInteractionId,
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
  });

  /// Creates an [Interaction] from JSON.
  factory Interaction.fromJson(Map<String, dynamic> json) => Interaction(
    id: json['id'] as String,
    status: InteractionStatus.fromString(json['status'] as String?),
    model: json['model'] as String?,
    agent: json['agent'] as String?,
    created: json['created'] != null
        ? DateTime.parse(json['created'] as String)
        : null,
    updated: json['updated'] != null
        ? DateTime.parse(json['updated'] as String)
        : null,
    role: json['role'] as String?,
    input: json['input'] != null
        ? InteractionInput.fromJson(json['input'] as Object)
        : null,
    steps: (json['steps'] as List<dynamic>?)
        ?.map((e) => InteractionStep.fromJson(e as Map<String, dynamic>))
        .toList(),
    usage: json['usage'] != null
        ? InteractionUsage.fromJson(json['usage'] as Map<String, dynamic>)
        : null,
    object: json['object'] as String? ?? 'interaction',
    previousInteractionId: json['previous_interaction_id'] as String?,
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
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status.toJson(),
    if (model != null) 'model': model,
    if (agent != null) 'agent': agent,
    if (created != null) 'created': created!.toIso8601String(),
    if (updated != null) 'updated': updated!.toIso8601String(),
    if (role != null) 'role': role,
    if (input != null) 'input': input!.toJson(),
    if (steps != null) 'steps': steps!.map((e) => e.toJson()).toList(),
    if (usage != null) 'usage': usage!.toJson(),
    'object': object,
    if (previousInteractionId != null)
      'previous_interaction_id': previousInteractionId,
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
  };

  /// Creates a copy with replaced values.
  Interaction copyWith({
    Object? id = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? model = unsetCopyWithValue,
    Object? agent = unsetCopyWithValue,
    Object? created = unsetCopyWithValue,
    Object? updated = unsetCopyWithValue,
    Object? role = unsetCopyWithValue,
    Object? input = unsetCopyWithValue,
    Object? steps = unsetCopyWithValue,
    Object? usage = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
    Object? previousInteractionId = unsetCopyWithValue,
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
  }) {
    return Interaction(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      status: status == unsetCopyWithValue
          ? this.status
          : status! as InteractionStatus,
      model: model == unsetCopyWithValue ? this.model : model as String?,
      agent: agent == unsetCopyWithValue ? this.agent : agent as String?,
      created: created == unsetCopyWithValue
          ? this.created
          : created as DateTime?,
      updated: updated == unsetCopyWithValue
          ? this.updated
          : updated as DateTime?,
      role: role == unsetCopyWithValue ? this.role : role as String?,
      input: input == unsetCopyWithValue
          ? this.input
          : input as InteractionInput?,
      steps: steps == unsetCopyWithValue
          ? this.steps
          : steps as List<InteractionStep>?,
      usage: usage == unsetCopyWithValue
          ? this.usage
          : usage as InteractionUsage?,
      object: object == unsetCopyWithValue ? this.object : object! as String,
      previousInteractionId: previousInteractionId == unsetCopyWithValue
          ? this.previousInteractionId
          : previousInteractionId as String?,
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
    );
  }
}

/// Parameters for creating an interaction with a model.
class CreateModelInteractionParams {
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

  /// Whether to run the model interaction in the background.
  final bool? background;

  /// The service tier for the interaction.
  final ServiceTier? serviceTier;

  /// The environment configuration for the interaction.
  ///
  /// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) or a
  /// reference to an existing environment by id ([EnvironmentIdRef]).
  final EnvironmentConfigOrId? environment;

  /// Webhook configuration for receiving notifications when the interaction
  /// completes.
  final WebhookConfig? webhookConfig;

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
    this.background,
    this.serviceTier,
    this.environment,
    this.webhookConfig,
  });

  /// Creates from JSON.
  factory CreateModelInteractionParams.fromJson(Map<String, dynamic> json) =>
      CreateModelInteractionParams(
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
        background: json['background'] as bool?,
        serviceTier: json['service_tier'] != null
            ? serviceTierFromString(json['service_tier'] as String?)
            : null,
        environment: json['environment'] != null
            ? EnvironmentConfigOrId.fromJson(json['environment'] as Object)
            : null,
        webhookConfig: json['webhook_config'] != null
            ? WebhookConfig.fromJson(
                json['webhook_config'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
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
    if (background != null) 'background': background,
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'service_tier': serviceTierToString(serviceTier!),
    if (environment != null) 'environment': environment!.toJson(),
    if (webhookConfig != null) 'webhook_config': webhookConfig!.toJson(),
  };
}

/// Parameters for creating an interaction with an agent.
class CreateAgentInteractionParams {
  /// The name of the agent to use.
  final String agent;

  /// The input for the interaction.
  final InteractionInput? input;

  /// Configuration for the agent.
  final AgentConfig? agentConfig;

  /// Enforces the response format (a single [InteractionResponseFormat] or a list of
  /// them). Used for structured output and per-modality output configuration.
  final InteractionResponseFormatConfig? responseFormat;

  /// The ID of a previous interaction to continue from.
  final String? previousInteractionId;

  /// Whether to run the agent interaction in the background.
  final bool? background;

  /// The service tier for the interaction.
  final ServiceTier? serviceTier;

  /// The environment configuration for the interaction.
  ///
  /// Either an inline [EnvironmentConfig] ([InlineEnvironmentConfig]) or a
  /// reference to an existing environment by id ([EnvironmentIdRef]).
  final EnvironmentConfigOrId? environment;

  /// Webhook configuration for receiving notifications when the interaction
  /// completes.
  final WebhookConfig? webhookConfig;

  /// Creates a [CreateAgentInteractionParams] instance.
  const CreateAgentInteractionParams({
    required this.agent,
    this.input,
    this.agentConfig,
    this.responseFormat,
    this.previousInteractionId,
    this.background,
    this.serviceTier,
    this.environment,
    this.webhookConfig,
  });

  /// Creates from JSON.
  factory CreateAgentInteractionParams.fromJson(Map<String, dynamic> json) =>
      CreateAgentInteractionParams(
        agent: json['agent'] as String,
        input: json['input'] != null
            ? InteractionInput.fromJson(json['input'] as Object)
            : null,
        agentConfig: json['agent_config'] != null
            ? AgentConfig.fromJson(json['agent_config'] as Map<String, dynamic>)
            : null,
        responseFormat: json['response_format'] != null
            ? InteractionResponseFormatConfig.fromJson(
                json['response_format'] as Object,
              )
            : null,
        previousInteractionId: json['previous_interaction_id'] as String?,
        background: json['background'] as bool?,
        serviceTier: json['service_tier'] != null
            ? serviceTierFromString(json['service_tier'] as String?)
            : null,
        environment: json['environment'] != null
            ? EnvironmentConfigOrId.fromJson(json['environment'] as Object)
            : null,
        webhookConfig: json['webhook_config'] != null
            ? WebhookConfig.fromJson(
                json['webhook_config'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'agent': agent,
    if (input != null) 'input': input!.toJson(),
    if (agentConfig != null) 'agent_config': agentConfig!.toJson(),
    if (responseFormat != null) 'response_format': responseFormat!.toJson(),
    if (previousInteractionId != null)
      'previous_interaction_id': previousInteractionId,
    if (background != null) 'background': background,
    if (serviceTier != null && serviceTier != ServiceTier.unspecified)
      'service_tier': serviceTierToString(serviceTier!),
    if (environment != null) 'environment': environment!.toJson(),
    if (webhookConfig != null) 'webhook_config': webhookConfig!.toJson(),
  };
}
