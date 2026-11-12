import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../platform/environment.dart';
import 'provider_transport.dart';

/// AWS IAM credentials for signing Claude provider requests.
final class ClaudeAwsCredentials {
  /// Creates long-lived IAM credentials or a temporary session.
  const ClaudeAwsCredentials({
    required this.accessKeyId,
    required this.secretAccessKey,
    this.sessionToken,
  });

  /// The AWS access key ID.
  final String accessKeyId;

  /// Secret key used only to calculate the request signature.
  final String secretAccessKey;

  /// AWS session token for temporary credentials.
  final String? sessionToken;

  /// Reads the standard AWS credential environment variables.
  factory ClaudeAwsCredentials.fromEnvironment() {
    final accessKeyId = getEnvironmentVariable('AWS_ACCESS_KEY_ID');
    final secretAccessKey = getEnvironmentVariable('AWS_SECRET_ACCESS_KEY');
    if (accessKeyId == null || secretAccessKey == null) {
      throw StateError(
        'Set AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY or supply an AWS credential provider',
      );
    }
    return ClaudeAwsCredentials(
      accessKeyId: accessKeyId,
      secretAccessKey: secretAccessKey,
      sessionToken: getEnvironmentVariable('AWS_SESSION_TOKEN'),
    );
  }

  @override
  String toString() => 'ClaudeAwsCredentials([REDACTED])';
}

/// Obtains fresh AWS credentials for a request or retry.
typedef ClaudeAwsCredentialProvider = FutureOr<ClaudeAwsCredentials> Function();

/// Applies either an AWS-issued API key or AWS SigV4 to a final request.
final class AwsRequestAuth {
  /// Configures authentication for one AWS service and region.
  const AwsRequestAuth({
    required this.region,
    required this.service,
    required this.apiKey,
    required this.credentials,
    required this.skipAuth,
  });

  /// Region that owns the API endpoint.
  final String? region;

  /// AWS SigV4 service identifier.
  final String service;

  /// AWS-issued bearer key, when configured.
  final String? apiKey;

  /// Optional IAM credential resolver.
  final ClaudeAwsCredentialProvider? credentials;

  /// Whether a gateway supplies credentials.
  final bool skipAuth;

  /// Adds authentication to the final outbound request.
  Future<void> apply(ProviderRequest request) async {
    request.headers.remove('x-api-key');
    if (skipAuth) return;
    request.headers
      ..remove('authorization')
      ..remove('x-amz-security-token');
    if (apiKey case final key?) {
      if (key.trim().isEmpty || key.contains(RegExp(r'[\r\n]'))) {
        throw ArgumentError('Invalid AWS-issued API key');
      }
      request.headers['authorization'] = 'Bearer $key';
      return;
    }

    final provider = credentials ?? ClaudeAwsCredentials.fromEnvironment;
    final ClaudeAwsCredentials resolved;
    try {
      resolved = await provider();
      if (resolved.accessKeyId.isEmpty || resolved.secretAccessKey.isEmpty) {
        throw StateError('Incomplete AWS credentials');
      }
    } catch (_) {
      throw http.ClientException(
        'Could not resolve AWS credentials',
        request.uri,
      );
    }
    signAwsRequest(
      request,
      credentials: resolved,
      region: region!,
      service: service,
      now: DateTime.now(),
    );
  }
}

/// Signs a finalized non-S3 AWS service request with SigV4.
///
/// See the AWS IAM User Guide's canonical-request and signing-key algorithms.
void signAwsRequest(
  ProviderRequest request, {
  required ClaudeAwsCredentials credentials,
  required String region,
  required String service,
  required DateTime now,
}) {
  const algorithm = 'AWS4-HMAC-SHA256';
  final timestamp =
      '${now.toUtc().toIso8601String().substring(0, 19).replaceAll(RegExp(r'[-:]'), '')}Z';
  final date = timestamp.substring(0, 8);
  final scope = '$date/$region/$service/aws4_request';
  final bodyHash = sha256.convert(request.body).toString();
  if (request.uri.hasQuery) {
    // Send the same RFC 3986-encoded values that the signature covers.
    request.uri = request.uri.replace(
      query: _renderQuery(_queryPairs(request.uri)),
    );
  }

  final headers = request.headers
    ..remove('authorization')
    ..remove('x-amz-security-token')
    ..['host'] = request.uri.authority
    ..['x-amz-date'] = timestamp
    ..['x-amz-content-sha256'] = bodyHash;
  if (credentials.sessionToken case final token?) {
    headers['x-amz-security-token'] = token;
  }
  final names =
      headers.keys.where((name) => !_unsignedHeaders.contains(name)).toList()
        ..sort();
  final signedHeaders = names.join(';');
  final canonicalHeaders = [
    for (final name in names)
      '$name:${headers[name]!.trim().replaceAll(RegExp(r'[\t ]+'), ' ')}\n',
  ].join();
  final canonicalRequest = [
    request.method,
    _canonicalPath(request.uri.path),
    _canonicalQuery(request.uri),
    canonicalHeaders,
    signedHeaders,
    bodyHash,
  ].join('\n');
  final stringToSign = [
    algorithm,
    timestamp,
    scope,
    sha256.convert(utf8.encode(canonicalRequest)).toString(),
  ].join('\n');

  final dateKey = _hmac(
    utf8.encode('AWS4${credentials.secretAccessKey}'),
    date,
  );
  final regionKey = _hmac(dateKey.bytes, region);
  final serviceKey = _hmac(regionKey.bytes, service);
  final signingKey = _hmac(serviceKey.bytes, 'aws4_request');
  final signature = _hmac(signingKey.bytes, stringToSign);
  headers['authorization'] =
      '$algorithm Credential=${credentials.accessKeyId}/$scope, '
      'SignedHeaders=$signedHeaders, Signature=$signature';
}

const _unsignedHeaders = {
  'accept-encoding',
  'authorization',
  'cache-control',
  'connection',
  'content-length',
  'expect',
  'from',
  'keep-alive',
  'max-forwards',
  'pragma',
  'proxy-authenticate',
  'proxy-authorization',
  'range',
  'te',
  'trailer',
  'transfer-encoding',
  'upgrade',
  'user-agent',
  'x-amzn-trace-id',
  'traceparent',
  'tracestate',
};

Digest _hmac(List<int> key, String value) =>
    Hmac(sha256, key).convert(utf8.encode(value));

String _canonicalPath(String path) {
  final segments = <String>[];
  for (final segment in path.split('/')) {
    switch (segment) {
      case '' || '.':
        break;
      case '..':
        if (segments.isNotEmpty) segments.removeLast();
      default:
        segments.add(_uriEncode(segment));
    }
  }
  if (segments.isEmpty) return '/';
  return '/${segments.join('/')}${path.endsWith('/') ? '/' : ''}';
}

List<(String, String)> _queryPairs(Uri uri) => [
  for (final entry in uri.queryParametersAll.entries)
    for (final value in entry.value) (_uriEncode(entry.key), _uriEncode(value)),
];

String _canonicalQuery(Uri uri) {
  final pairs = _queryPairs(uri)
    ..sort((a, b) {
      final keyOrder = a.$1.compareTo(b.$1);
      return keyOrder == 0 ? a.$2.compareTo(b.$2) : keyOrder;
    });
  return _renderQuery(pairs);
}

String _renderQuery(List<(String, String)> pairs) =>
    pairs.map((pair) => '${pair.$1}=${pair.$2}').join('&');

String _uriEncode(String value) => Uri.encodeComponent(value).replaceAllMapped(
  RegExp(r"[!'()*]"),
  (match) => '%${match[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}',
);

/// Resolves the standard AWS region variables for a provider client.
String? resolveAwsRegion(String? region) {
  final value =
      region ??
      providerEnvironmentValue('AWS_REGION') ??
      providerEnvironmentValue('AWS_DEFAULT_REGION');
  if (value != null && !RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)+$').hasMatch(value)) {
    throw ArgumentError('Invalid AWS region');
  }
  return value;
}
