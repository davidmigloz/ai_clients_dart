/// Complete wire response independent of production model serialization.
Map<String, dynamic> savedAgentWire({String id = 'agent_fixture'}) => {
  'id': id,
  'object': 'agent',
  'created_at': 100,
  'updated_at': 101,
  'name': null,
  'instructions': null,
  'metadata': <String, String>{},
  'model': 'requested-model',
  'reasoning': {'effort': null, 'summary': null},
  'text': {
    'format': {'type': 'text'},
    'verbosity': 'medium',
  },
  'service_tier': 'fast',
  'tools': <Object>[],
  'multi_agent': {'enabled': false, 'max_concurrent_subagents': null},
};

/// The canonical empty page retains both nullable cursor keys.
Map<String, dynamic> emptyAgentPageWire() => {
  'object': 'list',
  'data': <Object>[],
  'first_id': null,
  'last_id': null,
  'has_more': false,
};
