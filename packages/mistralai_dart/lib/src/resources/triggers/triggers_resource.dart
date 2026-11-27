import '../../models/triggers/trigger.dart';
import '../base_resource.dart';
import '../platform_resource.dart';

/// Manages rules that start workflows, build apps, or launch agent sessions
/// on inbound provider events (beta).
class TriggersResource extends ResourceBase with PlatformResource {
  /// Creates a [TriggersResource].
  TriggersResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _path = '/v1/triggers';

  String _trigger(String id) => '$_path/${Uri.encodeComponent(id)}';

  /// Lists triggers, optionally by webhook or by handler and primitive.
  Future<List<Trigger>> list({
    TriggerHandler? handler,
    String? primitiveId,
    String? eventSourceId,
  }) => requestPlatform(
    'GET',
    _path,
    (json) => (json! as List)
        .cast<Map<String, dynamic>>()
        .map(Trigger.fromJson)
        .toList(),
    query: {
      'handler': ?handler?.value,
      'primitive_id': ?primitiveId,
      'event_source_id': ?eventSourceId,
    },
    redactErrorBody: true,
  );

  /// Creates a trigger attached to a registered webhook.
  Future<Trigger> create({required CreateTriggerRequest request}) =>
      requestPlatform(
        'POST',
        _path,
        (json) => Trigger.fromJson(json! as Map<String, dynamic>),
        body: request.toJson(),
        redactErrorBody: true,
      );

  /// Retrieves a trigger.
  Future<Trigger> get({required String triggerId}) => requestPlatform(
    'GET',
    _trigger(triggerId),
    (json) => Trigger.fromJson(json! as Map<String, dynamic>),
    redactErrorBody: true,
  );

  /// Deletes a trigger.
  Future<void> delete({required String triggerId}) =>
      requestPlatform('DELETE', _trigger(triggerId), (_) {});

  /// Lists recent events for a trigger. [limit] accepts 1–1,000.
  Future<TriggerEventList> listEvents({
    required String triggerId,
    int? limit,
  }) => requestPlatform(
    'GET',
    '${_trigger(triggerId)}/events',
    (json) => TriggerEventList.fromJson(json! as Map<String, dynamic>),
    query: {'limit': ?limit?.toString()},
  );
}
