part of 'agent_environment_models.dart';

/// Refuse forbidden readback values, including nested future received objects.
/// Unknown safe metadata is retained; confidential inputs cannot become extras.
void _rejectEnvironmentReadback(Object? value, String context) {
  final safe = snapshotAgentJson({'value': value}, context)['value'];
  _walkEnvironmentReadback(safe, context);
}

void _walkEnvironmentReadback(Object? value, String context) {
  if (value is Map) {
    for (final entry in value.entries) {
      if ((entry.key == 'data' && value['type'] == 'inline') ||
          const {
            'env',
            'setup_commands',
            'command',
            'content_base64',
            'archive_base64',
            'secret_value',
            'source',
          }.contains(entry.key)) {
        throw FormatException(
          '$context: confidential request field in resource',
        );
      }
      _walkEnvironmentReadback(entry.value, context);
    }
  } else if (value is List) {
    for (final item in value) {
      _walkEnvironmentReadback(item, context);
    }
  }
}

Map<String, dynamic> _environmentReceivedExtras(
  Map<String, dynamic> value,
  List<String> known,
  String context,
) {
  // Snapshot first to reject cycles and nonfinite numbers before recursion.
  final snapshot = snapshotAgentJson(value, context);
  _rejectEnvironmentReadback(snapshot, context);
  return agentExtras(snapshot, known, context);
}
