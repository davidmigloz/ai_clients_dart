import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';


/// Registers an inbound webhook event source.
@immutable
class CreateWebhookRequest {
  /// Creates a [CreateWebhookRequest].
  const CreateWebhookRequest({
    this.description,
    this.encryptionKey,
    this.eventIdPattern,
    this.eventTypePattern,
    this.expiresAt,
    required this.name,
    this.ownerType,
    required this.provider,
    this.secret,
    this.signatureEncoding,
    this.signatureExtractorRegex,
    this.signatureHashAlgorithm,
    this.signatureHeaderName,
    this.signaturePayloadPattern,
    this.successStatusCode,
    this.timestampExtractorRegex,
    this.timestampPattern,
    this.urlVerificationToken,
    this.validityPeriodSecond,
  });

  /// What this webhook is used for
  final String? description;

  /// Encryption key used to decrypt webhook payloads
  final String? encryptionKey;

  /// Pattern for a unique event identifier used to deduplicate deliveries, with {body.&lt;path&gt;} and {headers.&lt;Header-Name&gt;} placeholders, eg {body.id} or {body.event_id}.{headers.X-Delivery-Id}. Defaults to a hash of the request body
  final String? eventIdPattern;

  /// Pattern for the event type, with {body.&lt;path&gt;} and {headers.&lt;Header-Name&gt;} placeholders, eg {body.type} or {headers.X-GitHub-Event}
  final String? eventTypePattern;

  /// The expires_at field.
  final String? expiresAt;

  /// Human-readable name for this webhook
  final String name;

  /// The owner_type field.
  final TriggerOwnerType? ownerType;

  /// The provider field.
  final WebhookProvider provider;

  /// Signing secret provided by the third-party provider
  final String? secret;

  /// The signature_encoding field.
  final WebhookSignatureEncoding? signatureEncoding;

  /// Regex to extract signature, eg sha256=(.*)
  final String? signatureExtractorRegex;

  /// The signature_hash_algorithm field.
  final WebhookSignatureHashAlgorithm? signatureHashAlgorithm;

  /// The signature_header_name field.
  final String? signatureHeaderName;

  /// Pattern for signature payload, eg {body} or {timestamp}.{body}
  final String? signaturePayloadPattern;

  /// HTTP status code returned for accepted deliveries, eg 200
  final int? successStatusCode;

  /// Regex to extract the timestamp from the rendered timestamp_pattern (the signature header by default), used as {timestamp}, eg t=([^,]+). Defaults to the whole value when timestamp_pattern is set
  final String? timestampExtractorRegex;

  /// Pattern for the timestamp used as {timestamp}, with {body.&lt;path&gt;} and {headers.&lt;Header-Name&gt;} placeholders, eg {headers.X-Slack-Request-Timestamp} or {body.webhookTimestamp}. Defaults to the signature header when timestamp_extractor_regex is set
  final String? timestampPattern;

  /// Token the provider echoes back when verifying the URL. Required for WhatsApp (paste the same value in the Verify token field of the Meta App Dashboard), forbidden for other providers
  final String? urlVerificationToken;

  /// Maximum allowed drift in seconds between the signed timestamp and reception time, eg 300
  final int? validityPeriodSecond;

  /// Parses a [CreateWebhookRequest] from JSON.
  factory CreateWebhookRequest.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('CreateWebhookRequest: missing name');
    }
    if (json['provider'] == null) {
      throw const FormatException('CreateWebhookRequest: missing provider');
    }
    return CreateWebhookRequest(
      description: json['description'] == null
          ? null
          : json['description'] as String,
      encryptionKey: json['encryption_key'] == null
          ? null
          : json['encryption_key'] as String,
      eventIdPattern: json['event_id_pattern'] == null
          ? null
          : json['event_id_pattern'] as String,
      eventTypePattern: json['event_type_pattern'] == null
          ? null
          : json['event_type_pattern'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : json['expires_at'] as String,
      name: json['name'] as String,
      ownerType: json['owner_type'] == null
          ? null
          : TriggerOwnerType.fromJson(json['owner_type'] as String),
      provider: WebhookProvider.fromJson(json['provider'] as String),
      secret: json['secret'] == null ? null : json['secret'] as String,
      signatureEncoding: json['signature_encoding'] == null
          ? null
          : WebhookSignatureEncoding.fromJson(
              json['signature_encoding'] as String,
            ),
      signatureExtractorRegex: json['signature_extractor_regex'] == null
          ? null
          : json['signature_extractor_regex'] as String,
      signatureHashAlgorithm: json['signature_hash_algorithm'] == null
          ? null
          : WebhookSignatureHashAlgorithm.fromJson(
              json['signature_hash_algorithm'] as String,
            ),
      signatureHeaderName: json['signature_header_name'] == null
          ? null
          : json['signature_header_name'] as String,
      signaturePayloadPattern: json['signature_payload_pattern'] == null
          ? null
          : json['signature_payload_pattern'] as String,
      successStatusCode: json['success_status_code'] == null
          ? null
          : json['success_status_code'] as int,
      timestampExtractorRegex: json['timestamp_extractor_regex'] == null
          ? null
          : json['timestamp_extractor_regex'] as String,
      timestampPattern: json['timestamp_pattern'] == null
          ? null
          : json['timestamp_pattern'] as String,
      urlVerificationToken: json['url_verification_token'] == null
          ? null
          : json['url_verification_token'] as String,
      validityPeriodSecond: json['validity_period_second'] == null
          ? null
          : json['validity_period_second'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'description': ?description,
    'encryption_key': ?encryptionKey,
    'event_id_pattern': ?eventIdPattern,
    'event_type_pattern': ?eventTypePattern,
    'expires_at': ?expiresAt,
    'name': name,
    if (ownerType != null) 'owner_type': ownerType!.toJson(),
    'provider': provider.toJson(),
    'secret': ?secret,
    if (signatureEncoding != null)
      'signature_encoding': signatureEncoding!.toJson(),
    'signature_extractor_regex': ?signatureExtractorRegex,
    if (signatureHashAlgorithm != null)
      'signature_hash_algorithm': signatureHashAlgorithm!.toJson(),
    'signature_header_name': ?signatureHeaderName,
    'signature_payload_pattern': ?signaturePayloadPattern,
    'success_status_code': ?successStatusCode,
    'timestamp_extractor_regex': ?timestampExtractorRegex,
    'timestamp_pattern': ?timestampPattern,
    'url_verification_token': ?urlVerificationToken,
    'validity_period_second': ?validityPeriodSecond,
  };

  /// Creates a copy with the given fields replaced.
  CreateWebhookRequest copyWith({
    Object? description = unsetCopyWithValue,
    Object? encryptionKey = unsetCopyWithValue,
    Object? eventIdPattern = unsetCopyWithValue,
    Object? eventTypePattern = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
    String? name,
    Object? ownerType = unsetCopyWithValue,
    WebhookProvider? provider,
    Object? secret = unsetCopyWithValue,
    Object? signatureEncoding = unsetCopyWithValue,
    Object? signatureExtractorRegex = unsetCopyWithValue,
    Object? signatureHashAlgorithm = unsetCopyWithValue,
    Object? signatureHeaderName = unsetCopyWithValue,
    Object? signaturePayloadPattern = unsetCopyWithValue,
    Object? successStatusCode = unsetCopyWithValue,
    Object? timestampExtractorRegex = unsetCopyWithValue,
    Object? timestampPattern = unsetCopyWithValue,
    Object? urlVerificationToken = unsetCopyWithValue,
    Object? validityPeriodSecond = unsetCopyWithValue,
  }) => CreateWebhookRequest(
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    encryptionKey: encryptionKey == unsetCopyWithValue
        ? this.encryptionKey
        : encryptionKey as String?,
    eventIdPattern: eventIdPattern == unsetCopyWithValue
        ? this.eventIdPattern
        : eventIdPattern as String?,
    eventTypePattern: eventTypePattern == unsetCopyWithValue
        ? this.eventTypePattern
        : eventTypePattern as String?,
    expiresAt: expiresAt == unsetCopyWithValue
        ? this.expiresAt
        : expiresAt as String?,
    name: name ?? this.name,
    ownerType: ownerType == unsetCopyWithValue
        ? this.ownerType
        : ownerType as TriggerOwnerType?,
    provider: provider ?? this.provider,
    secret: secret == unsetCopyWithValue ? this.secret : secret as String?,
    signatureEncoding: signatureEncoding == unsetCopyWithValue
        ? this.signatureEncoding
        : signatureEncoding as WebhookSignatureEncoding?,
    signatureExtractorRegex: signatureExtractorRegex == unsetCopyWithValue
        ? this.signatureExtractorRegex
        : signatureExtractorRegex as String?,
    signatureHashAlgorithm: signatureHashAlgorithm == unsetCopyWithValue
        ? this.signatureHashAlgorithm
        : signatureHashAlgorithm as WebhookSignatureHashAlgorithm?,
    signatureHeaderName: signatureHeaderName == unsetCopyWithValue
        ? this.signatureHeaderName
        : signatureHeaderName as String?,
    signaturePayloadPattern: signaturePayloadPattern == unsetCopyWithValue
        ? this.signaturePayloadPattern
        : signaturePayloadPattern as String?,
    successStatusCode: successStatusCode == unsetCopyWithValue
        ? this.successStatusCode
        : successStatusCode as int?,
    timestampExtractorRegex: timestampExtractorRegex == unsetCopyWithValue
        ? this.timestampExtractorRegex
        : timestampExtractorRegex as String?,
    timestampPattern: timestampPattern == unsetCopyWithValue
        ? this.timestampPattern
        : timestampPattern as String?,
    urlVerificationToken: urlVerificationToken == unsetCopyWithValue
        ? this.urlVerificationToken
        : urlVerificationToken as String?,
    validityPeriodSecond: validityPeriodSecond == unsetCopyWithValue
        ? this.validityPeriodSecond
        : validityPeriodSecond as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateWebhookRequest &&
          runtimeType == other.runtimeType &&
          description == other.description &&
          encryptionKey == other.encryptionKey &&
          eventIdPattern == other.eventIdPattern &&
          eventTypePattern == other.eventTypePattern &&
          expiresAt == other.expiresAt &&
          name == other.name &&
          ownerType == other.ownerType &&
          provider == other.provider &&
          secret == other.secret &&
          signatureEncoding == other.signatureEncoding &&
          signatureExtractorRegex == other.signatureExtractorRegex &&
          signatureHashAlgorithm == other.signatureHashAlgorithm &&
          signatureHeaderName == other.signatureHeaderName &&
          signaturePayloadPattern == other.signaturePayloadPattern &&
          successStatusCode == other.successStatusCode &&
          timestampExtractorRegex == other.timestampExtractorRegex &&
          timestampPattern == other.timestampPattern &&
          urlVerificationToken == other.urlVerificationToken &&
          validityPeriodSecond == other.validityPeriodSecond;

  @override
  int get hashCode => Object.hashAll([
    description,
    encryptionKey,
    eventIdPattern,
    eventTypePattern,
    expiresAt,
    name,
    ownerType,
    provider,
    secret,
    signatureEncoding,
    signatureExtractorRegex,
    signatureHashAlgorithm,
    signatureHeaderName,
    signaturePayloadPattern,
    successStatusCode,
    timestampExtractorRegex,
    timestampPattern,
    urlVerificationToken,
    validityPeriodSecond,
  ]);

  @override
  String toString() =>
      'CreateWebhookRequest('
      'description: $description, '
      'encryptionKey: [REDACTED], '
      'eventIdPattern: $eventIdPattern, '
      'eventTypePattern: $eventTypePattern, '
      'expiresAt: $expiresAt, '
      'name: $name, '
      'ownerType: $ownerType, '
      'provider: $provider, '
      'secret: [REDACTED], '
      'signatureEncoding: $signatureEncoding, '
      'signatureExtractorRegex: $signatureExtractorRegex, '
      'signatureHashAlgorithm: $signatureHashAlgorithm, '
      'signatureHeaderName: $signatureHeaderName, '
      'signaturePayloadPattern: $signaturePayloadPattern, '
      'successStatusCode: $successStatusCode, '
      'timestampExtractorRegex: $timestampExtractorRegex, '
      'timestampPattern: $timestampPattern, '
      'urlVerificationToken: [REDACTED], '
      'validityPeriodSecond: $validityPeriodSecond)';
}

/// A registered source of provider events for a trigger.
@immutable
class Webhook {
  /// Creates a [Webhook].
  const Webhook({
    required this.createdAt,
    required this.creatorId,
    this.description,
    this.eventIdPattern,
    this.eventTypePath,
    this.eventTypePattern,
    required this.expiresAt,
    required this.httpMethod,
    required this.id,
    required this.name,
    required this.organizationId,
    required this.ownerType,
    required this.provider,
    required this.signatureEncoding,
    required this.signatureExtractorRegex,
    required this.signatureHashAlgorithm,
    required this.signatureHeaderName,
    required this.signaturePayloadPattern,
    required this.successStatusCode,
    required this.timestampExtractorRegex,
    this.timestampPattern,
    required this.updatedAt,
    required this.url,
    this.urlVerificationToken,
    required this.urlVerified,
    required this.validityPeriodSecond,
    required this.workspaceId,
  });

  /// The created_at field.
  final String createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The description field.
  final String? description;

  /// The event_id_pattern field.
  final String? eventIdPattern;

  /// The event_type_path field.
  final String? eventTypePath;

  /// The event_type_pattern field.
  final String? eventTypePattern;

  /// The expires_at field.
  final String? expiresAt;

  /// The http_method field.
  final String httpMethod;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The organization_id field.
  final String organizationId;

  /// The owner_type field.
  final TriggerOwnerType ownerType;

  /// The provider field.
  final WebhookProvider provider;

  /// The signature_encoding field.
  final WebhookSignatureEncoding? signatureEncoding;

  /// The signature_extractor_regex field.
  final String? signatureExtractorRegex;

  /// The signature_hash_algorithm field.
  final WebhookSignatureHashAlgorithm? signatureHashAlgorithm;

  /// The signature_header_name field.
  final String? signatureHeaderName;

  /// The signature_payload_pattern field.
  final String? signaturePayloadPattern;

  /// The success_status_code field.
  final int? successStatusCode;

  /// The timestamp_extractor_regex field.
  final String? timestampExtractorRegex;

  /// The timestamp_pattern field.
  final String? timestampPattern;

  /// The updated_at field.
  final String updatedAt;

  /// The url field.
  final String url;

  /// Token the provider echoes back when verifying the URL (WhatsApp: the Verify token)
  final String? urlVerificationToken;

  /// The url_verified field.
  final bool? urlVerified;

  /// The validity_period_second field.
  final int? validityPeriodSecond;

  /// The workspace_id field.
  final String workspaceId;

  /// Parses a [Webhook] from JSON.
  factory Webhook.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('Webhook: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('Webhook: missing creator_id');
    }
    if (!json.containsKey('expires_at')) {
      throw const FormatException('Webhook: missing expires_at');
    }
    if (json['http_method'] == null) {
      throw const FormatException('Webhook: missing http_method');
    }
    if (json['id'] == null) {
      throw const FormatException('Webhook: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('Webhook: missing name');
    }
    if (json['organization_id'] == null) {
      throw const FormatException('Webhook: missing organization_id');
    }
    if (json['owner_type'] == null) {
      throw const FormatException('Webhook: missing owner_type');
    }
    if (json['provider'] == null) {
      throw const FormatException('Webhook: missing provider');
    }
    if (!json.containsKey('signature_encoding')) {
      throw const FormatException('Webhook: missing signature_encoding');
    }
    if (!json.containsKey('signature_extractor_regex')) {
      throw const FormatException('Webhook: missing signature_extractor_regex');
    }
    if (!json.containsKey('signature_hash_algorithm')) {
      throw const FormatException('Webhook: missing signature_hash_algorithm');
    }
    if (!json.containsKey('signature_header_name')) {
      throw const FormatException('Webhook: missing signature_header_name');
    }
    if (!json.containsKey('signature_payload_pattern')) {
      throw const FormatException('Webhook: missing signature_payload_pattern');
    }
    if (!json.containsKey('success_status_code')) {
      throw const FormatException('Webhook: missing success_status_code');
    }
    if (!json.containsKey('timestamp_extractor_regex')) {
      throw const FormatException('Webhook: missing timestamp_extractor_regex');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('Webhook: missing updated_at');
    }
    if (json['url'] == null) {
      throw const FormatException('Webhook: missing url');
    }
    if (!json.containsKey('url_verified')) {
      throw const FormatException('Webhook: missing url_verified');
    }
    if (!json.containsKey('validity_period_second')) {
      throw const FormatException('Webhook: missing validity_period_second');
    }
    if (json['workspace_id'] == null) {
      throw const FormatException('Webhook: missing workspace_id');
    }
    return Webhook(
      createdAt: json['created_at'] as String,
      creatorId: json['creator_id'] as String,
      description: json['description'] == null
          ? null
          : json['description'] as String,
      eventIdPattern: json['event_id_pattern'] == null
          ? null
          : json['event_id_pattern'] as String,
      eventTypePath: json['event_type_path'] == null
          ? null
          : json['event_type_path'] as String,
      eventTypePattern: json['event_type_pattern'] == null
          ? null
          : json['event_type_pattern'] as String,
      expiresAt: json['expires_at'] == null
          ? null
          : json['expires_at'] as String,
      httpMethod: json['http_method'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      organizationId: json['organization_id'] as String,
      ownerType: TriggerOwnerType.fromJson(json['owner_type'] as String),
      provider: WebhookProvider.fromJson(json['provider'] as String),
      signatureEncoding: json['signature_encoding'] == null
          ? null
          : WebhookSignatureEncoding.fromJson(
              json['signature_encoding'] as String,
            ),
      signatureExtractorRegex: json['signature_extractor_regex'] == null
          ? null
          : json['signature_extractor_regex'] as String,
      signatureHashAlgorithm: json['signature_hash_algorithm'] == null
          ? null
          : WebhookSignatureHashAlgorithm.fromJson(
              json['signature_hash_algorithm'] as String,
            ),
      signatureHeaderName: json['signature_header_name'] == null
          ? null
          : json['signature_header_name'] as String,
      signaturePayloadPattern: json['signature_payload_pattern'] == null
          ? null
          : json['signature_payload_pattern'] as String,
      successStatusCode: json['success_status_code'] == null
          ? null
          : json['success_status_code'] as int,
      timestampExtractorRegex: json['timestamp_extractor_regex'] == null
          ? null
          : json['timestamp_extractor_regex'] as String,
      timestampPattern: json['timestamp_pattern'] == null
          ? null
          : json['timestamp_pattern'] as String,
      updatedAt: json['updated_at'] as String,
      url: json['url'] as String,
      urlVerificationToken: json['url_verification_token'] == null
          ? null
          : json['url_verification_token'] as String,
      urlVerified: json['url_verified'] == null
          ? null
          : json['url_verified'] as bool,
      validityPeriodSecond: json['validity_period_second'] == null
          ? null
          : json['validity_period_second'] as int,
      workspaceId: json['workspace_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt,
    'creator_id': creatorId,
    'description': ?description,
    'event_id_pattern': ?eventIdPattern,
    'event_type_path': ?eventTypePath,
    'event_type_pattern': ?eventTypePattern,
    'expires_at': expiresAt,
    'http_method': httpMethod,
    'id': id,
    'name': name,
    'organization_id': organizationId,
    'owner_type': ownerType.toJson(),
    'provider': provider.toJson(),
    'signature_encoding': signatureEncoding?.toJson(),
    'signature_extractor_regex': signatureExtractorRegex,
    'signature_hash_algorithm': signatureHashAlgorithm?.toJson(),
    'signature_header_name': signatureHeaderName,
    'signature_payload_pattern': signaturePayloadPattern,
    'success_status_code': successStatusCode,
    'timestamp_extractor_regex': timestampExtractorRegex,
    'timestamp_pattern': ?timestampPattern,
    'updated_at': updatedAt,
    'url': url,
    'url_verification_token': ?urlVerificationToken,
    'url_verified': urlVerified,
    'validity_period_second': validityPeriodSecond,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with the given fields replaced.
  Webhook copyWith({
    String? createdAt,
    String? creatorId,
    Object? description = unsetCopyWithValue,
    Object? eventIdPattern = unsetCopyWithValue,
    Object? eventTypePath = unsetCopyWithValue,
    Object? eventTypePattern = unsetCopyWithValue,
    Object? expiresAt = unsetCopyWithValue,
    String? httpMethod,
    String? id,
    String? name,
    String? organizationId,
    TriggerOwnerType? ownerType,
    WebhookProvider? provider,
    Object? signatureEncoding = unsetCopyWithValue,
    Object? signatureExtractorRegex = unsetCopyWithValue,
    Object? signatureHashAlgorithm = unsetCopyWithValue,
    Object? signatureHeaderName = unsetCopyWithValue,
    Object? signaturePayloadPattern = unsetCopyWithValue,
    Object? successStatusCode = unsetCopyWithValue,
    Object? timestampExtractorRegex = unsetCopyWithValue,
    Object? timestampPattern = unsetCopyWithValue,
    String? updatedAt,
    String? url,
    Object? urlVerificationToken = unsetCopyWithValue,
    Object? urlVerified = unsetCopyWithValue,
    Object? validityPeriodSecond = unsetCopyWithValue,
    String? workspaceId,
  }) => Webhook(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    eventIdPattern: eventIdPattern == unsetCopyWithValue
        ? this.eventIdPattern
        : eventIdPattern as String?,
    eventTypePath: eventTypePath == unsetCopyWithValue
        ? this.eventTypePath
        : eventTypePath as String?,
    eventTypePattern: eventTypePattern == unsetCopyWithValue
        ? this.eventTypePattern
        : eventTypePattern as String?,
    expiresAt: expiresAt == unsetCopyWithValue
        ? this.expiresAt
        : expiresAt as String?,
    httpMethod: httpMethod ?? this.httpMethod,
    id: id ?? this.id,
    name: name ?? this.name,
    organizationId: organizationId ?? this.organizationId,
    ownerType: ownerType ?? this.ownerType,
    provider: provider ?? this.provider,
    signatureEncoding: signatureEncoding == unsetCopyWithValue
        ? this.signatureEncoding
        : signatureEncoding as WebhookSignatureEncoding?,
    signatureExtractorRegex: signatureExtractorRegex == unsetCopyWithValue
        ? this.signatureExtractorRegex
        : signatureExtractorRegex as String?,
    signatureHashAlgorithm: signatureHashAlgorithm == unsetCopyWithValue
        ? this.signatureHashAlgorithm
        : signatureHashAlgorithm as WebhookSignatureHashAlgorithm?,
    signatureHeaderName: signatureHeaderName == unsetCopyWithValue
        ? this.signatureHeaderName
        : signatureHeaderName as String?,
    signaturePayloadPattern: signaturePayloadPattern == unsetCopyWithValue
        ? this.signaturePayloadPattern
        : signaturePayloadPattern as String?,
    successStatusCode: successStatusCode == unsetCopyWithValue
        ? this.successStatusCode
        : successStatusCode as int?,
    timestampExtractorRegex: timestampExtractorRegex == unsetCopyWithValue
        ? this.timestampExtractorRegex
        : timestampExtractorRegex as String?,
    timestampPattern: timestampPattern == unsetCopyWithValue
        ? this.timestampPattern
        : timestampPattern as String?,
    updatedAt: updatedAt ?? this.updatedAt,
    url: url ?? this.url,
    urlVerificationToken: urlVerificationToken == unsetCopyWithValue
        ? this.urlVerificationToken
        : urlVerificationToken as String?,
    urlVerified: urlVerified == unsetCopyWithValue
        ? this.urlVerified
        : urlVerified as bool?,
    validityPeriodSecond: validityPeriodSecond == unsetCopyWithValue
        ? this.validityPeriodSecond
        : validityPeriodSecond as int?,
    workspaceId: workspaceId ?? this.workspaceId,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Webhook &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          description == other.description &&
          eventIdPattern == other.eventIdPattern &&
          eventTypePath == other.eventTypePath &&
          eventTypePattern == other.eventTypePattern &&
          expiresAt == other.expiresAt &&
          httpMethod == other.httpMethod &&
          id == other.id &&
          name == other.name &&
          organizationId == other.organizationId &&
          ownerType == other.ownerType &&
          provider == other.provider &&
          signatureEncoding == other.signatureEncoding &&
          signatureExtractorRegex == other.signatureExtractorRegex &&
          signatureHashAlgorithm == other.signatureHashAlgorithm &&
          signatureHeaderName == other.signatureHeaderName &&
          signaturePayloadPattern == other.signaturePayloadPattern &&
          successStatusCode == other.successStatusCode &&
          timestampExtractorRegex == other.timestampExtractorRegex &&
          timestampPattern == other.timestampPattern &&
          updatedAt == other.updatedAt &&
          url == other.url &&
          urlVerificationToken == other.urlVerificationToken &&
          urlVerified == other.urlVerified &&
          validityPeriodSecond == other.validityPeriodSecond &&
          workspaceId == other.workspaceId;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    description,
    eventIdPattern,
    eventTypePath,
    eventTypePattern,
    expiresAt,
    httpMethod,
    id,
    name,
    organizationId,
    ownerType,
    provider,
    signatureEncoding,
    signatureExtractorRegex,
    signatureHashAlgorithm,
    signatureHeaderName,
    signaturePayloadPattern,
    successStatusCode,
    timestampExtractorRegex,
    timestampPattern,
    updatedAt,
    url,
    urlVerificationToken,
    urlVerified,
    validityPeriodSecond,
    workspaceId,
  ]);

  @override
  String toString() =>
      'Webhook('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'description: $description, '
      'eventIdPattern: $eventIdPattern, '
      'eventTypePath: $eventTypePath, '
      'eventTypePattern: $eventTypePattern, '
      'expiresAt: $expiresAt, '
      'httpMethod: $httpMethod, '
      'id: $id, '
      'name: $name, '
      'organizationId: $organizationId, '
      'ownerType: $ownerType, '
      'provider: $provider, '
      'signatureEncoding: $signatureEncoding, '
      'signatureExtractorRegex: $signatureExtractorRegex, '
      'signatureHashAlgorithm: $signatureHashAlgorithm, '
      'signatureHeaderName: $signatureHeaderName, '
      'signaturePayloadPattern: $signaturePayloadPattern, '
      'successStatusCode: $successStatusCode, '
      'timestampExtractorRegex: $timestampExtractorRegex, '
      'timestampPattern: $timestampPattern, '
      'updatedAt: $updatedAt, '
      'url: $url, '
      'urlVerificationToken: [REDACTED], '
      'urlVerified: $urlVerified, '
      'validityPeriodSecond: $validityPeriodSecond, '
      'workspaceId: $workspaceId)';
}

/// The credential used to authenticate the webhook provider's deliveries.
@immutable
class WebhookSigningSecret {
  /// Creates a [WebhookSigningSecret].
  const WebhookSigningSecret({required this.signingSecret});

  /// The signing_secret field.
  final String signingSecret;

  /// Parses a [WebhookSigningSecret] from JSON.
  factory WebhookSigningSecret.fromJson(Map<String, dynamic> json) {
    if (json['signing_secret'] == null) {
      throw const FormatException(
        'WebhookSigningSecret: missing signing_secret',
      );
    }
    return WebhookSigningSecret(
      signingSecret: json['signing_secret'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'signing_secret': signingSecret};

  /// Creates a copy with the given fields replaced.
  WebhookSigningSecret copyWith({String? signingSecret}) =>
      WebhookSigningSecret(signingSecret: signingSecret ?? this.signingSecret);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebhookSigningSecret &&
          runtimeType == other.runtimeType &&
          signingSecret == other.signingSecret;

  @override
  int get hashCode => Object.hashAll([signingSecret]);

  @override
  String toString() =>
      'WebhookSigningSecret('
      'signingSecret: [REDACTED])';
}

/// Provider delivering webhook events.
enum WebhookProvider {
  /// Represents slack.
  slack('slack'),

  /// Represents github.
  github('github'),

  /// Represents notion.
  notion('notion'),

  /// Represents lucca.
  lucca('lucca'),

  /// Represents linear.
  linear('linear'),

  /// Represents microsoft.
  microsoft('microsoft'),

  /// Represents ashby.
  ashby('ashby'),

  /// Represents whatsapp.
  whatsapp('whatsapp'),

  /// Represents custom.
  custom('custom'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const WebhookProvider(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static WebhookProvider fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Controls whether the webhook or trigger belongs to the workspace or user.
enum TriggerOwnerType {
  /// Represents workspace.
  workspace('workspace'),

  /// Represents user.
  user('user'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const TriggerOwnerType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static TriggerOwnerType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Encoding used by the provider for its signature.
enum WebhookSignatureEncoding {
  /// Represents hex.
  hex('hex'),

  /// Represents base64.
  base64('base64'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const WebhookSignatureEncoding(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static WebhookSignatureEncoding fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Hash algorithm used by the provider for its signature.
enum WebhookSignatureHashAlgorithm {
  /// Represents sha256.
  sha256('sha256'),

  /// Represents sha1.
  sha1('sha1'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const WebhookSignatureHashAlgorithm(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static WebhookSignatureHashAlgorithm fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}
