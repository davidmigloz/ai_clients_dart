import 'dart:async' show Completer, FutureOr, StreamIterator, Timer, unawaited;
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../errors/response_error.dart';
import 'auth_provider.dart';

const _federationBeta = 'oidc-federation-2026-04-01';
const _jwtBearerGrant = 'urn:ietf:params:oauth:grant-type:jwt-bearer';
const int _maxAssertionBytes = 16 * 1024;
const int _maxResponseBytes = 1024 * 1024;

/// A JWT exchange result. Do not log the access token.
final class WorkloadIdentityAccessToken {
  const WorkloadIdentityAccessToken._({
    required this.accessToken,
    required this.expiresIn,
    required this.scope,
  });

  /// The token sent as an OAuth bearer credential.
  final String accessToken;

  /// Lifetime of the token from the time of exchange.
  final Duration expiresIn;

  /// The scope returned by the server, if reported.
  final String? scope;

  @override
  String toString() => 'WorkloadIdentityAccessToken([REDACTED])';
}

/// Exchanges an identity provider's JWT for a short-lived Claude API token.
///
/// The supplied HTTP client is borrowed. Keep token acquisition separate from
/// this exchange and obtain a fresh identity token when one is needed.
final class WorkloadIdentityTokenExchange {
  /// Creates an exchange transport. Only HTTPS and loopback HTTP are allowed.
  WorkloadIdentityTokenExchange({
    required http.Client httpClient,
    String baseUrl = 'https://api.anthropic.com',
    Duration timeout = const Duration(seconds: 30),
  }) : _client = httpClient,
       _url = _tokenUrl(baseUrl),
       _timeout = timeout {
    if (timeout <= Duration.zero) {
      throw ArgumentError('The token exchange timeout must be positive.');
    }
  }

  final http.Client _client;
  final Uri _url;
  final Duration _timeout;

  /// Exchanges a JWT using the selected federation rule.
  ///
  /// Pass [serviceAccountId] from the rule's service account. [workspaceId]
  /// is required when the server cannot choose a workspace from the rule.
  Future<WorkloadIdentityAccessToken> exchange({
    required String assertion,
    required String federationRuleId,
    required String organizationId,
    required String serviceAccountId,
    String? workspaceId,
  }) => _exchangeJwt(
    assertion: assertion,
    federationRuleId: federationRuleId,
    organizationId: organizationId,
    serviceAccountId: serviceAccountId,
    workspaceId: workspaceId,
  );

  Future<WorkloadIdentityAccessToken> _exchangeJwt({
    required String assertion,
    required String federationRuleId,
    required String organizationId,
    required String serviceAccountId,
    String? workspaceId,
    Future<void>? ownerClosed,
  }) {
    if (assertion.isEmpty ||
        utf8.encode(assertion).length > _maxAssertionBytes) {
      throw ArgumentError(
        'The identity assertion must be between 1 and 16 KiB.',
      );
    }
    if (federationRuleId.isEmpty ||
        organizationId.isEmpty ||
        serviceAccountId.isEmpty) {
      throw ArgumentError(
        'The federation rule, organization, and service account are required.',
      );
    }
    final abort = Completer<void>();
    StreamIterator<List<int>>? responseBody;
    final request =
        http.AbortableRequest('POST', _url, abortTrigger: abort.future)
          ..followRedirects = false
          ..headers.addAll({
            'content-type': 'application/json',
            'anthropic-beta': '$oauthBetaHeader,$_federationBeta',
          })
          ..body = jsonEncode({
            'grant_type': _jwtBearerGrant,
            'assertion': assertion,
            'federation_rule_id': federationRuleId,
            'organization_id': organizationId,
            'service_account_id': serviceAccountId,
            'workspace_id': ?workspaceId,
          });
    final result = Completer<WorkloadIdentityAccessToken>();
    final watch = Stopwatch()..start();

    void stop(Object error) {
      if (result.isCompleted) return;
      result.completeError(error);
      abort.complete();
      responseBody?.cancel().ignore();
    }

    final closed = ownerClosed?.asStream().listen(
      (_) => stop(StateError('Client has been closed')),
    );
    final timer = Timer(
      _timeout,
      () => stop(
        TimeoutException(
          message: 'Workload identity token exchange timed out',
          timeout: _timeout,
          elapsed: watch.elapsed,
        ),
      ),
    );

    Future<void> run() async {
      try {
        final token = await _exchange(
          request,
          assertion,
          abort,
          watch,
          (iterator) => responseBody = iterator,
        );
        if (!result.isCompleted) result.complete(token);
      } catch (error, stackTrace) {
        if (!result.isCompleted) result.completeError(error, stackTrace);
      }
    }

    unawaited(run());
    return result.future.whenComplete(() {
      timer.cancel();
      watch.stop();
      responseBody = null;
      unawaited(closed?.cancel());
    });
  }

  Future<WorkloadIdentityAccessToken> _exchange(
    http.AbortableRequest request,
    String assertion,
    Completer<void> abort,
    Stopwatch watch,
    void Function(StreamIterator<List<int>>) onResponseBody,
  ) async {
    final http.StreamedResponse response;
    try {
      response = await _client.send(request);
    } on http.ClientException {
      // A transport implementation may include a request dump in its error.
      throw http.ClientException(
        'Workload identity token endpoint unreachable',
      );
    }

    ResponseMetadata metadata([String? bodyRequestId]) =>
        createSafeResponseMetadata(
          statusCode: response.statusCode,
          headers: {
            for (final entry in response.headers.entries)
              if (!entry.value.contains(assertion)) entry.key: entry.value,
          },
          latency: watch.elapsed,
          bodyRequestId: bodyRequestId?.contains(assertion) ?? false
              ? null
              : bodyRequestId,
        );

    if (abort.isCompleted ||
        (response.statusCode >= 300 && response.statusCode < 400)) {
      await response.stream.listen(null).cancel();
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Unexpected workload identity token response',
        responseMetadata: metadata(),
      );
    }

    final iterator = StreamIterator(response.stream);
    onResponseBody(iterator);
    final bytes = BytesBuilder(copy: false);
    try {
      while (!abort.isCompleted && await iterator.moveNext()) {
        final chunk = iterator.current;
        if (bytes.length + chunk.length > _maxResponseBytes) {
          throw ApiException(
            statusCode: response.statusCode,
            message: 'Workload identity token response exceeds 1 MiB',
            responseMetadata: metadata(),
          );
        }
        bytes.add(chunk);
      }
    } on http.ClientException {
      throw http.ClientException(
        'Workload identity token response interrupted',
      );
    } finally {
      iterator.cancel().ignore();
    }
    final body = bytes.takeBytes();
    final status = response.statusCode;
    if (status < 200 || status >= 300) {
      final error = parseApiErrorBody(
        decodeStreamingApiErrorBody(body, response.headers),
      );
      final responseMetadata = metadata(error.requestId);
      const message = 'Workload identity token exchange failed';
      if (status == 401) {
        throw AuthenticationException(
          message: message,
          responseMetadata: responseMetadata,
        );
      }
      if (status == 429) {
        throw RateLimitException(
          statusCode: status,
          message: message,
          responseMetadata: responseMetadata,
          retryAfter: retryAfterTime(responseMetadata.headers),
        );
      }
      throw ApiException(
        statusCode: status,
        message: message,
        responseMetadata: responseMetadata,
      );
    }

    try {
      final json = jsonDecode(utf8.decode(body));
      if (json
          case {
            'access_token': final String token,
            'expires_in': final int expires,
          }
          when token.isNotEmpty &&
              !token.contains(RegExp(r'\s')) &&
              expires > 0 &&
              expires <= 86400) {
        final tokenType = (json as Map<String, dynamic>)['token_type'];
        final scope = json['scope'];
        if ((tokenType == null ||
                tokenType is String && tokenType.toLowerCase() == 'bearer') &&
            (scope == null || scope is String)) {
          return WorkloadIdentityAccessToken._(
            accessToken: token,
            expiresIn: Duration(seconds: expires),
            scope: scope as String?,
          );
        }
      }
    } on FormatException {
      // Dart's decoding exception can embed the token response verbatim.
    }
    throw const FormatException('Invalid workload identity token response');
  }

  static Uri _tokenUrl(String baseUrl) {
    final base = Uri.tryParse(baseUrl);
    final loopback =
        base?.host == 'localhost' ||
        base?.host == '127.0.0.1' ||
        base?.host == '::1';
    if (base == null ||
        base.host.isEmpty ||
        base.userInfo.isNotEmpty ||
        base.hasQuery ||
        base.hasFragment ||
        !(base.scheme == 'https' || base.scheme == 'http' && loopback)) {
      throw ArgumentError('Use an HTTPS or loopback token endpoint base URL.');
    }
    final prefix = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    return base.replace(path: '$prefix/v1/oauth/token');
  }
}

/// Caches one workspace's federated token for the owning API client.
final class WorkloadIdentityAuthProvider implements AuthProvider {
  /// Creates the provider for one rule and target workspace.
  WorkloadIdentityAuthProvider({
    required WorkloadIdentityTokenExchange exchange,
    required this._identityTokenProvider,
    required String federationRuleId,
    required String organizationId,
    required String serviceAccountId,
    String? workspaceId,
    DateTime Function()? now,
  }) : _exchange = ((assertion, ownerClosed) => exchange._exchangeJwt(
         assertion: assertion,
         federationRuleId: federationRuleId,
         organizationId: organizationId,
         serviceAccountId: serviceAccountId,
         workspaceId: workspaceId,
         ownerClosed: ownerClosed,
       )),
       _now = now ?? DateTime.now;

  final FutureOr<String> Function() _identityTokenProvider;
  final Future<WorkloadIdentityAccessToken> Function(String, Future<void>)
  _exchange;
  final DateTime Function() _now;
  final _closed = Completer<void>();
  ({BearerTokenCredentials credentials, DateTime expiresAt})? _cached;
  Completer<BearerTokenCredentials>? _pending;
  DateTime? _retryAdvisoryAt;

  @override
  Future<BearerTokenCredentials> getCredentials() async {
    _ensureOpen();
    final cached = _cached;
    final now = _now();
    if (cached == null ||
        cached.expiresAt.difference(now) <= const Duration(seconds: 30)) {
      return _refresh();
    }
    if (cached.expiresAt.difference(now) <= const Duration(seconds: 120) &&
        _pending == null &&
        (_retryAdvisoryAt == null || !now.isBefore(_retryAdvisoryAt!))) {
      unawaited(
        _refresh().then<void>(
          (_) {},
          onError: (Object _, StackTrace _) {
            if (!_closed.isCompleted) {
              _retryAdvisoryAt = _now().add(const Duration(seconds: 5));
            }
          },
        ),
      );
    }
    return cached.credentials;
  }

  /// Stops credential acquisition and releases the owner's cached token.
  void close() {
    if (_closed.isCompleted) return;
    _closed.complete();
    _cached = null;
    final pending = _pending;
    if (pending != null && !pending.isCompleted) {
      pending.completeError(StateError('Client has been closed'));
    }
  }

  void _ensureOpen() {
    if (_closed.isCompleted) throw StateError('Client has been closed');
  }

  Future<BearerTokenCredentials> _refresh() {
    final current = _pending;
    if (current != null) return current.future;

    final pending = _pending = Completer<BearerTokenCredentials>();
    unawaited(
      Future<void>.microtask(() async {
        try {
          _ensureOpen();
          final assertion = await _identityTokenProvider();
          _ensureOpen();
          final token = await _exchange(assertion, _closed.future);
          _ensureOpen();
          final credentials = BearerTokenCredentials(
            token.accessToken,
            workspaceScoped: true,
          );
          _cached = (
            credentials: credentials,
            expiresAt: _now().add(token.expiresIn),
          );
          _retryAdvisoryAt = null;
          pending.complete(credentials);
        } catch (error, stackTrace) {
          if (!pending.isCompleted) pending.completeError(error, stackTrace);
        } finally {
          _pending = null;
        }
      }),
    );
    return pending.future;
  }
}
