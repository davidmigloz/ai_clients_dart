import 'dart:async' show FutureOr;

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../auth/workload_identity.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../resources/agents_resource.dart';
import '../resources/compliance_resource.dart';
import '../resources/deployment_runs_resource.dart';
import '../resources/deployments_resource.dart';
import '../resources/dreams_resource.dart';
import '../resources/environments_resource.dart';
import '../resources/files_resource.dart';
import '../resources/memory_stores_resource.dart';
import '../resources/message_batches_resource.dart';
import '../resources/messages_resource.dart';
import '../resources/models_resource.dart';
import '../resources/organization/organization_resource.dart';
import '../resources/sessions_resource.dart';
import '../resources/skills_resource.dart';
import '../resources/tunnels_resource.dart';
import '../resources/user_profiles_resource.dart';
import '../resources/vaults_resource.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Dart client for the Anthropic API.
///
/// Provides type-safe access to Claude models via the Anthropic API.
///
/// ## Basic Usage
///
/// ```dart
/// final client = AnthropicClient(
///   config: AnthropicConfig(
///     authProvider: ApiKeyProvider('your-api-key'),
///   ),
/// );
///
/// // Use client.messages, client.models, etc.
///
/// client.close();
/// ```
///
/// ## Environment Configuration
///
/// ```dart
/// final client = AnthropicClient.fromEnvironment();
/// // Reads ANTHROPIC_API_KEY first, then ANTHROPIC_AUTH_TOKEN.
/// ```
class AnthropicClient {
  /// Client configuration.
  final AnthropicConfig config;

  /// HTTP client for requests.
  final http.Client _httpClient;

  /// Whether this client owns the HTTP client (and should close it).
  final bool _ownsHttpClient;

  final void Function()? _closeAuth;

  /// Whether the client has been closed.
  bool _closed = false;

  /// Interceptor chain for request processing.
  late final InterceptorChain _interceptorChain;

  /// Request builder for URL and header construction.
  late final RequestBuilder _requestBuilder;

  /// Resource for the Messages API.
  late final MessagesResource messages;

  /// Resource for the Claude Compliance API.
  late final ComplianceResource compliance;

  /// Organization Admin API. Requires a credential with administrative scope.
  late final OrganizationResource organization;

  /// Resource for the Models API.
  late final ModelsResource models;

  /// Resource for the Message Batches API.
  ///
  /// **Deprecated:** Use [messages.batches] instead for consistency with the
  /// API structure.
  @Deprecated('Use client.messages.batches instead')
  MessageBatchesResource get batches => messages.batches;

  /// Resource for the Files API (Beta).
  late final FilesResource files;

  /// Resource for the Skills API (Beta).
  late final SkillsResource skills;

  /// Resource for the Agents API (Beta).
  late final AgentsResource agents;

  /// Resource for the Sessions API (Beta).
  late final SessionsResource sessions;

  /// Resource for the Memory Stores API (Beta).
  late final MemoryStoresResource memoryStores;

  /// Resource for managing Claude Managed Agents environments.
  late final EnvironmentsResource environments;

  /// Workspace MCP tunnels and CA certificates (research preview).
  late final TunnelsResource tunnels;

  /// Legacy User Profiles beta and the generally available resource.
  ///
  /// Use `userProfiles.current` for the generally available API.
  late final UserProfilesResource userProfiles;

  /// Resource for the Vaults API (Beta).
  late final VaultsResource vaults;

  /// Resource for the Dreams API (Beta, research preview).
  late final DreamsResource dreams;

  /// Resource for the Deployments API (Beta).
  late final DeploymentsResource deployments;

  /// Resource for the Deployment Runs API (Beta).
  late final DeploymentRunsResource deploymentRuns;

  /// Creates an [AnthropicClient].
  ///
  /// Optionally accepts a custom [httpClient] for testing or advanced use
  /// cases. If not provided, a new client is created and will be closed when
  /// [close] is called. If provided, you are responsible for closing it.
  AnthropicClient({AnthropicConfig? config, http.Client? httpClient})
    : this._(
        config ?? const AnthropicConfig(),
        httpClient ?? http.Client(),
        ownsHttpClient: httpClient == null,
      );

  AnthropicClient._(
    this.config,
    this._httpClient, {
    required this._ownsHttpClient,
    this._closeAuth,
  }) {
    _initialize();
  }

  /// Creates an [AnthropicClient] from environment variables.
  ///
  /// Reads `ANTHROPIC_API_KEY` or, if it is absent or empty,
  /// `ANTHROPIC_AUTH_TOKEN` for an OAuth access token.
  /// Optionally reads `ANTHROPIC_BASE_URL` for custom API endpoints.
  ///
  /// Throws [StateError] if both credential variables are absent or empty.
  /// Throws [UnsupportedError] on web platforms.
  factory AnthropicClient.fromEnvironment({http.Client? httpClient}) {
    return AnthropicClient(
      config: AnthropicConfig.fromEnvironment(),
      httpClient: httpClient,
    );
  }

  /// Creates an [AnthropicClient] with the given API key.
  ///
  /// This is a convenience constructor for simple use cases.
  factory AnthropicClient.withApiKey(
    String apiKey, {
    String? baseUrl,
    Map<String, String>? defaultHeaders,
    http.Client? httpClient,
  }) {
    return AnthropicClient(
      config: AnthropicConfig(
        authProvider: ApiKeyProvider(apiKey),
        baseUrl: baseUrl ?? 'https://api.anthropic.com',
        defaultHeaders: defaultHeaders ?? const {},
      ),
      httpClient: httpClient,
    );
  }

  /// Creates a client with an existing OAuth bearer token.
  ///
  /// The token's scope determines the API operations it can authorize.
  factory AnthropicClient.withAuthToken(
    String authToken, {
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) => AnthropicClient(
    config: config.copyWith(authProvider: BearerTokenProvider(authToken)),
    httpClient: httpClient,
  );

  /// Authenticates with a JWT obtained from an external identity provider.
  ///
  /// Exchanges and refreshes the token on the same API endpoint as requests.
  /// The callback is invoked for every exchange so it can supply a fresh JWT.
  /// Set the exchange [workspaceId] instead of a request workspace override.
  factory AnthropicClient.withWorkloadIdentity({
    required FutureOr<String> Function() identityTokenProvider,
    required String federationRuleId,
    required String organizationId,
    required String serviceAccountId,
    String? workspaceId,
    AnthropicConfig config = const AnthropicConfig(),
    http.Client? httpClient,
  }) {
    final transport = httpClient ?? http.Client();
    try {
      final auth = WorkloadIdentityAuthProvider(
        exchange: WorkloadIdentityTokenExchange(
          httpClient: transport,
          baseUrl: config.baseUrl,
        ),
        identityTokenProvider: identityTokenProvider,
        federationRuleId: federationRuleId,
        organizationId: organizationId,
        serviceAccountId: serviceAccountId,
        workspaceId: workspaceId,
      );
      return AnthropicClient._(
        config.copyWith(authProvider: auth),
        transport,
        ownsHttpClient: httpClient == null,
        closeAuth: auth.close,
      );
    } catch (_) {
      if (httpClient == null) transport.close();
      rethrow;
    }
  }

  /// Initializes the client with interceptor chain and resources.
  void _initialize() {
    // Build request builder
    _requestBuilder = RequestBuilder(config: config);

    // Build interceptor list
    // Order: Auth → Logging → Error → Transport (wrapped by Retry)
    final interceptors = <Interceptor>[
      if (config.authProvider != null)
        AuthInterceptor(authProvider: config.authProvider!),
      LoggingInterceptor(
        logLevel: config.logLevel,
        redactionList: config.redactionList,
      ),
      const ErrorInterceptor(),
    ];

    // Build retry wrapper if retries are enabled
    final retryWrapper = config.retryPolicy.maxRetries > 0
        ? RetryWrapper(config: config)
        : null;

    // Build interceptor chain
    _interceptorChain = InterceptorChain(
      interceptors: interceptors,
      httpClient: _httpClient,
      retryWrapper: retryWrapper,
      timeout: config.timeout,
      ensureNotClosed: _ensureNotClosed,
    );

    organization = OrganizationResource(
      requestBuilder: _requestBuilder,
      interceptorChain: _interceptorChain,
      ensureNotClosed: _ensureNotClosed,
    );

    // Initialize resources
    messages = MessagesResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    compliance = ComplianceResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    models = ModelsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    // Note: batches is now accessible via messages.batches (nested resource)
    files = FilesResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    skills = SkillsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    agents = AgentsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    sessions = SessionsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    environments = EnvironmentsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    tunnels = TunnelsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    memoryStores = MemoryStoresResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    vaults = VaultsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    dreams = DreamsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    deployments = DeploymentsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    deploymentRuns = DeploymentRunsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    userProfiles = UserProfilesResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  /// Closes the client and releases resources.
  ///
  /// After calling this method, any subsequent requests will throw
  /// [StateError]. This method is idempotent and can be called multiple
  /// times safely.
  ///
  /// If a custom [http.Client] was provided to the constructor,
  /// it will not be closed by this method.
  void close() {
    if (_closed) return;
    _closed = true;
    _closeAuth?.call();
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  /// Throws a [StateError] if the client has been closed.
  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('Client has been closed');
    }
  }

  /// Gets the interceptor chain for advanced usage.
  ///
  /// This is primarily for internal use by resources.
  InterceptorChain get interceptorChain => _interceptorChain;

  /// Gets the request builder for advanced usage.
  ///
  /// This is primarily for internal use by resources.
  RequestBuilder get requestBuilder => _requestBuilder;

  /// Gets the HTTP client for streaming requests.
  ///
  /// This is primarily for internal use by streaming resources.
  http.Client get httpClient => _httpClient;
}
