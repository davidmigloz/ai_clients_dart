import 'dart:convert';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import '../fixtures/agent_session_wire_fixtures.dart';

void main() {
  test('AgentContentResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionContent.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionContent.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test(
    'AgentOutputItemResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionOutputItem.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionOutputItem.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('AgentToolConfigParam: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionTool.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionTool.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('AgentToolResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionToolResource.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionToolResource.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test(
    'BrowserAuthenticationHistoryRequestKindResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value =
          AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
            raw,
          );
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () =>
            AgentSessionBrowserAuthenticationHistoryRequestKindResource.fromJson(
              const {'type': 'future', 'invalid': double.nan},
            ),
        throwsFormatException,
      );
    },
  );
  test(
    'BrowserOriginAccessDecisionParam: every source enum and future string',
    () {
      for (final value in ['approve', 'deny', 'cancel']) {
        final model = AgentSessionBrowserOriginAccessDecision.fromJson(value);
        expect(model.isKnown, isTrue);
        expect(model.toJson(), value);
        expect(model.copyWith(), model);
        expect(model.copyWith().hashCode, model.hashCode);
      }
      final future = AgentSessionBrowserOriginAccessDecision.fromJson(
        'PRIVATE-future',
      );
      expect(future.isKnown, isFalse);
      expect(future.toJson(), 'PRIVATE-future');
      expect(future.toString(), isNot(contains('PRIVATE')));
    },
  );
  test(
    'ComputerUseApprovalRequestKindResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionComputerUseApprovalRequestKind.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionComputerUseApprovalRequestKind.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'ComputerUseApprovalResponseKindResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'browser_authentication',
        'action': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionBrowserAuthenticationResponseResource.fromJson(
        raw,
      );
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionBrowserAuthenticationResponseResource.fromJson(const {
          'type': 'browser_authentication',
          'action': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'ComputerUseApprovalResponseParam: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionComputerUseApprovalResponse.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionComputerUseApprovalResponse.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'ComputerUseApprovalResponseParamBrowserAuthentication: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'browser_authentication',
        'action': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionBrowserAuthenticationResponse.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionBrowserAuthenticationResponse.fromJson(const {
          'type': 'browser_authentication',
          'action': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('ContainerSizeParam: every source enum and future string', () {
    for (final value in ['small', 'medium', 'large']) {
      final model = AgentSessionContainerSizeConfig.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionContainerSizeConfig.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('ContainerSizeResource: every source enum and future string', () {
    for (final value in ['small', 'medium', 'large']) {
      final model = AgentSessionContainerSizeResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionContainerSizeResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('EnvironmentParam: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionEnvironment.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionEnvironment.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('EnvironmentResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionEnvironmentResource.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionEnvironmentResource.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('FunctionCallStatusResource: every source enum and future string', () {
    for (final value in ['in_progress', 'completed', 'failed', 'incomplete']) {
      final model = AgentSessionFunctionCallStatusResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionFunctionCallStatusResource.fromJson(
      'PRIVATE-future',
    );
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test(
    'HostedEnvironmentFileParam: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionHostedEnvironmentFileConfig.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionHostedEnvironmentFileConfig.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test(
    'HostedEnvironmentFileResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionHostedEnvironmentFileResource.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionHostedEnvironmentFileResource.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('HostedPluginParam: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionHostedPluginConfig.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionHostedPluginConfig.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('HostedPluginResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionHostedPluginResource.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionHostedPluginResource.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('HostedSkillParam: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionHostedSkillConfig.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionHostedSkillConfig.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('HostedSkillResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionHostedSkillResource.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionHostedSkillResource.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test(
    'InlineCapabilitySourceParam: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionInlineCapabilitySourceConfig.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionInlineCapabilitySourceConfig.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('InputContentParam: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionInputContent.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionInputContent.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('InputContentResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionInputContentResource.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionInputContentResource.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test(
    'McpTransportConfigParam: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionMcpTransport.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionMcpTransport.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('McpTransportResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionMcpTransportResource.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionMcpTransportResource.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('MessageContentResource: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionMessageContent.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionMessageContent.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('MessagePhaseResource: every source enum and future string', () {
    for (final value in ['commentary', 'final_answer']) {
      final model = AgentSessionMessagePhaseResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionMessagePhaseResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('NetworkAccessParam: every source enum and future string', () {
    for (final value in ['enabled', 'disabled', 'restricted']) {
      final model = AgentSessionNetworkAccessConfig.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionNetworkAccessConfig.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('NetworkAccessResource: every source enum and future string', () {
    for (final value in ['enabled', 'disabled', 'restricted']) {
      final model = AgentSessionNetworkAccessResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionNetworkAccessResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('OutputItemStatusResource: every source enum and future string', () {
    for (final value in ['in_progress', 'completed', 'incomplete']) {
      final model = AgentSessionOutputItemStatusResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionOutputItemStatusResource.fromJson(
      'PRIVATE-future',
    );
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test(
    'SessionEnvironmentStatusResource: every source enum and future string',
    () {
      for (final value in [
        'pending',
        'ready',
        'connected',
        'disconnected',
        'suspended',
        'expired',
        'failed',
      ]) {
        final model = AgentSessionEnvironmentStatusResource.fromJson(value);
        expect(model.isKnown, isTrue);
        expect(model.toJson(), value);
        expect(model.copyWith(), model);
        expect(model.copyWith().hashCode, model.hashCode);
      }
      final future = AgentSessionEnvironmentStatusResource.fromJson(
        'PRIVATE-future',
      );
      expect(future.isKnown, isFalse);
      expect(future.toJson(), 'PRIVATE-future');
      expect(future.toString(), isNot(contains('PRIVATE')));
    },
  );
  test('SessionEvent: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionEvent.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionEvent.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('SessionInputParam: future branch finite detached and private', () {
    final raw = <String, dynamic>{
      'type': 'PRIVATE-future',
      'nested': <String, dynamic>{
        'list': <Object?>[1, 'PRIVATE'],
      },
    };
    final value = AgentSessionInput.fromJson(raw);
    final before = jsonDecode(jsonEncode(value.toJson()));
    (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
    expect(value.toJson(), before);
    expect(value.toString(), isNot(contains('PRIVATE')));
    expect(
      () => AgentSessionInput.fromJson(const {
        'type': 'future',
        'invalid': double.nan,
      }),
      throwsFormatException,
    );
  });
  test('SessionMessageRoleResource: every source enum and future string', () {
    for (final value in ['user', 'assistant']) {
      final model = AgentSessionMessageRoleResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionMessageRoleResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test(
    'SessionRequiredActionResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionRequiredAction.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionRequiredAction.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('SessionStatusResource: every source enum and future string', () {
    for (final value in ['idle', 'in_progress', 'requires_action', 'failed']) {
      final model = AgentSessionStatusResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionStatusResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('SessionTurnErrorCodeResource: every source enum and future string', () {
    for (final value in [
      'context_length_exceeded',
      'session_budget_exceeded',
      'usage_limit_exceeded',
      'project_spend_limit_exceeded',
      'organization_spend_limit_exceeded',
      'organization_usage_limit_exceeded',
      'billing_not_active',
      'credit_balance_exhausted',
      'rate_limit_exceeded',
      'flex_unavailable',
      'server_overloaded',
      'cyber_policy',
      'misalignment_policy_violation',
      'connection_failed',
      'server_error',
      'authentication_error',
      'invalid_request',
      'resource_not_found',
      'sandbox_error',
      'executor_version_incompatible',
      'active_turn_not_steerable',
      'request_timeout',
      'internal_error',
    ]) {
      final model = AgentSessionTurnErrorCodeResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionTurnErrorCodeResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test(
    'SessionTurnItemResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionTurnItem.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionTurnItem.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('SubagentObjectResource: every source enum and future string', () {
    for (final value in ['agent.session.subagent']) {
      final model = AgentSessionSubagentObjectResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionSubagentObjectResource.fromJson(
      'PRIVATE-future',
    );
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('SubagentStatusResource: every source enum and future string', () {
    for (final value in ['active', 'closed']) {
      final model = AgentSessionSubagentStatusResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionSubagentStatusResource.fromJson(
      'PRIVATE-future',
    );
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('TurnObjectResource: every source enum and future string', () {
    for (final value in ['agent.session.turn']) {
      final model = AgentSessionTurnObjectResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionTurnObjectResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test('TurnStatusResource: every source enum and future string', () {
    for (final value in [
      'queued',
      'in_progress',
      'waiting',
      'completed',
      'failed',
      'cancelled',
    ]) {
      final model = AgentSessionTurnStatusResource.fromJson(value);
      expect(model.isKnown, isTrue);
      expect(model.toJson(), value);
      expect(model.copyWith(), model);
      expect(model.copyWith().hashCode, model.hashCode);
    }
    final future = AgentSessionTurnStatusResource.fromJson('PRIVATE-future');
    expect(future.isKnown, isFalse);
    expect(future.toJson(), 'PRIVATE-future');
    expect(future.toString(), isNot(contains('PRIVATE')));
  });
  test(
    'WebSearchActionResource: future branch finite detached and private',
    () {
      final raw = <String, dynamic>{
        'type': 'PRIVATE-future',
        'nested': <String, dynamic>{
          'list': <Object?>[1, 'PRIVATE'],
        },
      };
      final value = AgentSessionWebSearchActionResource.fromJson(raw);
      final before = jsonDecode(jsonEncode(value.toJson()));
      (raw['nested'] as Map<String, dynamic>)['list'] = ['mutated'];
      expect(value.toJson(), before);
      expect(value.toString(), isNot(contains('PRIVATE')));
      expect(
        () => AgentSessionWebSearchActionResource.fromJson(const {
          'type': 'future',
          'invalid': double.nan,
        }),
        throwsFormatException,
      );
    },
  );
  test('Every object snapshot owns nested caller JSON and returned JSON', () {
    for (final fixture in agentSessionWireFixtures) {
      final raw = jsonDecode(jsonEncode(fixture.full));
      final value = fixture.parse(raw);
      final expected = jsonDecode(jsonEncode(value.toJson()));
      void mutate(Object? node) {
        if (node is Map) {
          node.values.toList().forEach(mutate);
          node.clear();
        }
        if (node is List) {
          node.toList().forEach(mutate);
          node.clear();
        }
      }

      mutate(raw);
      expect(value.toJson(), expected, reason: fixture.schema);
      final returned = value.toJson();
      try {
        mutate(returned);
      } on UnsupportedError {
        /* Immutable output is also owned. */
      }
      expect(value.toJson(), expected, reason: fixture.schema);
    }
  });
  test(
    'Scalar/list values parse through actual parent request and received output',
    () {
      for (final input in <Object?>[
        'café🚀',
        <Object?>[
          {
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'hello'},
            ],
          },
        ],
      ]) {
        final request = CreateAgentSessionRequest.fromJson({
          'agent_id': 'saved',
          'environment': const {'type': 'none'},
          'input': input,
        });
        expect(request.toJson()['input'], input);
        expect(request.copyWith().toJson()['input'], input);
      }
      for (final output in <Object?>[
        'answer',
        <Object?>[
          {'type': 'input_text', 'text': 'answer'},
        ],
      ]) {
        final request = AgentSessionInput.toolResult(
          callId: 'call',
          success: true,
          turnId: 'turn',
          output: AgentSessionFunctionOutput.fromJson(output),
        );
        expect(request.toJson()['output'], output);
      }
      expect(
        AgentSessionFunctionOutputResource.fromJson('answer').toJson(),
        'answer',
      );
    },
  );
  test(
    'Unknown request inputs are private fallbacks but cannot be submitted',
    () {
      final value = AgentSessionInput.fromJson(const {
        'type': 'future',
        'private': 'PRIVATE',
      });
      expect(value.toJson()['private'], 'PRIVATE');
      expect(
        () => CreateAgentSessionEventsRequest(events: [value]),
        throwsFormatException,
      );
      expect(
        () => AgentSessionInput.fromJson(const {
          'type': 'agent.session.input.cancel',
          'turn_id': 'PRIVATE',
        }),
        throwsFormatException,
      );
    },
  );
  test('Finite JSON rejects cycles and non-finite numbers', () {
    final cyclic = <String, dynamic>{};
    cyclic['self'] = cyclic;
    for (final invalid in <Object?>[cyclic, double.nan, double.infinity]) {
      expect(
        () => AgentSessionEvent.fromJson({'type': 'future', 'data': invalid}),
        throwsFormatException,
      );
    }
  });
  test('Runtime compact UTF-8 budget and schema share four MiB', () {
    const maximum = 4194304;
    CreateAgentSessionRequest create(int encodedBytes) =>
        CreateAgentSessionRequest(
          agentId: 'saved',
          environment: AgentSessionEnvironment.none(),
          input: AgentSessionInitialInput.text('🚀' * (encodedBytes ~/ 4)),
        );
    expect(
      create(maximum - 4).toJson()['input'],
      hasLength((maximum - 4) ~/ 2),
    );
    expect(() => create(maximum), throwsFormatException);
    final schema = <String, dynamic>{
      'type': 'object',
      'description': 'a' * (maximum - 100),
    };
    expect(
      () => CreateAgentSessionRequest.fromJson({
        'agent_id': 'saved',
        'environment': const {'type': 'none'},
        'input': 'a' * 200,
        'agent': {
          'text': {
            'format': {
              'type': 'json_schema',
              'name': 'result',
              'schema': schema,
            },
          },
        },
      }),
      throwsFormatException,
    );
    expect(
      () => CreateAgentSessionEventsRequest(
        events: [
          AgentSessionInput.message(
            input: [
              AgentSessionInputMessage(
                content: [
                  AgentSessionInputContent.inputText(text: 'a' * maximum),
                ],
              ),
            ],
          ),
        ],
      ),
      throwsFormatException,
    );
  });
  test('Authentication exact UTF-8 budget, six fields and value limit', () {
    final overhead = utf8
        .encode(
          jsonEncode({
            'fields': [
              {'field_id': '', 'value': ''},
            ],
          }),
        )
        .length;
    AgentSessionBrowserAuthenticationSubmit auth(int length) =>
        AgentSessionBrowserAuthenticationSubmit(
          fields: [
            AgentSessionBrowserAuthenticationFieldValue(
              fieldId: 'a' * length,
              value: '',
            ),
          ],
        );
    expect(
      utf8
          .encode(
            jsonEncode(
              auth(122880 - overhead).toJson()
                ..remove('type')
                ..remove('action'),
            ),
          )
          .length,
      122880,
    );
    expect(() => auth(122881 - overhead), throwsFormatException);
    expect(
      () => AgentSessionBrowserAuthenticationSubmit(
        fields: List.generate(
          7,
          (i) => AgentSessionBrowserAuthenticationFieldValue(
            fieldId: '$i',
            value: '',
          ),
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => AgentSessionBrowserAuthenticationFieldValue(
        fieldId: 'field',
        value: 'a' * 16385,
      ),
      throwsFormatException,
    );
    expect(
      () => AgentSessionBrowserAuthenticationSubmit(
        fields: [
          AgentSessionBrowserAuthenticationFieldValue(
            fieldId: 'f1',
            value: '🚀' * 16000,
          ),
          AgentSessionBrowserAuthenticationFieldValue(
            fieldId: 'f2',
            value: '🚀' * 16000,
          ),
        ],
      ),
      throwsFormatException,
    );
  });
  test('Known optional non-null fields reject explicit null', () {
    for (final fixture in agentSessionWireFixtures.where(
      (f) => f.full is Map,
    )) {
      final full = fixture.full! as Map<String, dynamic>;
      for (final key in full.keys.where(
        (key) => !fixture.nullableKeys.contains(key),
      )) {
        if (key == 'arguments' ||
            (fixture.schema == 'McpCallItemResource' &&
                const {'output', 'error'}.contains(key))) {
          continue;
        }
        expect(
          () => fixture.parse({...full, key: null}),
          throwsFormatException,
          reason: '${fixture.schema}.$key',
        );
      }
    }
  });
}
