import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../client/config.dart';
import '../models/messages/message_create_request.dart';
import '../models/tokens/token_count.dart';
import '../resources/message_request_validation.dart';
import 'aws_signing.dart';
import 'bedrock_event_stream.dart';
import 'provider_transport.dart';

/// Amazon Bedrock Mantle with the native Claude Messages protocol.
final class AnthropicBedrockMantleClient extends ProviderAnthropicClient {
  /// Creates a Bedrock Mantle client using a Bedrock key or IAM credentials.
  factory AnthropicBedrockMantleClient({
    String? region,
    String? apiKey,
    ClaudeAwsCredentialProvider? credentials,
    String? baseUrl,
    bool skipAuth = false,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    final settings = _bedrockSettings(
      config: config,
      region: region,
      baseUrl: baseUrl,
      apiKey: apiKey,
      credentials: credentials,
      skipAuth: skipAuth,
      runtime: false,
    );
    return AnthropicBedrockMantleClient._(
      config.copyWith(baseUrl: settings.base.toString(), workspaceId: null),
      _MantleTransport(httpClient, settings.base, settings.auth),
    );
  }

  AnthropicBedrockMantleClient._(super.config, super._transport);
}

/// Amazon Bedrock Runtime for Claude InvokeModel and binary streaming.
final class AnthropicBedrockClient extends ProviderAnthropicClient {
  /// Creates a Bedrock Runtime client using a Bedrock key or IAM credentials.
  ///
  /// For Claude 4.6 and earlier, configure the API version supported by your
  /// existing Bedrock invocation.
  factory AnthropicBedrockClient({
    String? region,
    String? apiKey,
    ClaudeAwsCredentialProvider? credentials,
    String? baseUrl,
    bool skipAuth = false,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    final settings = _bedrockSettings(
      config: config,
      region: region,
      baseUrl: baseUrl,
      apiKey: apiKey,
      credentials: credentials,
      skipAuth: skipAuth,
      runtime: true,
    );
    return AnthropicBedrockClient._(
      config.copyWith(baseUrl: settings.base.toString(), workspaceId: null),
      _RuntimeTransport(httpClient, settings.base, settings.auth),
    );
  }

  AnthropicBedrockClient._(super.config, super._transport);

  /// Counts tokens for an InvokeModel body on supported Runtime models.
  ///
  /// Use the same request that you would pass to Messages so fields required
  /// by InvokeModel, including max_tokens, reach the AWS token counter.
  Future<TokenCountResponse> countInvokeTokens(
    MessageCreateRequest request, {
    List<String> betas = const [],
    Future<void>? abortTrigger,
  }) async {
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {
        if (betas.isNotEmpty) 'anthropic-beta': betas.join(','),
      },
    );
    final body = request.toJson();
    validateMessageRequestVersion(headers['anthropic-version'], body);
    final outbound =
        http.Request(
            'POST',
            requestBuilder.buildUrl('/v1/messages/count_invoke_tokens'),
          )
          ..headers.addAll(headers)
          ..body = jsonEncode(body);
    final response = await interceptorChain.execute(
      outbound,
      abortTrigger: abortTrigger,
    );
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return TokenCountResponse.fromJson({'input_tokens': json['inputTokens']});
  }
}

({Uri base, AwsRequestAuth auth}) _bedrockSettings({
  required AnthropicConfig config,
  required String? region,
  required String? baseUrl,
  required String? apiKey,
  required ClaudeAwsCredentialProvider? credentials,
  required bool skipAuth,
  required bool runtime,
}) {
  if (config.authProvider != null) {
    throw ArgumentError('Configure Bedrock credentials on the Bedrock client');
  }
  if ((apiKey != null && credentials != null) ||
      (skipAuth && (apiKey != null || credentials != null))) {
    throw ArgumentError(
      'Use either a Bedrock key, IAM credentials, or a gateway',
    );
  }
  final awsRegion = resolveAwsRegion(region) ?? (runtime ? 'us-east-1' : null);
  final key =
      apiKey ??
      (credentials == null && !skipAuth
          ? providerEnvironmentValue('AWS_BEARER_TOKEN_BEDROCK')
          : null);
  final resolvedBase =
      baseUrl ??
      configuredProviderBase(config.baseUrl) ??
      providerEnvironmentValue(
        runtime
            ? 'ANTHROPIC_BEDROCK_BASE_URL'
            : 'ANTHROPIC_BEDROCK_MANTLE_BASE_URL',
      ) ??
      switch ((runtime, awsRegion)) {
        (true, final value?) => 'https://bedrock-runtime.$value.amazonaws.com',
        (false, final value?) =>
          'https://bedrock-mantle.$value.api.aws/anthropic',
        _ => null,
      };
  if (resolvedBase == null || (awsRegion == null && key == null && !skipAuth)) {
    throw ArgumentError(
      'Set a Bedrock region or a base URL for Bearer authentication',
    );
  }
  return (
    base: validateProviderBase(resolvedBase),
    auth: AwsRequestAuth(
      region: awsRegion,
      service: runtime ? 'bedrock' : 'bedrock-mantle',
      apiKey: key,
      credentials: credentials,
      skipAuth: skipAuth,
    ),
  );
}

abstract base class _BedrockTransport extends ProviderTransport {
  _BedrockTransport(super.client, this.base, this.auth);

  final Uri base;
  final AwsRequestAuth auth;
}

final class _MantleTransport extends _BedrockTransport {
  _MantleTransport(super.client, super.base, super.auth);

  @override
  Future<void> prepare(ProviderRequest request) async {
    final path = providerPath(request.uri, base).join('/');
    if (request.method != 'POST' ||
        (path != 'v1/messages' && path != 'v1/messages/count_tokens')) {
      throw UnsupportedError(
        'Bedrock Mantle supports Messages and token counting',
      );
    }
    final profile = (request.headers..remove('anthropic-workspace-id')).remove(
      'anthropic-user-profile-id',
    );
    final body = _jsonRequest(request);
    if (body['fallbacks'] != null) {
      throw UnsupportedError('Server-side fallback is unavailable on Bedrock');
    }
    if (profile != null) {
      body.putIfAbsent('user_profile_id', () => profile);
      request.body = Uint8List.fromList(utf8.encode(jsonEncode(body)));
    }
    await auth.apply(request);
  }
}

final class _RuntimeTransport extends _BedrockTransport {
  _RuntimeTransport(super.client, super.base, super.auth);

  @override
  Future<void> prepare(ProviderRequest request) async {
    final path = providerPath(request.uri, base).join('/');
    final count = path == 'v1/messages/count_invoke_tokens';
    if (request.method != 'POST' || (!count && path != 'v1/messages')) {
      throw UnsupportedError(
        'Use countInvokeTokens for Runtime token counting or use Bedrock Mantle for the Claude count_tokens endpoint',
      );
    }
    request.headers.remove('anthropic-workspace-id');
    final body = _jsonRequest(request);
    if (request.headers.containsKey('anthropic-user-profile-id') ||
        body.containsKey('user_profile_id')) {
      throw UnsupportedError(
        'User profile attribution is unavailable on Bedrock Runtime',
      );
    }
    if (body['fallbacks'] != null) {
      throw UnsupportedError('Server-side fallback is unavailable on Bedrock');
    }
    final model = body.remove('model');
    final streaming = body.remove('stream') == true;
    final version = request.headers.remove('anthropic-version');
    if (version != null) body.putIfAbsent('anthropic_version', () => version);
    if (request.headers['anthropic-beta'] case final betas?) {
      body.putIfAbsent(
        'anthropic_beta',
        () => betas.split(',').map((value) => value.trim()).toList(),
      );
    }

    final original = request.uri;
    final prefix = original.path.substring(
      0,
      original.path.length - path.length - 1,
    );
    final action = count
        ? 'count-tokens'
        : streaming
        ? 'invoke-with-response-stream'
        : 'invoke';
    request.uri = replaceProviderPath(
      original,
      '$prefix/model/${_bedrockModel(model)}/$action',
      removeBeta: true,
    );
    final invokeBody = utf8.encode(jsonEncode(body));
    request.body = Uint8List.fromList(
      count
          ? utf8.encode(
              jsonEncode({
                'input': {
                  'invokeModel': {'body': base64Encode(invokeBody)},
                },
              }),
            )
          : invokeBody,
    );
    if (streaming && !count) {
      request.headers
        ..['accept'] = 'application/vnd.amazon.eventstream'
        ..putIfAbsent('x-amzn-bedrock-accept', () => 'application/json');
    }
    await auth.apply(request);
  }

  @override
  http.StreamedResponse adaptResponse(
    ProviderRequest request,
    http.StreamedResponse response,
  ) {
    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        request.uri.path.endsWith('/invoke-with-response-stream')) {
      return bedrockEventStreamResponse(response);
    }
    return response;
  }
}

Map<String, dynamic> _jsonRequest(ProviderRequest request) {
  if (jsonDecode(utf8.decode(request.body))
      case final Map<String, dynamic> body) {
    return body;
  }
  throw const FormatException('Expected a Claude Messages request object');
}

String _bedrockModel(Object? value) {
  if (value is! String) {
    throw ArgumentError('Expected a Bedrock model ID');
  }
  final leading = value.split(';').first;
  if (leading.isEmpty || leading == '.' || leading == '..') {
    throw ArgumentError('Invalid Bedrock model ID');
  }
  return Uri.encodeComponent(
    value,
  ).replaceAll('%3A', ':').replaceAll('%3B', ';');
}
