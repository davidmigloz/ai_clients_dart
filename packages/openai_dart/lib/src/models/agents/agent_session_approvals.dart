part of 'agent_session_models.dart';

/// A control in a registered browser-login form.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationField extends AgentJsonModel {
  /// Creates a validated [AgentSessionBrowserAuthenticationField].
  AgentSessionBrowserAuthenticationField({
    required this.id,
    required this.label,
    required this.required,
    required this.type,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'label',
         'required',
         'type',
       ], 'AgentSessionBrowserAuthenticationField') {
    validate();
  }

  /// The field ID to submit as field_id in a fields entry.
  final String id;

  /// The label to display beside the control.
  final String label;

  /// Whether this control requires a nonempty value.
  final bool required;

  /// The rendering type, such as email, password, or text.
  final String type;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationField] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationField.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionBrowserAuthenticationField(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionBrowserAuthenticationField.id',
        requireAgentString,
        nullable: false,
      )!,
      label: requiredAgentValue(
        json,
        'label',
        'AgentSessionBrowserAuthenticationField.label',
        requireAgentString,
        nullable: false,
      )!,
      required: requiredAgentValue(
        json,
        'required',
        'AgentSessionBrowserAuthenticationField.required',
        requireAgentBool,
        nullable: false,
      )!,
      type: requiredAgentValue(
        json,
        'type',
        'AgentSessionBrowserAuthenticationField.type',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['id', 'label', 'required', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      id,
      'AgentSessionBrowserAuthenticationField.id',
      min: 0,
    );
    validateAgentLength(
      label,
      'AgentSessionBrowserAuthenticationField.label',
      min: 0,
    );
    validateAgentLength(
      type,
      'AgentSessionBrowserAuthenticationField.type',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'label': label,
    'required': required,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationField copyWith({
    String? id,
    String? label,
    bool? required,
    String? type,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationField(
    id: id ?? this.id,
    label: label ?? this.label,
    required: required ?? this.required,
    type: type ?? this.type,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// One user-entered value, including non-password fields such as an email address.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionBrowserAuthenticationFieldValue extends AgentJsonModel {
  /// Creates a validated [AgentSessionBrowserAuthenticationFieldValue].
  AgentSessionBrowserAuthenticationFieldValue({
    required this.fieldId,
    required this.value,
  }) {
    validate();
  }

  /// The field ID from the required action.
  final String fieldId;

  /// The value to enter into the registered control.
  final String value;

  /// Parses [AgentSessionBrowserAuthenticationFieldValue] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationFieldValue.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'field_id',
      'value',
    ], 'AgentSessionBrowserAuthenticationFieldValue');
    return AgentSessionBrowserAuthenticationFieldValue(
      fieldId: requiredAgentValue(
        json,
        'field_id',
        'AgentSessionBrowserAuthenticationFieldValue.fieldId',
        requireAgentString,
        nullable: false,
      )!,
      value: requiredAgentValue(
        json,
        'value',
        'AgentSessionBrowserAuthenticationFieldValue.value',
        requireAgentString,
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      fieldId,
      'AgentSessionBrowserAuthenticationFieldValue.fieldId',
      min: 0,
      max: 1048576,
    );
    validateAgentLength(
      value,
      'AgentSessionBrowserAuthenticationFieldValue.value',
      min: 0,
      max: 16384,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'field_id': fieldId, 'value': value};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationFieldValue copyWith({
    String? fieldId,
    String? value,
  }) => AgentSessionBrowserAuthenticationFieldValue(
    fieldId: fieldId ?? this.fieldId,
    value: value ?? this.value,
  );
}

/// AgentSessionBrowserAuthenticationHistoryRequestKindResource
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionBrowserAuthenticationHistoryRequestKindResource
    extends AgentJsonModel {
  const AgentSessionBrowserAuthenticationHistoryRequestKindResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionBrowserAuthenticationHistoryRequestKindResource.type',
    )) {
      'browser_authentication' =>
        AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
          json,
        ),
      _ =>
        UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
          json,
        ),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `browser_authentication` contract.
  factory AgentSessionBrowserAuthenticationHistoryRequestKindResource.browserAuthentication({
    required String? credentialOrigin,
    required List<AgentSessionBrowserAuthenticationField> fields,
    required List<AgentSessionBrowserAuthenticationOption> options,
    required String? reason,
    Map<String, dynamic> rawJson,
  }) =
      AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource
    extends AgentSessionBrowserAuthenticationHistoryRequestKindResource {
  const UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource._(
    this.rawJson,
  );

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource.type',
    );
    if (const ['browser_authentication'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource._(
      snapshotAgentJson(
        json,
        'UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource',
      ),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource copyWith({
    Map<String, dynamic>? rawJson,
  }) =>
      UnknownAgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
        rawJson ?? this.rawJson,
      );
}

/// A registered form awaiting the application's response.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication
    extends AgentSessionBrowserAuthenticationHistoryRequestKindResource {
  /// Creates a validated [AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication].
  AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication({
    required this.credentialOrigin,
    required List<AgentSessionBrowserAuthenticationField> fields,
    required List<AgentSessionBrowserAuthenticationOption> options,
    required this.reason,
    Map<String, dynamic> rawJson = const {},
  }) : fields = List.unmodifiable(fields),
       options = List.unmodifiable(options),
       rawJson = agentExtras(
         rawJson,
         const ['credential_origin', 'fields', 'options', 'reason', 'type'],
         'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
       ) {
    validate();
  }

  /// The registered form or frame origin where values will be entered.
  final String? credentialOrigin;

  /// Controls to render. All submitted values are sensitive.
  final List<AgentSessionBrowserAuthenticationField> fields;

  /// Sign-in methods. Empty for a plain form.
  final List<AgentSessionBrowserAuthenticationOption> options;

  /// Why the agent needs the user to sign in.
  final String? reason;

  /// The type of the object. Always `browser_authentication`.
  @override
  String get type => 'browser_authentication';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication',
    );
    return AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication(
      credentialOrigin: requiredAgentValue(
        json,
        'credential_origin',
        'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.credentialOrigin',
        requireAgentString,
        nullable: true,
      ),
      fields: requiredAgentValue(
        json,
        'fields',
        'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fields',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionBrowserAuthenticationField.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      options: requiredAgentValue(
        json,
        'options',
        'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.options',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionBrowserAuthenticationOption.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      reason: requiredAgentValue(
        json,
        'reason',
        'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.reason',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'credential_origin',
            'fields',
            'options',
            'reason',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (credentialOrigin != null) {
      validateAgentLength(
        credentialOrigin!,
        'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.credentialOrigin',
        min: 0,
      );
    }
    validateAgentCount(
      fields.length,
      'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.fields',
      min: 0,
      max: 2000,
    );
    for (final item in fields) {
      item.validate();
    }
    validateAgentCount(
      options.length,
      'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.options',
      min: 0,
      max: 2000,
    );
    for (final item in options) {
      item.validate();
    }
    if (reason != null) {
      validateAgentLength(
        reason!,
        'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.reason',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'credential_origin': credentialOrigin,
    'fields': fields.map((value) => value.toJson()).toList(),
    'options': options.map((value) => value.toJson()).toList(),
    'reason': reason,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication
  copyWith({
    Object? credentialOrigin = unsetCopyWithValue,
    List<AgentSessionBrowserAuthenticationField>? fields,
    List<AgentSessionBrowserAuthenticationOption>? options,
    Object? reason = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication(
    credentialOrigin: copyAgentValue<String>(
      credentialOrigin,
      this.credentialOrigin,
      'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.credentialOrigin',
    ),
    fields: fields ?? this.fields,
    options: options ?? this.options,
    reason: copyAgentValue<String>(
      reason,
      this.reason,
      'AgentSessionBrowserAuthenticationHistoryRequestKindResourceBrowserAuthentication.reason',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A sign-in method and the fields that belong to it.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationOption extends AgentJsonModel {
  /// Creates a validated [AgentSessionBrowserAuthenticationOption].
  AgentSessionBrowserAuthenticationOption({
    required List<String> fieldIds,
    required this.id,
    required this.label,
    Map<String, dynamic> rawJson = const {},
  }) : fieldIds = List.unmodifiable(fieldIds),
       rawJson = agentExtras(rawJson, const [
         'field_ids',
         'id',
         'label',
       ], 'AgentSessionBrowserAuthenticationOption') {
    validate();
  }

  /// IDs from the registered fields that this method accepts.
  final List<String> fieldIds;

  /// The option ID to submit as selected_option.
  final String id;

  /// The method label to display.
  final String label;

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationOption] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationOption.fromJson(
    Map<String, dynamic> json,
  ) {
    return AgentSessionBrowserAuthenticationOption(
      fieldIds: requiredAgentValue(
        json,
        'field_ids',
        'AgentSessionBrowserAuthenticationOption.fieldIds',
        (value, context) => requireAgentList(
          value,
          context,
        ).map((value) => requireAgentString(value, context)).toList(),
        nullable: false,
      )!,
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionBrowserAuthenticationOption.id',
        requireAgentString,
        nullable: false,
      )!,
      label: requiredAgentValue(
        json,
        'label',
        'AgentSessionBrowserAuthenticationOption.label',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const ['field_ids', 'id', 'label'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentCount(
      fieldIds.length,
      'AgentSessionBrowserAuthenticationOption.fieldIds',
      min: 0,
      max: 2000,
    );
    for (final item in fieldIds) {
      validateAgentLength(
        item,
        'AgentSessionBrowserAuthenticationOption.fieldIds',
        min: 0,
      );
    }
    validateAgentLength(
      id,
      'AgentSessionBrowserAuthenticationOption.id',
      min: 0,
    );
    validateAgentLength(
      label,
      'AgentSessionBrowserAuthenticationOption.label',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'field_ids': fieldIds.map((value) => value).toList(),
    'id': id,
    'label': label,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationOption copyWith({
    List<String>? fieldIds,
    String? id,
    String? label,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationOption(
    fieldIds: fieldIds ?? this.fieldIds,
    id: id ?? this.id,
    label: label ?? this.label,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A credential-free history record of the emitted login request.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationRequestItemResource
    extends AgentSessionOutputItem
    implements
        // Canonical overlapping unions inherit the same equality/hash behavior.
        // ignore: avoid_implementing_value_types
        AgentSessionTurnItem {
  /// Creates a validated [AgentSessionBrowserAuthenticationRequestItemResource].
  AgentSessionBrowserAuthenticationRequestItemResource({
    required this.id,
    required this.request,
    required this.requestId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'request',
         'request_id',
         'turn_id',
         'type',
       ], 'AgentSessionBrowserAuthenticationRequestItemResource') {
    validate();
  }

  /// The stable history item ID.
  final String id;

  /// The `request` field.
  final AgentSessionBrowserAuthenticationHistoryRequestKindResource request;

  /// The `request_id` field.
  final String requestId;

  /// The `turn_id` field.
  final String turnId;

  /// The item type. Always computer_use_approval_request.
  @override
  String get type => 'computer_use_approval_request';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationRequestItemResource] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationRequestItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'computer_use_approval_request',
      'AgentSessionBrowserAuthenticationRequestItemResource',
    );
    return AgentSessionBrowserAuthenticationRequestItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionBrowserAuthenticationRequestItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      request: requiredAgentValue(
        json,
        'request',
        'AgentSessionBrowserAuthenticationRequestItemResource.request',
        (value, context) =>
            AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
              requireAgentObject(value, context),
            ),
        nullable: false,
      )!,
      requestId: requiredAgentValue(
        json,
        'request_id',
        'AgentSessionBrowserAuthenticationRequestItemResource.requestId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionBrowserAuthenticationRequestItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'request',
            'request_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      id,
      'AgentSessionBrowserAuthenticationRequestItemResource.id',
      min: 0,
    );
    request.validate();
    validateAgentLength(
      requestId,
      'AgentSessionBrowserAuthenticationRequestItemResource.requestId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionBrowserAuthenticationRequestItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'request': request.toJson(),
    'request_id': requestId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationRequestItemResource copyWith({
    String? id,
    AgentSessionBrowserAuthenticationHistoryRequestKindResource? request,
    String? requestId,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationRequestItemResource(
    id: id ?? this.id,
    request: request ?? this.request,
    requestId: requestId ?? this.requestId,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AgentSessionComputerUseApprovalRequestKind
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionComputerUseApprovalRequestKind extends AgentJsonModel {
  const AgentSessionComputerUseApprovalRequestKind();

  /// Parses a known contract or detached future received value.
  factory AgentSessionComputerUseApprovalRequestKind.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionComputerUseApprovalRequestKind.type',
    )) {
      'browser_authentication' =>
        AgentSessionBrowserAuthenticationRequest.fromJson(json),
      'browser_origin_access' =>
        AgentSessionBrowserOriginAccessRequest.fromJson(json),
      _ => UnknownAgentSessionComputerUseApprovalRequestKind.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `browser_authentication` contract.
  factory AgentSessionComputerUseApprovalRequestKind.browserAuthentication({
    required String? credentialOrigin,
    required List<AgentSessionBrowserAuthenticationField> fields,
    required List<AgentSessionBrowserAuthenticationOption> options,
    required String? reason,
    Map<String, dynamic> rawJson,
  }) = AgentSessionBrowserAuthenticationRequest;

  /// Builds the `browser_origin_access` contract.
  factory AgentSessionComputerUseApprovalRequestKind.browserOriginAccess({
    required String origin,
    required String? reason,
    Map<String, dynamic> rawJson,
  }) = AgentSessionBrowserOriginAccessRequest;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionComputerUseApprovalRequestKind
    extends AgentSessionComputerUseApprovalRequestKind {
  const UnknownAgentSessionComputerUseApprovalRequestKind._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionComputerUseApprovalRequestKind.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionComputerUseApprovalRequestKind.type',
    );
    if (const [
      'browser_authentication',
      'browser_origin_access',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionComputerUseApprovalRequestKind: expected a future discriminator',
      );
    }
    return UnknownAgentSessionComputerUseApprovalRequestKind._(
      snapshotAgentJson(
        json,
        'UnknownAgentSessionComputerUseApprovalRequestKind',
      ),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionComputerUseApprovalRequestKind copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionComputerUseApprovalRequestKind.fromJson(
    rawJson ?? this.rawJson,
  );
}

/// A registered form awaiting the application's response.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationRequest
    extends AgentSessionComputerUseApprovalRequestKind {
  /// Creates a validated [AgentSessionBrowserAuthenticationRequest].
  AgentSessionBrowserAuthenticationRequest({
    required this.credentialOrigin,
    required List<AgentSessionBrowserAuthenticationField> fields,
    required List<AgentSessionBrowserAuthenticationOption> options,
    required this.reason,
    Map<String, dynamic> rawJson = const {},
  }) : fields = List.unmodifiable(fields),
       options = List.unmodifiable(options),
       rawJson = agentExtras(rawJson, const [
         'credential_origin',
         'fields',
         'options',
         'reason',
         'type',
       ], 'AgentSessionBrowserAuthenticationRequest') {
    validate();
  }

  /// The registered form or frame origin where values will be entered.
  final String? credentialOrigin;

  /// Controls to render. All submitted values are sensitive.
  final List<AgentSessionBrowserAuthenticationField> fields;

  /// Sign-in methods. Empty for a plain form.
  final List<AgentSessionBrowserAuthenticationOption> options;

  /// Why the agent needs the user to sign in.
  final String? reason;

  /// The type of the object. Always `browser_authentication`.
  @override
  String get type => 'browser_authentication';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationRequest] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationRequest',
    );
    return AgentSessionBrowserAuthenticationRequest(
      credentialOrigin: requiredAgentValue(
        json,
        'credential_origin',
        'AgentSessionBrowserAuthenticationRequest.credentialOrigin',
        requireAgentString,
        nullable: true,
      ),
      fields: requiredAgentValue(
        json,
        'fields',
        'AgentSessionBrowserAuthenticationRequest.fields',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionBrowserAuthenticationField.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      options: requiredAgentValue(
        json,
        'options',
        'AgentSessionBrowserAuthenticationRequest.options',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionBrowserAuthenticationOption.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      reason: requiredAgentValue(
        json,
        'reason',
        'AgentSessionBrowserAuthenticationRequest.reason',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'credential_origin',
            'fields',
            'options',
            'reason',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (credentialOrigin != null) {
      validateAgentLength(
        credentialOrigin!,
        'AgentSessionBrowserAuthenticationRequest.credentialOrigin',
        min: 0,
      );
    }
    validateAgentCount(
      fields.length,
      'AgentSessionBrowserAuthenticationRequest.fields',
      min: 0,
      max: 2000,
    );
    for (final item in fields) {
      item.validate();
    }
    validateAgentCount(
      options.length,
      'AgentSessionBrowserAuthenticationRequest.options',
      min: 0,
      max: 2000,
    );
    for (final item in options) {
      item.validate();
    }
    if (reason != null) {
      validateAgentLength(
        reason!,
        'AgentSessionBrowserAuthenticationRequest.reason',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'credential_origin': credentialOrigin,
    'fields': fields.map((value) => value.toJson()).toList(),
    'options': options.map((value) => value.toJson()).toList(),
    'reason': reason,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationRequest copyWith({
    Object? credentialOrigin = unsetCopyWithValue,
    List<AgentSessionBrowserAuthenticationField>? fields,
    List<AgentSessionBrowserAuthenticationOption>? options,
    Object? reason = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationRequest(
    credentialOrigin: copyAgentValue<String>(
      credentialOrigin,
      this.credentialOrigin,
      'AgentSessionBrowserAuthenticationRequest.credentialOrigin',
    ),
    fields: fields ?? this.fields,
    options: options ?? this.options,
    reason: copyAgentValue<String>(
      reason,
      this.reason,
      'AgentSessionBrowserAuthenticationRequest.reason',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A browser origin awaiting the application's approval decision.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserOriginAccessRequest
    extends AgentSessionComputerUseApprovalRequestKind {
  /// Creates a validated [AgentSessionBrowserOriginAccessRequest].
  AgentSessionBrowserOriginAccessRequest({
    required this.origin,
    required this.reason,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'origin',
         'reason',
         'type',
       ], 'AgentSessionBrowserOriginAccessRequest') {
    validate();
  }

  /// The origin the browser needs permission to access.
  final String origin;

  /// The browser's explanation for this request, or null when unavailable.
  final String? reason;

  /// The type of the object. Always `browser_origin_access`.
  @override
  String get type => 'browser_origin_access';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserOriginAccessRequest] with contextual, payload-free errors.
  factory AgentSessionBrowserOriginAccessRequest.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'browser_origin_access',
      'AgentSessionBrowserOriginAccessRequest',
    );
    return AgentSessionBrowserOriginAccessRequest(
      origin: requiredAgentValue(
        json,
        'origin',
        'AgentSessionBrowserOriginAccessRequest.origin',
        requireAgentString,
        nullable: false,
      )!,
      reason: requiredAgentValue(
        json,
        'reason',
        'AgentSessionBrowserOriginAccessRequest.reason',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['origin', 'reason', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      origin,
      'AgentSessionBrowserOriginAccessRequest.origin',
      min: 0,
    );
    if (reason != null) {
      validateAgentLength(
        reason!,
        'AgentSessionBrowserOriginAccessRequest.reason',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'origin': origin,
    'reason': reason,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserOriginAccessRequest copyWith({
    String? origin,
    Object? reason = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserOriginAccessRequest(
    origin: origin ?? this.origin,
    reason: copyAgentValue<String>(
      reason,
      this.reason,
      'AgentSessionBrowserOriginAccessRequest.reason',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// A credential-free record of an admitted response, not proof of completion.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionComputerUseApprovalRequestResultItemResource
    extends AgentSessionTurnItem {
  /// Creates a validated [AgentSessionComputerUseApprovalRequestResultItemResource].
  AgentSessionComputerUseApprovalRequestResultItemResource({
    required this.id,
    required this.requestId,
    required this.response,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'id',
         'request_id',
         'response',
         'turn_id',
         'type',
       ], 'AgentSessionComputerUseApprovalRequestResultItemResource') {
    validate();
  }

  /// The stable history item ID.
  final String id;

  /// The registered request answered by this item.
  final String requestId;

  /// The admitted response, without submitted credential values.
  final AgentSessionBrowserAuthenticationResponseResource response;

  /// The ID of the turn that contains this item.
  final String turnId;

  /// The `type` field.
  @override
  String get type => 'computer_use_approval_request_result';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionComputerUseApprovalRequestResultItemResource] with contextual, payload-free errors.
  factory AgentSessionComputerUseApprovalRequestResultItemResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'computer_use_approval_request_result',
      'AgentSessionComputerUseApprovalRequestResultItemResource',
    );
    return AgentSessionComputerUseApprovalRequestResultItemResource(
      id: requiredAgentValue(
        json,
        'id',
        'AgentSessionComputerUseApprovalRequestResultItemResource.id',
        requireAgentString,
        nullable: false,
      )!,
      requestId: requiredAgentValue(
        json,
        'request_id',
        'AgentSessionComputerUseApprovalRequestResultItemResource.requestId',
        requireAgentString,
        nullable: false,
      )!,
      response: requiredAgentValue(
        json,
        'response',
        'AgentSessionComputerUseApprovalRequestResultItemResource.response',
        (value, context) =>
            AgentSessionBrowserAuthenticationResponseResource.fromJson(
              requireAgentObject(value, context),
            ),
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionComputerUseApprovalRequestResultItemResource.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'id',
            'request_id',
            'response',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    validateAgentLength(
      id,
      'AgentSessionComputerUseApprovalRequestResultItemResource.id',
      min: 0,
    );
    validateAgentLength(
      requestId,
      'AgentSessionComputerUseApprovalRequestResultItemResource.requestId',
      min: 0,
    );
    response.validate();
    validateAgentLength(
      turnId,
      'AgentSessionComputerUseApprovalRequestResultItemResource.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'id': id,
    'request_id': requestId,
    'response': response.toJson(),
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionComputerUseApprovalRequestResultItemResource copyWith({
    String? id,
    String? requestId,
    AgentSessionBrowserAuthenticationResponseResource? response,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionComputerUseApprovalRequestResultItemResource(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    response: response ?? this.response,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AgentSessionBrowserAuthenticationResponseResource
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionBrowserAuthenticationResponseResource
    extends AgentJsonModel {
  const AgentSessionBrowserAuthenticationResponseResource();

  /// Parses a known contract or detached future received value.
  factory AgentSessionBrowserAuthenticationResponseResource.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['action'],
      'AgentSessionBrowserAuthenticationResponseResource.action',
    )) {
      'cancel' => AgentSessionBrowserAuthenticationCancelResource.fromJson(
        json,
      ),
      'submit' => AgentSessionBrowserAuthenticationSubmitResource.fromJson(
        json,
      ),
      _ => UnknownAgentSessionBrowserAuthenticationResponseResource.fromJson(
        json,
      ),
    };
  }

  /// Canonical `action` discriminator.
  String get action;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `cancel` contract.
  factory AgentSessionBrowserAuthenticationResponseResource.cancel({
    Map<String, dynamic> rawJson,
  }) = AgentSessionBrowserAuthenticationCancelResource;

  /// Builds the `submit` contract.
  factory AgentSessionBrowserAuthenticationResponseResource.submit({
    required String? selectedOption,
    Map<String, dynamic> rawJson,
  }) = AgentSessionBrowserAuthenticationSubmitResource;
}

/// Detached future `action` value with private diagnostics.
final class UnknownAgentSessionBrowserAuthenticationResponseResource
    extends AgentSessionBrowserAuthenticationResponseResource {
  const UnknownAgentSessionBrowserAuthenticationResponseResource._(
    this.rawJson,
  );

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionBrowserAuthenticationResponseResource.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['action'],
      'UnknownAgentSessionBrowserAuthenticationResponseResource.action',
    );
    if (const ['cancel', 'submit'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionBrowserAuthenticationResponseResource: expected a future discriminator',
      );
    }
    return UnknownAgentSessionBrowserAuthenticationResponseResource._(
      snapshotAgentJson(
        json,
        'UnknownAgentSessionBrowserAuthenticationResponseResource',
      ),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get action => rawJson['action'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionBrowserAuthenticationResponseResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionBrowserAuthenticationResponseResource.fromJson(
    rawJson ?? this.rawJson,
  );
}

/// AgentSessionBrowserAuthenticationCancelResource
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationCancelResource
    extends AgentSessionBrowserAuthenticationResponseResource {
  /// Creates a validated [AgentSessionBrowserAuthenticationCancelResource].
  AgentSessionBrowserAuthenticationCancelResource({
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'action',
         'type',
       ], 'AgentSessionBrowserAuthenticationCancelResource') {
    validate();
  }

  /// The `action` field.
  @override
  String get action => 'cancel';

  /// The `type` field.
  String get type => 'browser_authentication';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationCancelResource] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationCancelResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'action',
      'cancel',
      'AgentSessionBrowserAuthenticationCancelResource',
    );
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationCancelResource',
    );
    return AgentSessionBrowserAuthenticationCancelResource(
      rawJson: {
        for (final entry in json.entries)
          if (!const ['action', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {...rawJson, 'action': action, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationCancelResource copyWith({
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationCancelResource(
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AgentSessionBrowserAuthenticationSubmitResource
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionBrowserAuthenticationSubmitResource
    extends AgentSessionBrowserAuthenticationResponseResource {
  /// Creates a validated [AgentSessionBrowserAuthenticationSubmitResource].
  AgentSessionBrowserAuthenticationSubmitResource({
    required this.selectedOption,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'action',
         'selected_option',
         'type',
       ], 'AgentSessionBrowserAuthenticationSubmitResource') {
    validate();
  }

  /// The `action` field.
  @override
  String get action => 'submit';

  /// The chosen sign-in method, or null when no options were offered.
  final String? selectedOption;

  /// The `type` field.
  String get type => 'browser_authentication';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionBrowserAuthenticationSubmitResource] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationSubmitResource.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'action',
      'submit',
      'AgentSessionBrowserAuthenticationSubmitResource',
    );
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationSubmitResource',
    );
    return AgentSessionBrowserAuthenticationSubmitResource(
      selectedOption: requiredAgentValue(
        json,
        'selected_option',
        'AgentSessionBrowserAuthenticationSubmitResource.selectedOption',
        requireAgentString,
        nullable: true,
      ),
      rawJson: {
        for (final entry in json.entries)
          if (!const ['action', 'selected_option', 'type'].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    if (selectedOption != null) {
      validateAgentLength(
        selectedOption!,
        'AgentSessionBrowserAuthenticationSubmitResource.selectedOption',
        min: 0,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'action': action,
    'selected_option': selectedOption,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationSubmitResource copyWith({
    Object? selectedOption = unsetCopyWithValue,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionBrowserAuthenticationSubmitResource(
    selectedOption: copyAgentValue<String>(
      selectedOption,
      this.selectedOption,
      'AgentSessionBrowserAuthenticationSubmitResource.selectedOption',
    ),
    rawJson: rawJson ?? this.rawJson,
  );
}

/// AgentSessionComputerUseApprovalResponse
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionComputerUseApprovalResponse extends AgentJsonModel {
  const AgentSessionComputerUseApprovalResponse();

  /// Parses a known contract or detached future received value.
  factory AgentSessionComputerUseApprovalResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return switch (requireAgentString(
      json['type'],
      'AgentSessionComputerUseApprovalResponse.type',
    )) {
      'browser_authentication' =>
        AgentSessionBrowserAuthenticationResponse.fromJson(json),
      'browser_origin_access' =>
        AgentSessionBrowserOriginAccessResponse.fromJson(json),
      _ => UnknownAgentSessionComputerUseApprovalResponse.fromJson(json),
    };
  }

  /// Canonical `type` discriminator.
  String get type;
  @override
  Map<String, dynamic> toJson();

  /// Builds the `browser_origin_access` contract.
  factory AgentSessionComputerUseApprovalResponse.browserOriginAccess({
    required AgentSessionBrowserOriginAccessDecision decision,
  }) = AgentSessionBrowserOriginAccessResponse;
}

/// Detached future `type` value with private diagnostics.
final class UnknownAgentSessionComputerUseApprovalResponse
    extends AgentSessionComputerUseApprovalResponse {
  const UnknownAgentSessionComputerUseApprovalResponse._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionComputerUseApprovalResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['type'],
      'UnknownAgentSessionComputerUseApprovalResponse.type',
    );
    if (const [
      'browser_authentication',
      'browser_origin_access',
    ].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionComputerUseApprovalResponse: expected a future discriminator',
      );
    }
    return UnknownAgentSessionComputerUseApprovalResponse._(
      snapshotAgentJson(json, 'UnknownAgentSessionComputerUseApprovalResponse'),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get type => rawJson['type'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionComputerUseApprovalResponse copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionComputerUseApprovalResponse.fromJson(
    rawJson ?? this.rawJson,
  );
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionComputerUseApprovalResponse: future input is not writable',
  );
}

/// AgentSessionBrowserAuthenticationResponse
/// Private diagnostics; known variants are parsed strictly.
sealed class AgentSessionBrowserAuthenticationResponse
    extends AgentSessionComputerUseApprovalResponse {
  const AgentSessionBrowserAuthenticationResponse();

  /// Parses a known contract or detached future received value.
  factory AgentSessionBrowserAuthenticationResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationResponse',
    );
    return switch (requireAgentString(
      json['action'],
      'AgentSessionBrowserAuthenticationResponse.action',
    )) {
      'cancel' => AgentSessionBrowserAuthenticationCancel.fromJson(json),
      'submit' => AgentSessionBrowserAuthenticationSubmit.fromJson(json),
      _ => UnknownAgentSessionBrowserAuthenticationResponse.fromJson(json),
    };
  }

  /// Canonical `action` discriminator.
  String get action;
  @override
  Map<String, dynamic> toJson();
  @override
  String get type => 'browser_authentication';

  /// Builds the `cancel` contract.
  factory AgentSessionBrowserAuthenticationResponse.cancel() =
      AgentSessionBrowserAuthenticationCancel;

  /// Builds the `submit` contract.
  factory AgentSessionBrowserAuthenticationResponse.submit({
    required List<AgentSessionBrowserAuthenticationFieldValue> fields,
    String? selectedOption,
    bool clearSelectedOption,
  }) = AgentSessionBrowserAuthenticationSubmit;
}

/// Detached future `action` value with private diagnostics.
final class UnknownAgentSessionBrowserAuthenticationResponse
    extends AgentSessionBrowserAuthenticationResponse {
  const UnknownAgentSessionBrowserAuthenticationResponse._(this.rawJson);

  /// Parses only unknown discriminators; known malformed values are rejected.
  factory UnknownAgentSessionBrowserAuthenticationResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final tag = requireAgentString(
      json['action'],
      'UnknownAgentSessionBrowserAuthenticationResponse.action',
    );
    if (const ['cancel', 'submit'].contains(tag)) {
      throw const FormatException(
        'UnknownAgentSessionBrowserAuthenticationResponse: expected a future discriminator',
      );
    }
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'UnknownAgentSessionBrowserAuthenticationResponse',
    );
    return UnknownAgentSessionBrowserAuthenticationResponse._(
      snapshotAgentJson(
        json,
        'UnknownAgentSessionBrowserAuthenticationResponse',
      ),
    );
  }

  /// Finite detached received snapshot; never an executable instruction.
  final Map<String, dynamic> rawJson;
  @override
  String get action => rawJson['action'] as String;
  @override
  Map<String, dynamic> toJson() => Map.of(rawJson);

  /// Replaces a received snapshot while retaining the unknown discriminator.
  UnknownAgentSessionBrowserAuthenticationResponse copyWith({
    Map<String, dynamic>? rawJson,
  }) => UnknownAgentSessionBrowserAuthenticationResponse.fromJson(
    rawJson ?? this.rawJson,
  );
  @override
  void validate() => throw const FormatException(
    'UnknownAgentSessionBrowserAuthenticationResponse: future input is not writable',
  );
}

/// AgentSessionBrowserAuthenticationCancel
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionBrowserAuthenticationCancel
    extends AgentSessionBrowserAuthenticationResponse {
  /// Creates a validated [AgentSessionBrowserAuthenticationCancel].
  AgentSessionBrowserAuthenticationCancel() {
    validate();
  }

  /// The `action` field.
  @override
  String get action => 'cancel';

  /// The `type` field.
  @override
  String get type => 'browser_authentication';

  /// Parses [AgentSessionBrowserAuthenticationCancel] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationCancel.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'action',
      'type',
    ], 'AgentSessionBrowserAuthenticationCancel');
    requireAgentTag(
      json,
      'action',
      'cancel',
      'AgentSessionBrowserAuthenticationCancel',
    );
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationCancel',
    );
    return AgentSessionBrowserAuthenticationCancel();
  }
  @override
  void validate() {}
  @override
  Map<String, dynamic> toJson() => {'action': action, 'type': type};

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationCancel copyWith() =>
      AgentSessionBrowserAuthenticationCancel();
}

/// AgentSessionBrowserAuthenticationSubmit
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionBrowserAuthenticationSubmit
    extends AgentSessionBrowserAuthenticationResponse {
  /// Creates a validated [AgentSessionBrowserAuthenticationSubmit].
  AgentSessionBrowserAuthenticationSubmit({
    required List<AgentSessionBrowserAuthenticationFieldValue> fields,
    String? selectedOption,
    bool clearSelectedOption = false,
  }) : fields = List.unmodifiable(fields),
       clearSelectedOption = clearSelectedOption,
       selectedOption = clearSelectedOption ? null : selectedOption {
    validate();
  }

  /// The `action` field.
  @override
  String get action => 'submit';

  /// Values for up to six active fields in the required action. The submitted field-value mapping and selected option must fit within 120 KiB of JSON.
  final List<AgentSessionBrowserAuthenticationFieldValue> fields;

  /// The chosen method. Required when the required action contains options.
  final String? selectedOption;

  /// Sends `selected_option: null`, rather than omitting it.
  final bool clearSelectedOption;

  /// The `type` field.
  @override
  String get type => 'browser_authentication';

  /// Parses [AgentSessionBrowserAuthenticationSubmit] with contextual, payload-free errors.
  factory AgentSessionBrowserAuthenticationSubmit.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'action',
      'fields',
      'selected_option',
      'type',
    ], 'AgentSessionBrowserAuthenticationSubmit');
    requireAgentTag(
      json,
      'action',
      'submit',
      'AgentSessionBrowserAuthenticationSubmit',
    );
    requireAgentTag(
      json,
      'type',
      'browser_authentication',
      'AgentSessionBrowserAuthenticationSubmit',
    );
    return AgentSessionBrowserAuthenticationSubmit(
      fields: requiredAgentValue(
        json,
        'fields',
        'AgentSessionBrowserAuthenticationSubmit.fields',
        (value, context) => requireAgentList(value, context)
            .map(
              (value) => AgentSessionBrowserAuthenticationFieldValue.fromJson(
                requireAgentObject(value, context),
              ),
            )
            .toList(),
        nullable: false,
      )!,
      selectedOption: optionalAgentValue(
        json,
        'selected_option',
        'AgentSessionBrowserAuthenticationSubmit.selectedOption',
        requireAgentString,
        nullable: true,
      ),
      clearSelectedOption:
          json.containsKey('selected_option') &&
          json['selected_option'] == null,
    );
  }
  @override
  void validate() {
    _validateAgentSessionAuthenticationBudget(toJson());
    validateAgentCount(
      fields.length,
      'AgentSessionBrowserAuthenticationSubmit.fields',
      min: 0,
      max: 6,
    );
    for (final item in fields) {
      item.validate();
    }
    if (selectedOption != null) {
      validateAgentLength(
        selectedOption!,
        'AgentSessionBrowserAuthenticationSubmit.selectedOption',
        min: 0,
        max: 1048576,
      );
    }
  }

  @override
  Map<String, dynamic> toJson() => {
    'action': action,
    'fields': fields.map((value) => value.toJson()).toList(),
    if (clearSelectedOption)
      'selected_option': null
    else
      'selected_option': ?selectedOption,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserAuthenticationSubmit copyWith({
    List<AgentSessionBrowserAuthenticationFieldValue>? fields,
    Object? selectedOption = unsetCopyWithValue,
    bool? clearSelectedOption,
  }) => AgentSessionBrowserAuthenticationSubmit(
    fields: fields ?? this.fields,
    selectedOption: copyAgentValue<String>(
      selectedOption,
      this.selectedOption,
      'AgentSessionBrowserAuthenticationSubmit.selectedOption',
    ),
    clearSelectedOption:
        clearSelectedOption ??
        (identical(selectedOption, unsetCopyWithValue)
            ? this.clearSelectedOption
            : selectedOption == null),
  );
}

/// AgentSessionBrowserOriginAccessResponse
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionBrowserOriginAccessResponse
    extends AgentSessionComputerUseApprovalResponse {
  /// Creates a validated [AgentSessionBrowserOriginAccessResponse].
  AgentSessionBrowserOriginAccessResponse({required this.decision}) {
    validate();
  }

  /// Whether to allow, deny, or cancel the requested origin access.
  final AgentSessionBrowserOriginAccessDecision decision;

  /// The `type` field.
  @override
  String get type => 'browser_origin_access';

  /// Parses [AgentSessionBrowserOriginAccessResponse] with contextual, payload-free errors.
  factory AgentSessionBrowserOriginAccessResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    requireClosedAgentJson(json, const [
      'decision',
      'type',
    ], 'AgentSessionBrowserOriginAccessResponse');
    requireAgentTag(
      json,
      'type',
      'browser_origin_access',
      'AgentSessionBrowserOriginAccessResponse',
    );
    return AgentSessionBrowserOriginAccessResponse(
      decision: requiredAgentValue(
        json,
        'decision',
        'AgentSessionBrowserOriginAccessResponse.decision',
        (value, context) =>
            AgentSessionBrowserOriginAccessDecision.fromJson(value),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentEnum(decision.value, [
      'approve',
      'deny',
      'cancel',
    ], 'AgentSessionBrowserOriginAccessResponse.decision');
  }

  @override
  Map<String, dynamic> toJson() => {
    'decision': decision.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionBrowserOriginAccessResponse copyWith({
    AgentSessionBrowserOriginAccessDecision? decision,
  }) => AgentSessionBrowserOriginAccessResponse(
    decision: decision ?? this.decision,
  );
}

/// Responds to a pending Computer Use approval request.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
/// Optional nullable fields use `clearX: true` to send explicit JSON null.
/// Clearing wins over a simultaneous value; copy omission retains presence.
final class AgentSessionApprovalResultInput extends AgentSessionInput {
  /// Creates a validated [AgentSessionApprovalResultInput].
  AgentSessionApprovalResultInput({
    required this.requestId,
    required this.response,
  }) {
    validate();
  }

  /// The registered request ID from the required action.
  final String requestId;

  /// The response for this request type.
  final AgentSessionComputerUseApprovalResponse response;

  /// The type of the object. Always `agent.session.input.computer_use_approval_request_result`.
  @override
  String get type => 'agent.session.input.computer_use_approval_request_result';

  /// Parses [AgentSessionApprovalResultInput] with contextual, payload-free errors.
  factory AgentSessionApprovalResultInput.fromJson(Map<String, dynamic> json) {
    requireClosedAgentJson(json, const [
      'request_id',
      'response',
      'type',
    ], 'AgentSessionApprovalResultInput');
    requireAgentTag(
      json,
      'type',
      'agent.session.input.computer_use_approval_request_result',
      'AgentSessionApprovalResultInput',
    );
    return AgentSessionApprovalResultInput(
      requestId: requiredAgentValue(
        json,
        'request_id',
        'AgentSessionApprovalResultInput.requestId',
        requireAgentString,
        nullable: false,
      )!,
      response: requiredAgentValue(
        json,
        'response',
        'AgentSessionApprovalResultInput.response',
        (value, context) => AgentSessionComputerUseApprovalResponse.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
    );
  }
  @override
  void validate() {
    validateAgentLength(
      requestId,
      'AgentSessionApprovalResultInput.requestId',
      min: 0,
      max: 1048576,
    );
    response.validate();
  }

  @override
  Map<String, dynamic> toJson() => {
    'request_id': requestId,
    'response': response.toJson(),
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionApprovalResultInput copyWith({
    String? requestId,
    AgentSessionComputerUseApprovalResponse? response,
  }) => AgentSessionApprovalResultInput(
    requestId: requestId ?? this.requestId,
    response: response ?? this.response,
  );
}

/// Respond to a computer-use request.
///
/// Diagnostics redact all payloads. Collections are detached and immutable.
final class AgentSessionComputerUseApprovalRequiredAction
    extends AgentSessionRequiredAction {
  /// Creates a validated [AgentSessionComputerUseApprovalRequiredAction].
  AgentSessionComputerUseApprovalRequiredAction({
    required this.request,
    required this.requestId,
    required this.turnId,
    Map<String, dynamic> rawJson = const {},
  }) : rawJson = agentExtras(rawJson, const [
         'request',
         'request_id',
         'turn_id',
         'type',
       ], 'AgentSessionComputerUseApprovalRequiredAction') {
    validate();
  }

  /// The information needed to render the request.
  final AgentSessionComputerUseApprovalRequestKind request;

  /// The registered request ID to echo when responding.
  final String requestId;

  /// The turn that requested approval.
  final String turnId;

  /// The type of the object. Always `computer_use_approval_request`.
  @override
  String get type => 'computer_use_approval_request';

  /// Detached received extras; declared fields cannot be overridden.
  final Map<String, dynamic> rawJson;

  /// Parses [AgentSessionComputerUseApprovalRequiredAction] with contextual, payload-free errors.
  factory AgentSessionComputerUseApprovalRequiredAction.fromJson(
    Map<String, dynamic> json,
  ) {
    requireAgentTag(
      json,
      'type',
      'computer_use_approval_request',
      'AgentSessionComputerUseApprovalRequiredAction',
    );
    return AgentSessionComputerUseApprovalRequiredAction(
      request: requiredAgentValue(
        json,
        'request',
        'AgentSessionComputerUseApprovalRequiredAction.request',
        (value, context) => AgentSessionComputerUseApprovalRequestKind.fromJson(
          requireAgentObject(value, context),
        ),
        nullable: false,
      )!,
      requestId: requiredAgentValue(
        json,
        'request_id',
        'AgentSessionComputerUseApprovalRequiredAction.requestId',
        requireAgentString,
        nullable: false,
      )!,
      turnId: requiredAgentValue(
        json,
        'turn_id',
        'AgentSessionComputerUseApprovalRequiredAction.turnId',
        requireAgentString,
        nullable: false,
      )!,
      rawJson: {
        for (final entry in json.entries)
          if (!const [
            'request',
            'request_id',
            'turn_id',
            'type',
          ].contains(entry.key))
            entry.key: entry.value,
      },
    );
  }
  @override
  void validate() {
    request.validate();
    validateAgentLength(
      requestId,
      'AgentSessionComputerUseApprovalRequiredAction.requestId',
      min: 0,
    );
    validateAgentLength(
      turnId,
      'AgentSessionComputerUseApprovalRequiredAction.turnId',
      min: 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...rawJson,
    'request': request.toJson(),
    'request_id': requestId,
    'turn_id': turnId,
    'type': type,
  };

  /// Copies values; omitted arguments retain their values and null presence.
  AgentSessionComputerUseApprovalRequiredAction copyWith({
    AgentSessionComputerUseApprovalRequestKind? request,
    String? requestId,
    String? turnId,
    Map<String, dynamic>? rawJson,
  }) => AgentSessionComputerUseApprovalRequiredAction(
    request: request ?? this.request,
    requestId: requestId ?? this.requestId,
    turnId: turnId ?? this.turnId,
    rawJson: rawJson ?? this.rawJson,
  );
}
